; ============================================================================
; PureBasic OOP GUI Framework - ObservableObject.pbi
; Property Change Notification Subsystem (INotifyPropertyChanged equivalent)
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "../Component.pbi"

Structure UI_PropertyObserver
  *observer
  *callback
EndStructure

Namespace MVVM {

  Class ObservableObject {
    Protected Map propStrings.s()
    Protected Map propInts.i()
    Protected Map propBools.b()
    Protected Map propFloats.d()
    Protected List observers.UI_PropertyObserver()

    Public Method Init() {
    }

    Public Method Free() {
      ClearMap(This\propStrings())
      ClearMap(This\propInts())
      ClearMap(This\propBools())
      ClearMap(This\propFloats())
      ClearList(This\observers())
    }

    ; ------------------------------------------------------------------------
    ; Observer Registration
    ; ------------------------------------------------------------------------
    Public Method RegisterObserver(*observer, *cb) {
      If *observer And *cb
        ; Check if already registered
        ForEach This\observers()
          If This\observers()\observer = *observer
            This\observers()\callback = *cb
            ProcedureReturn
          EndIf
        Next

        AddElement(This\observers())
        This\observers()\observer = *observer
        This\observers()\callback = *cb
      EndIf
    }

    Public Method UnregisterObserver(*observer) {
      If *observer
        ForEach This\observers()
          If This\observers()\observer = *observer
            DeleteElement(This\observers())
            Break
          EndIf
        Next
      EndIf
    }

    Public Method NotifyPropertyChanged(propName.s) {
      Protected pKey.s = LCase(propName)
      ForEach This\observers()
        If This\observers()\callback
          CallFunctionFast(This\observers()\callback, This, @pKey)
        EndIf
      Next
    }

    ; ------------------------------------------------------------------------
    ; Universal & Short Get / Set Methods
    ; ------------------------------------------------------------------------
    Public Method.s Get(propName.s) {
      ProcedureReturn This\GetValueAsString(propName)
    }

    Public Method.b Set(propName.s, val.s) {
      ProcedureReturn This\SetString(propName, val)
    }

    Public Method.b Set(propName.s, val.i) {
      ProcedureReturn This\SetInt(propName, val)
    }

    Public Method.b Set(propName.s, val.b) {
      ProcedureReturn This\SetBool(propName, val)
    }

    Public Method.b Set(propName.s, val.d) {
      ProcedureReturn This\SetDouble(propName, val)
    }

    ; ------------------------------------------------------------------------
    ; String Properties
    ; ------------------------------------------------------------------------
    Public Method.s GetString(propName.s) {
      Protected pKey.s = LCase(propName)
      If FindMapElement(This\propStrings(), pKey)
        ProcedureReturn This\propStrings()
      EndIf
      ProcedureReturn ""
    }

    Public Method.b SetString(propName.s, val.s) {
      Protected pKey.s = LCase(propName)
      If FindMapElement(This\propStrings(), pKey)
        If This\propStrings() = val
          ProcedureReturn #False ; No change
        EndIf
      EndIf
      This\propStrings(pKey) = val
      This\NotifyPropertyChanged(propName)
      ProcedureReturn #True
    }

    ; ------------------------------------------------------------------------
    ; Integer Properties
    ; ------------------------------------------------------------------------
    Public Method.i GetInt(propName.s) {
      Protected pKey.s = LCase(propName)
      If FindMapElement(This\propInts(), pKey)
        ProcedureReturn This\propInts()
      EndIf
      ProcedureReturn 0
    }

    Public Method.b SetInt(propName.s, val.i) {
      Protected pKey.s = LCase(propName)
      If FindMapElement(This\propInts(), pKey)
        If This\propInts() = val
          ProcedureReturn #False ; No change
        EndIf
      EndIf
      This\propInts(pKey) = val
      This\NotifyPropertyChanged(propName)
      ProcedureReturn #True
    }

    ; ------------------------------------------------------------------------
    ; Boolean Properties
    ; ------------------------------------------------------------------------
    Public Method.b GetBool(propName.s) {
      Protected pKey.s = LCase(propName)
      If FindMapElement(This\propBools(), pKey)
        ProcedureReturn This\propBools()
      EndIf
      ProcedureReturn #False
    }

    Public Method.b SetBool(propName.s, val.b) {
      Protected pKey.s = LCase(propName)
      If FindMapElement(This\propBools(), pKey)
        If This\propBools() = val
          ProcedureReturn #False ; No change
        EndIf
      EndIf
      This\propBools(pKey) = val
      This\NotifyPropertyChanged(propName)
      ProcedureReturn #True
    }

    ; ------------------------------------------------------------------------
    ; Double / Float Properties
    ; ------------------------------------------------------------------------
    Public Method.d GetDouble(propName.s) {
      Protected pKey.s = LCase(propName)
      If FindMapElement(This\propFloats(), pKey)
        ProcedureReturn This\propFloats()
      EndIf
      ProcedureReturn 0.0
    }

    Public Method.b SetDouble(propName.s, val.d) {
      Protected pKey.s = LCase(propName)
      If FindMapElement(This\propFloats(), pKey)
        If This\propFloats() = val
          ProcedureReturn #False ; No change
        EndIf
      EndIf
      This\propFloats(pKey) = val
      This\NotifyPropertyChanged(propName)
      ProcedureReturn #True
    }

    ; ------------------------------------------------------------------------
    ; Generic String-based accessor for binding engine
    ; ------------------------------------------------------------------------
    Public Method.s GetValueAsString(propName.s) {
      Protected pKey.s = LCase(propName)
      If FindMapElement(This\propStrings(), pKey)
        ProcedureReturn This\propStrings()
      ElseIf FindMapElement(This\propInts(), pKey)
        ProcedureReturn Str(This\propInts())
      ElseIf FindMapElement(This\propBools(), pKey)
        If This\propBools()
          ProcedureReturn "true"
        Else
          ProcedureReturn "false"
        EndIf
      ElseIf FindMapElement(This\propFloats(), pKey)
        ProcedureReturn StrD(This\propFloats())
      EndIf
      ProcedureReturn ""
    }

    Public Method SetValueFromString(propName.s, valStr.s) {
      Protected pKey.s = LCase(propName)
      If FindMapElement(This\propInts(), pKey)
        This\SetInt(propName, Val(valStr))
      ElseIf FindMapElement(This\propBools(), pKey)
        Protected bVal.b = #False
        Protected uStr.s = UCase(Trim(valStr))
        If uStr = "TRUE" Or uStr = "1" : bVal = #True : EndIf
        This\SetBool(propName, bVal)
      ElseIf FindMapElement(This\propFloats(), pKey)
        This\SetDouble(propName, ValD(valStr))
      Else
        This\SetString(propName, valStr)
      EndIf
    }
  }

}
