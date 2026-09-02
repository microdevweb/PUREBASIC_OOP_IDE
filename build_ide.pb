; ============================================================================
; Title:       build_ide.pb
; Description: Automated Build Engine for PureBasic OOP IDE (Version ALPHA 1.0)
; Author:      MicrodevWeb
; License:     GNU General Public License v3 (GPL v3)
; ============================================================================

EnableExplicit

Global PBCompilerPath.s = "C:\Program Files\PureBasic\Compilers\pbcompiler.exe"
Global RootPath.s = GetCurrentDirectory()
Global IDEPath.s = RootPath + "ide\"
Global BuildPath.s = IDEPath + "PureBasicIDE\Build\"

Procedure LogMsg(msg.s)
  PrintN("[BUILD] " + msg)
EndProcedure

Procedure RunCommandQuiet(cmd.s, args.s, workDir.s = "")
  Protected prg = RunProgram(cmd, args, workDir, #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
  If prg
    While ProgramRunning(prg)
      Protected out.s = ReadProgramString(prg)
      If out <> "" : PrintN("  " + out) : EndIf
    Wend
    Protected exitCode = ProgramExitCode(prg)
    CloseProgram(prg)
    ProcedureReturn exitCode
  EndIf
  ProcedureReturn -1
EndProcedure

OpenConsole("PureBasic OOP IDE Build Pipeline - ALPHA 1.0")
LogMsg("Starting PureBasic OOP IDE compilation pipeline (ALPHA 1.0)...")

; Check compiler availability
If FileSize(PBCompilerPath) <= 0
  ; Check environment variable
  Define envPB.s = GetEnvironmentVariable("PUREBASIC_HOME")
  If envPB <> ""
    If Right(envPB, 1) <> "\" And Right(envPB, 1) <> "/" : envPB + "\" : EndIf
    If FileSize(envPB + "Compilers\pbcompiler.exe") > 0
      PBCompilerPath = envPB + "Compilers\pbcompiler.exe"
    EndIf
  EndIf
EndIf

If FileSize(PBCompilerPath) <= 0
  LogMsg("ERROR: PureBasic compiler not found at: " + PBCompilerPath)
  LogMsg("Please set PUREBASIC_HOME or adjust the path in build_ide.pb.")
  PrintN("Press Enter to exit...")
  Input()
  End 1
EndIf

; 1. Build Transpiler
LogMsg("Compiling OOP Transpiler (compiler/transpiler.exe)...")
RunCommandQuiet(PBCompilerPath, Chr(34) + RootPath + "compiler\transpiler.pb" + Chr(34) + " /EXE " + Chr(34) + RootPath + "compiler\transpiler.exe" + Chr(34) + " /CONSOLE /QUIET")

; 2. Create Build directory if missing
If FileSize(BuildPath) <> -2
  CreateDirectory(BuildPath)
EndIf

; 3. Compile DialogCompiler
LogMsg("Compiling DialogCompiler...")
RunCommandQuiet(PBCompilerPath, Chr(34) + IDEPath + "DialogManager\DialogCompiler.pb" + Chr(34) + " /EXE " + Chr(34) + BuildPath + "DialogCompiler.exe" + Chr(34) + " /CONSOLE /QUIET")

; 4. Compile all XML dialogs
LogMsg("Generating dialog pb files from XML...")
Define dialogList.s = "Find;Grep;Goto;CompilerOptions;AddTools;About;Preferences;Templates;StructureViewer;Projects;Build;Diff;FileMonitor;History;HistoryShutdown;CreateApp;Updates"
Define i.i, dlgName.s
For i = 1 To CountString(dialogList, ";") + 1
  dlgName = StringField(dialogList, i, ";")
  RunCommandQuiet(BuildPath + "DialogCompiler.exe", Chr(34) + IDEPath + "PureBasicIDE\dialogs\" + dlgName + ".xml" + Chr(34) + " " + Chr(34) + BuildPath + dlgName + ".pb" + Chr(34))
Next

; 5. Compile makebuildinfo and generate BuildInfo.pb
LogMsg("Generating BuildInfo.pb...")
RunCommandQuiet(PBCompilerPath, Chr(34) + IDEPath + "PureBasicIDE\tools\makebuildinfo.pb" + Chr(34) + " /EXE " + Chr(34) + BuildPath + "makebuildinfo.exe" + Chr(34) + " /CONSOLE /QUIET")
RunCommandQuiet(BuildPath + "makebuildinfo.exe", Chr(34) + BuildPath + Chr(34), IDEPath + "PureBasicIDE")

; 6. Compile maketheme and package themes
LogMsg("Packaging official themes (DefaultTheme & SilkTheme)...")
RunCommandQuiet(PBCompilerPath, Chr(34) + IDEPath + "PureBasicIDE\tools\maketheme.pb" + Chr(34) + " /EXE " + Chr(34) + BuildPath + "maketheme.exe" + Chr(34) + " /CONSOLE /QUIET")
RunCommandQuiet(BuildPath + "maketheme.exe", Chr(34) + BuildPath + "DefaultTheme.zip" + Chr(34) + " " + Chr(34) + IDEPath + "PureBasicIDE\data\DefaultTheme" + Chr(34))
RunCommandQuiet(BuildPath + "maketheme.exe", Chr(34) + BuildPath + "SilkTheme.zip" + Chr(34) + " " + Chr(34) + IDEPath + "PureBasicIDE\data\SilkTheme" + Chr(34))

; 7. Compile the main PureBasic OOP IDE executable
LogMsg("Compiling final executable pbo_ide.exe...")
Define targetExe.s = RootPath + "pbo_ide.exe"
Define res = RunCommandQuiet(PBCompilerPath, Chr(34) + IDEPath + "PureBasicIDE\PureBasic.pb" + Chr(34) + " /EXE " + Chr(34) + targetExe + Chr(34) + " /THREAD /UNICODE /XP /USER /DPIAWARE /ICON " + Chr(34) + IDEPath + "PureBasicIDE\data\PBLogoBig.ico" + Chr(34), IDEPath + "PureBasicIDE")

If res = 0 And FileSize(targetExe) > 0
  LogMsg("SUCCESS! PureBasic OOP IDE successfully built at: " + targetExe)
Else
  LogMsg("ERROR: Failed to compile PureBasic OOP IDE.")
EndIf

LogMsg("Done.")
End 0