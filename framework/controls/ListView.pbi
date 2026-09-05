; ============================================================================
; PureBasic OOP GUI Framework - ListView.pbi
; Simple ListBox / ListViewGadget wrapper
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "../Gadget.pbi"
XIncludeFile "../Application.pbi"

Namespace UI {

  Class ListView Extends Gadget {

    ; Constructeur 0: Par defaut (0,0, 180x140)
    Public Method Init() {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = 180 : This\height = 140
      This\desiredWidth = 180 : This\desiredHeight = 140
      This\isVisible = #True : This\isEnabled = #True
      This\id = ListViewGadget(#PB_Any, 0, 0, 180, 140, 0)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
      }
    }

    ; Constructeur 1: Dimensions
    Public Method Init(w_p.i, h_p.i) {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\isVisible = #True : This\isEnabled = #True
      This\id = ListViewGadget(#PB_Any, 0, 0, w_p, h_p, 0)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
      }
    }

    ; Constructeur 2: Complet
    Public Method Init(x_p.i, y_p.i, w_p.i, h_p.i, flags_p.i = 0) {
      Super\Init()
      This\x = x_p : This\y = y_p : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\isVisible = #True : This\isEnabled = #True
      This\id = ListViewGadget(#PB_Any, x_p, y_p, w_p, h_p, flags_p)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
      }
    }

    Public Method AddItem(text_p.s) {
      If (This\id And IsGadget(This\id)) {
        AddGadgetItem(This\id, -1, text_p)
      }
    }

    Public Method InsertItem(pos_p.i, text_p.s) {
      If (This\id And IsGadget(This\id)) {
        AddGadgetItem(This\id, pos_p, text_p)
      }
    }

    Public Method RemoveItem(pos_p.i) {
      If (This\id And IsGadget(This\id)) {
        RemoveGadgetItem(This\id, pos_p)
      }
    }

    Public Method ClearItems() {
      If (This\id And IsGadget(This\id)) {
        ClearGadgetItems(This\id)
      }
    }

    Public Method.s GetItemText(pos_p.i) {
      If (This\id And IsGadget(This\id)) {
        ProcedureReturn GetGadgetItemText(This\id, pos_p)
      }
      ProcedureReturn ""
    }

    Public Method SetItemText(pos_p.i, text_p.s) {
      If (This\id And IsGadget(This\id)) {
        SetGadgetItemText(This\id, pos_p, text_p)
      }
    }

    Public Method.i GetItemCount() {
      If (This\id And IsGadget(This\id)) {
        ProcedureReturn CountGadgetItems(This\id)
      }
      ProcedureReturn 0
    }

    Public Method.i GetSelectedIndex() {
      If (This\id And IsGadget(This\id)) {
        ProcedureReturn GetGadgetState(This\id)
      }
      ProcedureReturn -1
    }

    Public Method SetSelectedIndex(idx_p.i) {
      If (This\id And IsGadget(This\id)) {
        SetGadgetState(This\id, idx_p)
      }
    }

    Public Method.s GetSelectedText() {
      Protected idx.i = This\GetSelectedIndex()
      If idx >= 0
        ProcedureReturn This\GetItemText(idx)
      EndIf
      ProcedureReturn ""
    }

    Public Method Free() {
      If (This\id) {
        UI::UnregisterGadget(This\id)
        Super\Free()
      }
    }
  }

}
