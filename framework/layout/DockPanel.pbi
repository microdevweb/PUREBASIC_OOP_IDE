; ============================================================================
; PureBasic OOP GUI Framework - DockPanel.pbi
; Edge-docking layout panel with center-filling area (WPF DockPanel style)
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "Container.pbi"

Namespace UI::Layouts {

  Class DockPanel Extends UI::Layouts::Container {
    Protected List items.UI_DockItem()
    Protected lastChildFill.b

    Public Method Init() {
      Super\Init()
      This\lastChildFill = #True
    }

    Public Method Init(fill.b) {
      Super\Init()
      This\lastChildFill = fill
    }

    Public Method Init(fill.b, w_p.i, h_p.i) {
      Super\Init(w_p, h_p)
      This\lastChildFill = fill
    }

    Public Method SetLastChildFill(fill.b) {
      This\lastChildFill = fill
      This\UpdateLayout()
    }

    Public Method.b GetLastChildFill() {
      ProcedureReturn This\lastChildFill
    }

    Public Method AddDockChild(*child.UI::Component, dockType.i) {
      If *child
        AddElement(This\items())
        This\items()\child = *child
        This\items()\dock = dockType
        This\AddChild(*child)
      EndIf
    }

    Public Method SetDock(*child.UI::Component, dockType.i) {
      If *child
        Protected found.b = #False
        ForEach This\items()
          If This\items()\child = *child
            This\items()\dock = dockType
            found = #True
            Break
          EndIf
        Next
        If Not found
          AddElement(This\items())
          This\items()\child = *child
          This\items()\dock = dockType
          This\AddChild(*child)
        EndIf
        This\UpdateLayout()
      EndIf
    }

    Public Method.i GetDock(*child.UI::Component) {
      ForEach This\items()
        If This\items()\child = *child
          ProcedureReturn This\items()\dock
        EndIf
      Next
      ProcedureReturn #UI_Dock_Fill
    }

    Public Method Arrange(nx.i, ny.i, nw.i, nh.i) {
      This\SetPosition(nx, ny, nw, nh)
      If This\id And IsGadget(This\id)
        ResizeGadget(This\id, nx, ny, nw, nh)
      EndIf

      Protected curX.i = nx + This\paddingLeft
      Protected curY.i = ny + This\paddingTop
      Protected curW.i = nw - (This\paddingLeft + This\paddingRight)
      Protected curH.i = nh - (This\paddingTop + This\paddingBottom)

      If curW < 0 : curW = 0 : EndIf
      If curH < 0 : curH = 0 : EndIf

      Protected totalItems.i = ListSize(This\items())
      Protected index.i = 0

      ForEach This\items()
        index = index + 1
        Protected *c.UI::Component = This\items()\child
        Protected d.i = This\items()\dock

        If This\lastChildFill And index = totalItems
          d = #UI_Dock_Fill
        EndIf

        If *c
          Select d
            Case #UI_Dock_Top
              Protected itemH.i = *c\GetDesiredHeight()
              Protected targetY.i = curY + *c\GetMarginTop()
              Protected targetW.i = curW - (*c\GetMarginLeft() + *c\GetMarginRight())
              If targetW < 0 : targetW = 0 : EndIf

              *c\Arrange(curX + *c\GetMarginLeft(), targetY, targetW, itemH)
              Protected usedH.i = itemH + *c\GetMarginTop() + *c\GetMarginBottom()
              curY = curY + usedH
              curH = curH - usedH
              If curH < 0 : curH = 0 : EndIf

            Case #UI_Dock_Bottom
              Protected itemHb.i = *c\GetDesiredHeight()
              Protected targetYb.i = curY + curH - itemHb - *c\GetMarginBottom()
              Protected targetWb.i = curW - (*c\GetMarginLeft() + *c\GetMarginRight())
              If targetWb < 0 : targetWb = 0 : EndIf

              *c\Arrange(curX + *c\GetMarginLeft(), targetYb, targetWb, itemHb)
              Protected usedHb.i = itemHb + *c\GetMarginTop() + *c\GetMarginBottom()
              curH = curH - usedHb
              If curH < 0 : curH = 0 : EndIf

            Case #UI_Dock_Left
              Protected itemW.i = *c\GetDesiredWidth()
              Protected targetXl.i = curX + *c\GetMarginLeft()
              Protected targetHl.i = curH - (*c\GetMarginTop() + *c\GetMarginBottom())
              If targetHl < 0 : targetHl = 0 : EndIf

              *c\Arrange(targetXl, curY + *c\GetMarginTop(), itemW, targetHl)
              Protected usedWl.i = itemW + *c\GetMarginLeft() + *c\GetMarginRight()
              curX = curX + usedWl
              curW = curW - usedWl
              If curW < 0 : curW = 0 : EndIf

            Case #UI_Dock_Right
              Protected itemWr.i = *c\GetDesiredWidth()
              Protected targetXr.i = curX + curW - itemWr - *c\GetMarginRight()
              Protected targetHr.i = curH - (*c\GetMarginTop() + *c\GetMarginBottom())
              If targetHr < 0 : targetHr = 0 : EndIf

              *c\Arrange(targetXr, curY + *c\GetMarginTop(), itemWr, targetHr)
              Protected usedWr.i = itemWr + *c\GetMarginLeft() + *c\GetMarginRight()
              curW = curW - usedWr
              If curW < 0 : curW = 0 : EndIf

            Case #UI_Dock_Fill
              Protected targetXf.i = curX + *c\GetMarginLeft()
              Protected targetYf.i = curY + *c\GetMarginTop()
              Protected targetWf.i = curW - (*c\GetMarginLeft() + *c\GetMarginRight())
              Protected targetHf.i = curH - (*c\GetMarginTop() + *c\GetMarginBottom())
              If targetWf < 0 : targetWf = 0 : EndIf
              If targetHf < 0 : targetHf = 0 : EndIf

              *c\Arrange(targetXf, targetYf, targetWf, targetHf)
          EndSelect
        EndIf
      Next
    }
  }

}
