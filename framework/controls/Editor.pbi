; ============================================================================
; PureBasic OOP GUI Framework - Editor.pbi
; Multiline Text Editor / EditorGadget wrapper
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "../Gadget.pbi"
XIncludeFile "../Application.pbi"

Namespace UI {

  Class Editor Extends Gadget {

    ; Constructeur 0: Par defaut (0,0, 200x120)
    Public Method Init() {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = 200 : This\height = 120
      This\desiredWidth = 200 : This\desiredHeight = 120
      This\isVisible = #True : This\isEnabled = #True
      This\id = EditorGadget(#PB_Any, 0, 0, 200, 120, 0)
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
      This\id = EditorGadget(#PB_Any, 0, 0, w_p, h_p, 0)
      If (This\id) {
        UI::RegisterGadget(This\id, This)
      }
    }

    ; Constructeur 2: Texte initial et dimensions
    Public Method Init(text_p.s, w_p.i, h_p.i) {
      Super\Init()
      This\x = 0 : This\y = 0 : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\isVisible = #True : This\isEnabled = #True
      This\id = EditorGadget(#PB_Any, 0, 0, w_p, h_p, 0)
      If (This\id) {
        SetGadgetText(This\id, text_p)
        UI::RegisterGadget(This\id, This)
      }
    }

    ; Constructeur 3: Complet
    Public Method Init(x_p.i, y_p.i, w_p.i, h_p.i, text_p.s, flags_p.i = 0) {
      Super\Init()
      This\x = x_p : This\y = y_p : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\isVisible = #True : This\isEnabled = #True
      This\id = EditorGadget(#PB_Any, x_p, y_p, w_p, h_p, flags_p)
      If (This\id) {
        If text_p <> "" : SetGadgetText(This\id, text_p) : EndIf
        UI::RegisterGadget(This\id, This)
      }
    }

    Public Method AddLine(lineText.s) {
      If (This\id And IsGadget(This\id)) {
        AddGadgetItem(This\id, -1, lineText)
      }
    }

    Public Method Clear() {
      If (This\id And IsGadget(This\id)) {
        ClearGadgetItems(This\id)
      }
    }

    Public Method SetReadOnly(ro.b) {
      If (This\id And IsGadget(This\id)) {
        SetGadgetAttribute(This\id, #PB_Editor_ReadOnly, ro)
      }
    }

    Public Method.b GetReadOnly() {
      If (This\id And IsGadget(This\id)) {
        ProcedureReturn GetGadgetAttribute(This\id, #PB_Editor_ReadOnly)
      }
      ProcedureReturn #False
    }

    Public Method SetWordWrap(wrap.b) {
      If (This\id And IsGadget(This\id)) {
        SetGadgetAttribute(This\id, #PB_Editor_WordWrap, wrap)
      }
    }

    Public Method.b GetWordWrap() {
      If (This\id And IsGadget(This\id)) {
        ProcedureReturn GetGadgetAttribute(This\id, #PB_Editor_WordWrap)
      }
      ProcedureReturn #False
    }

    Public Method Free() {
      If (This\id) {
        UI::UnregisterGadget(This\id)
        Super\Free()
      }
    }
  }

}
