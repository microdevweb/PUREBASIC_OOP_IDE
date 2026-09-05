; ============================================================================
; PureBasic OOP - Contextual Help System
; Dispatches F1 on OOP keywords and UI classes to dedicated HTML documentation
; Author:      MicrodevWeb
; ============================================================================

Procedure.s GetOOPHelpPage(Keyword.s)
  Protected kw.s = LCase(Trim(Keyword))
  
  ; Strip trailing punctuation or prefixes if any
  If Left(kw, 1) = "*" Or Left(kw, 1) = "#" Or Left(kw, 1) = "@"
    kw = Mid(kw, 2)
  EndIf
  
  Select kw
    ; OOP Keywords
    Case "class", "endclass", "abstract"
      ProcedureReturn "keywords/class.html"
      
    Case "method", "endmethod", "abstract method", "override"
      ProcedureReturn "keywords/method.html"
      
    Case "getter", "setter", "property", "endgetter", "endsetter", "endproperty"
      ProcedureReturn "keywords/properties.html"
      
    Case "extends", "super"
      ProcedureReturn "keywords/inheritance.html"
      
    Case "public", "protected", "private"
      ProcedureReturn "keywords/encapsulation.html"
      
    Case "new", "free", "init", "constructor", "destructor", "newobject", "freeobject"
      ProcedureReturn "keywords/lifecycle.html"
      
    Case "this", "cast", "typeof", "instanceof"
      ProcedureReturn "keywords/operators.html"
      
    ; UI Classes & Framework
    Case "application"
      ProcedureReturn "ui/application.html"
      
    Case "window"
      ProcedureReturn "ui/window.html"
      
    Case "gadget", "component", "customgadget"
      ProcedureReturn "ui/gadget.html"
      
    Case "button"
      ProcedureReturn "ui/button.html"
      
    Case "checkbox"
      ProcedureReturn "ui/checkbox.html"
      
    Case "combobox"
      ProcedureReturn "ui/combobox.html"
      
    Case "datepicker", "dategadget"
      ProcedureReturn "ui/datepicker.html"
      
    Case "editor", "editorgadget"
      ProcedureReturn "ui/editor.html"
      
    Case "groupbox", "framegadget"
      ProcedureReturn "ui/groupbox.html"
      
    Case "label", "textgadget"
      ProcedureReturn "ui/label.html"
      
    Case "listicon", "listicongadget"
      ProcedureReturn "ui/listicon.html"
      
    Case "listview", "listviewgadget"
      ProcedureReturn "ui/listview.html"
      
    Case "progressbar", "progressbargadget"
      ProcedureReturn "ui/progressbar.html"
      
    Case "radiobutton", "optiongadget"
      ProcedureReturn "ui/radiobutton.html"
      
    Case "slider", "trackbargadget"
      ProcedureReturn "ui/slider.html"
      
    Case "spinbox", "spingadget"
      ProcedureReturn "ui/spinbox.html"
      
    Case "tabcontrol", "panelgadget"
      ProcedureReturn "ui/tabcontrol.html"
      
    Case "textbox", "stringgadget"
      ProcedureReturn "ui/textbox.html"
      
    Case "toggleswitch"
      ProcedureReturn "ui/toggleswitch.html"
      
    Case "treeview", "treegadget"
      ProcedureReturn "ui/treeview.html"
      
    ; Responsive Layouts (WPF Style)
    Case "container"
      ProcedureReturn "ui/container.html"
      
    Case "stackpanel"
      ProcedureReturn "ui/stackpanel.html"
      
    Case "dockpanel"
      ProcedureReturn "ui/dockpanel.html"
      
    Case "grid"
      ProcedureReturn "ui/grid.html"
      
    ; MVVM Architecture & DataBinding
    Case "mvvm", "observableobject", "viewmodelbase", "stringproperty", "intproperty", "boolproperty", "doubleproperty", "bindingengine", "xmlloader", "binding"
      ProcedureReturn "ui/mvvm.html"
      
    Default
      ProcedureReturn ""
  EndSelect
EndProcedure

Procedure.i OpenOOPHelp(PageSubPath.s)
  Protected LangFolder.s = "en"
  If UCase(CurrentLanguage$) = "FRANCAIS"
    LangFolder = "fr"
  EndIf
  
  If PageSubPath = ""
    PageSubPath = "index.html"
  EndIf
  
  ; Look in workspace / executable directory
  Protected AppDir.s = GetPathPart(ProgramFilename())
  Protected DocFilePath.s = AppDir + "doc\html\" + LangFolder + "\" + ReplaceString(PageSubPath, "/", "\")
  
  ; Fallback check relative to current working directory
  If FileSize(DocFilePath) <= 0
    DocFilePath = GetCurrentDirectory() + "doc\html\" + LangFolder + "\" + ReplaceString(PageSubPath, "/", "\")
  EndIf
  
  ; Fallback check in parent directory
  If FileSize(DocFilePath) <= 0
    DocFilePath = GetPathPart(RTrim(AppDir, "\")) + "doc\html\" + LangFolder + "\" + ReplaceString(PageSubPath, "/", "\")
  EndIf
  
  If FileSize(DocFilePath) > 0
    RunProgram(DocFilePath)
    ProcedureReturn #True
  Else
    Protected FileUrl.s = "file:///" + ReplaceString(DocFilePath, "\", "/")
    RunProgram(FileUrl)
    ProcedureReturn #True
  EndIf
  
  ProcedureReturn #False
EndProcedure
