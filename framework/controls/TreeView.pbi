; ============================================================================
; PureBasic OOP GUI Framework - TreeView.pbi
; Hierarchical Tree (TreeGadget) wrapper
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "../Gadget.pbi"
XIncludeFile "../Application.pbi"

Namespace UI {

  Class TreeView Extends Gadget {

    ; Constructeur 0: Par defaut (0,0, 200x180)
    Public Method Init() {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = 200 : This\height = 180
      This\desiredWidth = 200 : This\desiredHeight = 180
      This\isVisible = #True : This\isEnabled = #True
      This\id = TreeGadget(#PB_Any, 0, 0, 200, 180, 0)
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
      This\id = TreeGadget(#PB_Any, 0, 0, w_p, h_p, 0)
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
      This\id = TreeGadget(#PB_Any, x_p, y_p, w_p, h_p, flags_p)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
      }
    }

    Public Method AddItem(text_p.s) {
      If (This\id And IsGadget(This\id)) {
        AddGadgetItem(This\id, -1, text_p, 0, 0)
      }
    }

    Public Method AddChildItem(text_p.s, subLevel_p.i) {
      If (This\id And IsGadget(This\id)) {
        AddGadgetItem(This\id, -1, text_p, 0, subLevel_p)
      }
    }

    Public Method InsertItem(pos_p.i, text_p.s, subLevel_p.i = 0) {
      If (This\id And IsGadget(This\id)) {
        AddGadgetItem(This\id, pos_p, text_p, 0, subLevel_p)
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

    Public Method.i GetItemSubLevel(pos_p.i) {
      If (This\id And IsGadget(This\id)) {
        ProcedureReturn GetGadgetAttribute(This\id, #PB_Tree_SubLevel)
      }
      ProcedureReturn 0
    }

    Public Method Expand(pos_p.i) {
      If (This\id And IsGadget(This\id)) {
        SetGadgetItemState(This\id, pos_p, #PB_Tree_Expanded)
      }
    }

    Public Method Collapse(pos_p.i) {
      If (This\id And IsGadget(This\id)) {
        SetGadgetItemState(This\id, pos_p, #PB_Tree_Collapsed)
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
