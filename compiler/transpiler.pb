; ============================================================================
; Title:       PureBasic OOP Transpiler / Code Generator (Full OOP Engine)
; Description: Transpiles OOP syntax (.pbo) to native PureBasic code (.pb)
;              Supports Single Inheritance, Dynamic VTable Polymorphism,
;              Method Overriding, Method Overloading (Surcharge de methodes),
;              Multiple Constructors (Init overloads), Default Parameters,
;              'Super::' / 'Super\' calls, 'New' instantiation,
;              inline / out-of-class method bodies, Syntax/Semantic Checking,
;              Source Line Mapping (.pb.map), Hierarchical Namespaces,
;              'Using' directives, Namespace Aliases, and Multi-File Includes.
; Author:      MicrodevWeb
; Version:     ALPHA 1.2 (Method Overloading & Multi-Constructors)
; ============================================================================

EnableExplicit

; ----------------------------------------------------------------------------
; Data Structures for OOP Meta-Model
; ----------------------------------------------------------------------------

Structure OOP_Field
  name.s          ; e.g. "nom.s"
  visibility.s    ; "Public", "Protected", "Private"
  srcLineNumber.i
  srcFile.s
EndStructure

Structure OOP_Method
  name.s              ; e.g. "Additionner"
  rawDecl.s           ; e.g. "Public Method Additionner(a.i, b.i)"
  params.s            ; e.g. "a.i, b.i = 10" (raw params with defaults)
  cleanParams.s       ; e.g. "a.i, b.i" (types only, defaults stripped)
  returnType.s        ; e.g. ".i", ".s", ""
  visibility.s        ; "Public", "Protected", "Private"
  isOverride.b
  isAbstract.b
  signature.s         ; e.g. "i_i", "s_s", "void"
  paramCount.i        ; Total parameters
  minParamCount.i     ; Minimum required parameters (excluding defaults)
  mangledMethodName.s ; Unique name in Interface & VTable e.g. "Additionner_i_i" or "Additionner"
  hasDefaults.b
  srcLineNumber.i
  srcFile.s
EndStructure

Structure OOP_VTableSlot
  methodName.s        ; mangled slot name (e.g. "Additionner_i_i" or "Additionner")
  baseMethodName.s    ; original method name (e.g. "Additionner")
  signature.s         ; e.g. "i_i"
  implementingClass.s ; fullName
  declaringClass.s    ; fullName
  params.s            ; raw params
  cleanParams.s       ; params without defaults
  returnType.s
  isAbstract.b
  paramCount.i
  minParamCount.i
  srcLineNumber.i
  srcFile.s
EndStructure

Structure OOP_InitConstructor
  params.s            ; raw parameters
  cleanParams.s       ; parameters without defaults
  signature.s         ; e.g. "i_i", "void"
  paramCount.i
  minParamCount.i
  mangledName.s       ; e.g. "New_ClassName_i_i" or "New_ClassName"
  initProcMangled.s   ; e.g. "ClassName_Init_i_i"
  srcLineNumber.i
  srcFile.s
EndStructure

Structure OOP_Class
  name.s                ; Short name e.g. "Renderer"
  namespace.s           ; e.g. "Game::Graphics"
  fullName.s            ; e.g. "Game::Graphics::Renderer"
  mangledName.s         ; e.g. "Game_Graphics_Renderer"
  parentName.s          ; Raw parent name from Extends
  fullParentName.s      ; Resolved full parent name
  mangledParentName.s   ; Mangled parent name
  isAbstract.b
  srcLineNumber.i
  srcFile.s
  List Fields.OOP_Field()
  List Methods.OOP_Method()
  List VTableSlots.OOP_VTableSlot()
  List InitConstructors.OOP_InitConstructor()
  hasInit.b
  hasFree.b
  freeClassMangled.s
EndStructure

Structure OOP_SourceLine
  content.s
  srcLineNumber.i
  srcFile.s
EndStructure

Structure OOP_MethodBody
  className.s           ; Resolved fullName
  mangledClassName.s    ; Mangled class name
  methodName.s          ; Base method name
  signature.s           ; Computed param signature
  mangledMethodName.s   ; e.g. "Additionner_i_i" or "Additionner"
  params.s
  cleanParams.s
  returnType.s
  srcLineNumber.i
  srcFile.s
  List BodyLines.OOP_SourceLine()
EndStructure

Structure OOP_GeneratedLine
  content.s
  srcLineNumber.i
  srcFile.s
EndStructure

; ----------------------------------------------------------------------------
; Global Transpiler State
; ----------------------------------------------------------------------------

Global NewList Classes.OOP_Class()
Global NewMap ClassMap.i()          ; Map FullName & MangledName to ListIndex
Global NewList MethodBodies.OOP_MethodBody()
Global NewList MainLines.OOP_SourceLine()
Global NewList TypeDeclarations.OOP_SourceLine()
Global NewList HeaderDeclarations.OOP_SourceLine()
Global NewList FileSourceLines.OOP_SourceLine()
Global NewList GeneratedLines.OOP_GeneratedLine()

Global NewList NamespaceStack.s()
Global NewList UsingList.s()
Global NewMap NamespaceAliases.s()  ; Alias -> Target Namespace
Global NewMap IncludedFilesMap.i()

; Set of method names that are overloaded across the project
Global NewMap OverloadedMethodNames.i()

Global LastErrorMessage.s = ""
Global LastErrorLine.i = 0
Global LastErrorFile.s = ""

Procedure SetOOPError(lineNum.i, message.s, file.s = "")
  LastErrorLine = lineNum
  LastErrorMessage = message
  If file <> ""
    LastErrorFile = file
  EndIf
  PrintN("[ERROR] Line " + Str(lineNum) + ": " + message)
EndProcedure

; ----------------------------------------------------------------------------
; Helper Functions & Parameter Signature Utilities
; ----------------------------------------------------------------------------

Procedure.b IsIdentifierChar(c.s)
  Protected a.i = Asc(c)
  If (a >= 65 And a <= 90) Or (a >= 97 And a <= 122) Or (a >= 48 And a <= 57) Or a = 95
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure.s ReplaceWord(text.s, findWord.s, replaceWith.s)
  Protected res.s = ""
  Protected lenT.i = Len(text)
  Protected lenW.i = Len(findWord)
  Protected i.i = 1
  
  While i <= lenT
    If Mid(text, i, lenW) = findWord
      Protected isStart.b = #False
      Protected isEnd.b = #False
      
      If i = 1
        isStart = #True
      Else
        Protected prevChar.s = Mid(text, i - 1, 1)
        If Not IsIdentifierChar(prevChar) And prevChar <> "*"
          isStart = #True
        EndIf
      EndIf
      
      If (i + lenW > lenT)
        isEnd = #True
      Else
        Protected nextChar.s = Mid(text, i + lenW, 1)
        If Not IsIdentifierChar(nextChar)
          isEnd = #True
        EndIf
      EndIf
      
      If isStart And isEnd
        res + replaceWith
        i + lenW
        Continue
      EndIf
    EndIf
    
    res + Mid(text, i, 1)
    i + 1
  Wend
  
  ProcedureReturn res
EndProcedure

Procedure.s StripComment(text.s)
  Protected inQuotes.b = #False
  Protected i.i, lenT.i = Len(text)
  For i = 1 To lenT
    Protected c.s = Mid(text, i, 1)
    If c = Chr(34)
      inQuotes = ~inQuotes & 1
    ElseIf c = ";" And Not inQuotes
      ProcedureReturn Trim(Left(text, i - 1))
    EndIf
  Next
  ProcedureReturn Trim(text)
EndProcedure

; Splits parameter string by comma taking quotes and parentheses into account
Procedure.i SplitParams(params.s, List outTokens.s())
  ClearList(outTokens())
  Protected p.s = Trim(params)
  If p = "" : ProcedureReturn 0 : EndIf
  
  Protected i.i, lenP.i = Len(p)
  Protected inQuotes.b = #False
  Protected parenDepth.i = 0
  Protected curToken.s = ""
  
  For i = 1 To lenP
    Protected c.s = Mid(p, i, 1)
    If c = Chr(34)
      inQuotes = ~inQuotes & 1
      curToken + c
    ElseIf c = "(" And Not inQuotes
      parenDepth + 1
      curToken + c
    ElseIf c = ")" And Not inQuotes
      If parenDepth > 0 : parenDepth - 1 : EndIf
      curToken + c
    ElseIf c = "," And Not inQuotes And parenDepth = 0
      AddElement(outTokens())
      outTokens() = Trim(curToken)
      curToken = ""
    Else
      curToken + c
    EndIf
  Next
  If Trim(curToken) <> ""
    AddElement(outTokens())
    outTokens() = Trim(curToken)
  EndIf
  ProcedureReturn ListSize(outTokens())
EndProcedure

; Extracts parameter type string e.g. "a.i" -> "i", "*buf" -> "p", "text.s = ''" -> "s"
Procedure.s ExtractParamType(paramDecl.s)
  Protected p.s = Trim(paramDecl)
  Protected pEq.i = FindString(p, "=")
  If pEq > 0
    p = Trim(Left(p, pEq - 1))
  EndIf
  If Left(p, 1) = "*"
    ProcedureReturn "p"
  EndIf
  Protected pDot.i = FindString(p, ".")
  If pDot > 0
    Protected t.s = LCase(Trim(Mid(p, pDot + 1)))
    ; Standard PB types
    If t = "i" Or t = "s" Or t = "d" Or t = "f" Or t = "q" Or t = "l" Or t = "b" Or t = "a" Or t = "u" Or t = "w" Or t = "c"
      ProcedureReturn t
    Else
      ; Custom structure / interface pointer
      ProcedureReturn "p"
    EndIf
  EndIf
  ; Default integer
  ProcedureReturn "i"
EndProcedure

; Calculates the signature string for a parameter declaration list e.g. "a.i, b.i" -> "i_i"
Procedure.s GetParamSignature(params.s)
  Protected NewList tokens.s()
  Protected count.i = SplitParams(params, tokens())
  If count = 0
    ProcedureReturn "void"
  EndIf
  Protected sig.s = ""
  ForEach tokens()
    Protected pType.s = ExtractParamType(tokens())
    If sig = ""
      sig = pType
    Else
      sig + "_" + pType
    EndIf
  Next
  ProcedureReturn sig
EndProcedure

; Removes "= defaultValue" from parameter declarations
Procedure.s GetCleanParams(params.s)
  Protected NewList tokens.s()
  Protected count.i = SplitParams(params, tokens())
  If count = 0 : ProcedureReturn "" : EndIf
  Protected res.s = ""
  ForEach tokens()
    Protected tok.s = tokens()
    Protected pEq.i = FindString(tok, "=")
    If pEq > 0
      tok = Trim(Left(tok, pEq - 1))
    EndIf
    If res = ""
      res = tok
    Else
      res + ", " + tok
    EndIf
  Next
  ProcedureReturn res
EndProcedure

; Counts minimum parameters (parameters without default values)
Procedure.i CountMinParameters(params.s)
  Protected NewList tokens.s()
  Protected count.i = SplitParams(params, tokens())
  If count = 0 : ProcedureReturn 0 : EndIf
  Protected minCount.i = 0
  ForEach tokens()
    If FindString(tokens(), "=") = 0
      minCount + 1
    EndIf
  Next
  ProcedureReturn minCount
EndProcedure

