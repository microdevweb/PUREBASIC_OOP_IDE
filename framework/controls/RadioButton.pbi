; ============================================================================
; PureBasic OOP GUI Framework - RadioButton.pbi
; Radio / Option Button (OptionGadget) wrapper
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "../Gadget.pbi"
XIncludeFile "../Application.pbi"

Namespace UI {

  Class RadioButton Extends Gadget {
    Protected groupID.i

    ; Constructeur 0: Texte par defaut (0,0, 120x24)
    Public Method Init(text_p.s) {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = 120 : This\height = 24
      This\desiredWidth = 120 : This\desiredHeight = 24
      This\isVisible = #True : This\isEnabled = #True
      This\groupID = 0
      This\id = OptionGadget(#PB_Any, 0, 0, 120, 24, text_p)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
      }
    }

    ; Constructeur 1: Texte et etat coche
    Public Method Init(text_p.s, checked_p.b) {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = 120 : This\height = 24
      This\desiredWidth = 120 : This\desiredHeight = 24
      This\isVisible = #True : This\isEnabled = #True
      This\groupID = 0
      This\id = OptionGadget(#PB_Any, 0, 0, 120, 24, text_p)
      If (This\id) {
        SetGadgetState(This\id, checked_p)
        UI::RegisterGadget(This\id, This)
      }
    }

    ; Constructeur 2: Texte, dimensions et etat
    Public Method Init(text_p.s, w_p.i, h_p.i, checked_p.b = #False) {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\isVisible = #True : This\isEnabled = #True
      This\groupID = 0
      This\id = OptionGadget(#PB_Any, 0, 0, w_p, h_p, text_p)
      If (This\id) {
        SetGadgetState(This\id, checked_p)
        UI::RegisterGadget(This\id, This)
      }
    }

    ; Constructeur 3: Complet (x, y, w, h, texte, etat)
    Public Method Init(x_p.i, y_p.i, w_p.i, h_p.i, text_p.s, checked_p.b = #False) {
      Super\Init()
      This\x = x_p : This\y = y_p : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\isVisible = #True : This\isEnabled = #True
      This\groupID = 0
      This\id = OptionGadget(#PB_Any, x_p, y_p, w_p, h_p, text_p)
      If (This\id) {
        SetGadgetState(This\id, checked_p)
        UI::RegisterGadget(This\id, This)
      }
    }

    Public Method.b IsChecked() {
      If (This\id And IsGadget(This\id)) {
        ProcedureReturn GetGadgetState(This\id)
      }
      ProcedureReturn #False
    }

    Public Method SetChecked(state_p.b) {
      If (This\id And IsGadget(This\id)) {
        SetGadgetState(This\id, state_p)
      }
    }

    Public Method.i GetGroup() {
      ProcedureReturn This\groupID
    }

    Public Method SetGroup(grp.i) {
      This\groupID = grp
    }

    Public Method Free() {
      If (This\id) {
        UI::UnregisterGadget(This\id)
        Super\Free()
      }
    }
  }

}
