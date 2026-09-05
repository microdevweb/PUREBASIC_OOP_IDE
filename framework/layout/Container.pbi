; ============================================================================
; PureBasic OOP GUI Framework - Container.pbi
; Base abstract class for all responsive layout panels
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "../Component.pbi"

Namespace UI::Layouts {

  Class Container Extends UI::Component {
    Protected List *children.UI::Component()
    Protected paddingLeft.i
    Protected paddingTop.i
    Protected paddingRight.i
    Protected paddingBottom.i

    ; Constructeur 1: Par défaut
    Public Method Init() {
      Super\Init()
      This\paddingLeft = 0
      This\paddingTop = 0
      This\paddingRight = 0
      This\paddingBottom = 0
      This\horizontalAlignment = #UI_Align_Stretch
      This\verticalAlignment = #UI_Align_VStretch
    }

    ; Constructeur 2: Dimensions
    Public Method Init(w_p.i, h_p.i) {
      Super\Init()
      This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\paddingLeft = 0
      This\paddingTop = 0
      This\paddingRight = 0
      This\paddingBottom = 0
      This\horizontalAlignment = #UI_Align_Stretch
      This\verticalAlignment = #UI_Align_VStretch
    }

    ; Constructeur 3: Position et dimensions
    Public Method Init(x_p.i, y_p.i, w_p.i, h_p.i) {
      Super\Init()
      This\x = x_p : This\y = y_p : This\width = w_p : This\height = h_p
      This\desiredWidth = w_p : This\desiredHeight = h_p
      This\paddingLeft = 0
      This\paddingTop = 0
      This\paddingRight = 0
      This\paddingBottom = 0
      This\horizontalAlignment = #UI_Align_Stretch
      This\verticalAlignment = #UI_Align_VStretch
    }

    Public Method SetPadding(l.i, t.i, r.i, b.i) {
      This\paddingLeft = l
      This\paddingTop = t
      This\paddingRight = r
      This\paddingBottom = b
      This\UpdateLayout()
    }

    Public Method SetPaddingAll(p.i) {
      This\paddingLeft = p
      This\paddingTop = p
      This\paddingRight = p
      This\paddingBottom = p
      This\UpdateLayout()
    }

    Public Method.i GetPaddingLeft() {
      ProcedureReturn This\paddingLeft
    }

    Public Method.i GetPaddingTop() {
      ProcedureReturn This\paddingTop
    }

    Public Method.i GetPaddingRight() {
      ProcedureReturn This\paddingRight
    }

    Public Method.i GetPaddingBottom() {
      ProcedureReturn This\paddingBottom
    }

    Public Method AddChild(*child.UI::Component) {
      If *child
        AddElement(This\children())
        This\children() = *child
        This\UpdateLayout()
      EndIf
    }

    Public Method RemoveChild(*child.UI::Component) {
      If *child
        ForEach This\children()
          If This\children() = *child
            DeleteElement(This\children())
            Break
          EndIf
        Next
        This\UpdateLayout()
      EndIf
    }

    Public Method ClearChildren() {
      ClearList(This\children())
      This\UpdateLayout()
    }

    Public Method.i GetChildCount() {
      ProcedureReturn ListSize(This\children())
    }

    Public Method SetWidth(nw.i) {
      Super\SetWidth(nw)
      This\UpdateLayout()
    }

    Public Method SetHeight(nh.i) {
      Super\SetHeight(nh)
      This\UpdateLayout()
    }

    Public Method SetSize(nw.i, nh.i) {
      Super\SetSize(nw, nh)
      This\UpdateLayout()
    }

    Public Method UpdateLayout() {
      If This\width > 0 And This\height > 0
        This\Arrange(This\x, This\y, This\width, This\height)
      EndIf
    }

    ; Default container arrange: arranges all children to stretch inside padding
    Public Method Arrange(nx.i, ny.i, nw.i, nh.i) {
      This\SetPosition(nx, ny, nw, nh)
      If This\id And IsGadget(This\id)
        ResizeGadget(This\id, nx, ny, nw, nh)
      EndIf

      Protected innerX.i = nx + This\paddingLeft
      Protected innerY.i = ny + This\paddingTop
      Protected innerW.i = nw - (This\paddingLeft + This\paddingRight)
      Protected innerH.i = nh - (This\paddingTop + This\paddingBottom)

      If innerW < 0 : innerW = 0 : EndIf
      If innerH < 0 : innerH = 0 : EndIf

      ForEach This\children()
        Protected *child.UI::Component = This\children()
        If *child
          Protected cx.i = innerX + *child\GetMarginLeft()
          Protected cy.i = innerY + *child\GetMarginTop()
          Protected cw.i = innerW - (*child\GetMarginLeft() + *child\GetMarginRight())
          Protected ch.i = innerH - (*child\GetMarginTop() + *child\GetMarginBottom())
          If cw < 0 : cw = 0 : EndIf
          If ch < 0 : ch = 0 : EndIf
          *child\Arrange(cx, cy, cw, ch)
        EndIf
      Next
    }
  }

}
