; ============================================================================
; PureBasic OOP GUI Framework - XMLLoader.pbi
; Declarative XML / XAML Layout & View Loader for PureBasic OOP UI
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "Component.pbi"
XIncludeFile "Gadget.pbi"
XIncludeFile "Window.pbi"
XIncludeFile "layout/Container.pbi"
XIncludeFile "layout/StackPanel.pbi"
XIncludeFile "layout/DockPanel.pbi"
XIncludeFile "layout/Grid.pbi"
XIncludeFile "controls/Button.pbi"
XIncludeFile "controls/TextBox.pbi"
XIncludeFile "controls/Label.pbi"
XIncludeFile "controls/CheckBox.pbi"
XIncludeFile "controls/RadioButton.pbi"
XIncludeFile "controls/ProgressBar.pbi"
XIncludeFile "controls/Slider.pbi"
XIncludeFile "controls/ComboBox.pbi"
XIncludeFile "controls/SpinBox.pbi"
XIncludeFile "controls/Editor.pbi"
XIncludeFile "controls/ListView.pbi"
XIncludeFile "controls/TreeView.pbi"
XIncludeFile "controls/DatePicker.pbi"
XIncludeFile "controls/GroupBox.pbi"
XIncludeFile "controls/TabControl.pbi"
XIncludeFile "controls/ListIcon.pbi"
XIncludeFile "controls/ToggleSwitch.pbi"

