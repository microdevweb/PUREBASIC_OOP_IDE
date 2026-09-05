; ============================================================================
; PureBasic OOP GUI Framework - RelayCommand.pbi
; Action and Execution Command Encapsulation (ICommand equivalent)
; Author:      MicrodevWeb
; ============================================================================

Namespace MVVM {

  Class RelayCommand {
    Protected *actionProc
    Protected *canExecuteProc

    Public Method Init(*action) {
      This\*actionProc = *action
      This\*canExecuteProc = 0
    }

    Public Method Init(*action, *canExec) {
      This\*actionProc = *action
      This\*canExecuteProc = *canExec
    }

    Public Method Free() {
      This\*actionProc = 0
      This\*canExecuteProc = 0
    }

    Public Method.b CanExecute(*param = 0) {
      If This\*canExecuteProc
        ProcedureReturn CallFunctionFast(This\*canExecuteProc, *param)
      EndIf
      ProcedureReturn #True
    }

    Public Method Execute(*param = 0) {
      If This\CanExecute(*param)
        If This\*actionProc
          CallFunctionFast(This\*actionProc, *param)
        EndIf
      EndIf
    }
  }

}

