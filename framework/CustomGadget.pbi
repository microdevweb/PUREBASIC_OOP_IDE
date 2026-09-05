; ============================================================================
; PureBasic OOP GUI Framework - CustomGadget.pbi
; Base class for 2D Vector-rendered / Canvas Custom Gadgets
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "Gadget.pbi"
XIncludeFile "Application.pbi"

Namespace UI {

  Abstract Class CustomGadget Extends Gadget {
    Protected isHovered.b
    Protected isPressed.b
    Protected mouseX.i
    Protected mouseY.i

    ; Constructeur 1: Par défaut (Positionné par Layout 0,0, 100x30)
    Public Method Init() {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = 100 : This\height = 30
      This\desiredWidth = 100 : This\desiredHeight = 30
      This\isVisible = #True : This\isEnabled = #True
      This\isHovered = #False : This\isPressed = #False
      This\id = CanvasGadget(#PB_Any, 0, 0, 100, 30, #PB_Canvas_Keyboard)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
        This\Redraw()
      }
    }

    ; Constructeur 2: Dimensions personnalisées
    Public Method Init(w_p.i, h_p.i) {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\isVisible = #True : This\isEnabled = #True
      This\isHovered = #False : This\isPressed = #False
      This\id = CanvasGadget(#PB_Any, 0, 0, w_p, h_p, #PB_Canvas_Keyboard)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
        This\Redraw()
      }
    }

    ; Constructeur 3: Position et dimensions
    Public Method Init(x_p.i, y_p.i, w_p.i, h_p.i) {
      Super\Init()
      This\x = x_p : This\y = y_p : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\isVisible = #True : This\isEnabled = #True
      This\isHovered = #False : This\isPressed = #False
      This\id = CanvasGadget(#PB_Any, x_p, y_p, w_p, h_p, #PB_Canvas_Keyboard)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
        This\Redraw()
      }
    }

    ; Constructeur 4: Complet avec flags
    Public Method Init(x_p.i, y_p.i, w_p.i, h_p.i, flags_p.i) {
      Super\Init()
      This\x = x_p : This\y = y_p : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\isVisible = #True : This\isEnabled = #True
      This\isHovered = #False : This\isPressed = #False
      This\id = CanvasGadget(#PB_Any, x_p, y_p, w_p, h_p, flags_p | #PB_Canvas_Keyboard)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
        This\Redraw()
      }
    }

    Public Abstract Method OnPaint(w.i, h.i)

    Public Method Redraw() {
      If (This\id And IsGadget(This\id)) {
        If (StartDrawing(CanvasOutput(This\id))) {
          This\OnPaint(OutputWidth(), OutputHeight())
          StopDrawing()
        }
      }
    }

    Public Method OnMouseEnter() {
    }

    Public Method OnMouseLeave() {
    }

    Public Method OnMouseDown(mx.i, my.i, button.i) {
    }

    Public Method OnMouseUp(mx.i, my.i, button.i) {
    }

    Public Method OnMouseMove(mx.i, my.i) {
    }

    Public Method OnKeyDown(key.i) {
    }

    Public Method OnCustomEvent(eventType.i) {
      Select (eventType) {
        Case #PB_EventType_MouseEnter:
          This\isHovered = #True
          This\OnMouseEnter()
          This\Redraw()

        Case #PB_EventType_MouseLeave:
          This\isHovered = #False
          This\isPressed = #False
          This\OnMouseLeave()
          This\Redraw()

        Case #PB_EventType_LeftButtonDown:
          This\isPressed = #True
          This\mouseX = GetGadgetAttribute(This\id, #PB_Canvas_MouseX)
          This\mouseY = GetGadgetAttribute(This\id, #PB_Canvas_MouseY)
          This\OnMouseDown(This\mouseX, This\mouseY, 1)
          This\Redraw()

        Case #PB_EventType_LeftButtonUp:
          Protected wasPressed.b = This\isPressed
          This\isPressed = #False
          This\mouseX = GetGadgetAttribute(This\id, #PB_Canvas_MouseX)
          This\mouseY = GetGadgetAttribute(This\id, #PB_Canvas_MouseY)
          This\OnMouseUp(This\mouseX, This\mouseY, 1)
          If (wasPressed) {
            This\OnClick()
          }
          This\Redraw()

        Case #PB_EventType_MouseMove:
          This\mouseX = GetGadgetAttribute(This\id, #PB_Canvas_MouseX)
          This\mouseY = GetGadgetAttribute(This\id, #PB_Canvas_MouseY)
          This\OnMouseMove(This\mouseX, This\mouseY)
          This\Redraw()

        Case #PB_EventType_KeyDown:
          This\OnKeyDown(GetGadgetAttribute(This\id, #PB_Canvas_Key))
          This\Redraw()
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