Namespace UI {

  Class XMLLoader {

    Public Method Init() {
    }

    Public Method Free() {
    }

    ; ------------------------------------------------------------------------
    ; Helper: Parse margin or padding strings ("10", "10,5", "10,5,10,5")
    ; ------------------------------------------------------------------------
    Protected Method ParseBoxValues(valStr.s, *outL.INTEGER, *outT.INTEGER, *outR.INTEGER, *outB.INTEGER) {
      valStr = Trim(valStr)
      If valStr = ""
        *outL\i = 0 : *outT\i = 0 : *outR\i = 0 : *outB\i = 0
        ProcedureReturn
      EndIf

      Protected count.i = CountString(valStr, ",") + 1
      If count = 1
        Protected v.i = Val(valStr)
        *outL\i = v : *outT\i = v : *outR\i = v : *outB\i = v
      ElseIf count = 2
        Protected vH.i = Val(Trim(StringField(valStr, 1, ",")))
        Protected vV.i = Val(Trim(StringField(valStr, 2, ",")))
        *outL\i = vH : *outT\i = vV : *outR\i = vH : *outB\i = vV
      ElseIf count >= 4
        *outL\i = Val(Trim(StringField(valStr, 1, ",")))
        *outT\i = Val(Trim(StringField(valStr, 2, ",")))
        *outR\i = Val(Trim(StringField(valStr, 3, ",")))
        *outB\i = Val(Trim(StringField(valStr, 4, ",")))
      EndIf
    }

    ; ------------------------------------------------------------------------
    ; Helper: Apply common component attributes (Name, Width, Height, Margins, Alignments)
    ; ------------------------------------------------------------------------
    Protected Method ApplyCommonAttributes(*comp.UI::Component, node.i, *targetWindow.UI::Window) {
      If Not *comp : ProcedureReturn : EndIf

      ; Name / ID for named control registration
      Protected nameStr.s = GetXMLAttribute(node, "Name")
      If nameStr = "" : nameStr = GetXMLAttribute(node, "name") : EndIf
      If nameStr = "" : nameStr = GetXMLAttribute(node, "ID") : EndIf
      If nameStr = "" : nameStr = GetXMLAttribute(node, "id") : EndIf
      If nameStr <> ""
        *comp\SetTag(nameStr)
        If *targetWindow
          *targetWindow\RegisterControl(nameStr, *comp)
        EndIf
      EndIf

      ; Dimensions
      Protected wStr.s = GetXMLAttribute(node, "Width")
      If wStr = "" : wStr = GetXMLAttribute(node, "width") : EndIf
      If wStr <> "" : *comp\SetWidth(Val(wStr)) : EndIf

      Protected hStr.s = GetXMLAttribute(node, "Height")
      If hStr = "" : hStr = GetXMLAttribute(node, "height") : EndIf
      If hStr <> "" : *comp\SetHeight(Val(hStr)) : EndIf

      Protected minW.s = GetXMLAttribute(node, "MinWidth")
      If minW <> "" : *comp\SetMinWidth(Val(minW)) : EndIf

      Protected minH.s = GetXMLAttribute(node, "MinHeight")
      If minH <> "" : *comp\SetMinHeight(Val(minH)) : EndIf

      Protected maxW.s = GetXMLAttribute(node, "MaxWidth")
      If maxW <> "" : *comp\SetMaxWidth(Val(maxW)) : EndIf

      Protected maxH.s = GetXMLAttribute(node, "MaxHeight")
      If maxH <> "" : *comp\SetMaxHeight(Val(maxH)) : EndIf

      ; Margins
      Protected mStr.s = GetXMLAttribute(node, "Margin")
      If mStr = "" : mStr = GetXMLAttribute(node, "margin") : EndIf
      If mStr <> ""
        Protected mL.INTEGER, mT.INTEGER, mR.INTEGER, mB.INTEGER
        This\ParseBoxValues(mStr, @mL, @mT, @mR, @mB)
        *comp\SetMargin(mL\i, mT\i, mR\i, mB\i)
      EndIf

      Protected mLStr.s = GetXMLAttribute(node, "MarginLeft")
      If mLStr <> "" : *comp\SetMargin(Val(mLStr), *comp\GetMarginTop(), *comp\GetMarginRight(), *comp\GetMarginBottom()) : EndIf

      Protected mTStr.s = GetXMLAttribute(node, "MarginTop")
      If mTStr <> "" : *comp\SetMargin(*comp\GetMarginLeft(), Val(mTStr), *comp\GetMarginRight(), *comp\GetMarginBottom()) : EndIf

      Protected mRStr.s = GetXMLAttribute(node, "MarginRight")
      If mRStr <> "" : *comp\SetMargin(*comp\GetMarginLeft(), *comp\GetMarginTop(), Val(mRStr), *comp\GetMarginBottom()) : EndIf

      Protected mBStr.s = GetXMLAttribute(node, "MarginBottom")
      If mBStr <> "" : *comp\SetMargin(*comp\GetMarginLeft(), *comp\GetMarginTop(), *comp\GetMarginRight(), Val(mBStr)) : EndIf

      ; Alignments
      Protected hAlignStr.s = UCase(Trim(GetXMLAttribute(node, "HorizontalAlignment")))
      If hAlignStr = "" : hAlignStr = UCase(Trim(GetXMLAttribute(node, "horizontalAlignment"))) : EndIf
      If hAlignStr = "" : hAlignStr = UCase(Trim(GetXMLAttribute(node, "Align"))) : EndIf
      If hAlignStr <> ""
        Select hAlignStr
          Case "LEFT"    : *comp\SetHorizontalAlignment(#UI_Align_Left)
          Case "CENTER"  : *comp\SetHorizontalAlignment(#UI_Align_Center)
          Case "RIGHT"   : *comp\SetHorizontalAlignment(#UI_Align_Right)
          Case "STRETCH" : *comp\SetHorizontalAlignment(#UI_Align_Stretch)
        EndSelect
      EndIf

      Protected vAlignStr.s = UCase(Trim(GetXMLAttribute(node, "VerticalAlignment")))
      If vAlignStr = "" : vAlignStr = UCase(Trim(GetXMLAttribute(node, "verticalAlignment"))) : EndIf
      If vAlignStr = "" : vAlignStr = UCase(Trim(GetXMLAttribute(node, "VAlign"))) : EndIf
      If vAlignStr <> ""
        Select vAlignStr
          Case "TOP"      : *comp\SetVerticalAlignment(#UI_Align_Top)
          Case "MIDDLE", "CENTER" : *comp\SetVerticalAlignment(#UI_Align_Middle)
          Case "BOTTOM"   : *comp\SetVerticalAlignment(#UI_Align_Bottom)
          Case "STRETCH", "VSTRETCH" : *comp\SetVerticalAlignment(#UI_Align_VStretch)
        EndSelect
      EndIf

      ; Visibility & Enabled
      Protected visStr.s = UCase(Trim(GetXMLAttribute(node, "IsVisible")))
      If visStr = "" : visStr = UCase(Trim(GetXMLAttribute(node, "Visible"))) : EndIf
      If visStr = "FALSE" Or visStr = "0"
        *comp\SetVisible(#False)
      EndIf

      Protected enStr.s = UCase(Trim(GetXMLAttribute(node, "IsEnabled")))
      If enStr = "" : enStr = UCase(Trim(GetXMLAttribute(node, "Enabled"))) : EndIf
      If enStr = "FALSE" Or enStr = "0"
        *comp\SetEnabled(#False)
      EndIf

      ; MVVM DataBindings
      This\ApplyDataBindings(*comp, node, *targetWindow)
    }

    ; ------------------------------------------------------------------------
    ; Helper: Parse {Binding Path=..., Mode=...}
    ; ------------------------------------------------------------------------
    Protected Method.b ParseBindingExpression(attrVal.s, *outPropName.STRING, *outMode.INTEGER) {
      attrVal = Trim(attrVal)
      If Left(attrVal, 1) = "{" And Right(attrVal, 1) = "}"
        Protected inside.s = Trim(Mid(attrVal, 2, Len(attrVal) - 2))
        If LCase(Left(inside, 7)) = "binding"
          inside = Trim(Mid(inside, 8))
          *outMode\i = #UI_BindingMode_OneWay
          *outPropName\s = ""

          Protected count.i = CountString(inside, ",") + 1
          Protected i.i
          For i = 1 To count
            Protected part.s = Trim(StringField(inside, i, ","))
            If LCase(Left(part, 5)) = "path="
              *outPropName\s = Trim(Mid(part, 6))
            ElseIf LCase(Left(part, 5)) = "mode="
              Protected mStr.s = UCase(Trim(Mid(part, 6)))
              If mStr = "TWOWAY"
                *outMode\i = #UI_BindingMode_TwoWay
              ElseIf mStr = "ONEWAY"
                *outMode\i = #UI_BindingMode_OneWay
              EndIf
            ElseIf *outPropName\s = "" And Not FindString(part, "=")
              *outPropName\s = part
            EndIf
          Next
          ProcedureReturn #True
        EndIf
      EndIf
      ProcedureReturn #False
    }

    Protected Method ApplyDataBindings(*comp.UI::Component, node.i, *targetWindow.UI::Window) {
      If Not *comp Or Not *targetWindow : ProcedureReturn : EndIf
      Protected *vm.MVVM::ViewModelBase = *targetWindow\GetDataContext()
      If Not *vm : ProcedureReturn : EndIf

      Protected propName.STRING, modeVal.INTEGER

      ; 1. Text Binding
      Protected textAttr.s = GetXMLAttribute(node, "Text")
      If textAttr = "" : textAttr = GetXMLAttribute(node, "text") : EndIf
      If This\ParseBindingExpression(textAttr, @propName, @modeVal)
        UI_MVVM_RegisterBinding(*comp, "Text", *vm, propName\s, modeVal\i)
      EndIf

      ; 2. Checked / State Binding
      Protected chkAttr.s = GetXMLAttribute(node, "Checked")
      If chkAttr = "" : chkAttr = GetXMLAttribute(node, "checked") : EndIf
      If This\ParseBindingExpression(chkAttr, @propName, @modeVal)
        UI_MVVM_RegisterBinding(*comp, "Checked", *vm, propName\s, modeVal\i)
      EndIf

      ; 3. Value / Progress Binding
      Protected valAttr.s = GetXMLAttribute(node, "Value")
      If valAttr = "" : valAttr = GetXMLAttribute(node, "value") : EndIf
      If This\ParseBindingExpression(valAttr, @propName, @modeVal)
        UI_MVVM_RegisterBinding(*comp, "Value", *vm, propName\s, modeVal\i)
      EndIf

      ; 4. Command / Click Binding
      Protected cmdAttr.s = GetXMLAttribute(node, "Command")
      If cmdAttr = "" : cmdAttr = GetXMLAttribute(node, "command") : EndIf
      If cmdAttr = "" : cmdAttr = GetXMLAttribute(node, "Click") : EndIf
      If cmdAttr = "" : cmdAttr = GetXMLAttribute(node, "click") : EndIf
      If cmdAttr = "" : cmdAttr = GetXMLAttribute(node, "OnClick") : EndIf
      If cmdAttr = "" : cmdAttr = GetXMLAttribute(node, "onclick") : EndIf
      If cmdAttr <> ""
        If This\ParseBindingExpression(cmdAttr, @propName, @modeVal)
          UI_MVVM_RegisterCommandBinding(*comp, *vm, propName\s)
        Else
          UI_MVVM_RegisterCommandBinding(*comp, *vm, cmdAttr)
        EndIf
      EndIf
    }

    ; ------------------------------------------------------------------------
    ; Recursive XML Node Parser
    ; ------------------------------------------------------------------------
    Public Method.i ParseNode(node.i, *targetWindow.UI::Window, *parentContainer.UI::Layouts::Container = 0) {
      If Not node Or XMLNodeType(node) <> #PB_XML_Normal
        ProcedureReturn 0
      EndIf

      Protected tag.s = UCase(Trim(GetXMLNodeName(node)))
      Protected *createdComp.UI::Component = 0

      Select tag
        ; ====================================================================
        ; 1. WINDOW
        ; ====================================================================
        Case "WINDOW"
          Protected title.s = GetXMLAttribute(node, "Title")
          If title = "" : title = GetXMLAttribute(node, "title") : EndIf
          If title = "" : title = "PureBasic OOP Window" : EndIf

          Protected winW.i = Val(GetXMLAttribute(node, "Width"))
          If winW <= 0 : winW = 800 : EndIf

          Protected winH.i = Val(GetXMLAttribute(node, "Height"))
          If winH <= 0 : winH = 600 : EndIf

          If *targetWindow
            If *targetWindow\GetID() = 0
              *targetWindow\CreateWindowInternal(title, #PB_Ignore, #PB_Ignore, winW, winH, #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_SizeGadget | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget, 0)
            Else
              *targetWindow\SetTitle(title)
              *targetWindow\SetSize(winW, winH)
            EndIf
          EndIf

          ; Parse children inside Window (first container becomes root content)
          Protected *childNode = ChildXMLNode(node)
          While *childNode
            If XMLNodeType(*childNode) = #PB_XML_Normal
              Protected *rootChild.UI::Component = This\ParseNode(*childNode, *targetWindow, 0)
              If *rootChild And *targetWindow
                *targetWindow\SetContent(*rootChild)
                Break
              EndIf
            EndIf
            *childNode = NextXMLNode(*childNode)
          Wend
          ProcedureReturn *targetWindow

        ; ====================================================================
        ; 2. LAYOUT PANELS
        ; ====================================================================
        Case "DOCKPANEL"
          Protected *dockPanel.UI::Layouts::DockPanel = New UI::Layouts::DockPanel()
          Protected fillStr.s = UCase(Trim(GetXMLAttribute(node, "LastChildFill")))
          If fillStr = "FALSE" Or fillStr = "0"
            *dockPanel\SetLastChildFill(#False)
          EndIf

          Protected padStr.s = GetXMLAttribute(node, "Padding")
          If padStr <> ""
            Protected pL.INTEGER, pT.INTEGER, pR.INTEGER, pB.INTEGER
            This\ParseBoxValues(padStr, @pL, @pT, @pR, @pB)
            *dockPanel\SetPadding(pL\i, pT\i, pR\i, pB\i)
          EndIf

          This\ApplyCommonAttributes(*dockPanel, node, *targetWindow)
          *createdComp = *dockPanel

          ; Parse children of DockPanel
          Protected *dChildNode = ChildXMLNode(node)
          While *dChildNode
            If XMLNodeType(*dChildNode) = #PB_XML_Normal
              Protected *cChild.UI::Component = This\ParseNode(*dChildNode, *targetWindow, *dockPanel)
              If *cChild
                Protected dockStr.s = UCase(Trim(GetXMLAttribute(*dChildNode, "Dock")))
                If dockStr = "" : dockStr = UCase(Trim(GetXMLAttribute(*dChildNode, "dock"))) : EndIf
                Protected dockType.i = #UI_Dock_Fill
                Select dockStr
                  Case "TOP"    : dockType = #UI_Dock_Top
                  Case "BOTTOM" : dockType = #UI_Dock_Bottom
                  Case "LEFT"   : dockType = #UI_Dock_Left
                  Case "RIGHT"  : dockType = #UI_Dock_Right
                  Case "FILL"   : dockType = #UI_Dock_Fill
                EndSelect
                *dockPanel\SetDock(*cChild, dockType)
              EndIf
            EndIf
            *dChildNode = NextXMLNode(*dChildNode)
          Wend

        Case "STACKPANEL"
          Protected *stackPanel.UI::Layouts::StackPanel = New UI::Layouts::StackPanel()
          Protected orientStr.s = UCase(Trim(GetXMLAttribute(node, "Orientation")))
          If orientStr = "HORIZONTAL"
            *stackPanel\SetOrientation(#UI_Orientation_Horizontal)
          Else
            *stackPanel\SetOrientation(#UI_Orientation_Vertical)
          EndIf

          Protected spStr.s = GetXMLAttribute(node, "Spacing")
          If spStr <> "" : *stackPanel\SetSpacing(Val(spStr)) : EndIf

          Protected sPadStr.s = GetXMLAttribute(node, "Padding")
          If sPadStr <> ""
            Protected spL.INTEGER, spT.INTEGER, spR.INTEGER, spB.INTEGER
            This\ParseBoxValues(sPadStr, @spL, @spT, @spR, @spB)
            *stackPanel\SetPadding(spL\i, spT\i, spR\i, spB\i)
          EndIf

          This\ApplyCommonAttributes(*stackPanel, node, *targetWindow)
          *createdComp = *stackPanel

          ; Parse children of StackPanel
          Protected *sChildNode = ChildXMLNode(node)
          While *sChildNode
            If XMLNodeType(*sChildNode) = #PB_XML_Normal
              Protected *sChild.UI::Component = This\ParseNode(*sChildNode, *targetWindow, *stackPanel)
              If *sChild
                *stackPanel\AddChild(*sChild)
              EndIf
            EndIf
            *sChildNode = NextXMLNode(*sChildNode)
          Wend

        Case "GRID"
          Protected *grid.UI::Layouts::Grid = New UI::Layouts::Grid()
          Protected rowsStr.s = GetXMLAttribute(node, "Rows")
          If rowsStr = "" : rowsStr = GetXMLAttribute(node, "rows") : EndIf
          If rowsStr <> ""
            Protected rCount.i = CountString(rowsStr, ",") + 1
            Protected rIdx.i
            For rIdx = 1 To rCount
              *grid\AddRow(Trim(StringField(rowsStr, rIdx, ",")))
            Next rIdx
          EndIf

          Protected colsStr.s = GetXMLAttribute(node, "Columns")
          If colsStr = "" : colsStr = GetXMLAttribute(node, "columns") : EndIf
          If colsStr = "" : colsStr = GetXMLAttribute(node, "Cols") : EndIf
          If colsStr <> ""
            Protected cCount.i = CountString(colsStr, ",") + 1
            Protected cIdx.i
            For cIdx = 1 To cCount
              *grid\AddColumn(Trim(StringField(colsStr, cIdx, ",")))
            Next cIdx
          EndIf

          Protected gPadStr.s = GetXMLAttribute(node, "Padding")
          If gPadStr <> ""
            Protected gpL.INTEGER, gpT.INTEGER, gpR.INTEGER, gpB.INTEGER
            This\ParseBoxValues(gPadStr, @gpL, @gpT, @gpR, @gpB)
            *grid\SetPadding(gpL\i, gpT\i, gpR\i, gpB\i)
          EndIf

          This\ApplyCommonAttributes(*grid, node, *targetWindow)
          *createdComp = *grid

          ; Parse children of Grid
          Protected *gChildNode = ChildXMLNode(node)
          While *gChildNode
            If XMLNodeType(*gChildNode) = #PB_XML_Normal
              Protected *gChild.UI::Component = This\ParseNode(*gChildNode, *targetWindow, *grid)
              If *gChild
                Protected rowVal.i = Val(GetXMLAttribute(*gChildNode, "Row"))
                Protected colVal.i = Val(GetXMLAttribute(*gChildNode, "Col"))
                If colVal = 0 : colVal = Val(GetXMLAttribute(*gChildNode, "Column")) : EndIf
                Protected rowSpan.i = Val(GetXMLAttribute(*gChildNode, "RowSpan"))
                If rowSpan <= 0 : rowSpan = 1 : EndIf
                Protected colSpan.i = Val(GetXMLAttribute(*gChildNode, "ColSpan"))
                If colSpan <= 0 : colSpan = 1 : EndIf

                *grid\SetCellSpan(*gChild, rowVal, colVal, rowSpan, colSpan)
              EndIf
            EndIf
            *gChildNode = NextXMLNode(*gChildNode)
          Wend

        Case "CONTAINER"
          Protected *container.UI::Layouts::Container = New UI::Layouts::Container()
          Protected cPadStr.s = GetXMLAttribute(node, "Padding")
          If cPadStr <> ""
            Protected cpL.INTEGER, cpT.INTEGER, cpR.INTEGER, cpB.INTEGER
            This\ParseBoxValues(cPadStr, @cpL, @cpT, @cpR, @cpB)
            *container\SetPadding(cpL\i, cpT\i, cpR\i, cpB\i)
          EndIf

          This\ApplyCommonAttributes(*container, node, *targetWindow)
          *createdComp = *container

          Protected *cntChildNode = ChildXMLNode(node)
          While *cntChildNode
            If XMLNodeType(*cntChildNode) = #PB_XML_Normal
              Protected *cntChild.UI::Component = This\ParseNode(*cntChildNode, *targetWindow, *container)
              If *cntChild
                *container\AddChild(*cntChild)
              EndIf
            EndIf
            *cntChildNode = NextXMLNode(*cntChildNode)
          Wend

        ; ====================================================================
        ; 3. STANDARD & CUSTOM CONTROLS
        ; ====================================================================
        Case "BUTTON"
          Protected btnText.s = GetXMLAttribute(node, "Text")
          If btnText = "" : btnText = GetXMLAttribute(node, "text") : EndIf
          Protected *btn.UI::Button = New UI::Button(btnText)
          This\ApplyCommonAttributes(*btn, node, *targetWindow)
          *createdComp = *btn

        Case "TEXTBOX", "STRING"
          Protected tbText.s = GetXMLAttribute(node, "Text")
          Protected *tb.UI::TextBox = New UI::TextBox(tbText)
          Protected tbPlaceholder.s = GetXMLAttribute(node, "Placeholder")
          If tbPlaceholder <> ""
            *tb\SetPlaceholder(tbPlaceholder)
          EndIf
          This\ApplyCommonAttributes(*tb, node, *targetWindow)
          *createdComp = *tb

        Case "LABEL", "TEXT"
          Protected lblText.s = GetXMLAttribute(node, "Text")
          Protected *lbl.UI::Label = New UI::Label(lblText)
          This\ApplyCommonAttributes(*lbl, node, *targetWindow)
          *createdComp = *lbl

        Case "CHECKBOX"
          Protected cbText.s = GetXMLAttribute(node, "Text")
          Protected cbChkStr.s = UCase(Trim(GetXMLAttribute(node, "Checked")))
          Protected cbChk.b = #False
          If cbChkStr = "TRUE" Or cbChkStr = "1" : cbChk = #True : EndIf
          Protected *cb.UI::CheckBox = New UI::CheckBox(cbText, cbChk)
          This\ApplyCommonAttributes(*cb, node, *targetWindow)
          *createdComp = *cb

        Case "PROGRESSBAR"
          Protected pbMin.i = Val(GetXMLAttribute(node, "Min"))
          Protected pbMax.i = Val(GetXMLAttribute(node, "Max"))
          If pbMax <= 0 : pbMax = 100 : EndIf
          Protected pbVal.i = Val(GetXMLAttribute(node, "Value"))
          Protected *pb.UI::ProgressBar = New UI::ProgressBar(pbMin, pbMax)
          If pbVal > 0 : *pb\SetValue(pbVal) : EndIf
          This\ApplyCommonAttributes(*pb, node, *targetWindow)
          *createdComp = *pb

        Case "SLIDER", "TRACKBAR"
          Protected slMin.i = Val(GetXMLAttribute(node, "Min"))
          Protected slMax.i = Val(GetXMLAttribute(node, "Max"))
          If slMax <= 0 : slMax = 100 : EndIf
          Protected slVal.i = Val(GetXMLAttribute(node, "Value"))
          Protected *sl.UI::Slider = New UI::Slider(slMin, slMax)
          If slVal > 0 : *sl\SetValue(slVal) : EndIf
          This\ApplyCommonAttributes(*sl, node, *targetWindow)
          *createdComp = *sl

        Case "COMBOBOX"
          Protected *combo.UI::ComboBox = New UI::ComboBox()
          Protected cboItems.s = GetXMLAttribute(node, "Items")
          If cboItems <> ""
            Protected iCount.i = CountString(cboItems, ",") + 1
            Protected ci.i
            For ci = 1 To iCount
              *combo\AddItem(Trim(StringField(cboItems, ci, ",")))
            Next
          EndIf
          Protected cboSel.s = GetXMLAttribute(node, "SelectedIndex")
          If cboSel <> ""
            *combo\SetSelectedIndex(Val(cboSel))
          EndIf
          This\ApplyCommonAttributes(*combo, node, *targetWindow)
          *createdComp = *combo

          ; Parse child <Item> nodes
          Protected *itemNode = ChildXMLNode(node)
          While *itemNode
            If XMLNodeType(*itemNode) = #PB_XML_Normal And UCase(GetXMLNodeName(*itemNode)) = "ITEM"
              Protected itemText.s = GetXMLAttribute(*itemNode, "Text")
              If itemText = "" : itemText = GetXMLNodeText(*itemNode) : EndIf
              *combo\AddItem(itemText)
            EndIf
            *itemNode = NextXMLNode(*itemNode)
          Wend

        Case "LISTICON"
          Protected colsAttr.s = GetXMLAttribute(node, "Columns")
          Protected *li.UI::ListIcon = 0
          If colsAttr <> ""
            Protected firstColDef.s = StringField(colsAttr, 1, ",")
            Protected firstColTitle.s = Trim(StringField(firstColDef, 1, ":"))
            Protected firstColWidth.i = Val(Trim(StringField(firstColDef, 2, ":")))
            If firstColWidth <= 0 : firstColWidth = 100 : EndIf
            *li = New UI::ListIcon(firstColTitle, firstColWidth)
            Protected colTotal.i = CountString(colsAttr, ",") + 1
            Protected liColIdx.i
            For liColIdx = 2 To colTotal
              Protected cDef.s = StringField(colsAttr, liColIdx, ",")
              Protected cTitle.s = Trim(StringField(cDef, 1, ":"))
              Protected cWidth.i = Val(Trim(StringField(cDef, 2, ":")))
              If cWidth <= 0 : cWidth = 100 : EndIf
              *li\AddColumn(liColIdx - 1, cTitle, cWidth)
            Next
          Else
            Protected firstColTitleDef.s = GetXMLAttribute(node, "FirstColumnTitle")
            If firstColTitleDef = "" : firstColTitleDef = "Item" : EndIf
            Protected firstColWidthDef.i = Val(GetXMLAttribute(node, "FirstColumnWidth"))
            If firstColWidthDef <= 0 : firstColWidthDef = 150 : EndIf
            *li = New UI::ListIcon(firstColTitleDef, firstColWidthDef)
          EndIf

          This\ApplyCommonAttributes(*li, node, *targetWindow)
          *createdComp = *li

          ; Parse child <Column> nodes and <Item> nodes
          Protected *liSubNode = ChildXMLNode(node)
          Protected colPos.i = 1
          While *liSubNode
            If XMLNodeType(*liSubNode) = #PB_XML_Normal
              Protected subTag.s = UCase(GetXMLNodeName(*liSubNode))
              If subTag = "COLUMN"
                Protected colTitle.s = GetXMLAttribute(*liSubNode, "Title")
                Protected colWidth.i = Val(GetXMLAttribute(*liSubNode, "Width"))
                If colWidth <= 0 : colWidth = 100 : EndIf
                *li\AddColumn(colPos, colTitle, colWidth)
                colPos + 1
              ElseIf subTag = "ITEM"
                Protected lItemText.s = GetXMLAttribute(*liSubNode, "Text")
                If lItemText = "" : lItemText = GetXMLNodeText(*liSubNode) : EndIf
                *li\AddItem(-1, lItemText, 0)
              EndIf
            EndIf
            *liSubNode = NextXMLNode(*liSubNode)
          Wend

        Case "TOGGLESWITCH"
          Protected tsChkStr.s = UCase(Trim(GetXMLAttribute(node, "Checked")))
          Protected tsChk.b = #False
          If tsChkStr = "TRUE" Or tsChkStr = "1" : tsChk = #True : EndIf
          Protected *ts.UI::ToggleSwitch = New UI::ToggleSwitch(tsChk)
          This\ApplyCommonAttributes(*ts, node, *targetWindow)
          *createdComp = *ts

        Case "EDITOR", "TEXTAREA"
          Protected edText.s = GetXMLAttribute(node, "Text")
          If edText = "" : edText = GetXMLNodeText(node) : EndIf
          Protected *ed.UI::Editor = New UI::Editor()
          If edText <> "" : *ed\SetText(edText) : EndIf
          This\ApplyCommonAttributes(*ed, node, *targetWindow)
          *createdComp = *ed

        Case "RADIOBUTTON", "OPTION"
          Protected rbText.s = GetXMLAttribute(node, "Text")
          If rbText = "" : rbText = GetXMLNodeText(node) : EndIf
          Protected rbChkStr.s = UCase(Trim(GetXMLAttribute(node, "Checked")))
          Protected rbChk.b = #False
          If rbChkStr = "TRUE" Or rbChkStr = "1" : rbChk = #True : EndIf
          Protected *rb.UI::RadioButton = New UI::RadioButton(rbText, rbChk)
          Protected rbGrp.s = GetXMLAttribute(node, "Group")
          If rbGrp <> "" : *rb\SetGroup(Val(rbGrp)) : EndIf
          This\ApplyCommonAttributes(*rb, node, *targetWindow)
          *createdComp = *rb

        Case "LISTVIEW"
          Protected *lv.UI::ListView = New UI::ListView()
          Protected lvItems.s = GetXMLAttribute(node, "Items")
          If lvItems <> ""
            Protected lviCount.i = CountString(lvItems, ",") + 1
            Protected lvi.i
            For lvi = 1 To lviCount
              *lv\AddItem(Trim(StringField(lvItems, lvi, ",")))
            Next
          EndIf
          This\ApplyCommonAttributes(*lv, node, *targetWindow)
          *createdComp = *lv
          Protected *lvItemNode = ChildXMLNode(node)
          While *lvItemNode
            If XMLNodeType(*lvItemNode) = #PB_XML_Normal And UCase(GetXMLNodeName(*lvItemNode)) = "ITEM"
              Protected lvItemText.s = GetXMLAttribute(*lvItemNode, "Text")
              If lvItemText = "" : lvItemText = GetXMLNodeText(*lvItemNode) : EndIf
              *lv\AddItem(lvItemText)
            EndIf
            *lvItemNode = NextXMLNode(*lvItemNode)
          Wend

        Case "SPINBOX", "SPIN"
          Protected spMin.i = Val(GetXMLAttribute(node, "Min"))
          Protected spMax.i = Val(GetXMLAttribute(node, "Max"))
          If spMax <= spMin : spMax = 100 : EndIf
          Protected spVal.i = Val(GetXMLAttribute(node, "Value"))
          Protected *sp.UI::SpinBox = New UI::SpinBox(spMin, spMax, spVal)
          This\ApplyCommonAttributes(*sp, node, *targetWindow)
          *createdComp = *sp

        Case "GROUPBOX", "FRAME"
          Protected gbText.s = GetXMLAttribute(node, "Text")
          If gbText = "" : gbText = GetXMLAttribute(node, "Caption") : EndIf
          Protected *gb.UI::GroupBox = New UI::GroupBox(gbText)
          This\ApplyCommonAttributes(*gb, node, *targetWindow)
          *createdComp = *gb

        Case "TREEVIEW", "TREE"
          Protected *tv.UI::TreeView = New UI::TreeView()
          This\ApplyCommonAttributes(*tv, node, *targetWindow)
          *createdComp = *tv

        Case "DATEPICKER", "DATE"
          Protected dpMask.s = GetXMLAttribute(node, "Mask")
          If dpMask = "" : dpMask = "%dd/%mm/%yyyy" : EndIf
          Protected *dp.UI::DatePicker = New UI::DatePicker(dpMask)
          This\ApplyCommonAttributes(*dp, node, *targetWindow)
          *createdComp = *dp

        Case "TABCONTROL", "PANEL"
          Protected *tc.UI::TabControl = New UI::TabControl()
          This\ApplyCommonAttributes(*tc, node, *targetWindow)
          *createdComp = *tc
          Protected *tabNode = ChildXMLNode(node)
          While *tabNode
            If XMLNodeType(*tabNode) = #PB_XML_Normal And (UCase(GetXMLNodeName(*tabNode)) = "TAB" Or UCase(GetXMLNodeName(*tabNode)) = "ITEM")
              Protected tabTitle.s = GetXMLAttribute(*tabNode, "Title")
              If tabTitle = "" : tabTitle = GetXMLAttribute(*tabNode, "Text") : EndIf
              *tc\AddTab(tabTitle)
            EndIf
            *tabNode = NextXMLNode(*tabNode)
          Wend

      EndSelect

      ProcedureReturn *createdComp
    }

    ; ------------------------------------------------------------------------
    ; Public Entry Points: LoadFromFile and LoadFromString
    ; ------------------------------------------------------------------------
    Public Method.b LoadFromFile(xmlPath.s, *targetWindow.UI::Window) {
      If FileSize(xmlPath) <= 0
        ProcedureReturn #False
      EndIf

      Protected xmlHandle.i = LoadXML(#PB_Any, xmlPath)
      If Not xmlHandle Or XMLStatus(xmlHandle) <> #PB_XML_Success
        If xmlHandle : FreeXML(xmlHandle) : EndIf
        ProcedureReturn #False
      EndIf

      Protected *mainNode = MainXMLNode(xmlHandle)
      If *mainNode
        This\ParseNode(*mainNode, *targetWindow, 0)
      EndIf

      FreeXML(xmlHandle)
      ProcedureReturn #True
    }

    Public Method.b LoadFromString(xmlContent.s, *targetWindow.UI::Window) {
      If xmlContent = ""
        ProcedureReturn #False
      EndIf

      Protected xmlHandle.i = ParseXML(#PB_Any, xmlContent)
      If Not xmlHandle Or XMLStatus(xmlHandle) <> #PB_XML_Success
        If xmlHandle : FreeXML(xmlHandle) : EndIf
        ProcedureReturn #False
      EndIf

      Protected *mainNode = MainXMLNode(xmlHandle)
      If *mainNode
        This\ParseNode(*mainNode, *targetWindow, 0)
      EndIf

      FreeXML(xmlHandle)
      ProcedureReturn #True
    }

  }

}
