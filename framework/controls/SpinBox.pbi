; ============================================================================
; PureBasic OOP GUI Framework - SpinBox.pbi
; Numeric Up/Down Spinner (SpinGadget) wrapper
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "../Gadget.pbi"
XIncludeFile "../Application.pbi"

Namespace UI {

  Class SpinBox Extends Gadget {
    Protected minVal.i
    Protected maxVal.i

    ; Constructeur 0: Par defaut (0..100, 0,0, 100x25)
    Public Method Init() {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = 100 : This\height = 25
      This\desiredWidth = 100 : This\desiredHeight = 25
      This\isVisible = #True : This\isEnabled = #True
      This\minVal = 0 : This\maxVal = 100
      This\id = SpinGadget(#PB_Any, 0, 0, 100, 25, 0, 100, #PB_Spin_Numeric)
      If (This\id) {
        SetGadgetState(This\id, 0)
        SetGadgetText(This\id, "0")
        UI::RegisterGadget(This\id, This)
      }
    }

    ; Constructeur 1: Min et Max
    Public Method Init(min_p.i, max_p.i) {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = 100 : This\height = 25
      This\desiredWidth = 100 : This\desiredHeight = 25
      This\isVisible = #True : This\isEnabled = #True
      This\minVal = min_p : This\maxVal = max_p
      This\id = SpinGadget(#PB_Any, 0, 0, 100, 25, min_p, max_p, #PB_Spin_Numeric)
      If (This\id) {
        SetGadgetState(This\id, min_p)
        SetGadgetText(This\id, Str(min_p))
        UI::RegisterGadget(This\id, This)
      }
    }

    ; Constructeur 2: Min, Max et valeur initiale (100x25 par defaut)
    Public Method Init(min_p.i, max_p.i, current_p.i) {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = 100 : This\height = 25
      This\desiredWidth = 100 : This\desiredHeight = 25
      This\isVisible = #True : This\isEnabled = #True
      This\minVal = min_p : This\maxVal = max_p
      This\id = SpinGadget(#PB_Any, 0, 0, 100, 25, min_p, max_p, #PB_Spin_Numeric)
      If (This\id) {
        SetGadgetState(This\id, current_p)
        SetGadgetText(This\id, Str(current_p))
        UI::RegisterGadget(This\id, This)
      }
    }

    ; Constructeur 3: Min, Max, valeur initiale et dimensions
    Public Method Init(min_p.i, max_p.i, current_p.i, w_p.i, h_p.i) {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\isVisible = #True : This\isEnabled = #True
      This\minVal = min_p : This\maxVal = max_p
      This\id = SpinGadget(#PB_Any, 0, 0, w_p, h_p, min_p, max_p, #PB_Spin_Numeric)
      If (This\id) {
        SetGadgetState(This\id, current_p)
        SetGadgetText(This\id, Str(current_p))
        UI::RegisterGadget(This\id, This)
      }
    }

    Public Method.i GetValue() {
      If (This\id And IsGadget(This\id)) {
        ProcedureReturn GetGadgetState(This\id)
      }
      ProcedureReturn 0
    }

    Public Method SetValue(val_p.i) {
      If (This\id And IsGadget(This\id)) {
        SetGadgetState(This\id, val_p)
        SetGadgetText(This\id, Str(val_p))
      }
    }

    Public Method.i GetMin() {
      ProcedureReturn This\minVal
    }

    Public Method.i GetMax() {
      ProcedureReturn This\maxVal
    }

    Public Method SetRange(min_p.i, max_p.i) {
      This\minVal = min_p : This\maxVal = max_p
      If (This\id And IsGadget(This\id)) {
        SetGadgetAttribute(This\id, #PB_Spin_Minimum, min_p)
        SetGadgetAttribute(This\id, #PB_Spin_Maximum, max_p)
      }
    }

    Public Method Free() {
      If (This\id) {
        UI::UnregisterGadget(This\id)
        Super\Free()
      }
    }
  }

}
