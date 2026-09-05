; ============================================================================
; PureBasic OOP GUI Framework - GroupBox.pbi
; Frame / GroupBox (FrameGadget) wrapper
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "../Gadget.pbi"
XIncludeFile "../Application.pbi"

Namespace UI {

  Class GroupBox Extends Gadget {

    ; Constructeur 0: Titre par defaut (0,0, 200x150)
    Public Method Init(caption_p.s) {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = 200 : This\height = 150
      This\desiredWidth = 200 : This\desiredHeight = 150
      This\isVisible = #True : This\isEnabled = #True
      This\id = FrameGadget(#PB_Any, 0, 0, 200, 150, caption_p)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
      }
    }

    ; Constructeur 1: Titre et dimensions
    Public Method Init(caption_p.s, w_p.i, h_p.i) {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\isVisible = #True : This\isEnabled = #True
      This\id = FrameGadget(#PB_Any, 0, 0, w_p, h_p, caption_p)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
      }
    }

    ; Constructeur 2: Complet
    Public Method Init(x_p.i, y_p.i, w_p.i, h_p.i, caption_p.s, flags_p.i = 0) {
      Super\Init()
      This\x = x_p : This\y = y_p : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\isVisible = #True : This\isEnabled = #True
      This\id = FrameGadget(#PB_Any, x_p, y_p, w_p, h_p, caption_p, flags_p)
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
