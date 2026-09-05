; ============================================================================
; PureBasic OOP GUI Framework - ComboBox.pbi
; Standard ComboBox wrapper with Multi-Constructors
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "../Gadget.pbi"
XIncludeFile "../Application.pbi"

Namespace UI {

  Class ComboBox Extends Gadget {

    ; Constructeur 1: Par défaut (Positionné par Layout 0,0, 150x25)
    Public Method Init() {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = 150 : This\height = 25
      This\desiredWidth = 150 : This\desiredHeight = 25
      This\isVisible = #True : This\isEnabled = #True
      This\id = ComboBoxGadget(#PB_Any, 0, 0, 150, 25, 0)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
      }
    }

    ; Constructeur 2: Dimensions personnalisées
    Public Method Init(w_p.i, h_p.i) {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\isVisible = #True : This\isEnabled = #True
      This\id = ComboBoxGadget(#PB_Any, 0, 0, w_p, h_p, 0)
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
      This\id = ComboBoxGadget(#PB_Any, x_p, y_p, w_p, h_p, 0)
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
      This\id = ComboBoxGadget(#PB_Any, x_p, y_p, w_p, h_p, flags_p)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
      }
    }

    Public Method AddItem(text.s) {
      If (This\id And IsGadget(This\id)) {
        AddGadgetItem(This\id, -1, text)
      }
    }

    Public Method.i GetSelectedIndex() {
      If (This\id And IsGadget(This\id)) {
        ProcedureReturn GetGadgetState(This\id)
      }
      ProcedureReturn -1
    }

    Public Method SetSelectedIndex(idx.i) {
      If (This\id And IsGadget(This\id)) {
        SetGadgetState(This\id, idx)
      }
    }

    Public Method.s GetSelectedItem() {
      Protected idx.i = This\GetSelectedIndex()
      If (idx >= 0 And This\id And IsGadget(This\id)) {
        ProcedureReturn GetGadgetItemText(This\id, idx)
      }
      ProcedureReturn ""
    }

    Public Method Clear() {
      If (This\id And IsGadget(This\id)) {
        ClearGadgetItems(This\id)
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
