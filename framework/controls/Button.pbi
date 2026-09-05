; ============================================================================
; PureBasic OOP GUI Framework - Button.pbi
; Standard Button and ImageButton wrapper with Multi-Constructors
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "../Gadget.pbi"
XIncludeFile "../Application.pbi"

Namespace UI {

  Class Button Extends Gadget {

    ; Constructeur 1: Texte seul (Positionné par Layout 0,0, 120x30)
    Public Method Init(text_p.s) {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = 120 : This\height = 30
      This\desiredWidth = 120 : This\desiredHeight = 30
      This\isVisible = #True : This\isEnabled = #True
      This\id = ButtonGadget(#PB_Any, 0, 0, 120, 30, text_p, 0)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
      }
    }

    ; Constructeur 2: Texte et dimensions
    Public Method Init(text_p.s, w_p.i, h_p.i) {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\isVisible = #True : This\isEnabled = #True
      This\id = ButtonGadget(#PB_Any, 0, 0, w_p, h_p, text_p, 0)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
      }
    }

    ; Constructeur 3: Position, dimensions et texte
    Public Method Init(x_p.i, y_p.i, w_p.i, h_p.i, text_p.s) {
      Super\Init()
      This\x = x_p : This\y = y_p : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\isVisible = #True : This\isEnabled = #True
      This\id = ButtonGadget(#PB_Any, x_p, y_p, w_p, h_p, text_p, 0)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
      }
    }

    ; Constructeur 4: Complet
    Public Method Init(x_p.i, y_p.i, w_p.i, h_p.i, text_p.s, flags_p.i) {
      Super\Init()
      This\x = x_p : This\y = y_p : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\isVisible = #True : This\isEnabled = #True
      This\id = ButtonGadget(#PB_Any, x_p, y_p, w_p, h_p, text_p, flags_p)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
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
