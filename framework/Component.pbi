; ============================================================================
; PureBasic OOP GUI Framework - Component.pbi
; Base abstract class for all PureBasic UI elements & Layouts
; Author:      MicrodevWeb
; ============================================================================

#UI_Align_Left = 0
#UI_Align_Center = 1
#UI_Align_Right = 2
#UI_Align_Stretch = 3

#UI_Align_Top = 0
#UI_Align_Middle = 1
#UI_Align_Bottom = 2
#UI_Align_VStretch = 3

#UI_Orientation_Vertical = 0
#UI_Orientation_Horizontal = 1

#UI_Dock_Left = 0
#UI_Dock_Top = 1
#UI_Dock_Right = 2
#UI_Dock_Bottom = 3
#UI_Dock_Fill = 4

#UI_GridUnit_Pixel = 0
#UI_GridUnit_Auto  = 1
#UI_GridUnit_Star  = 2

Structure UI_DockItem
  *child
  dock.i
EndStructure

Structure UI_GridDef
  unitType.i
  val.f
  computedSize.i
  computedPos.i
EndStructure

Structure UI_GridItem
  *child
  row.i
  col.i
  rowSpan.i
  colSpan.i
EndStructure

Namespace UI {

  Abstract Class Component {
    Protected id.i
    Protected tag.s
    Protected x.i
    Protected y.i
    Protected width.i
    Protected height.i
    Protected isVisible.b
    Protected isEnabled.b
    Protected userData.i

    ; Layout & Responsive properties
    Protected marginLeft.i
    Protected marginTop.i
    Protected marginRight.i
    Protected marginBottom.i
    Protected horizontalAlignment.i
    Protected verticalAlignment.i
    Protected minWidth.i
    Protected maxWidth.i
    Protected minHeight.i
    Protected maxHeight.i
    Protected desiredWidth.i
    Protected desiredHeight.i
    Protected hasExplicitWidth.b
    Protected hasExplicitHeight.b
    Protected dataContext.i

    Public Method Init() {
      This\isVisible = #True
      This\isEnabled = #True
      This\horizontalAlignment = #UI_Align_Stretch
      This\verticalAlignment = #UI_Align_VStretch
      This\desiredWidth = 100
      This\desiredHeight = 30
      This\hasExplicitWidth = #False
      This\hasExplicitHeight = #False
      This\dataContext = 0
    }

    Public Method SetDataContext(*dc) {
      This\dataContext = *dc
    }

    Public Method.i GetDataContext() {
      ProcedureReturn This\dataContext
    }

    Public Method.i GetID() {
      ProcedureReturn This\id
    }

    Public Method.i GetHandle() {
      ProcedureReturn This\id
    }

    Public Method.s GetTag() {
      ProcedureReturn This\tag
    }

    Public Method SetTag(t.s) {
      This\tag = t
    }

    Public Method.i GetX() {
      ProcedureReturn This\x
    }

    Public Method SetX(nx.i) {
      This\x = nx
    }

    Public Method.i GetY() {
      ProcedureReturn This\y
    }

    Public Method SetY(ny.i) {
      This\y = ny
    }

    Public Method.i GetWidth() {
      ProcedureReturn This\width
    }

    Public Method SetWidth(nw.i) {
      This\width = nw
      This\desiredWidth = nw
      This\hasExplicitWidth = #True
    }

    Public Method.i GetHeight() {
      ProcedureReturn This\height
    }

    Public Method SetHeight(nh.i) {
      This\height = nh
      This\desiredHeight = nh
      This\hasExplicitHeight = #True
    }

    Public Method SetAutoWidth() {
      This\hasExplicitWidth = #False
      This\desiredWidth = 0
    }

    Public Method SetAutoHeight() {
      This\hasExplicitHeight = #False
      This\desiredHeight = 0
    }

    Public Method.b HasExplicitWidth() {
      ProcedureReturn This\hasExplicitWidth
    }

    Public Method.b HasExplicitHeight() {
      ProcedureReturn This\hasExplicitHeight
    }

    Public Method SetLocation(nx.i, ny.i) {
      This\x = nx
      This\y = ny
    }

    Public Method SetSize(nw.i, nh.i) {
      This\width = nw
      This\height = nh
      This\desiredWidth = nw
      This\desiredHeight = nh
      This\hasExplicitWidth = #True
      This\hasExplicitHeight = #True
    }

    Public Method SetPosition(nx.i, ny.i, nw.i, nh.i) {
      This\x = nx
      This\y = ny
      This\width = nw
      This\height = nh
      This\desiredWidth = nw
      This\desiredHeight = nh
    }

    Public Method.b IsVisible() {
      ProcedureReturn This\isVisible
    }

    Public Method.b GetVisible() {
      ProcedureReturn This\isVisible
    }

    Public Method SetVisible(v.b) {
      This\isVisible = v
    }

    Public Method.b IsEnabled() {
      ProcedureReturn This\isEnabled
    }

    Public Method.b GetEnabled() {
      ProcedureReturn This\isEnabled
    }

    Public Method SetEnabled(e.b) {
      This\isEnabled = e
    }

    Public Method.i GetUserData() {
      ProcedureReturn This\userData
    }

    Public Method SetUserData(val.i) {
      This\userData = val
    }

    ; ------------------------------------------------------------------------
    ; Responsive Layout Accessors
    ; ------------------------------------------------------------------------

    Public Method SetMargin(l.i, t.i, r.i, b.i) {
      This\marginLeft = l
      This\marginTop = t
      This\marginRight = r
      This\marginBottom = b
    }

    Public Method SetMarginAll(m.i) {
      This\marginLeft = m
      This\marginTop = m
      This\marginRight = m
      This\marginBottom = m
    }

    Public Method.i GetMarginLeft() {
      ProcedureReturn This\marginLeft
    }

    Public Method.i GetMarginTop() {
      ProcedureReturn This\marginTop
    }

    Public Method.i GetMarginRight() {
      ProcedureReturn This\marginRight
    }

    Public Method.i GetMarginBottom() {
      ProcedureReturn This\marginBottom
    }

    Public Method SetHorizontalAlignment(align.i) {
      This\horizontalAlignment = align
    }

    Public Method.i GetHorizontalAlignment() {
      ProcedureReturn This\horizontalAlignment
    }

    Public Method SetVerticalAlignment(align.i) {
      This\verticalAlignment = align
    }

    Public Method.i GetVerticalAlignment() {
      ProcedureReturn This\verticalAlignment
    }

    Public Method SetMinWidth(mw.i) {
      This\minWidth = mw
    }

    Public Method.i GetMinWidth() {
      ProcedureReturn This\minWidth
    }

    Public Method SetMaxWidth(mw.i) {
      This\maxWidth = mw
    }

    Public Method.i GetMaxWidth() {
      ProcedureReturn This\maxWidth
    }

    Public Method SetMinHeight(mh.i) {
      This\minHeight = mh
    }

    Public Method.i GetMinHeight() {
      ProcedureReturn This\minHeight
    }

    Public Method SetMaxHeight(mh.i) {
      This\maxHeight = mh
    }

    Public Method.i GetMaxHeight() {
      ProcedureReturn This\maxHeight
    }

    Public Method.i GetDesiredWidth() {
      If (This\desiredWidth > 0) {
        ProcedureReturn This\desiredWidth
      }
      If (This\width > 0) {
        ProcedureReturn This\width
      }
      ProcedureReturn 100
    }

    Public Method.i GetDesiredHeight() {
      If (This\desiredHeight > 0) {
        ProcedureReturn This\desiredHeight
      }
      If (This\height > 0) {
        ProcedureReturn This\height
      }
      ProcedureReturn 30
    }

    ; Virtual Layout Arrange method
    Public Method Arrange(nx.i, ny.i, nw.i, nh.i) {
      This\SetPosition(nx, ny, nw, nh)
      If (This\id And IsGadget(This\id)) {
        ResizeGadget(This\id, nx, ny, nw, nh)
      }
    }
  }

}
