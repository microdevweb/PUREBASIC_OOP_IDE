; ============================================================================
; PureBasic OOP GUI Framework - TabControl.pbi
; Tabbed Panel (PanelGadget) wrapper
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "../Gadget.pbi"
XIncludeFile "../Application.pbi"

Namespace UI {

  Class TabControl Extends Gadget {

    ; Constructeur 0: Par defaut (0,0, 300x200)
    Public Method Init() {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = 300 : This\height = 200
      This\desiredWidth = 300 : This\desiredHeight = 200
      This\isVisible = #True : This\isEnabled = #True
      This\id = PanelGadget(#PB_Any, 0, 0, 300, 200)
      If (This\id) {
        CloseGadgetList()
        UI::RegisterGadget(This\id, This)
      }
    }

    ; Constructeur 1: Dimensions
    Public Method Init(w_p.i, h_p.i) {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\isVisible = #True : This\isEnabled = #True
      This\id = PanelGadget(#PB_Any, 0, 0, w_p, h_p)
      If (This\id) {
        CloseGadgetList()
        UI::RegisterGadget(This\id, This)
      }
    }

    Public Method AddTab(title_p.s) {
      If (This\id And IsGadget(This\id)) {
        OpenGadgetList(This\id)
        AddGadgetItem(This\id, -1, title_p, 0)
        CloseGadgetList()
      }
    }

    Public Method AddTabWithIcon(title_p.s, imageID_p.i) {
      If (This\id And IsGadget(This\id)) {
        OpenGadgetList(This\id)
        AddGadgetItem(This\id, -1, title_p, imageID_p)
        CloseGadgetList()
      }
    }

    Public Method OpenTab(tabIndex_p.i) {
      If (This\id And IsGadget(This\id)) {
        OpenGadgetList(This\id, tabIndex_p)
      }
    }

    Public Method CloseTab() {
      CloseGadgetList()
    }

    Public Method.i GetCurrentTab() {
      If (This\id And IsGadget(This\id)) {
        ProcedureReturn GetGadgetState(This\id)
      }
      ProcedureReturn -1
    }

    Public Method SetCurrentTab(tabIndex_p.i) {
      If (This\id And IsGadget(This\id)) {
        SetGadgetState(This\id, tabIndex_p)
      }
    }

    Public Method.i GetTabCount() {
      If (This\id And IsGadget(This\id)) {
        ProcedureReturn CountGadgetItems(This\id)
      }
      ProcedureReturn 0
    }

    Public Method.s GetTabText(tabIndex_p.i) {
      If (This\id And IsGadget(This\id)) {
        ProcedureReturn GetGadgetItemText(This\id, tabIndex_p)
      }
      ProcedureReturn ""
    }

    Public Method SetTabText(tabIndex_p.i, text_p.s) {
      If (This\id And IsGadget(This\id)) {
        SetGadgetItemText(This\id, tabIndex_p, text_p)
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
