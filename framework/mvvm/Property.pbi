; ============================================================================
; PureBasic OOP GUI Framework - Property.pbi
; Strongly-Typed Observable Property wrappers for MVVM ViewModels
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "ObservableObject.pbi"

Namespace MVVM {

  ; --------------------------------------------------------------------------
  ; StringProperty
  ; --------------------------------------------------------------------------
  Class StringProperty {
    Protected *owner.MVVM::ObservableObject
    Protected name.s

    Public Method Init(*ownerObj.MVVM::ObservableObject, propName.s, initialVal.s = "") {
      This\*owner = *ownerObj
      This\name = propName
      If (This\*owner) {
        This\*owner\SetString(This\name, initialVal)
      }
    }

    Public Method.s Get() {
      If (This\*owner) {
        ProcedureReturn This\*owner\GetString(This\name)
      }
      ProcedureReturn ""
    }

    Public Method.s GetValue() {
      ProcedureReturn This\Get()
    }

    Public Method Set(val.s) {
      If (This\*owner) {
        This\*owner\SetString(This\name, val)
      }
    }

    Public Method SetValue(val.s) {
      This\Set(val)
    }

    Public Method.s ToString() {
      ProcedureReturn This\Get()
    }

    Public Method.s GetName() {
      ProcedureReturn This\name
    }
  }

  ; --------------------------------------------------------------------------
  ; IntProperty
  ; --------------------------------------------------------------------------
  Class IntProperty {
    Protected *owner.MVVM::ObservableObject
    Protected name.s

    Public Method Init(*ownerObj.MVVM::ObservableObject, propName.s, initialVal.i = 0) {
      This\*owner = *ownerObj
      This\name = propName
      If (This\*owner) {
        This\*owner\SetInt(This\name, initialVal)
      }
    }

    Public Method.i Get() {
      If (This\*owner) {
        ProcedureReturn This\*owner\GetInt(This\name)
      }
      ProcedureReturn 0
    }

    Public Method.i GetValue() {
      ProcedureReturn This\Get()
    }

    Public Method Set(val.i) {
      If (This\*owner) {
        This\*owner\SetInt(This\name, val)
      }
    }

    Public Method SetValue(val.i) {
      This\Set(val)
    }

    Public Method.s ToString() {
      ProcedureReturn Str(This\Get())
    }

    Public Method.s GetString() {
      ProcedureReturn Str(This\Get())
    }

    Public Method Increment() {
      This\Set(This\Get() + 1)
    }

    Public Method Increment(stepVal.i) {
      This\Set(This\Get() + stepVal)
    }

    Public Method Decrement() {
      This\Set(This\Get() - 1)
    }

    Public Method Decrement(stepVal.i) {
      This\Set(This\Get() - stepVal)
    }

    Public Method.s GetName() {
      ProcedureReturn This\name
    }
  }

  ; --------------------------------------------------------------------------
  ; BoolProperty
  ; --------------------------------------------------------------------------
  Class BoolProperty {
    Protected *owner.MVVM::ObservableObject
    Protected name.s

    Public Method Init(*ownerObj.MVVM::ObservableObject, propName.s, initialVal.b = #False) {
      This\*owner = *ownerObj
      This\name = propName
      If (This\*owner) {
        This\*owner\SetBool(This\name, initialVal)
      }
    }

    Public Method.b Get() {
      If (This\*owner) {
        ProcedureReturn This\*owner\GetBool(This\name)
      }
      ProcedureReturn #False
    }

    Public Method.b GetValue() {
      ProcedureReturn This\Get()
    }

    Public Method Set(val.b) {
      If (This\*owner) {
        This\*owner\SetBool(This\name, val)
      }
    }

    Public Method SetValue(val.b) {
      This\Set(val)
    }

    Public Method Toggle() {
      This\Set(1 - This\Get())
    }

    Public Method.s ToString() {
      If This\Get()
        ProcedureReturn "true"
      Else
        ProcedureReturn "false"
      EndIf
    }

    Public Method.s GetName() {
      ProcedureReturn This\name
    }
  }

  ; --------------------------------------------------------------------------
  ; DoubleProperty
  ; --------------------------------------------------------------------------
  Class DoubleProperty {
    Protected *owner.MVVM::ObservableObject
    Protected name.s

    Public Method Init(*ownerObj.MVVM::ObservableObject, propName.s, initialVal.d = 0.0) {
      This\*owner = *ownerObj
      This\name = propName
      If (This\*owner) {
        This\*owner\SetDouble(This\name, initialVal)
      }
    }

    Public Method.d Get() {
      If (This\*owner) {
        ProcedureReturn This\*owner\GetDouble(This\name)
      }
      ProcedureReturn 0.0
    }

    Public Method.d GetValue() {
      ProcedureReturn This\Get()
    }

    Public Method Set(val.d) {
      If (This\*owner) {
        This\*owner\SetDouble(This\name, val)
      }
    }

    Public Method SetValue(val.d) {
      This\Set(val)
    }

    Public Method.s ToString(nbDecimals.i = 2) {
      ProcedureReturn StrD(This\Get(), nbDecimals)
    }

    Public Method.s GetName() {
      ProcedureReturn This\name
    }
  }

}
