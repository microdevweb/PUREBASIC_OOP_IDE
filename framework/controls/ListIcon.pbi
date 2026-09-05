; ============================================================================
; PureBasic OOP GUI Framework - ListIcon.pbi
; Standard ListIconGadget wrapper for tables and data grids
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "../Gadget.pbi"
XIncludeFile "../Application.pbi"

Namespace UI {

  Class ListIcon Extends Gadget {

    ; Constructor 1: Column title and column width (auto-positioned by layout)
    Public Method Init(title_p.s, colWidth_p.i) {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = 300 : This\height = 200
      This\desiredWidth = 300 : This\desiredHeight = 200
      This\isVisible = #True : This\isEnabled = #True
      This\id = ListIconGadget(#PB_Any, 0, 0, 300, 200, title_p, colWidth_p, #PB_ListIcon_FullRowSelect | #PB_ListIcon_AlwaysShowSelection)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
      }
    }

    ; Constructor 2: Column title, column width and custom flags
    Public Method Init(title_p.s, colWidth_p.i, flags_p.i) {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = 300 : This\height = 200
      This\desiredWidth = 300 : This\desiredHeight = 200
      This\isVisible = #True : This\isEnabled = #True
      This\id = ListIconGadget(#PB_Any, 0, 0, 300, 200, title_p, colWidth_p, flags_p)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
      }
    }

    ; Constructor 3: Position, dimensions, column title and width
    Public Method Init(x_p.i, y_p.i, w_p.i, h_p.i, title_p.s, colWidth_p.i) {
      Super\Init()
      This\x = x_p : This\y = y_p : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\isVisible = #True : This\isEnabled = #True
      This\id = ListIconGadget(#PB_Any, x_p, y_p, w_p, h_p, title_p, colWidth_p, #PB_ListIcon_FullRowSelect | #PB_ListIcon_AlwaysShowSelection)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
      }
    }

    ; Constructor 4: Full parameters
    Public Method Init(x_p.i, y_p.i, w_p.i, h_p.i, title_p.s, colWidth_p.i, flags_p.i) {
      Super\Init()
      This\x = x_p : This\y = y_p : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\isVisible = #True : This\isEnabled = #True
      This\id = ListIconGadget(#PB_Any, x_p, y_p, w_p, h_p, title_p, colWidth_p, flags_p)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
      }
    }

    Public Method AddColumn(pos.i, title.s, width.i) {
      If (This\id And IsGadget(This\id)) {
        AddGadgetColumn(This\id, pos, title, width)
      }
    }

    Public Method AddItem(pos.i, text.s, imgId.i = 0) {
      If (This\id And IsGadget(This\id)) {
        AddGadgetItem(This\id, pos, text, imgId)
      }
    }

    Public Method SetItemText(item.i, text.s, column.i = 0) {
      If (This\id And IsGadget(This\id)) {
        SetGadgetItemText(This\id, item, text, column)
      }
    }

    Public Method.s GetItemText(item.i, column.i = 0) {
      If (This\id And IsGadget(This\id)) {
        ProcedureReturn GetGadgetItemText(This\id, item, column)
      }
      ProcedureReturn ""
    }

    Public Method.i GetSelectedIndex() {
      If (This\id And IsGadget(This\id)) {
        ProcedureReturn GetGadgetState(This\id)
      }
      ProcedureReturn -1
    }

    Public Method SetSelectedIndex(index.i) {
      If (This\id And IsGadget(This\id)) {
        SetGadgetState(This\id, index)
      }
    }

    Public Method.i GetItemCount() {
      If (This\id And IsGadget(This\id)) {
        ProcedureReturn CountGadgetItems(This\id)
      }
      ProcedureReturn 0
    }

    Public Method RemoveItem(pos.i) {
      If (This\id And IsGadget(This\id)) {
        RemoveGadgetItem(This\id, pos)
      }
    }

    Public Method Clear() {
      If (This\id And IsGadget(This\id)) {
        ClearGadgetItems(This\id)
      }
    }

    Public Method SetItemData(item.i, value.i) {
      If (This\id And IsGadget(This\id)) {
        SetGadgetItemData(This\id, item, value)
      }
    }

    Public Method.i GetItemData(item.i) {
      If (This\id And IsGadget(This\id)) {
        ProcedureReturn GetGadgetItemData(This\id, item)
      }
      ProcedureReturn 0
    }

    Public Method Free() {
      If (This\id) {
        UI::UnregisterGadget(This\id)
        Super\Free()
      }
    }
  }

}
