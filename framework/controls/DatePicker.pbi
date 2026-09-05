; ============================================================================
; PureBasic OOP GUI Framework - DatePicker.pbi
; Date Selection (DateGadget) wrapper
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "../Gadget.pbi"
XIncludeFile "../Application.pbi"

Namespace UI {

  Class DatePicker Extends Gadget {
    Protected mask.s

    ; Constructeur 0: Par defaut (date du jour, 0,0, 140x25)
    Public Method Init() {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = 140 : This\height = 25
      This\desiredWidth = 140 : This\desiredHeight = 25
      This\isVisible = #True : This\isEnabled = #True
      This\mask = "%dd/%mm/%yyyy"
      This\id = DateGadget(#PB_Any, 0, 0, 140, 25, This\mask, Date(), 0)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
      }
    }

    ; Constructeur 1: Masque personnalise
    Public Method Init(mask_p.s) {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = 140 : This\height = 25
      This\desiredWidth = 140 : This\desiredHeight = 25
      This\isVisible = #True : This\isEnabled = #True
      This\mask = mask_p
      This\id = DateGadget(#PB_Any, 0, 0, 140, 25, mask_p, Date(), 0)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
      }
    }

    ; Constructeur 2: Date et Masque
    Public Method Init(dateVal_p.i, mask_p.s) {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = 140 : This\height = 25
      This\desiredWidth = 140 : This\desiredHeight = 25
      This\isVisible = #True : This\isEnabled = #True
      This\mask = mask_p
      This\id = DateGadget(#PB_Any, 0, 0, 140, 25, mask_p, dateVal_p, 0)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
      }
    }

    ; Constructeur 3: Date, Masque et dimensions
    Public Method Init(dateVal_p.i, mask_p.s, w_p.i, h_p.i) {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\isVisible = #True : This\isEnabled = #True
      This\mask = mask_p
      This\id = DateGadget(#PB_Any, 0, 0, w_p, h_p, mask_p, dateVal_p, 0)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
      }
    }

    Public Method.i GetDate() {
      If (This\id And IsGadget(This\id)) {
        ProcedureReturn GetGadgetState(This\id)
      }
      ProcedureReturn 0
    }

    Public Method SetDate(dateVal_p.i) {
      If (This\id And IsGadget(This\id)) {
        SetGadgetState(This\id, dateVal_p)
      }
    }

    Public Method.s GetFormattedDate(format_p.s = "%dd/%mm/%yyyy") {
      Protected d.i = This\GetDate()
      If d > 0
        ProcedureReturn FormatDate(format_p, d)
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
