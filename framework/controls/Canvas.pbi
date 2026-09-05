; ============================================================================
; PureBasic OOP GUI Framework - Canvas.pbi
; Standard Canvas / CanvasGadget wrapper with Multi-Constructors
; ============================================================================

XIncludeFile "../Gadget.pbi"
XIncludeFile "../Application.pbi"

Namespace UI {

  Class Canvas Extends Gadget {

    ; Constructeur 1: Par défaut (positionné par Layout 0,0, 200x200)
    Public Method Init() {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = 200 : This\height = 200
      This\desiredWidth = 200 : This\desiredHeight = 200
      This\isVisible = #True : This\isEnabled = #True
      This\id = CanvasGadget(#PB_Any, 0, 0, 200, 200, #PB_Canvas_Keyboard | #PB_Canvas_ClipMouse)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
      }
    }

    ; Constructeur 2: Dimensions
    Public Method Init(w_p.i, h_p.i) {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\isVisible = #True : This\isEnabled = #True
      This\id = CanvasGadget(#PB_Any, 0, 0, w_p, h_p, #PB_Canvas_Keyboard | #PB_Canvas_ClipMouse)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
      }
    }

    ; Constructeur 3: Position et dimensions
    Public Method Init(x_p.i, y_p.i, w_p.i, h_p.i) {
      Super\Init()
      This\x = x_p : This\y = y_p : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\isVisible = #True : This\isEnabled = #True
      This\id = CanvasGadget(#PB_Any, x_p, y_p, w_p, h_p, #PB_Canvas_Keyboard | #PB_Canvas_ClipMouse)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
      }
    }

    ; Constructeur 4: Complet avec flags
    Public Method Init(x_p.i, y_p.i, w_p.i, h_p.i, flags_p.i) {
      Super\Init()
      This\x = x_p : This\y = y_p : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\isVisible = #True : This\isEnabled = #True
      This\id = CanvasGadget(#PB_Any, x_p, y_p, w_p, h_p, flags_p)
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
