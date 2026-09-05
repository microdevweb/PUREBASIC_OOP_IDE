; ============================================================================
; PureBasic OOP GUI Framework - Slider.pbi
; Standard TrackBar / TrackSlider wrapper with Multi-Constructors
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "../Gadget.pbi"
XIncludeFile "../Application.pbi"

Namespace UI {

  Class Slider Extends Gadget {
    Protected minVal.i
    Protected maxVal.i

    ; Constructeur 1: Par défaut 0..100 (Positionné par Layout 0,0, 200x25)
    Public Method Init() {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = 200 : This\height = 25
      This\desiredWidth = 200 : This\desiredHeight = 25
      This\minVal = 0 : This\maxVal = 100
      This\isVisible = #True : This\isEnabled = #True
      This\id = TrackBarGadget(#PB_Any, 0, 0, 200, 25, 0, 100, 0)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
      }
    }

    ; Constructeur 2: Min et Max spécifiés
    Public Method Init(min_p.i, max_p.i) {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = 200 : This\height = 25
      This\desiredWidth = 200 : This\desiredHeight = 25
      This\minVal = min_p : This\maxVal = max_p
      This\isVisible = #True : This\isEnabled = #True
      This\id = TrackBarGadget(#PB_Any, 0, 0, 200, 25, min_p, max_p, 0)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
      }
    }

    ; Constructeur 3: Min, Max et dimensions
    Public Method Init(min_p.i, max_p.i, w_p.i, h_p.i) {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\minVal = min_p : This\maxVal = max_p
      This\isVisible = #True : This\isEnabled = #True
      This\id = TrackBarGadget(#PB_Any, 0, 0, w_p, h_p, min_p, max_p, 0)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
      }
    }

    ; Constructeur 4: Complet avec position et flags
    Public Method Init(x_p.i, y_p.i, w_p.i, h_p.i, min_p.i, max_p.i, flags_p.i) {
      Super\Init()
      This\x = x_p : This\y = y_p : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\minVal = min_p : This\maxVal = max_p
      This\isVisible = #True : This\isEnabled = #True
      This\id = TrackBarGadget(#PB_Any, x_p, y_p, w_p, h_p, min_p, max_p, flags_p)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
      }
    }

    Public Method.i GetValue() {
      If (This\id And IsGadget(This\id)) {
        ProcedureReturn GetGadgetState(This\id)
      }
      ProcedureReturn 0
    }

    Public Method SetValue(v.i) {
      If (This\id And IsGadget(This\id)) {
        SetGadgetState(This\id, v)
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
