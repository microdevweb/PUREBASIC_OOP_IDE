; ============================================================================
; PureBasic OOP GUI Framework - Gadget.pbi
; Base abstract class for all PureBasic UI Controls and Gadgets
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "Component.pbi"

Namespace UI {

  Abstract Class Gadget Extends Component {
    Protected tooltip.s
    Protected fontID.i

    Public Method Init() {
      Super\Init()
    }

    Public Method.s GetText() {
      If (This\id And IsGadget(This\id)) {
        ProcedureReturn GetGadgetText(This\id)
      }
      ProcedureReturn ""
    }

    Public Method SetText(t.s) {
      If (This\id And IsGadget(This\id)) {
        SetGadgetText(This\id, t)
      }
    }

    Public Method SetToolTip(tip.s) {
      This\tooltip = tip
      If (This\id And IsGadget(This\id)) {
        GadgetToolTip(This\id, tip)
      }
    }

    Public Method.s GetToolTip() {
      ProcedureReturn This\tooltip
    }

    Public Method SetPosition(nx.i, ny.i, nw.i, nh.i) {
      If nw < 0 : nw = 0 : EndIf
      If nh < 0 : nh = 0 : EndIf
      This\x = nx : This\y = ny : This\width = nw : This\height = nh
      If (This\id And IsGadget(This\id)) {
        ResizeGadget(This\id, nx, ny, nw, nh)
      }
    }

    Public Method SetVisible(v.b) {
      This\isVisible = v
      If (This\id And IsGadget(This\id)) {
        HideGadget(This\id, 1 - v)
      }
    }

    Public Method SetEnabled(e.b) {
      This\isEnabled = e
      If (This\id And IsGadget(This\id)) {
        DisableGadget(This\id, 1 - e)
      }
    }

    Public Method SetColor(colorType.i, color.i) {
      If (This\id And IsGadget(This\id)) {
        SetGadgetColor(This\id, colorType, color)
      }
    }

    Public Method.i GetColor(colorType.i) {
      If (This\id And IsGadget(This\id)) {
        ProcedureReturn GetGadgetColor(This\id, colorType)
      }
      ProcedureReturn -1
    }

    Public Method SetFont(font.i) {
      This\fontID = font
      If (This\id And IsGadget(This\id)) {
        SetGadgetFont(This\id, font)
      }
    }

    Public Method SetFocus() {
      If (This\id And IsGadget(This\id)) {
        SetActiveGadget(This\id)
      }
    }

    Public Method Free() {
      If (This\id And IsGadget(This\id)) {
        FreeGadget(This\id)
        This\id = 0
      }
    }

    ; Virtual Event Handlers (Can be overridden by child classes)
    Public Method OnClick() {
    }

    Public Method OnChange() {
    }

    Public Method OnFocus() {
    }

    Public Method OnLostFocus() {
    }

    Public Method OnRightClick() {
    }

    Public Method OnCustomEvent(eventType.i) {
    }
  }

}
