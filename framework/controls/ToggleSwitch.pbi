; ============================================================================
; PureBasic OOP GUI Framework - ToggleSwitch.pbi
; Modern iOS/Material-style animated toggle switch CustomGadget with Multi-Constructors
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "../CustomGadget.pbi"

Namespace UI {

  Class ToggleSwitch Extends CustomGadget {
    Protected isChecked.b
    Protected activeColor.i
    Protected inactiveColor.i

    ; Constructeur 1: Par défaut (#False, 0,0, 50x26)
    Public Method Init() {
      Super\Init(50, 26)
      This\isChecked = #False
      This\activeColor = RGB(52, 199, 89)      ; iOS Green
      This\inactiveColor = RGB(200, 200, 205)  ; Light Gray
      This\Redraw()
    }

    ; Constructeur 2: État initial spécifié (0,0, 50x26)
    Public Method Init(defaultState_p.b) {
      Super\Init(50, 26)
      This\isChecked = defaultState_p
      This\activeColor = RGB(52, 199, 89)      ; iOS Green
      This\inactiveColor = RGB(200, 200, 205)  ; Light Gray
      This\Redraw()
    }

    ; Constructeur 3: Dimensions et état initial
    Public Method Init(w_p.i, h_p.i, defaultState_p.b) {
      Super\Init(w_p, h_p)
      This\isChecked = defaultState_p
      This\activeColor = RGB(52, 199, 89)      ; iOS Green
      This\inactiveColor = RGB(200, 200, 205)  ; Light Gray
      This\Redraw()
    }

    ; Constructeur 4: Position, dimensions et état initial
    Public Method Init(x_p.i, y_p.i, w_p.i, h_p.i, defaultState_p.b) {
      Super\Init(x_p, y_p, w_p, h_p)
      This\isChecked = defaultState_p
      This\activeColor = RGB(52, 199, 89)      ; iOS Green
      This\inactiveColor = RGB(200, 200, 205)  ; Light Gray
      This\Redraw()
    }

    Public Method.b IsChecked() {
      ProcedureReturn This\isChecked
    }

    Public Method SetChecked(state.b) {
      This\isChecked = state
      This\Redraw()
    }

    Public Method OnClick() {
      This\isChecked = 1 - This\isChecked
      This\Redraw()
      This\OnChange()
    }

    Public Method OnPaint(w.i, h.i) {
      ; Background fill
      Box(0, 0, w, h, RGB(245, 245, 247))

      ; Main Pill
      Protected pillColor.i = This\inactiveColor
      If (This\isChecked) {
        pillColor = This\activeColor
      }
      If (This\isHovered) {
        ; Slightly brighten on hover
        pillColor = RGB(Red(pillColor) + 15, Green(pillColor) + 15, Blue(pillColor) + 15)
      }

      Protected radius.i = h / 2
      RoundBox(1, 1, w - 2, h - 2, radius, radius, pillColor)

      ; White circular thumb knob
      Protected knobPadding.i = 3
      Protected knobDiameter.i = h - (knobPadding * 2)
      Protected knobRadius.i = knobDiameter / 2
      Protected knobX.i = knobPadding
      If (This\isChecked) {
        knobX = w - knobDiameter - knobPadding
      }
      Protected knobY.i = knobPadding

      RoundBox(knobX, knobY, knobDiameter, knobDiameter, knobRadius, knobRadius, RGB(255, 255, 255))
    }
  }

}