; Infers argument type from an expression passed to a method call
Procedure.s InferArgType(argExpr.s)
  Protected a.s = Trim(argExpr)
  If a = "" : ProcedureReturn "void" : EndIf
  
  ; String literal
  If Left(a, 1) = Chr(34) Or Left(a, 2) = "~" + Chr(34)
    ProcedureReturn "s"
  EndIf
  
  ; Check if it's a method call like *obj\GetText() or *obj\GetFirstName()
  If Left(a, 1) = "*" And FindString(a, "\") > 0
    Protected slashPos.i = FindString(a, "\")
    Protected methPart.s = Trim(Mid(a, slashPos + 1))
    Protected parenPos.i = FindString(methPart, "(")
    If parenPos > 0
      Protected methNameOnly.s = Trim(Left(methPart, parenPos - 1))
      Protected pDotRet.i = FindString(methNameOnly, ".")
      If pDotRet > 0
        Protected explicitRet.s = LCase(Mid(methNameOnly, pDotRet + 1))
        If explicitRet = "s" Or explicitRet = "d" Or explicitRet = "f" Or explicitRet = "i" Or explicitRet = "b"
          ProcedureReturn explicitRet
        EndIf
      EndIf
      ; Check in MethodBodies for return type
      PushListPosition(MethodBodies())
      ForEach MethodBodies()
        If UCase(MethodBodies()\methodName) = UCase(methNameOnly)
          If MethodBodies()\returnType = ".s"
            PopListPosition(MethodBodies())
            ProcedureReturn "s"
          ElseIf MethodBodies()\returnType = ".d"
            PopListPosition(MethodBodies())
            ProcedureReturn "d"
          ElseIf MethodBodies()\returnType = ".f"
            PopListPosition(MethodBodies())
            ProcedureReturn "f"
          ElseIf MethodBodies()\returnType = ".b"
            PopListPosition(MethodBodies())
            ProcedureReturn "b"
          ElseIf MethodBodies()\returnType = ".i"
            PopListPosition(MethodBodies())
            ProcedureReturn "i"
          EndIf
        EndIf
      Next
      PopListPosition(MethodBodies())
    EndIf
  EndIf

  ; Pointer or memory address
  If Left(a, 1) = "@" Or Left(a, 1) = "*" Or Left(a, 8) = "#Null"
    ProcedureReturn "p"
  EndIf
  
  ; String variable or string function call
  If Right(a, 1) = "$" Or Right(a, 2) = ".s" Or Right(a, 2) = ".S"
    ProcedureReturn "s"
  EndIf
  Protected aUp.s = UCase(a)
  If Left(aUp, 4) = "STR(" Or Left(aUp, 5) = "STRF(" Or Left(aUp, 5) = "STRD(" Or Left(aUp, 5) = "LEFT(" Or Left(aUp, 6) = "RIGHT(" Or Left(aUp, 4) = "MID(" Or Left(aUp, 6) = "UCASE(" Or Left(aUp, 6) = "LCASE(" Or Left(aUp, 5) = "TRIM(" Or Left(aUp, 4) = "CHR("
    ProcedureReturn "s"
  EndIf
  
  ; Float / Double literal with decimal dot
  If FindString(a, ".") > 0
    Protected isNum.b = #True
    Protected i.i, lenA.i = Len(a)
    For i = 1 To lenA
      Protected c.s = Mid(a, i, 1)
      If Not ((Asc(c) >= 48 And Asc(c) <= 57) Or c = "." Or c = "-" Or c = "+")
        isNum = #False
        Break
      EndIf
    Next
    If isNum
      ProcedureReturn "d"
    EndIf
  EndIf
  
  ; Double / Float explicit suffix
  If Right(a, 2) = ".d" Or Right(a, 2) = ".D"
    ProcedureReturn "d"
  ElseIf Right(a, 2) = ".f" Or Right(a, 2) = ".F"
    ProcedureReturn "f"
  ElseIf Right(a, 2) = ".q" Or Right(a, 2) = ".Q"
    ProcedureReturn "q"
  EndIf
  
  ; Default integer
  ProcedureReturn "i"
EndProcedure

; Computes the argument signature of an argument list in a call
Procedure.s GetCallArgSignature(argList.s, *outArgCount.Integer = 0)
  Protected NewList tokens.s()
  Protected count.i = SplitParams(argList, tokens())
  If *outArgCount
    *outArgCount\i = count
  EndIf
  If count = 0
    ProcedureReturn "void"
  EndIf
  Protected sig.s = ""
  ForEach tokens()
    Protected aType.s = InferArgType(tokens())
    If sig = ""
      sig = aType
    Else
      sig + "_" + aType
    EndIf
  Next
  ProcedureReturn sig
EndProcedure

Procedure.b IsValidFieldDeclaration(decl.s)
  Protected d.s = Trim(decl)
  Protected up.s = UCase(d)
  If up = "STRUCTUREUNION" Or up = "ENDSTRUCTUREUNION"
    ProcedureReturn #True
  EndIf
  If Left(up, 5) = "LIST " Or Left(up, 4) = "MAP " Or Left(up, 6) = "ARRAY "
    ProcedureReturn #True
  EndIf
  If Left(d, 1) = "*"
    ProcedureReturn #True
  EndIf
  If FindString(d, ".") > 0
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure.s MangleIdentifier(id.s)
  Protected clean.s = id
  While Left(clean, 2) = "::"
    clean = Mid(clean, 3)
  Wend
  ProcedureReturn ReplaceString(clean, "::", "_")
EndProcedure

Procedure.s GetCurrentNamespace()
  Protected ns.s = ""
  ForEach NamespaceStack()
    If ns = ""
      ns = NamespaceStack()
    Else
      ns + "::" + NamespaceStack()
    EndIf
  Next
  ProcedureReturn ns
EndProcedure

Procedure.s ResolveClassName(ident.s, currentNS.s)
  Protected raw.s = Trim(ident)
  If raw = "" : ProcedureReturn "" : EndIf
  
  Protected result.s = raw
  PushListPosition(Classes())
  
  ; 1. Root qualifier "::ClassName"
  If Left(raw, 2) = "::"
    Protected rootName.s = Mid(raw, 3)
    ForEach Classes()
      If UCase(Classes()\fullName) = UCase(rootName) Or (Classes()\namespace = "" And UCase(Classes()\name) = UCase(rootName))
        result = Classes()\fullName
        Break
      EndIf
    Next
    PopListPosition(Classes())
    ProcedureReturn result
  EndIf
  
  ; 2. Check Alias prefix (e.g. GFX::Renderer where GFX = Game::Graphics)
  Protected pColon.i = FindString(raw, "::")
  If pColon > 0
    Protected aliasKey.s = Left(raw, pColon - 1)
    Protected aliasRest.s = Mid(raw, pColon + 2)
    If FindMapElement(NamespaceAliases(), UCase(aliasKey))
      Protected unaliased.s = NamespaceAliases() + "::" + aliasRest
      ForEach Classes()
        If UCase(Classes()\fullName) = UCase(unaliased)
          result = Classes()\fullName
          Break
        EndIf
      Next
      If result = raw
        result = unaliased
      EndIf
      PopListPosition(Classes())
      ProcedureReturn result
    EndIf
  EndIf
  
  ; 3. Check exact match on fullName
  ForEach Classes()
    If UCase(Classes()\fullName) = UCase(raw)
      result = Classes()\fullName
      PopListPosition(Classes())
      ProcedureReturn result
    EndIf
  Next

  ; 4. Check relative to current namespace
  If currentNS <> ""
    Protected testNS.s = currentNS
    While testNS <> ""
      Protected testFull.s = testNS + "::" + raw
      ForEach Classes()
        If UCase(Classes()\fullName) = UCase(testFull)
          result = Classes()\fullName
          Break 2
        EndIf
      Next
      Protected pLastColon.i = 0
      Protected k.i
      For k = Len(testNS) - 1 To 1 Step -1
        If Mid(testNS, k, 2) = "::"
          pLastColon = k
          Break
        EndIf
      Next
      If pLastColon > 0
        testNS = Left(testNS, pLastColon - 1)
      Else
        testNS = ""
      EndIf
    Wend
    If result <> raw
      PopListPosition(Classes())
      ProcedureReturn result
    EndIf
  EndIf

  ; 5. Check in UsingList namespaces
  Protected NewList matches.s()
  ForEach UsingList()
    Protected usingFull.s = UsingList() + "::" + raw
    ForEach Classes()
      If UCase(Classes()\fullName) = UCase(usingFull)
        AddElement(matches())
        matches() = Classes()\fullName
      EndIf
    Next
  Next
  
  If ListSize(matches()) = 1
    FirstElement(matches())
    result = matches()
    PopListPosition(Classes())
    ProcedureReturn result
  ElseIf ListSize(matches()) > 1
    FirstElement(matches())
    Protected m1.s = matches()
    NextElement(matches())
    Protected m2.s = matches()
    SetOOPError(LastErrorLine, "Ambiguous class reference '" + raw + "': matches both '" + m1 + "' and '" + m2 + "'")
    PopListPosition(Classes())
    ProcedureReturn ""
  EndIf

  ; 5b. Support UI::MVVM:: legacy alias
  If Left(UCase(raw), 10) = "UI::MVVM::"
    Protected strippedMvvm.s = Mid(raw, 5) ; "MVVM::..."
    ForEach Classes()
      If UCase(Classes()\fullName) = UCase(strippedMvvm)
        result = Classes()\fullName
        PopListPosition(Classes())
        ProcedureReturn result
      EndIf
    Next
  EndIf

  ; 6. Check root/global namespace
  ForEach Classes()
    If Classes()\namespace = "" And UCase(Classes()\name) = UCase(raw)
      result = Classes()\fullName
      Break
    EndIf
  Next

  PopListPosition(Classes())
  ProcedureReturn result
EndProcedure

; ----------------------------------------------------------------------------
; Multi-file Recursive Loader
; ----------------------------------------------------------------------------

Global BaseDirectory.s = ""

Procedure.s CanonicalizePath(path.s)
  path = ReplaceString(path, "/", "\")
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    Protected buf.s = Space(2048)
    If GetFullPathName_(@path, 2048, @buf, 0)
      ProcedureReturn buf
    EndIf
  CompilerEndIf
  While FindString(path, "\.\") > 0
    path = ReplaceString(path, "\.\", "\")
  Wend
  While FindString(path, "\..\") > 0
    Protected pDotDot.i = FindString(path, "\..\")
    If pDotDot > 0
      Protected pPrevSlash.i = 0
      Protected i.i
      For i = pDotDot - 1 To 1 Step -1
        If Mid(path, i, 1) = "\"
          pPrevSlash = i
          Break
        EndIf
      Next
      If pPrevSlash > 0
        path = Left(path, pPrevSlash) + Mid(path, pDotDot + 4)
      Else
        Break
      EndIf
    EndIf
  Wend
  ProcedureReturn path
EndProcedure

Procedure.b LoadSourceLinesRecursive(filePath.s)
  filePath = CanonicalizePath(filePath)
  Protected normPath.s = GetPathPart(filePath)
  If normPath = ""
    filePath = GetCurrentDirectory() + filePath
    filePath = CanonicalizePath(filePath)
  EndIf

  Protected file = ReadFile(#PB_Any, filePath)
  If Not file And BaseDirectory <> ""
    Protected altPath.s = CanonicalizePath(BaseDirectory + GetFilePart(filePath))
    file = ReadFile(#PB_Any, altPath)
    If file
      filePath = altPath
    EndIf
  EndIf

  If Not file
    SetOOPError(1, "Cannot open source file: " + filePath)
    ProcedureReturn #False
  EndIf

  Protected fileFormat.i = ReadStringFormat(file)
  If fileFormat = #PB_Ascii
    fileFormat = #PB_UTF8
  EndIf

  Protected isFirstLine.b = #True
  Protected lineNum.i = 0
  Protected dir.s = GetPathPart(filePath)

  While Not Eof(file)
    lineNum + 1
    Protected rawLine.s = ReadString(file, fileFormat)
    If isFirstLine
      While rawLine <> "" And (Asc(Left(rawLine, 1)) = 65279 Or Asc(Left(rawLine, 1)) = 239 Or Asc(Left(rawLine, 1)) = 187 Or Asc(Left(rawLine, 1)) = 191 Or Asc(Left(rawLine, 1)) = 0)
        rawLine = Mid(rawLine, 2)
      Wend
      isFirstLine = #False
    EndIf

    Protected trimmed.s = Trim(rawLine)
    Protected upper.s = UCase(trimmed)

    ; Check IncludeFile or XIncludeFile
    If Left(upper, 12) = "INCLUDEFILE " Or Left(upper, 13) = "XINCLUDEFILE "
      Protected isXInclude.b = #False
      If Left(upper, 13) = "XINCLUDEFILE " : isXInclude = #True : EndIf

      Protected pQuote1.i = FindString(trimmed, Chr(34))
      Protected pQuote2.i = 0
      If pQuote1 > 0
        pQuote2 = FindString(trimmed, Chr(34), pQuote1 + 1)
      EndIf

      If pQuote1 > 0 And pQuote2 > pQuote1
        Protected incPath.s = Mid(trimmed, pQuote1 + 1, pQuote2 - pQuote1 - 1)
        incPath = ReplaceString(incPath, "/", "\")
        Protected isAbs.b = #False
        If Mid(incPath, 2, 1) = ":" Or Left(incPath, 2) = "\\"
          isAbs = #True
        EndIf
        
        Protected finalIncPath.s = incPath
        If Not isAbs
          finalIncPath = dir + incPath
          If FileSize(finalIncPath) <= 0 And BaseDirectory <> ""
            Protected testAlt.s = CanonicalizePath(BaseDirectory + incPath)
            If FileSize(testAlt) > 0
              finalIncPath = testAlt
            EndIf
          EndIf
        EndIf
        finalIncPath = CanonicalizePath(finalIncPath)

        If isXInclude And FindMapElement(IncludedFilesMap(), UCase(finalIncPath))
          Continue
        EndIf

        IncludedFilesMap(UCase(finalIncPath)) = 1
        If Not LoadSourceLinesRecursive(finalIncPath)
          CloseFile(file)
          ProcedureReturn #False
        EndIf
        Continue
      EndIf
    EndIf

    AddElement(FileSourceLines())
    FileSourceLines()\content = rawLine
    FileSourceLines()\srcLineNumber = lineNum
    FileSourceLines()\srcFile = filePath
  Wend

  CloseFile(file)
  ProcedureReturn #True
EndProcedure

; ----------------------------------------------------------------------------
; C-Style Braces Preprocessor
; ----------------------------------------------------------------------------

Enumeration
  #CBLOCK_NAMESPACE
  #CBLOCK_CLASS
  #CBLOCK_METHOD
  #CBLOCK_PROCEDURE
  #CBLOCK_IF
  #CBLOCK_ELSEIF
  #CBLOCK_ELSE
  #CBLOCK_WHILE
  #CBLOCK_FOR
  #CBLOCK_FOREACH
  #CBLOCK_REPEAT
  #CBLOCK_SELECT
  #CBLOCK_STRUCTURE
  #CBLOCK_ENUMERATION
  #CBLOCK_INTERFACE
  #CBLOCK_MODULE
  #CBLOCK_DECLAREMODULE
  #CBLOCK_WITH
  #CBLOCK_COMPILERIF
EndEnumeration

Structure CBlockEntry
  type.i
  openLine.i
  openFile.s
EndStructure

Global NewList CBlockStack.CBlockEntry()

Procedure.i DetectBlockOpener(code.s)
  Protected up.s = UCase(Trim(code))
  If Left(up, 10) = "NAMESPACE "
    ProcedureReturn #CBLOCK_NAMESPACE
  ElseIf Left(up, 6) = "CLASS " Or Left(up, 15) = "ABSTRACT CLASS "
    ProcedureReturn #CBLOCK_CLASS
  ElseIf Left(up, 7) = "METHOD " Or Left(up, 7) = "METHOD." Or Left(up, 14) = "PUBLIC METHOD " Or Left(up, 14) = "PUBLIC METHOD." Or Left(up, 17) = "PROTECTED METHOD " Or Left(up, 17) = "PROTECTED METHOD." Or Left(up, 15) = "PRIVATE METHOD " Or Left(up, 15) = "PRIVATE METHOD." Or Left(up, 16) = "OVERRIDE METHOD " Or Left(up, 16) = "OVERRIDE METHOD."
    ProcedureReturn #CBLOCK_METHOD
  ElseIf Left(up, 9) = "PROCEDURE" Or Left(up, 18) = "RUNTIME PROCEDURE "
    ProcedureReturn #CBLOCK_PROCEDURE
  ElseIf Left(up, 3) = "IF " Or Left(up, 3) = "IF(" Or up = "IF"
    ProcedureReturn #CBLOCK_IF
  ElseIf Left(up, 7) = "ELSEIF " Or Left(up, 7) = "ELSEIF(" Or up = "ELSEIF"
    ProcedureReturn #CBLOCK_ELSEIF
  ElseIf up = "ELSE" Or Left(up, 5) = "ELSE "
    ProcedureReturn #CBLOCK_ELSE
  ElseIf Left(up, 6) = "WHILE " Or Left(up, 6) = "WHILE(" Or up = "WHILE"
    ProcedureReturn #CBLOCK_WHILE
  ElseIf Left(up, 4) = "FOR "
    ProcedureReturn #CBLOCK_FOR
  ElseIf Left(up, 8) = "FOREACH "
    ProcedureReturn #CBLOCK_FOREACH
  ElseIf up = "REPEAT" Or Left(up, 7) = "REPEAT "
    ProcedureReturn #CBLOCK_REPEAT
  ElseIf Left(up, 7) = "SELECT "
    ProcedureReturn #CBLOCK_SELECT
  ElseIf Left(up, 10) = "STRUCTURE "
    ProcedureReturn #CBLOCK_STRUCTURE
  ElseIf up = "ENUMERATION" Or Left(up, 12) = "ENUMERATION "
    ProcedureReturn #CBLOCK_ENUMERATION
  ElseIf Left(up, 10) = "INTERFACE "
    ProcedureReturn #CBLOCK_INTERFACE
  ElseIf Left(up, 7) = "MODULE "
    ProcedureReturn #CBLOCK_MODULE
  ElseIf Left(up, 14) = "DECLAREMODULE "
    ProcedureReturn #CBLOCK_DECLAREMODULE
  ElseIf Left(up, 5) = "WITH "
    ProcedureReturn #CBLOCK_WITH
  ElseIf Left(up, 11) = "COMPILERIF " Or Left(up, 11) = "COMPILERIF("
    ProcedureReturn #CBLOCK_COMPILERIF
  EndIf
  ProcedureReturn -1
EndProcedure

Procedure.b PreprocessCurlyBraces()
  ClearList(CBlockStack())
  Protected pendingOpener.i = -1
  Protected pendingLine.i = 0
  Protected pendingFile.s = ""

  ForEach FileSourceLines()
    Protected raw.s = FileSourceLines()\content
    Protected lineNum.i = FileSourceLines()\srcLineNumber
    Protected srcFile.s = FileSourceLines()\srcFile

    Protected i.i, inStr.b = #False
    Protected codeEnd.i = Len(raw)
    Protected lenRaw.i = Len(raw)
    
    For i = 1 To lenRaw
      Protected ch.s = Mid(raw, i, 1)
      If ch = Chr(34)
        inStr = ~inStr & 1
      ElseIf ch = ";" And Not inStr
        codeEnd = i - 1
        Break
      EndIf
    Next

    Protected codePart.s = Left(raw, codeEnd)
    Protected commentPart.s = Mid(raw, codeEnd + 1)
    Protected trimmedCode.s = Trim(codePart)

    If trimmedCode = ""
      Continue
    EndIf

    ; Standalone opening brace on its own line: "{"
    If trimmedCode = "{"
      If pendingOpener >= 0
        AddElement(CBlockStack())
        CBlockStack()\type = pendingOpener
        CBlockStack()\openLine = pendingLine
        CBlockStack()\openFile = pendingFile
        pendingOpener = -1
        FileSourceLines()\content = commentPart
        Continue
      Else
        SetOOPError(lineNum, "Unexpected '{' without preceding block statement")
        ProcedureReturn #False
      EndIf
    EndIf

    If pendingOpener >= 0
      pendingOpener = -1
    EndIf

    ; Closing brace variations
    If Left(trimmedCode, 1) = "}"
      If ListSize(CBlockStack()) = 0
        SetOOPError(lineNum, "Unexpected '}' without matching opening block")
        ProcedureReturn #False
      EndIf

      LastElement(CBlockStack())
      Protected topType.i = CBlockStack()\type
      DeleteElement(CBlockStack())

      Protected restOfCode.s = Trim(Mid(trimmedCode, 2))
      Protected restUpper.s = UCase(restOfCode)

      If Left(restUpper, 4) = "ELSE"
        If Left(restUpper, 6) = "ELSEIF"
          Protected hasOpenBrace.b = #False
          If Right(restOfCode, 1) = "{"
            hasOpenBrace = #True
            restOfCode = Trim(Left(restOfCode, Len(restOfCode) - 1))
          EndIf
          If hasOpenBrace
            AddElement(CBlockStack())
            CBlockStack()\type = #CBLOCK_ELSEIF
            CBlockStack()\openLine = lineNum
            CBlockStack()\openFile = srcFile
          EndIf
          FileSourceLines()\content = restOfCode + commentPart
          Continue
        Else
          Protected hasOpenBrace2.b = #False
          If Right(restOfCode, 1) = "{"
            hasOpenBrace2 = #True
            restOfCode = Trim(Left(restOfCode, Len(restOfCode) - 1))
          EndIf
          If hasOpenBrace2
            AddElement(CBlockStack())
            CBlockStack()\type = #CBLOCK_ELSE
            CBlockStack()\openLine = lineNum
            CBlockStack()\openFile = srcFile
          EndIf
          If restOfCode = "" : restOfCode = "Else" : EndIf
          FileSourceLines()\content = restOfCode + commentPart
          Continue
        EndIf
      ElseIf Left(restUpper, 5) = "UNTIL"
        FileSourceLines()\content = restOfCode + commentPart
        Continue
      Else
        Protected endKeyword.s = ""
        Select topType
          Case #CBLOCK_NAMESPACE:     endKeyword = "EndNamespace"
          Case #CBLOCK_CLASS:         endKeyword = "EndClass"
          Case #CBLOCK_METHOD:        endKeyword = "EndMethod"
          Case #CBLOCK_PROCEDURE:     endKeyword = "EndProcedure"
          Case #CBLOCK_IF, #CBLOCK_ELSE, #CBLOCK_ELSEIF: endKeyword = "EndIf"
          Case #CBLOCK_WHILE:         endKeyword = "Wend"
          Case #CBLOCK_FOR, #CBLOCK_FOREACH: endKeyword = "Next"
          Case #CBLOCK_REPEAT:        endKeyword = "Until #True"
          Case #CBLOCK_SELECT:        endKeyword = "EndSelect"
          Case #CBLOCK_STRUCTURE:     endKeyword = "EndStructure"
          Case #CBLOCK_ENUMERATION:   endKeyword = "EndEnumeration"
          Case #CBLOCK_INTERFACE:     endKeyword = "EndInterface"
          Case #CBLOCK_MODULE:        endKeyword = "EndModule"
          Case #CBLOCK_DECLAREMODULE: endKeyword = "EndDeclareModule"
          Case #CBLOCK_WITH:          endKeyword = "EndWith"
          Case #CBLOCK_COMPILERIF:    endKeyword = "CompilerEndIf"
        EndSelect

        FileSourceLines()\content = endKeyword + commentPart
        Continue
      EndIf
    EndIf

    ; Opening line with trailing "{"
    If Right(trimmedCode, 1) = "{"
      Protected strippedCode.s = Trim(Left(trimmedCode, Len(trimmedCode) - 1))
      Protected openerType.i = DetectBlockOpener(strippedCode)
      If openerType >= 0
        AddElement(CBlockStack())
        CBlockStack()\type = openerType
        CBlockStack()\openLine = lineNum
        CBlockStack()\openFile = srcFile

        FileSourceLines()\content = strippedCode + commentPart
        Continue
      EndIf
    Else
      Protected possibleOpener.i = DetectBlockOpener(trimmedCode)
      If possibleOpener >= 0
        pendingOpener = possibleOpener
        pendingLine = lineNum
        pendingFile = srcFile
      EndIf
    EndIf

  Next

  If ListSize(CBlockStack()) > 0
    LastElement(CBlockStack())
    SetOOPError(CBlockStack()\openLine, "Missing closing brace '}' for block opened at line " + Str(CBlockStack()\openLine))
    ProcedureReturn #False
  EndIf

  ProcedureReturn #True
EndProcedure

; ----------------------------------------------------------------------------
; Parser Phase (.pbo -> AST / OOP Meta-Model)
; ----------------------------------------------------------------------------

Procedure.b ParsePBO(inputFile.s)
  LastErrorFile = inputFile
  LastErrorLine = 0
  LastErrorMessage = ""

  ClearList(FileSourceLines())
  ClearMap(IncludedFilesMap())
  ClearList(NamespaceStack())
  ClearList(UsingList())
  ClearMap(NamespaceAliases())

  IncludedFilesMap(UCase(CanonicalizePath(inputFile))) = 1
  If Not LoadSourceLinesRecursive(inputFile)
    ProcedureReturn #False
  EndIf

  ; Auto-detect Framework usage (UI::, MVVM::, Using UI, Using MVVM, etc.)
  Protected needsFramework.b = #False
  ForEach FileSourceLines()
    Protected chkUp.s = UCase(FileSourceLines()\content)
    If FindString(chkUp, "UI::") > 0 Or FindString(chkUp, "MVVM::") > 0 Or FindString(chkUp, "USING UI") > 0 Or FindString(chkUp, "USING MVVM") > 0 Or FindString(chkUp, "VIEWMODELBASE") > 0 Or FindString(chkUp, "OBSERVABLEOBJECT") > 0 Or FindString(chkUp, "STRINGPROPERTY") > 0 Or FindString(chkUp, "INTPROPERTY") > 0 Or FindString(chkUp, "<WINDOW") > 0 Or FindString(chkUp, "<STACKPANEL") > 0 Or FindString(chkUp, "<DOCKPANEL") > 0 Or FindString(chkUp, "<GRID") > 0
      needsFramework = #True
      Break
    EndIf
  Next

  If needsFramework
    Protected frameworkUIPath.s = CanonicalizePath(GetPathPart(ProgramFilename()) + "..\framework\UI.pbi")
    If FileSize(frameworkUIPath) <= 0
      frameworkUIPath = CanonicalizePath(GetCurrentDirectory() + "framework\UI.pbi")
    EndIf
    If FileSize(frameworkUIPath) <= 0 And BaseDirectory <> ""
      frameworkUIPath = CanonicalizePath(BaseDirectory + "..\framework\UI.pbi")
    EndIf
    If FileSize(frameworkUIPath) <= 0 And BaseDirectory <> ""
      frameworkUIPath = CanonicalizePath(BaseDirectory + "framework\UI.pbi")
    EndIf

    If FileSize(frameworkUIPath) > 0 And Not FindMapElement(IncludedFilesMap(), UCase(frameworkUIPath))
      ; Save user lines
      NewList UserSourceLines.OOP_SourceLine()
      CopyList(FileSourceLines(), UserSourceLines())
      ClearList(FileSourceLines())
      
      ; Load Framework first
      IncludedFilesMap(UCase(frameworkUIPath)) = 1
      If LoadSourceLinesRecursive(frameworkUIPath)
        ; Append User lines after framework
        ForEach UserSourceLines()
          AddElement(FileSourceLines())
          FileSourceLines()\content = UserSourceLines()\content
          FileSourceLines()\srcLineNumber = UserSourceLines()\srcLineNumber
          FileSourceLines()\srcFile = UserSourceLines()\srcFile
        Next
      Else
        ; Fallback: restore user lines
        CopyList(UserSourceLines(), FileSourceLines())
      EndIf
      ClearList(UserSourceLines())
    EndIf
  EndIf

  If Not PreprocessCurlyBraces()
    ProcedureReturn #False
  EndIf

  ClearList(Classes())
  ClearMap(ClassMap())
  ClearList(MethodBodies())
  ClearList(MainLines())
  ClearList(HeaderDeclarations())
  ClearMap(OverloadedMethodNames())

  Protected inClass.b = #False
  Protected inMethod.b = #False
  Protected inClassMethod.b = #False
  Protected inTopEnum.b = #False
  Protected inTopStruct.b = #False
  Protected inTopMacro.b = #False
  Protected *currentClass.OOP_Class = #Null
  Protected *currentMethod.OOP_MethodBody = #Null
  Protected rawLine.s, line.s, upper.s
  Protected p1.i, p2.i, p3.i, pEnd.i
  Protected currentLineNum.i = 0
  Protected currentFile.s = ""
  Protected classStartLine.i = 0
  Protected methodStartLine.i = 0

  ForEach FileSourceLines()
    currentLineNum = FileSourceLines()\srcLineNumber
    currentFile = FileSourceLines()\srcFile
    rawLine = FileSourceLines()\content
    line = StripComment(rawLine)
    upper = UCase(line)

    ; 0. Top-Level Namespace, EndNamespace, Using, and Aliases
    If Not inClass And Not inMethod And Not inClassMethod
      If Left(upper, 10) = "NAMESPACE "
        Protected nsArg.s = Trim(Mid(line, 11))
        Protected pEq.i = FindString(nsArg, "=")
        If pEq > 0
          Protected aliasName.s = Trim(Left(nsArg, pEq - 1))
          Protected targetNs.s = Trim(Mid(nsArg, pEq + 1))
          NamespaceAliases(UCase(aliasName)) = targetNs
          Continue
        Else
          AddElement(NamespaceStack())
          NamespaceStack() = nsArg
          Continue
        EndIf

      ElseIf upper = "ENDNAMESPACE"
        If ListSize(NamespaceStack()) > 0
          LastElement(NamespaceStack())
          DeleteElement(NamespaceStack())
        Else
          SetOOPError(currentLineNum, "Unexpected 'EndNamespace' without matching 'Namespace'")
          ProcedureReturn #False
        EndIf
        Continue

      ElseIf Left(upper, 6) = "USING "
        Protected usingNs.s = Trim(Mid(line, 7))
        AddElement(UsingList())
        UsingList() = usingNs
        Continue
      EndIf
    EndIf

    ; 1. Parsing inside an Inline Method Body
    If inClassMethod
      If Left(upper, 9) = "ENDMETHOD"
        inClassMethod = #False
        *currentMethod = #Null
        Continue
      Else
        AddElement(*currentMethod\BodyLines())
        *currentMethod\BodyLines()\content = rawLine
        *currentMethod\BodyLines()\srcLineNumber = currentLineNum
        *currentMethod\BodyLines()\srcFile = currentFile
        Continue
      EndIf

    ; 2. Parsing inside a Class Definition
    ElseIf inClass
      If Left(upper, 8) = "ENDCLASS"
        inClass = #False
        *currentClass = #Null
        Continue

      ElseIf Left(upper, 9) = "ENDMETHOD"
        SetOOPError(currentLineNum, "Unexpected 'EndMethod' inside Class without preceding Method")
        ProcedureReturn #False

      Else
        Protected vis.s = "Public"
        Protected workLine.s = line
        Protected matchedPrefix.b = #False

        If Left(upper, 7) = "PUBLIC "
          vis = "Public" : workLine = Trim(Mid(line, 8)) : matchedPrefix = #True
        ElseIf Left(upper, 10) = "PROTECTED "
          vis = "Protected" : workLine = Trim(Mid(line, 11)) : matchedPrefix = #True
        ElseIf Left(upper, 8) = "PRIVATE "
          vis = "Private" : workLine = Trim(Mid(line, 9)) : matchedPrefix = #True
        EndIf

        Protected workUpper.s = UCase(workLine)
        Protected isAbsMeth.b = #False
        If Left(workUpper, 9) = "ABSTRACT "
          isAbsMeth = #True
          workLine = Trim(Mid(workLine, 10))
          workUpper = UCase(workLine)
        EndIf

        ; Check Method declaration
        If Left(workUpper, 6) = "METHOD" And (Len(workUpper) = 6 Or Mid(workUpper, 7, 1) = " " Or Mid(workUpper, 7, 1) = ".")
          Protected mDecl.s = Trim(Mid(workLine, 7))
          Protected mRet.s = ""
          
          If Left(mDecl, 1) = "."
            p1 = FindString(mDecl, " ")
            p2 = FindString(mDecl, "(")
            pEnd = p1
            If pEnd = 0 Or (p2 > 0 And p2 < pEnd) : pEnd = p2 : EndIf
            If pEnd > 0
              mRet = Left(mDecl, pEnd - 1)
              mDecl = Trim(Mid(mDecl, pEnd))
            EndIf
          EndIf

          p1 = FindString(mDecl, "(")
          p2 = FindString(mDecl, ")")
          If p1 = 0 Or p2 = 0 Or p2 < p1
            SetOOPError(currentLineNum, "Invalid method declaration syntax: " + line)
            ProcedureReturn #False
          EndIf

          Protected mName.s = Trim(Left(mDecl, p1 - 1))
          Protected mParams.s = Trim(Mid(mDecl, p1 + 1, p2 - p1 - 1))

          Protected pDotInName.i = FindString(mName, ".")
          If pDotInName > 0
            If mRet = ""
              mRet = Mid(mName, pDotInName)
            EndIf
            mName = Left(mName, pDotInName - 1)
          EndIf

          Protected mSig.s = GetParamSignature(mParams)
          Protected mCleanParams.s = GetCleanParams(mParams)
          Protected NewList mParamsList.s()
          Protected mTotalParams.i = SplitParams(mParams, mParamsList())
          Protected mMinParams.i = CountMinParameters(mParams)
          Protected hasDef.b = #False
          If mMinParams < mTotalParams
            hasDef = #True
          EndIf

          AddElement(*currentClass\Methods())
          *currentClass\Methods()\name = mName
          *currentClass\Methods()\rawDecl = line
          *currentClass\Methods()\params = mParams
          *currentClass\Methods()\cleanParams = mCleanParams
          *currentClass\Methods()\returnType = mRet
          *currentClass\Methods()\visibility = vis
          *currentClass\Methods()\isAbstract = isAbsMeth
          *currentClass\Methods()\signature = mSig
          *currentClass\Methods()\paramCount = mTotalParams
          *currentClass\Methods()\minParamCount = mMinParams
          *currentClass\Methods()\hasDefaults = hasDef
          *currentClass\Methods()\mangledMethodName = mName ; will be updated if overloaded
          *currentClass\Methods()\srcLineNumber = currentLineNum
          *currentClass\Methods()\srcFile = currentFile

          If UCase(mName) = "INIT"
            *currentClass\hasInit = #True
            Protected alreadyInClassInit.b = #False
            ForEach *currentClass\InitConstructors()
              If *currentClass\InitConstructors()\signature = mSig
                alreadyInClassInit = #True
                Break
              EndIf
            Next
            If Not alreadyInClassInit
              AddElement(*currentClass\InitConstructors())
              *currentClass\InitConstructors()\params = mParams
              *currentClass\InitConstructors()\cleanParams = mCleanParams
              *currentClass\InitConstructors()\signature = mSig
              *currentClass\InitConstructors()\paramCount = mTotalParams
              *currentClass\InitConstructors()\minParamCount = mMinParams
              *currentClass\InitConstructors()\srcLineNumber = currentLineNum
              *currentClass\InitConstructors()\srcFile = currentFile
            EndIf
          ElseIf UCase(mName) = "FREE"
            *currentClass\hasFree = #True
            *currentClass\freeClassMangled = *currentClass\mangledName
          EndIf

          If isAbsMeth
            Continue
          EndIf

          ; Check if this is an inline method or a single-line declaration
          Protected isInline.b = #False
          PushListPosition(FileSourceLines())
          While NextElement(FileSourceLines())
            Protected nextLine.s = Trim(UCase(FileSourceLines()\content))
            If nextLine = "" Or Left(nextLine, 1) = ";"
              Continue
            ElseIf Left(nextLine, 9) = "ENDMETHOD"
              isInline = #True
              Break
            ElseIf Left(nextLine, 8) = "ENDCLASS" Or Left(nextLine, 6) = "METHOD" Or Left(nextLine, 13) = "PUBLIC METHOD" Or Left(nextLine, 16) = "PROTECTED METHOD" Or Left(nextLine, 14) = "PRIVATE METHOD"
              isInline = #False
              Break
            EndIf
          Wend
          PopListPosition(FileSourceLines())

          If isInline
            AddElement(MethodBodies())
            *currentMethod = @MethodBodies()
            *currentMethod\className = *currentClass\fullName
            *currentMethod\mangledClassName = *currentClass\mangledName
            *currentMethod\methodName = mName
            *currentMethod\signature = mSig
            *currentMethod\mangledMethodName = mName
            *currentMethod\params = mParams
            *currentMethod\cleanParams = mCleanParams
            *currentMethod\returnType = mRet
            *currentMethod\srcLineNumber = currentLineNum
            *currentMethod\srcFile = currentFile
            inClassMethod = #True
            methodStartLine = currentLineNum
          EndIf
          Continue

        ElseIf matchedPrefix Or (line <> "" And Left(line, 1) <> ";")
          If Not IsValidFieldDeclaration(workLine)
            SetOOPError(currentLineNum, "Syntax error or invalid declaration '" + workLine + "' in Class '" + *currentClass\fullName + "'")
            ProcedureReturn #False
          EndIf
          AddElement(*currentClass\Fields())
          *currentClass\Fields()\name = workLine
          *currentClass\Fields()\visibility = vis
          *currentClass\Fields()\srcLineNumber = currentLineNum
          *currentClass\Fields()\srcFile = currentFile
          Continue
        EndIf
      EndIf

    ; 3. Parsing inside Out-of-Class Method Implementation (Method Class::Name(params))
    ElseIf inMethod
      If Left(upper, 9) = "ENDMETHOD"
        inMethod = #False
        *currentMethod = #Null
        Continue
      Else
        AddElement(*currentMethod\BodyLines())
        *currentMethod\BodyLines()\content = rawLine
        *currentMethod\BodyLines()\srcLineNumber = currentLineNum
        *currentMethod\BodyLines()\srcFile = currentFile
        Continue
      EndIf

    ; 4. Top-Level Code: Class Declaration, Out-of-Class Method, or Regular PB Code
    Else
      If Left(upper, 6) = "CLASS " Or Left(upper, 15) = "ABSTRACT CLASS "
        Protected isAbsClass.b = #False
        Protected classDecl.s = Trim(Mid(line, 7))
        If Left(upper, 15) = "ABSTRACT CLASS "
          isAbsClass = #True
          classDecl = Trim(Mid(line, 16))
        EndIf

        Protected cName.s = ""
        Protected pName.s = ""
        p1 = FindString(UCase(classDecl), " EXTENDS ")
        If p1 > 0
          cName = Trim(Left(classDecl, p1 - 1))
          pName = Trim(Mid(classDecl, p1 + 9))
        Else
          cName = Trim(classDecl)
        EndIf

        If cName = ""
          SetOOPError(currentLineNum, "Missing class name in Class declaration")
          ProcedureReturn #False
        EndIf

        Protected currentNS.s = GetCurrentNamespace()
        Protected fullCName.s = cName
        If currentNS <> ""
          fullCName = currentNS + "::" + cName
        EndIf
        Protected mangledCName.s = MangleIdentifier(fullCName)

        If FindMapElement(ClassMap(), UCase(fullCName))
          SetOOPError(currentLineNum, "Duplicate Class '" + fullCName + "'")
          ProcedureReturn #False
        EndIf

        AddElement(Classes())
        *currentClass = @Classes()
        *currentClass\name = cName
        *currentClass\namespace = currentNS
        *currentClass\fullName = fullCName
        *currentClass\mangledName = mangledCName
        *currentClass\parentName = pName
        *currentClass\isAbstract = isAbsClass
        *currentClass\srcLineNumber = currentLineNum
        *currentClass\srcFile = currentFile
        
        ClassMap(UCase(fullCName)) = ListIndex(Classes())
        ClassMap(UCase(mangledCName)) = ListIndex(Classes())
        If currentNS = ""
          ClassMap(UCase(cName)) = ListIndex(Classes())
        EndIf

        inClass = #True
        classStartLine = currentLineNum
        Continue

      ElseIf Left(upper, 8) = "ENDCLASS"
        SetOOPError(currentLineNum, "Unexpected 'EndClass' without preceding Class declaration")
        ProcedureReturn #False

      ElseIf Left(upper, 9) = "ENDMETHOD"
        SetOOPError(currentLineNum, "Unexpected 'EndMethod' without preceding Method implementation")
        ProcedureReturn #False

      ElseIf Left(upper, 6) = "METHOD" And (Len(upper) = 6 Or Mid(upper, 7, 1) = " " Or Mid(upper, 7, 1) = ".")
        Protected outDecl.s = Trim(Mid(line, 7))
        Protected outRet.s = ""
        
        If Left(outDecl, 1) = "."
          p1 = FindString(outDecl, " ")
          p2 = FindString(outDecl, "(")
          pEnd = p1
          If pEnd = 0 Or (p2 > 0 And p2 < pEnd) : pEnd = p2 : EndIf
          If pEnd > 0
            outRet = Left(outDecl, pEnd - 1)
            outDecl = Trim(Mid(outDecl, pEnd))
          EndIf
        EndIf

        p1 = FindString(outDecl, "(")
        p2 = FindString(outDecl, ")")
        If p1 = 0 Or p2 = 0 Or p2 < p1
          SetOOPError(currentLineNum, "Invalid out-of-class method syntax: " + line)
          ProcedureReturn #False
        EndIf

        Protected fullTargetName.s = Trim(Left(outDecl, p1 - 1))
        Protected m_params.s = Trim(Mid(outDecl, p1 + 1, p2 - p1 - 1))

        p3 = 0
        Protected scanPos.i = 1
        While #True
          Protected foundSep.i = FindString(fullTargetName, "::", scanPos)
          If foundSep > 0
            p3 = foundSep
            scanPos = foundSep + 2
          Else
            Break
          EndIf
        Wend

        If p3 = 0
          SetOOPError(currentLineNum, "Out-of-class Method must specify 'ClassName::MethodName': " + line)
          ProcedureReturn #False
        EndIf

        Protected classPart.s = Trim(Left(fullTargetName, p3 - 1))
        Protected m_name.s = Trim(Mid(fullTargetName, p3 + 2))

        Protected pDotOutName.i = FindString(m_name, ".")
        If pDotOutName > 0
          If outRet = ""
            outRet = Mid(m_name, pDotOutName)
          EndIf
          m_name = Left(m_name, pDotOutName - 1)
        EndIf

        Protected resolvedClass.s = ResolveClassName(classPart, GetCurrentNamespace())
        Protected resolvedMangled.s = MangleIdentifier(resolvedClass)

        If Not FindMapElement(ClassMap(), UCase(resolvedClass))
          SetOOPError(currentLineNum, "Method implementation for unknown class '" + classPart + "'")
          ProcedureReturn #False
        EndIf

        Protected outSig.s = GetParamSignature(m_params)
        Protected outCleanParams.s = GetCleanParams(m_params)
        Protected NewList outParamsList.s()
        Protected outTotalParams.i = SplitParams(m_params, outParamsList())
        Protected outMinParams.i = CountMinParameters(m_params)

        Protected targetClassIdx.i = ClassMap(UCase(resolvedClass))
        PushListPosition(Classes())
        SelectElement(Classes(), targetClassIdx)
        If UCase(m_name) = "INIT"
          Classes()\hasInit = #True
          Protected alreadyHasInit.b = #False
          ForEach Classes()\InitConstructors()
            If Classes()\InitConstructors()\signature = outSig
              alreadyHasInit = #True
              Break
            EndIf
          Next
          If Not alreadyHasInit
            AddElement(Classes()\InitConstructors())
            Classes()\InitConstructors()\params = m_params
            Classes()\InitConstructors()\cleanParams = outCleanParams
            Classes()\InitConstructors()\signature = outSig
            Classes()\InitConstructors()\paramCount = outTotalParams
            Classes()\InitConstructors()\minParamCount = outMinParams
            Classes()\InitConstructors()\srcLineNumber = currentLineNum
            Classes()\InitConstructors()\srcFile = currentFile
          EndIf
        ElseIf UCase(m_name) = "FREE"
          Classes()\hasFree = #True
          Classes()\freeClassMangled = Classes()\mangledName
        EndIf
        PopListPosition(Classes())

        AddElement(MethodBodies())
        *currentMethod = @MethodBodies()
        *currentMethod\className = resolvedClass
        *currentMethod\mangledClassName = resolvedMangled
        *currentMethod\methodName = m_name
        *currentMethod\signature = outSig
        *currentMethod\mangledMethodName = m_name
        *currentMethod\params = m_params
        *currentMethod\cleanParams = outCleanParams
        *currentMethod\returnType = outRet
        *currentMethod\srcLineNumber = currentLineNum
        *currentMethod\srcFile = currentFile
        inMethod = #True
        methodStartLine = currentLineNum
        Continue

      Else
        Protected trimmedUpper.s = Trim(upper)
        If Left(trimmedUpper, 12) = "ENUMERATION " Or trimmedUpper = "ENUMERATION"
          inTopEnum = #True
        ElseIf Left(trimmedUpper, 10) = "STRUCTURE " Or trimmedUpper = "STRUCTURE"
          inTopStruct = #True
        ElseIf Left(trimmedUpper, 6) = "MACRO " Or trimmedUpper = "MACRO"
          inTopMacro = #True
        EndIf

        If inTopEnum Or inTopStruct Or inTopMacro Or Left(trimmedUpper, 1) = "#"
          AddElement(TypeDeclarations())
          TypeDeclarations()\content = rawLine
          TypeDeclarations()\srcLineNumber = currentLineNum
          TypeDeclarations()\srcFile = currentFile

          If trimmedUpper = "ENDENUMERATION" : inTopEnum = #False : EndIf
          If trimmedUpper = "ENDSTRUCTURE" : inTopStruct = #False : EndIf
          If trimmedUpper = "ENDMACRO" : inTopMacro = #False : EndIf
        ElseIf Left(trimmedUpper, 7) = "GLOBAL " Or Left(trimmedUpper, 7) = "NEWMAP " Or Left(trimmedUpper, 8) = "NEWLIST " Or Left(trimmedUpper, 4) = "DIM " Or Left(trimmedUpper, 9) = "THREADED " Or Left(trimmedUpper, 7) = "SHARED " Or Left(trimmedUpper, 8) = "DECLARE " Or Left(trimmedUpper, 8) = "DECLARE."
          AddElement(HeaderDeclarations())
          HeaderDeclarations()\content = rawLine
          HeaderDeclarations()\srcLineNumber = currentLineNum
          HeaderDeclarations()\srcFile = currentFile
        Else
          AddElement(MainLines())
          MainLines()\content = rawLine
          MainLines()\srcLineNumber = currentLineNum
          MainLines()\srcFile = currentFile
        EndIf
      EndIf
    EndIf
  Next

  If inClass
    SetOOPError(classStartLine, "Unclosed Class '" + *currentClass\fullName + "' - missing EndClass")
    ProcedureReturn #False
  EndIf

  If inMethod Or inClassMethod
    SetOOPError(methodStartLine, "Unclosed Method '" + *currentMethod\methodName + "' - missing EndMethod")
    ProcedureReturn #False
  EndIf

  ProcedureReturn #True
EndProcedure

; ----------------------------------------------------------------------------
; Semantic Analysis & Overloading Resolution & VTable Construction
; ----------------------------------------------------------------------------

Procedure.b BuildVTables()
  ; Step 1: Detect method overloading within each class and across hierarchy
  ForEach Classes()
    Protected *c.OOP_Class = @Classes()
    Protected NewMap methodCount.i()
    
    ; Count occurrences of each method name in class
    ForEach *c\Methods()
      Protected mKey.s = UCase(*c\Methods()\name)
      methodCount(mKey) + 1
    Next

    ; Mark overloaded methods
    ForEach *c\Methods()
      mKey = UCase(*c\Methods()\name)
      If methodCount(mKey) > 1
        *c\Methods()\mangledMethodName = *c\Methods()\name + "_" + *c\Methods()\signature
        OverloadedMethodNames(mKey) = 1
      Else
        *c\Methods()\mangledMethodName = *c\Methods()\name
      EndIf
    Next

    ; Name mangling for constructors
    If ListSize(*c\InitConstructors()) > 1
      ForEach *c\InitConstructors()
        *c\InitConstructors()\mangledName = "New_" + *c\mangledName + "_" + *c\InitConstructors()\signature
        *c\InitConstructors()\initProcMangled = *c\mangledName + "_Init_" + *c\InitConstructors()\signature
      Next
    ElseIf ListSize(*c\InitConstructors()) = 1
      FirstElement(*c\InitConstructors())
      *c\InitConstructors()\mangledName = "New_" + *c\mangledName
      *c\InitConstructors()\initProcMangled = *c\mangledName + "_Init"
    EndIf
  Next

  ; Step 2: Build VTable Slots with inheritance
  ForEach Classes()
    *c = @Classes()
    ClearList(*c\VTableSlots())

    ; Inherit slots from parent class
    If *c\parentName <> ""
      *c\fullParentName = ResolveClassName(*c\parentName, *c\namespace)
      *c\mangledParentName = MangleIdentifier(*c\fullParentName)

      If Not FindMapElement(ClassMap(), UCase(*c\fullParentName))
        SetOOPError(*c\srcLineNumber, "Class '" + *c\fullName + "' extends unknown parent class '" + *c\parentName + "'")
        ProcedureReturn #False
      EndIf
      
      Protected parentIdx.i = ClassMap(UCase(*c\fullParentName))
      PushListPosition(Classes())
      SelectElement(Classes(), parentIdx)
      Protected *parent.OOP_Class = @Classes()
      ForEach *parent\VTableSlots()
        AddElement(*c\VTableSlots())
        *c\VTableSlots()\methodName = *parent\VTableSlots()\methodName
        *c\VTableSlots()\baseMethodName = *parent\VTableSlots()\baseMethodName
        *c\VTableSlots()\signature = *parent\VTableSlots()\signature
        *c\VTableSlots()\implementingClass = *parent\VTableSlots()\implementingClass
        *c\VTableSlots()\declaringClass = *parent\VTableSlots()\declaringClass
        *c\VTableSlots()\params = *parent\VTableSlots()\params
        *c\VTableSlots()\cleanParams = *parent\VTableSlots()\cleanParams
        *c\VTableSlots()\returnType = *parent\VTableSlots()\returnType
        *c\VTableSlots()\isAbstract = *parent\VTableSlots()\isAbstract
        *c\VTableSlots()\paramCount = *parent\VTableSlots()\paramCount
        *c\VTableSlots()\minParamCount = *parent\VTableSlots()\minParamCount
        *c\VTableSlots()\srcLineNumber = *parent\VTableSlots()\srcLineNumber
        *c\VTableSlots()\srcFile = *parent\VTableSlots()\srcFile
      Next
      PopListPosition(Classes())
    EndIf

    ; Process methods declared in current class
    ForEach *c\Methods()
      Protected *m.OOP_Method = @*c\Methods()
      
      ; Constructors and Private methods do not go into VTable
      If *m\visibility = "Private" Or UCase(*m\name) = "INIT"
        Continue
      EndIf

      ; Check if overriding an existing VTable slot (matching baseMethodName AND signature)
      Protected isOverridden.b = #False
      ForEach *c\VTableSlots()
        If UCase(*c\VTableSlots()\baseMethodName) = UCase(*m\name) And *c\VTableSlots()\signature = *m\signature
          *c\VTableSlots()\implementingClass = *c\fullName
          *c\VTableSlots()\isAbstract = *m\isAbstract
          *c\VTableSlots()\methodName = *m\mangledMethodName
          *m\isOverride = #True
          isOverridden = #True
          Break
        EndIf
      Next

      ; If not overriding, append new VTable slot
      If Not isOverridden
        AddElement(*c\VTableSlots())
        *c\VTableSlots()\methodName = *m\mangledMethodName
        *c\VTableSlots()\baseMethodName = *m\name
        *c\VTableSlots()\signature = *m\signature
        *c\VTableSlots()\implementingClass = *c\fullName
        *c\VTableSlots()\declaringClass = *c\fullName
        *c\VTableSlots()\params = *m\params
        *c\VTableSlots()\cleanParams = *m\cleanParams
        *c\VTableSlots()\returnType = *m\returnType
        *c\VTableSlots()\isAbstract = *m\isAbstract
        *c\VTableSlots()\paramCount = *m\paramCount
        *c\VTableSlots()\minParamCount = *m\minParamCount
        *c\VTableSlots()\srcLineNumber = *m\srcLineNumber
        *c\VTableSlots()\srcFile = *m\srcFile
      EndIf
    Next


    ; Inherit Free if not explicitly defined
    If Not *c\hasFree And *c\parentName <> ""
      Protected curP.s = *c\fullParentName
      While curP <> ""
        If FindMapElement(ClassMap(), UCase(curP))
          PushListPosition(Classes())
          SelectElement(Classes(), ClassMap(UCase(curP)))
          If Classes()\hasFree
            *c\hasFree = #True
            *c\freeClassMangled = Classes()\freeClassMangled
            PopListPosition(Classes())
            Break
          EndIf
          curP = Classes()\fullParentName
          PopListPosition(Classes())
        Else
          Break
        EndIf
      Wend
    EndIf
  Next

  ; Step 3: Align MethodBodies with mangled names
  ForEach MethodBodies()
    Protected *b.OOP_MethodBody = @MethodBodies()
    If FindMapElement(ClassMap(), UCase(*b\className))
      PushListPosition(Classes())
      SelectElement(Classes(), ClassMap(UCase(*b\className)))
      If UCase(*b\methodName) = "INIT"
        If ListSize(Classes()\InitConstructors()) > 1
          *b\mangledMethodName = "Init_" + *b\signature
        Else
          *b\mangledMethodName = "Init"
        EndIf
      Else
        ForEach Classes()\Methods()
          If UCase(Classes()\Methods()\name) = UCase(*b\methodName) And Classes()\Methods()\signature = *b\signature
            *b\mangledMethodName = Classes()\Methods()\mangledMethodName
            Break
          EndIf
        Next
      EndIf
      PopListPosition(Classes())
    EndIf
  Next

  ProcedureReturn #True
EndProcedure

Procedure.b ValidateOOPModel()
  ; 1. Check that concrete classes implement all abstract methods
  ForEach Classes()
    Protected *c.OOP_Class = @Classes()
    If Not *c\isAbstract
      ForEach *c\VTableSlots()
        If *c\VTableSlots()\isAbstract
          Protected hasImpl.b = #False
          ForEach MethodBodies()
            If MethodBodies()\className = *c\fullName And UCase(MethodBodies()\mangledMethodName) = UCase(*c\VTableSlots()\methodName)
              hasImpl = #True
              Break
            EndIf
          Next
          If Not hasImpl
            SetOOPError(*c\srcLineNumber, "Class '" + *c\fullName + "' must implement abstract method '" + *c\VTableSlots()\baseMethodName + "' declared in abstract class '" + *c\VTableSlots()\declaringClass + "' (or be declared Abstract Class).")
            ProcedureReturn #False
          EndIf
        EndIf
      Next
    EndIf
  Next

  ; 2. Check that abstract classes are not instantiated in MainLines
  ForEach Classes()
    If Classes()\isAbstract
      Protected absFull.s = Classes()\fullName
      Protected absShort.s = Classes()\name
      Protected absUpperFull.s = UCase(absFull)
      Protected absUpperShort.s = UCase(absShort)

      ForEach MainLines()
        Protected mLine.s = MainLines()\content
        Protected upLine.s = UCase(mLine)
        If FindString(upLine, "NEW " + absUpperFull + "(") > 0 Or FindString(upLine, "NEW " + absUpperShort + "(") > 0 Or FindString(upLine, "NEW(" + absUpperFull + ")") > 0 Or FindString(upLine, "NEW(" + absUpperShort + ")") > 0
          SetOOPError(MainLines()\srcLineNumber, "Cannot instantiate abstract class '" + absFull + "'")
          ProcedureReturn #False
        EndIf
      Next
    EndIf
  Next

  ; 3. Check Super:: calls in method bodies
  ForEach MethodBodies()
    Protected *body.OOP_MethodBody = @MethodBodies()
    Protected parentClsName.s = ""
    If FindMapElement(ClassMap(), UCase(*body\className))
      SelectElement(Classes(), ClassMap(UCase(*body\className)))
      parentClsName = Classes()\parentName
    EndIf

    ForEach *body\BodyLines()
      Protected bLine.s = *body\BodyLines()\content
      Protected pSup.i = FindString(bLine, "Super::")
      If pSup = 0
        pSup = FindString(bLine, "Super\")
      EndIf
      If pSup > 0
        If parentClsName = ""
          SetOOPError(*body\BodyLines()\srcLineNumber, "Cannot call 'Super::' in Class '" + *body\className + "' because it does not inherit from any class")
          ProcedureReturn #False
        EndIf
      EndIf
    Next
  Next

  ProcedureReturn #True
EndProcedure

; ----------------------------------------------------------------------------
; Code Generation Phase: Emit PureBasic Code & Source Map
; ----------------------------------------------------------------------------

Declare.s TranspileMainLine(line.s)

; Resolves overloaded method calls on object instances: *obj\Method(args) -> *obj\Method_sig(args)
Procedure.s ResolveOverloadedMethodCalls(line.s)
  Protected res.s = line
  If MapSize(OverloadedMethodNames()) = 0 : ProcedureReturn res : EndIf

  ForEach OverloadedMethodNames()
    Protected mName.s = MapKey(OverloadedMethodNames())
    Protected searchPattern.s = "\" + mName + "("
    Protected pCall.i = FindString(UCase(res), searchPattern)
    
    While pCall > 0
      ; Find matching closing parenthesis
      Protected pOpen.i = pCall + Len(searchPattern) - 1
      Protected i.i, depth.i = 1, inQuote.b = #False
      Protected pClose.i = 0
      Protected lenR.i = Len(res)
      
      For i = pOpen + 1 To lenR
        Protected ch.s = Mid(res, i, 1)
        If ch = Chr(34)
          inQuote = ~inQuote & 1
        ElseIf ch = "(" And Not inQuote
          depth + 1
        ElseIf ch = ")" And Not inQuote
          depth - 1
          If depth = 0
            pClose = i
            Break
          EndIf
        EndIf
      Next

      If pClose > pOpen
        Protected argList.s = Trim(Mid(res, pOpen + 1, pClose - pOpen - 1))
        Protected argCount.i = 0
        Protected callSig.s = GetCallArgSignature(argList, argCount)
        
        ; Find best matching VTableSlot across classes
        Protected bestMangled.s = ""
        PushListPosition(Classes())
        ForEach Classes()
          ForEach Classes()\VTableSlots()
            If UCase(Classes()\VTableSlots()\baseMethodName) = mName
              ; Exact signature match
              If Classes()\VTableSlots()\signature = callSig
                bestMangled = Classes()\VTableSlots()\methodName
                Break 2
              ; Arity match
              ElseIf Classes()\VTableSlots()\paramCount = argCount
                bestMangled = Classes()\VTableSlots()\methodName
              EndIf
            EndIf
          Next
        Next
        PopListPosition(Classes())

        If bestMangled <> ""
          res = Left(res, pCall) + bestMangled + "(" + Mid(res, pOpen + 1)
        EndIf
      EndIf

      pCall = FindString(UCase(res), searchPattern, pCall + Len(searchPattern))
    Wend
  Next

  ProcedureReturn res
EndProcedure

Procedure.s TranspileMethodBodyLine(line.s, className.s, parentMangledName.s)
  Protected res.s = line
  
  ; 1. Replace Super::Method(args) with Parent_Method(*This, args)
  If parentMangledName <> ""
    Protected pSuper.i = FindString(res, "Super::")
    If pSuper = 0
      pSuper = FindString(res, "Super\")
    EndIf
    While pSuper > 0
      Protected sepLen.i = 7
      If Mid(res, pSuper, 6) = "Super\"
        sepLen = 6
      EndIf

      Protected pParenOpen.i = FindString(res, "(", pSuper)
      If pParenOpen > pSuper
        Protected superMethod.s = Trim(Mid(res, pSuper + sepLen, pParenOpen - (pSuper + sepLen)))
        Protected pClose.i = 0
        Protected i.i, depth.i = 1, inQuote.b = #False
        Protected lenR.i = Len(res)
        
        For i = pParenOpen + 1 To lenR
          Protected ch.s = Mid(res, i, 1)
          If ch = Chr(34)
            inQuote = ~inQuote & 1
          ElseIf ch = "(" And Not inQuote
            depth + 1
          ElseIf ch = ")" And Not inQuote
            depth - 1
            If depth = 0
              pClose = i
              Break
            EndIf
          EndIf
        Next

        If pClose > pParenOpen
          Protected superArgList.s = Trim(Mid(res, pParenOpen + 1, pClose - pParenOpen - 1))
          Protected callTarget.s = ""
          
          Protected foundParent.b = #False
          PushListPosition(Classes())
          ForEach Classes()
            If Classes()\mangledName = parentMangledName
              foundParent = #True
              Break
            EndIf
          Next
          
          If foundParent
            If UCase(superMethod) = "INIT"
              If ListSize(Classes()\InitConstructors()) > 1
                Protected argCount.i = 0
                Protected callSig.s = GetCallArgSignature(superArgList, @argCount)
                Protected bestMatch.s = ""
                ForEach Classes()\InitConstructors()
                  If Classes()\InitConstructors()\signature = callSig
                    bestMatch = Classes()\InitConstructors()\initProcMangled
                    Break
                  ElseIf argCount >= Classes()\InitConstructors()\minParamCount And argCount <= Classes()\InitConstructors()\paramCount
                    bestMatch = Classes()\InitConstructors()\initProcMangled
                  EndIf
                Next
                If bestMatch <> ""
                  callTarget = bestMatch
                Else
                  FirstElement(Classes()\InitConstructors())
                  callTarget = Classes()\InitConstructors()\initProcMangled
                EndIf
              ElseIf ListSize(Classes()\InitConstructors()) = 1
                FirstElement(Classes()\InitConstructors())
                callTarget = Classes()\InitConstructors()\initProcMangled
              Else
                callTarget = parentMangledName + "_Init"
              EndIf
            Else
              ; Method overloading check on parent
              Protected mCount.i = 0
              ForEach Classes()\Methods()
                If UCase(Classes()\Methods()\name) = UCase(superMethod)
                  mCount + 1
                EndIf
              Next
              If mCount > 1
                Protected mArgCount.i = 0
                Protected mCallSig.s = GetCallArgSignature(superArgList, @mArgCount)
                ForEach Classes()\Methods()
                  If UCase(Classes()\Methods()\name) = UCase(superMethod) And Classes()\Methods()\signature = mCallSig
                    callTarget = parentMangledName + "_" + Classes()\Methods()\mangledMethodName
                    Break
                  EndIf
                Next
                If callTarget = ""
                  callTarget = parentMangledName + "_" + superMethod
                EndIf
              Else
                callTarget = parentMangledName + "_" + superMethod
              EndIf
            EndIf
          Else
            callTarget = parentMangledName + "_" + superMethod
          EndIf
          PopListPosition(Classes())
          
          Protected beforeSuper.s = Left(res, pSuper - 1)
          Protected afterClose.s = Mid(res, pClose + 1)
          
          If superArgList = ""
            res = beforeSuper + callTarget + "(*This)" + afterClose
          Else
            res = beforeSuper + callTarget + "(*This, " + superArgList + ")" + afterClose
          EndIf
        Else
          Break
        EndIf
      Else
        Break
      EndIf
      pSuper = FindString(res, "Super::")
      If pSuper = 0
        pSuper = FindString(res, "Super\")
      EndIf
    Wend
  EndIf

  res = TranspileMainLine(res)

  ; 2. Replace This\Method(args) with *This_vt\Method(args)
  If FindMapElement(ClassMap(), UCase(className))
    PushListPosition(Classes())
    SelectElement(Classes(), ClassMap(UCase(className)))
    ForEach Classes()\VTableSlots()
      Protected mSlotName.s = Classes()\VTableSlots()\methodName
      If mSlotName <> ""
        res = ReplaceString(res, "This\" + mSlotName + "(", "*This_vt\" + mSlotName + "(")
        res = ReplaceString(res, "*This\" + mSlotName + "(", "*This_vt\" + mSlotName + "(")
      EndIf
    Next
    PopListPosition(Classes())
  EndIf

  ; 3. Replace remaining 'This' with '*This'
  res = ReplaceWord(res, "This", "*This")
  res = ReplaceString(res, "*This\*", "*This\")
  res = ReplaceString(res, "*This_vt\*", "*This_vt\")
  
  ProcedureReturn res
EndProcedure

; Resolves 'New ClassName(args)' expressions to correct constructor factory
Procedure.s ResolveNewExpressions(line.s)
  Protected res.s = line
  
  PushListPosition(Classes())
  ForEach Classes()
    Protected cFull.s = Classes()\fullName
    Protected cShort.s = Classes()\name
    Protected cMangled.s = Classes()\mangledName
    Protected isMultiInit.b = Bool(ListSize(Classes()\InitConstructors()) > 1)
    
    Protected NewList searchPrefixes.s()
    AddElement(searchPrefixes()) : searchPrefixes() = "New " + cFull + "("
    AddElement(searchPrefixes()) : searchPrefixes() = "New  " + cFull + "("
    AddElement(searchPrefixes()) : searchPrefixes() = "New(" + cFull + ")"
    AddElement(searchPrefixes()) : searchPrefixes() = "New(" + cFull + ","
    
    If cShort <> cFull
      AddElement(searchPrefixes()) : searchPrefixes() = "New " + cShort + "("
      AddElement(searchPrefixes()) : searchPrefixes() = "New  " + cShort + "("
      AddElement(searchPrefixes()) : searchPrefixes() = "New(" + cShort + ")"
      AddElement(searchPrefixes()) : searchPrefixes() = "New(" + cShort + ","
    EndIf
    
    ForEach searchPrefixes()
      Protected prefix.s = searchPrefixes()
      Protected pNew.i = FindString(res, prefix)
      
      While pNew > 0
        Protected pOpen.i = FindString(res, "(", pNew)
        If pOpen > 0
          Protected pClose.i = 0
          Protected i.i, depth.i = 1, inQuote.b = #False
          Protected lenR.i = Len(res)
          
          For i = pOpen + 1 To lenR
            Protected ch.s = Mid(res, i, 1)
            If ch = Chr(34)
              inQuote = ~inQuote & 1
            ElseIf ch = "(" And Not inQuote
              depth + 1
            ElseIf ch = ")" And Not inQuote
              depth - 1
              If depth = 0
                pClose = i
                Break
              EndIf
            EndIf
          Next
          
          If pClose > pOpen
            Protected argList.s = Trim(Mid(res, pOpen + 1, pClose - pOpen - 1))
            If Left(prefix, 4) = "New(" And FindString(prefix, ",") > 0
              Protected pFirstComma.i = FindString(argList, ",")
              If pFirstComma > 0
                argList = Trim(Mid(argList, pFirstComma + 1))
              EndIf
            EndIf
            Protected argCount.i = 0
            Protected callSig.s = GetCallArgSignature(argList, @argCount)
            Protected chosenFactory.s = "New_" + cMangled
            
            If isMultiInit
              Protected bestMatch.s = ""
              ForEach Classes()\InitConstructors()
                If Classes()\InitConstructors()\signature = callSig
                  bestMatch = Classes()\InitConstructors()\mangledName
                  Break
                ElseIf argCount >= Classes()\InitConstructors()\minParamCount And argCount <= Classes()\InitConstructors()\paramCount
                  bestMatch = Classes()\InitConstructors()\mangledName
                EndIf
              Next
              If bestMatch <> ""
                chosenFactory = bestMatch
              Else
                FirstElement(Classes()\InitConstructors())
                chosenFactory = Classes()\InitConstructors()\mangledName
              EndIf
            EndIf
            
            Protected beforeNew.s = Left(res, pNew - 1)
            Protected afterClose.s = Mid(res, pClose + 1)
            res = beforeNew + chosenFactory + "(" + argList + ")" + afterClose
            pNew = FindString(res, prefix, pNew + Len(chosenFactory) + 1)
            Continue
          EndIf
        EndIf
        pNew = FindString(res, prefix, pNew + Len(prefix))
      Wend
    Next
  Next
  PopListPosition(Classes())
  
  ProcedureReturn res
EndProcedure

Procedure.s TranspileMainLine(line.s)
  Protected res.s = line
  
  ; 0. Resolve Overloaded Method Calls (e.g. *m\Additionner(10, 20) -> *m\Additionner_i_i(10, 20))
  res = ResolveOverloadedMethodCalls(res)

  ; 1. Resolve Constructors (New Class(...) -> New_Class_sig(...))
  res = ResolveNewExpressions(res)

  ; 1.5 Support standalone 'Free(*obj)' syntax
  Protected trimmedForFree.s = Trim(res)
  If Left(trimmedForFree, 5) = "Free(" Or Left(trimmedForFree, 6) = "Free (" Or (Left(trimmedForFree, 5) = "Free " And FindString(trimmedForFree, "*") > 0)
    res = ReplaceWord(res, "Free", "FreeStructure")
  EndIf

  PushListPosition(Classes())
  ForEach Classes()
    Protected cFull.s = Classes()\fullName
    Protected cShort.s = Classes()\name
    Protected cMangled.s = Classes()\mangledName
    
    ; Type annotations (.ClassName -> .ClassName_vt)
    res = ReplaceString(res, "." + cFull + " ", "." + cMangled + "_vt ")
    res = ReplaceString(res, "." + cFull + "=", "." + cMangled + "_vt =")
    res = ReplaceString(res, "." + cFull + ",", "." + cMangled + "_vt,")
    res = ReplaceString(res, "." + cFull + ")", "." + cMangled + "_vt)")
    res = ReplaceString(res, "." + cFull + "(", "." + cMangled + "_vt(")
    res = ReplaceString(res, "." + cFull + "\", "." + cMangled + "_vt\")
    If Right(res, Len("." + cFull)) = "." + cFull
      res = Left(res, Len(res) - Len("." + cFull)) + "." + cMangled + "_vt"
    EndIf

    ; Check Alias references
    ForEach NamespaceAliases()
      Protected aKey.s = MapKey(NamespaceAliases())
      Protected aTarget.s = NamespaceAliases()
      If Classes()\namespace = aTarget
        Protected aFull.s = aKey + "::" + cShort
        res = ReplaceString(res, "New " + aFull + "(", "New_" + cMangled + "(")
        res = ReplaceString(res, "New(" + aFull + ",", "New_" + cMangled + "(")
        res = ReplaceString(res, "New(" + aFull + ")", "New_" + cMangled + "()")
        res = ReplaceString(res, "." + aFull + " ", "." + cMangled + "_vt ")
        res = ReplaceString(res, "." + aFull + "=", "." + cMangled + "_vt =")
        res = ReplaceString(res, "." + aFull + ",", "." + cMangled + "_vt,")
        res = ReplaceString(res, "." + aFull + ")", "." + cMangled + "_vt)")
      EndIf
    Next

    ; Replace ShortName if in UsingList or root
    Protected canUseShort.b = #False
    If Classes()\namespace = ""
      canUseShort = #True
    Else
      ForEach UsingList()
        If UCase(UsingList()) = UCase(Classes()\namespace)
          canUseShort = #True
          Break
        EndIf
      Next
    EndIf

    If canUseShort
      res = ReplaceString(res, "New(" + cShort + ",", "New_" + cMangled + "(")
      res = ReplaceString(res, "New(" + cShort + ")", "New_" + cMangled + "()")
      res = ReplaceString(res, "New( " + cShort + ",", "New_" + cMangled + "(")
      res = ReplaceString(res, "New( " + cShort + " )", "New_" + cMangled + "()")
      res = ReplaceString(res, "New " + cShort + "(", "New_" + cMangled + "(")
      res = ReplaceString(res, "New  " + cShort + "(", "New_" + cMangled + "(")
      
      res = ReplaceString(res, "." + cShort + " ", "." + cMangled + "_vt ")
      res = ReplaceString(res, "." + cShort + "=", "." + cMangled + "_vt =")
      res = ReplaceString(res, "." + cShort + ",", "." + cMangled + "_vt,")
      res = ReplaceString(res, "." + cShort + ")", "." + cMangled + "_vt)")
      res = ReplaceString(res, "." + cShort + "(", "." + cMangled + "_vt(")
      res = ReplaceString(res, "." + cShort + "\", "." + cMangled + "_vt\")
      If Right(res, Len("." + cShort)) = "." + cShort
        res = Left(res, Len(res) - Len("." + cShort)) + "." + cMangled + "_vt"
      EndIf
    EndIf
  Next
  PopListPosition(Classes())
  
  res = ReplaceString(res, "::", "_")
  
  ProcedureReturn res
EndProcedure

Procedure EmitLine(content.s, srcLine.i = 0, srcFile.s = "")
  AddElement(GeneratedLines())
  GeneratedLines()\content = content
  GeneratedLines()\srcLineNumber = srcLine
  GeneratedLines()\srcFile = srcFile
EndProcedure

Procedure.b GenerateTargetPB(outputFile.s, inputPBO.s)
  ClearList(GeneratedLines())

  EmitLine("; ============================================================================")
  EmitLine("; Generated by PureBasic OOP Transpiler (Native OOP Engine - ALPHA 1.2)")
  EmitLine("; Do not edit directly - modify the corresponding .pbo source file.")
  EmitLine("; ============================================================================")
  EmitLine("")
  EmitLine("EnableExplicit")
  EmitLine("")

  ; 0.5 Generate Top-Level Type Declarations (Structures, Enums, Constants, Macros)
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("; 0.5 GLOBAL TYPE DECLARATIONS, STRUCTURES & CONSTANTS")
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("")
  ForEach TypeDeclarations()
    EmitLine(TranspileMainLine(TypeDeclarations()\content), TypeDeclarations()\srcLineNumber, TypeDeclarations()\srcFile)
  Next
  EmitLine("")

  ; 1. Generate Interfaces
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("; 1. PUREBASIC INTERFACES (VTABLE PROTOTYPES)")
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("")

  ForEach Classes()
    Protected *c.OOP_Class = @Classes()
    If *c\mangledParentName <> ""
      EmitLine("Interface " + *c\mangledName + "_vt Extends " + *c\mangledParentName + "_vt", *c\srcLineNumber, *c\srcFile)
    Else
      EmitLine("Interface " + *c\mangledName + "_vt", *c\srcLineNumber, *c\srcFile)
    EndIf

    ForEach *c\Methods()
      Protected *m.OOP_Method = @*c\Methods()
      If *m\visibility <> "Private" And UCase(*m\name) <> "INIT"
        If *c\mangledParentName = "" Or Not *m\isOverride
          EmitLine("  " + *m\mangledMethodName + *m\returnType + "(" + TranspileMainLine(*m\cleanParams) + ")", *m\srcLineNumber, *m\srcFile)
        EndIf
      EndIf
    Next

    EmitLine("EndInterface")
    EmitLine("")
  Next

  ; 2. Generate Instance Structures
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("; 2. INSTANCE STRUCTURES")
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("")

  ForEach Classes()
    *c = @Classes()
    If *c\mangledParentName <> ""
      EmitLine("Structure " + *c\mangledName + "_Inst Extends " + *c\mangledParentName + "_Inst", *c\srcLineNumber, *c\srcFile)
    Else
      EmitLine("Structure " + *c\mangledName + "_Inst", *c\srcLineNumber, *c\srcFile)
      EmitLine("  *VTable." + *c\mangledName + "_vt")
    EndIf

    ForEach *c\Fields()
      Protected fDecl.s = *c\Fields()\name
      Protected numItems.i = CountString(fDecl, ",") + 1
      Protected fIdx.i
      For fIdx = 1 To numItems
        Protected item.s = Trim(StringField(fDecl, fIdx, ","))
        If item <> ""
          EmitLine("  " + TranspileMainLine(item), *c\Fields()\srcLineNumber, *c\Fields()\srcFile)
        EndIf
      Next
    Next

    EmitLine("EndStructure")
    EmitLine("")
  Next

  ; 2.5 Generate Global Variables, Maps, Lists & Declarations
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("; 2.5 GLOBAL VARIABLES, MAPS, LISTS & FORWARD DECLARATIONS")
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("")
  ForEach HeaderDeclarations()
    EmitLine(TranspileMainLine(HeaderDeclarations()\content), HeaderDeclarations()\srcLineNumber, HeaderDeclarations()\srcFile)
  Next
  EmitLine("")

  ; 3. Generate Method Procedures (Forward Declares & Implementations)
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("; 3. METHOD PROCEDURES IMPLEMENTATION")
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("")

  ForEach MethodBodies()
    Protected *b.OOP_MethodBody = @MethodBodies()
    Protected pDecl.s = ""
    If *b\cleanParams <> ""
      pDecl = "*This." + *b\mangledClassName + "_Inst, " + TranspileMainLine(*b\cleanParams)
    Else
      pDecl = "*This." + *b\mangledClassName + "_Inst"
    EndIf

    EmitLine("Declare" + *b\returnType + " " + *b\mangledClassName + "_" + *b\mangledMethodName + "(" + pDecl + ")", *b\srcLineNumber, *b\srcFile)
  Next
  EmitLine("")

  ; Constructors & Free forward declarations
  ForEach Classes()
    *c = @Classes()
    If Not *c\isAbstract
      If ListSize(*c\InitConstructors()) > 1
        ForEach *c\InitConstructors()
          If *c\InitConstructors()\cleanParams <> ""
            EmitLine("Declare.i " + *c\InitConstructors()\mangledName + "(" + TranspileMainLine(*c\InitConstructors()\cleanParams) + ")", *c\srcLineNumber, *c\srcFile)
          Else
            EmitLine("Declare.i " + *c\InitConstructors()\mangledName + "()", *c\srcLineNumber, *c\srcFile)
          EndIf
        Next
      ElseIf ListSize(*c\InitConstructors()) = 1
        FirstElement(*c\InitConstructors())
        If *c\InitConstructors()\cleanParams <> ""
          EmitLine("Declare.i " + *c\InitConstructors()\mangledName + "(" + TranspileMainLine(*c\InitConstructors()\cleanParams) + ")", *c\srcLineNumber, *c\srcFile)
        Else
          EmitLine("Declare.i " + *c\InitConstructors()\mangledName + "()", *c\srcLineNumber, *c\srcFile)
        EndIf
      Else
        EmitLine("Declare.i New_" + *c\mangledName + "()", *c\srcLineNumber, *c\srcFile)
      EndIf
      EmitLine("Declare Free_" + *c\mangledName + "(*obj." + *c\mangledName + "_Inst)", *c\srcLineNumber, *c\srcFile)
    EndIf
  Next
  EmitLine("")

  ; Method Procedures Bodies
  ForEach MethodBodies()
    *b = @MethodBodies()
    If *b\cleanParams <> ""
      pDecl = "*This." + *b\mangledClassName + "_Inst, " + TranspileMainLine(*b\cleanParams)
    Else
      pDecl = "*This." + *b\mangledClassName + "_Inst"
    EndIf

    EmitLine("Procedure" + *b\returnType + " " + *b\mangledClassName + "_" + *b\mangledMethodName + "(" + pDecl + ")", *b\srcLineNumber, *b\srcFile)
    EmitLine("  Protected *This_vt." + *b\mangledClassName + "_vt = *This", *b\srcLineNumber, *b\srcFile)
    
    Protected parentMangled.s = ""
    If FindMapElement(ClassMap(), UCase(*b\className))
      PushListPosition(Classes())
      SelectElement(Classes(), ClassMap(UCase(*b\className)))
      parentMangled = Classes()\mangledParentName
      PopListPosition(Classes())
    EndIf

    ForEach *b\BodyLines()
      Protected transformedLine.s = TranspileMethodBodyLine(*b\BodyLines()\content, *b\className, parentMangled)
      EmitLine("  " + transformedLine, *b\BodyLines()\srcLineNumber, *b\BodyLines()\srcFile)
    Next

    EmitLine("EndProcedure")
    EmitLine("")
  Next

  ; 4. Generate VTables DataSections
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("; 4. VTABLE DATASECTIONS (DYNAMIC DISPATCH)")
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("")

  EmitLine("DataSection")
  ForEach Classes()
    *c = @Classes()
    If Not *c\isAbstract
      EmitLine("  " + *c\mangledName + "_VTable_Data:", *c\srcLineNumber, *c\srcFile)
      ForEach *c\VTableSlots()
        Protected slotImpl.s = *c\VTableSlots()\implementingClass
        Protected slotMangled.s = MangleIdentifier(slotImpl)
        EmitLine("    Data.i @" + slotMangled + "_" + *c\VTableSlots()\methodName + "()", *c\VTableSlots()\srcLineNumber, *c\VTableSlots()\srcFile)
      Next
    EndIf
  Next
  EmitLine("EndDataSection")
  EmitLine("")

  ; 5. Generate Constructors & Destructors
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("; 5. CONSTRUCTORS & FACTORY FUNCTIONS")
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("")

  ForEach Classes()
    *c = @Classes()
    If Not *c\isAbstract
      If ListSize(*c\InitConstructors()) > 0
        ForEach *c\InitConstructors()
          Protected initArgDecl.s = TranspileMainLine(*c\InitConstructors()\cleanParams)
          Protected initArgPass.s = ""
          If initArgDecl <> ""
            Protected pCount.i = CountString(initArgDecl, ",") + 1
            Protected pIdx.i
            For pIdx = 1 To pCount
              Protected paramToken.s = Trim(StringField(initArgDecl, pIdx, ","))
              Protected pDot.i = FindString(paramToken, ".")
              If pDot > 0
                paramToken = Left(paramToken, pDot - 1)
              EndIf
              If initArgPass = ""
                initArgPass = paramToken
              Else
                initArgPass + ", " + paramToken
              EndIf
            Next
          EndIf

          If initArgDecl <> ""
            EmitLine("Procedure.i " + *c\InitConstructors()\mangledName + "(" + initArgDecl + ")", *c\srcLineNumber, *c\srcFile)
          Else
            EmitLine("Procedure.i " + *c\InitConstructors()\mangledName + "()", *c\srcLineNumber, *c\srcFile)
          EndIf
          
          EmitLine("  Protected *obj." + *c\mangledName + "_Inst = AllocateStructure(" + *c\mangledName + "_Inst)", *c\srcLineNumber, *c\srcFile)
          EmitLine("  If *obj", *c\srcLineNumber, *c\srcFile)
          EmitLine("    *obj\VTable = ?" + *c\mangledName + "_VTable_Data", *c\srcLineNumber, *c\srcFile)
          If initArgPass <> ""
            EmitLine("    " + *c\InitConstructors()\initProcMangled + "(*obj, " + initArgPass + ")", *c\srcLineNumber, *c\srcFile)
          Else
            EmitLine("    " + *c\InitConstructors()\initProcMangled + "(*obj)", *c\srcLineNumber, *c\srcFile)
          EndIf
          EmitLine("  EndIf", *c\srcLineNumber, *c\srcFile)
          EmitLine("  ProcedureReturn *obj", *c\srcLineNumber, *c\srcFile)
          EmitLine("EndProcedure")
          EmitLine("")
        Next
      Else
        ; Default parameterless constructor
        EmitLine("Procedure.i New_" + *c\mangledName + "()", *c\srcLineNumber, *c\srcFile)
        EmitLine("  Protected *obj." + *c\mangledName + "_Inst = AllocateStructure(" + *c\mangledName + "_Inst)", *c\srcLineNumber, *c\srcFile)
        EmitLine("  If *obj", *c\srcLineNumber, *c\srcFile)
        EmitLine("    *obj\VTable = ?" + *c\mangledName + "_VTable_Data", *c\srcLineNumber, *c\srcFile)
        EmitLine("  EndIf", *c\srcLineNumber, *c\srcFile)
        EmitLine("  ProcedureReturn *obj", *c\srcLineNumber, *c\srcFile)
        EmitLine("EndProcedure")
        EmitLine("")
      EndIf

      ; Free wrapper
      EmitLine("Procedure Free_" + *c\mangledName + "(*obj." + *c\mangledName + "_Inst)", *c\srcLineNumber, *c\srcFile)
      EmitLine("  If *obj", *c\srcLineNumber, *c\srcFile)
      If *c\hasFree
        Protected callFreeMangled.s = *c\mangledName
        If *c\freeClassMangled <> ""
          callFreeMangled = *c\freeClassMangled
        EndIf
        EmitLine("    " + callFreeMangled + "_Free(*obj)", *c\srcLineNumber, *c\srcFile)
      EndIf
      EmitLine("    FreeStructure(*obj)", *c\srcLineNumber, *c\srcFile)
      EmitLine("  EndIf", *c\srcLineNumber, *c\srcFile)
      EmitLine("EndProcedure")
      EmitLine("")
    EndIf
  Next

  ; 6. Generate Main Program Execution
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("; 6. MAIN PROGRAM EXECUTION")
  EmitLine("; " + RSet("", 76, "-"))
  EmitLine("")

  ForEach MainLines()
    Protected transpiledMain.s = TranspileMainLine(MainLines()\content)
    EmitLine(transpiledMain, MainLines()\srcLineNumber, MainLines()\srcFile)
  Next

  ; Write output file
  Protected outFile = CreateFile(#PB_Any, outputFile)
  If Not outFile
    SetOOPError(1, "Cannot create output file: " + outputFile)
    ProcedureReturn #False
  EndIf
  WriteStringFormat(outFile, #PB_UTF8)

  ; Write .map file
  Protected mapFile.s = outputFile + ".map"
  Protected fMap = CreateFile(#PB_Any, mapFile)
  If fMap
    WriteStringFormat(fMap, #PB_UTF8)
    WriteStringN(fMap, "# PBO_SOURCEMAP_V1", #PB_UTF8)
    WriteStringN(fMap, "SOURCE:" + inputPBO, #PB_UTF8)
    WriteStringN(fMap, "TARGET:" + outputFile, #PB_UTF8)
    WriteStringN(fMap, "MAP:", #PB_UTF8)
  EndIf

  Protected genLineNum.i = 0
  ForEach GeneratedLines()
    genLineNum + 1
    WriteStringN(outFile, GeneratedLines()\content, #PB_UTF8)
    If fMap And GeneratedLines()\srcLineNumber > 0
      WriteStringN(fMap, Str(genLineNum) + ":" + Str(GeneratedLines()\srcLineNumber), #PB_UTF8)
    EndIf
  Next

  CloseFile(outFile)
  If fMap : CloseFile(fMap) : EndIf

  ProcedureReturn #True
EndProcedure

; ----------------------------------------------------------------------------
; Transpiler Orchestration
; ----------------------------------------------------------------------------

Procedure.b TranspileSourceFile(inputFile.s, outputFile.s)
  If Not ParsePBO(inputFile)
    ProcedureReturn #False
  EndIf

  If Not BuildVTables()
    ProcedureReturn #False
  EndIf

  If Not ValidateOOPModel()
    ProcedureReturn #False
  EndIf

  If Not GenerateTargetPB(outputFile, inputFile)
    ProcedureReturn #False
  EndIf

  ProcedureReturn #True
EndProcedure

Procedure.b CheckSourceFileSyntax(inputFile.s)
  If Not ParsePBO(inputFile)
    ProcedureReturn #False
  EndIf

  If Not BuildVTables()
    ProcedureReturn #False
  EndIf

  If Not ValidateOOPModel()
    ProcedureReturn #False
  EndIf

  ProcedureReturn #True
EndProcedure

; ----------------------------------------------------------------------------
; Main Entry Point (CLI)
Procedure.i Main()
  OpenConsole()

  Protected argCount.i = CountProgramParameters()
  Protected i.i = 0
  Protected checkMode.b = #False
  Protected checkFile.s = ""
  Protected inputPBO.s = ""
  Protected outputPB.s = ""
  
  While i < argCount
    Protected param.s = ProgramParameter(i)
    If UCase(param) = "--BASE-DIR" Or UCase(param) = "-B"
      i + 1
      If i < argCount
        BaseDirectory = ProgramParameter(i)
        If BaseDirectory <> "" And Right(BaseDirectory, 1) <> "\"
          BaseDirectory + "\"
        EndIf
      EndIf
    ElseIf UCase(param) = "--CHECK" Or UCase(param) = "-C" Or UCase(param) = "/CHECK"
      checkMode = #True
      i + 1
      If i < argCount
        checkFile = ProgramParameter(i)
      EndIf
    Else
      If inputPBO = ""
        inputPBO = param
      ElseIf outputPB = ""
        outputPB = param
      EndIf
    EndIf
    i + 1
  Wend

  If checkMode
    If checkFile = "" : checkFile = inputPBO : EndIf
    If checkFile = ""
      PrintN("[ERROR] Missing filename for --check")
      CloseConsole()
      ProcedureReturn 1
    EndIf
    If CheckSourceFileSyntax(checkFile)
      PrintN("[OK]")
      CloseConsole()
      ProcedureReturn 0
    Else
      CloseConsole()
      ProcedureReturn 1
    EndIf
  EndIf

  If inputPBO = ""
    inputPBO = "../src/test_overloading.pbo"
    outputPB = "../src/test_overloading_generated.pb"
  EndIf

  If outputPB = ""
    outputPB = ReplaceString(inputPBO, ".pbo", "_generated.pb", #PB_String_NoCase)
  EndIf
  PrintN("=================================================================")
  PrintN("   PureBasic OOP Transpiler (Native Engine) - ALPHA 1.2 (Overload)")
  PrintN("=================================================================")
  PrintN("Input  PBO : " + inputPBO)
  PrintN("Output PB  : " + outputPB)
  If BaseDirectory <> ""
    PrintN("Base Dir   : " + BaseDirectory)
  EndIf
  PrintN("")

  If Not TranspileSourceFile(inputPBO, outputPB)
    PrintN("[ERROR] Transpilation failed for file: " + inputPBO)
    CloseConsole()
    ProcedureReturn 1
  EndIf

  PrintN("[INFO] Parsed " + Str(ListSize(Classes())) + " classes, " + Str(ListSize(MethodBodies())) + " method implementations.")
  PrintN("[SUCCESS] Successfully transpiled to: " + outputPB)
  PrintN("=================================================================")
  CloseConsole()
  ProcedureReturn 0
EndProcedure

End Main()
