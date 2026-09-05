; ============================================================================
; PureBasic OOP GUI Framework - ViewModelBase.pbi
; Base Class for all Application ViewModels
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "ObservableObject.pbi"
XIncludeFile "RelayCommand.pbi"

Namespace MVVM {

  Class ViewModelBase Extends ObservableObject {
    Protected Map *commands.MVVM::RelayCommand()

    Public Method Init() {
      Super\Init()
    }

    Public Method Free() {
      ForEach This\*commands()
        If This\*commands()
          This\*commands()\Free()
        EndIf
      Next
      ClearMap(This\*commands())
      Super\Free()
    }

    ; ------------------------------------------------------------------------
    ; Command Management
    ; ------------------------------------------------------------------------
    Public Method RegisterCommand(name_p.s, *cmd.MVVM::RelayCommand) {
      If name_p <> "" And *cmd
        This\*commands(LCase(name_p)) = *cmd
      EndIf
    }

    Public Method.i GetCommand(name_p.s) {
      Protected cKey.s = LCase(name_p)
      If FindMapElement(This\*commands(), cKey)
        ProcedureReturn This\*commands()
      EndIf
      ProcedureReturn 0
    }

    Public Method.b ExecuteCommand(name_p.s, *param = 0) {
      Protected *cmd.MVVM::RelayCommand = This\GetCommand(name_p)
      If *cmd
        If *cmd\CanExecute(*param)
          *cmd\Execute(*param)
          ProcedureReturn #True
        EndIf
      EndIf
      ; Fallback to virtual OnCommand for zero-boilerplate command handling
      ProcedureReturn This\OnCommand(name_p, *param)
    }

    ; ------------------------------------------------------------------------
    ; Strongly-Typed Observable Property Helpers
    ; ------------------------------------------------------------------------
    Public Method.i BindString(name_p.s, initialVal.s = "") {
      Protected *p.MVVM::StringProperty = New MVVM::StringProperty(This, name_p, initialVal)
      ProcedureReturn *p
    }

    Public Method.i BindInt(name_p.s, initialVal.i = 0) {
      Protected *p.MVVM::IntProperty = New MVVM::IntProperty(This, name_p, initialVal)
      ProcedureReturn *p
    }

    Public Method.i BindBool(name_p.s, initialVal.b = #False) {
      Protected *p.MVVM::BoolProperty = New MVVM::BoolProperty(This, name_p, initialVal)
      ProcedureReturn *p
    }

    Public Method.i BindDouble(name_p.s, initialVal.d = 0.0) {
      Protected *p.MVVM::DoubleProperty = New MVVM::DoubleProperty(This, name_p, initialVal)
      ProcedureReturn *p
    }

    ; Aliases for convenience & compatibility
    Public Method.i RegisterString(name_p.s, initialVal.s = "") {
      ProcedureReturn This\BindString(name_p, initialVal)
    }

    Public Method.i RegisterInt(name_p.s, initialVal.i = 0) {
      ProcedureReturn This\BindInt(name_p, initialVal)
    }

    Public Method.i RegisterBool(name_p.s, initialVal.b = #False) {
      ProcedureReturn This\BindBool(name_p, initialVal)
    }

    Public Method.i RegisterDouble(name_p.s, initialVal.d = 0.0) {
      ProcedureReturn This\BindDouble(name_p, initialVal)
    }

    Public Method.b OnCommand(name_p.s, *param = 0) {
      ProcedureReturn #False
    }
  }

}
