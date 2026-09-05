; ============================================================================
; PureBasic OOP GUI Framework - Grid.pbi
; 2D Flexible Grid layout panel with star sizing and row/column span
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "Container.pbi"

#UI_GridUnit_Pixel = 0
#UI_GridUnit_Auto  = 1
#UI_GridUnit_Star  = 2

Namespace UI::Layouts {

  Class Grid Extends UI::Layouts::Container {
    Protected List rows.UI_GridDef()
    Protected List cols.UI_GridDef()
    Protected List items.UI_GridItem()

    Public Method Init() {
      Super\Init()
    }

    Public Method Init(w_p.i, h_p.i) {
      Super\Init(w_p, h_p)
    }

    ; Parse definitions: "150", "Auto", "*", "2*"
    Protected Method ParseDefinition(*outDef.UI_GridDef, defStr.s) {
      Protected trimmed.s = Trim(UCase(defStr))
      If trimmed = "AUTO"
        *outDef\unitType = #UI_GridUnit_Auto
        *outDef\val = 0
      ElseIf FindString(trimmed, "*", 1)
        *outDef\unitType = #UI_GridUnit_Star
        Protected starCoeff.s = RemoveString(trimmed, "*")
        If starCoeff = ""
          *outDef\val = 1.0
        Else
          *outDef\val = ValF(starCoeff)
          If *outDef\val <= 0 : *outDef\val = 1.0 : EndIf
        EndIf
      Else
        *outDef\unitType = #UI_GridUnit_Pixel
        *outDef\val = Val(trimmed)
      EndIf
    }

    Public Method AddRow(defStr.s) {
      AddElement(This\rows())
      This\ParseDefinition(@This\rows(), defStr)
      This\UpdateLayout()
    }

    Public Method AddColumn(defStr.s) {
      AddElement(This\cols())
      This\ParseDefinition(@This\cols(), defStr)
      This\UpdateLayout()
    }

    Public Method SetCell(*child.UI::Component, r.i, c.i) {
      This\SetCellSpan(*child, r, c, 1, 1)
    }

    Public Method SetCellSpan(*child.UI::Component, r.i, c.i, rSpan.i, cSpan.i) {
      If *child
        Protected found.b = #False
        ForEach This\items()
          If This\items()\child = *child
            This\items()\row = r
            This\items()\col = c
            This\items()\rowSpan = rSpan
            This\items()\colSpan = cSpan
            found = #True
            Break
          EndIf
        Next
        If Not found
          AddElement(This\items())
          This\items()\child = *child
          This\items()\row = r
          This\items()\col = c
          This\items()\rowSpan = rSpan
          This\items()\colSpan = cSpan
          This\AddChild(*child)
        EndIf
        This\UpdateLayout()
      EndIf
    }

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

      ; Ensure at least 1 row and 1 col
      Protected numRows.i = ListSize(This\rows())
      Protected numCols.i = ListSize(This\cols())

      If numRows = 0
        This\AddRow("*")
        numRows = 1
      EndIf
      If numCols = 0
        This\AddColumn("*")
        numCols = 1
      EndIf

      ; ----------------------------------------------------------------------
      ; 1. Calculate Columns
      ; ----------------------------------------------------------------------
      Protected usedW.i = 0
      Protected totalStarW.f = 0.0

      ForEach This\cols()
        Select This\cols()\unitType
          Case #UI_GridUnit_Pixel
            This\cols()\computedSize = Int(This\cols()\val)
            usedW = usedW + This\cols()\computedSize
          Case #UI_GridUnit_Auto
            This\cols()\computedSize = 50 ; base auto size
            usedW = usedW + This\cols()\computedSize
          Case #UI_GridUnit_Star
            totalStarW = totalStarW + This\cols()\val
        EndSelect
      Next

      Protected remainingW.i = innerW - usedW
      If remainingW < 0 : remainingW = 0 : EndIf

      Protected curColX.i = innerX
      ForEach This\cols()
        If This\cols()\unitType = #UI_GridUnit_Star And totalStarW > 0
          This\cols()\computedSize = Int((This\cols()\val / totalStarW) * remainingW)
        EndIf
        This\cols()\computedPos = curColX
        curColX = curColX + This\cols()\computedSize
      Next

      ; ----------------------------------------------------------------------
      ; 2. Calculate Rows
      ; ----------------------------------------------------------------------
      Protected usedH.i = 0
      Protected totalStarH.f = 0.0

      ForEach This\rows()
        Select This\rows()\unitType
          Case #UI_GridUnit_Pixel
            This\rows()\computedSize = Int(This\rows()\val)
            usedH = usedH + This\rows()\computedSize
          Case #UI_GridUnit_Auto
            This\rows()\computedSize = 30 ; base auto size
            usedH = usedH + This\rows()\computedSize
          Case #UI_GridUnit_Star
            totalStarH = totalStarH + This\rows()\val
        EndSelect
      Next

      Protected remainingH.i = innerH - usedH
      If remainingH < 0 : remainingH = 0 : EndIf

      Protected curRowY.i = innerY
      ForEach This\rows()
        If This\rows()\unitType = #UI_GridUnit_Star And totalStarH > 0
          This\rows()\computedSize = Int((This\rows()\val / totalStarH) * remainingH)
        EndIf
        This\rows()\computedPos = curRowY
        curRowY = curRowY + This\rows()\computedSize
      Next

      ; ----------------------------------------------------------------------
      ; 3. Arrange Items in Grid Cells
      ; ----------------------------------------------------------------------
      ForEach This\items()
        Protected *childG.UI::Component = This\items()\child
        Protected rIdx.i = This\items()\row
        Protected cIdx.i = This\items()\col
        Protected rSpan.i = This\items()\rowSpan
        Protected cSpan.i = This\items()\colSpan

        If *childG
          ; Find cell bounds
          Protected cellX.i = innerX
          Protected cellY.i = innerY
          Protected cellW.i = innerW
          Protected cellH.i = innerH

          ; Compute Column pos & width
          If SelectElement(This\cols(), cIdx)
            cellX = This\cols()\computedPos
            cellW = This\cols()\computedSize
            If cSpan > 1
              Protected cs.i
              For cs = 1 To cSpan - 1
                If NextElement(This\cols())
                  cellW = cellW + This\cols()\computedSize
                EndIf
              Next
            EndIf
          EndIf

          ; Compute Row pos & height
          If SelectElement(This\rows(), rIdx)
            cellY = This\rows()\computedPos
            cellH = This\rows()\computedSize
            If rSpan > 1
              Protected rs.i
              For rs = 1 To rSpan - 1
                If NextElement(This\rows())
                  cellH = cellH + This\rows()\computedSize
                EndIf
              Next
            EndIf
          EndIf

          ; Margins & Alignment inside cell
          Protected targetX.i = cellX + *childG\GetMarginLeft()
          Protected targetY.i = cellY + *childG\GetMarginTop()
          Protected targetW.i = cellW - (*childG\GetMarginLeft() + *childG\GetMarginRight())
          Protected targetH.i = cellH - (*childG\GetMarginTop() + *childG\GetMarginBottom())

          If targetW < 0 : targetW = 0 : EndIf
          If targetH < 0 : targetH = 0 : EndIf

          Select *childG\GetHorizontalAlignment()
            Case #UI_Align_Left
              targetW = *childG\GetDesiredWidth()
            Case #UI_Align_Right
              targetW = *childG\GetDesiredWidth()
              targetX = cellX + cellW - targetW - *childG\GetMarginRight()
            Case #UI_Align_Center
              targetW = *childG\GetDesiredWidth()
              targetX = cellX + (cellW - targetW) / 2
          EndSelect

          Select *childG\GetVerticalAlignment()
            Case #UI_Align_Top
              targetH = *childG\GetDesiredHeight()
            Case #UI_Align_Bottom
              targetH = *childG\GetDesiredHeight()
              targetY = cellY + cellH - targetH - *childG\GetMarginBottom()
            Case #UI_Align_Middle
              targetH = *childG\GetDesiredHeight()
              targetY = cellY + (cellH - targetH) / 2
          EndSelect

          *childG\Arrange(targetX, targetY, targetW, targetH)
        EndIf
      Next
    }
  }

}
