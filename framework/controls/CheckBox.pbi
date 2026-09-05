; ============================================================================
; PureBasic OOP GUI Framework - CheckBox.pbi
; Standard CheckBox wrapper with Multi-Constructors
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "../Gadget.pbi"
XIncludeFile "../Application.pbi"

Namespace UI {

  Class CheckBox Extends Gadget {

    ; Constructeur 1: Texte seul (Positionné par Layout 0,0, 150x25)
    Public Method Init(text_p.s) {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = 150 : This\height = 25
      This\desiredWidth = 150 : This\desiredHeight = 25
      This\isVisible = #True : This\isEnabled = #True
      This\id = CheckBoxGadget(#PB_Any, 0, 0, 150, 25, text_p, 0)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
      }
    }

    ; Constructeur 2: Texte et état coché
    Public Method Init(text_p.s, checked_p.b) {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = 150 : This\height = 25
      This\desiredWidth = 150 : This\desiredHeight = 25
      This\isVisible = #True : This\isEnabled = #True
      This\id = CheckBoxGadget(#PB_Any, 0, 0, 150, 25, text_p, 0)
      If (This\id) {
        SetGadgetState(This\id, checked_p)
        UI::RegisterGadget(This\id, This)
      }
    }

    ; Constructeur 3: Texte, dimensions et état coché
    Public Method Init(text_p.s, w_p.i, h_p.i, checked_p.b) {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\isVisible = #True : This\isEnabled = #True
      This\id = CheckBoxGadget(#PB_Any, 0, 0, w_p, h_p, text_p, 0)
      If (This\id) {
        SetGadgetState(This\id, checked_p)
        UI::RegisterGadget(This\id, This)
      }
    }

    ; Constructeur 4: Complet avec position et flags
    Public Method Init(x_p.i, y_p.i, w_p.i, h_p.i, text_p.s, flags_p.i) {
      Super\Init()
      This\x = x_p : This\y = y_p : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\isVisible = #True : This\isEnabled = #True
      This\id = CheckBoxGadget(#PB_Any, x_p, y_p, w_p, h_p, text_p, flags_p)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
      }
    }

    Public Method.b IsChecked() {
      If (This\id And IsGadget(This\id)) {
        ProcedureReturn GetGadgetState(This\id)
      }
      ProcedureReturn #False
    }

    Public Method SetChecked(checked.b) {
      If (This\id And IsGadget(This\id)) {
        SetGadgetState(This\id, checked)
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
