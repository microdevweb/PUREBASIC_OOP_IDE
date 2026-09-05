; ============================================================================
; PureBasic OOP GUI Framework - BindingEngine.pbi
; Declarative DataBinding and Command Dispatching Engine
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "../Component.pbi"
XIncludeFile "../Gadget.pbi"
XIncludeFile "ViewModelBase.pbi"
XIncludeFile "ObservableCollection.pbi"

#UI_BindingMode_OneWay      = 1
#UI_BindingMode_TwoWay      = 2
#UI_BindingMode_Command     = 3
#UI_BindingMode_Collection  = 4

Structure UI_PropertyBinding
  *control.UI_Gadget_vt
  targetProp.s
  *viewModel.MVVM_ViewModelBase_vt
  sourceProp.s
  mode.i
  isUpdating.b
EndStructure

Structure UI_CommandBinding
  *control.UI_Gadget_vt
  *viewModel.MVVM_ViewModelBase_vt
  commandName.s
EndStructure

Structure UI_CollectionBinding
  *control.UI_Gadget_vt
  *collection.MVVM_ObservableCollection_vt
EndStructure

Global NewList UI_ActivePropertyBindings.UI_PropertyBinding()
Global NewList UI_ActiveCommandBindings.UI_CommandBinding()
Global NewList UI_ActiveCollectionBindings.UI_CollectionBinding()

; Forward procedure declarations for callbacks and API
Declare UI_BindingEngine_OnVMPropertyChanged(*vm, *pKeyPtr)
Declare UI_BindingEngine_OnCollectionChanged(*col, actionType.i, index.i, *pTextPtr)
Declare UI_MVVM_RegisterBinding(*control.UI_Gadget_vt, targetProp.s, *viewModel.MVVM_ViewModelBase_vt, sourceProp.s, mode.i = #UI_BindingMode_OneWay)
Declare UI_MVVM_RegisterCommandBinding(*control.UI_Gadget_vt, *viewModel.MVVM_ViewModelBase_vt, commandName.s)
Declare UI_MVVM_RegisterCollectionBinding(*control.UI_Gadget_vt, *collection.MVVM_ObservableCollection_vt)
Declare.b UI_MVVM_DispatchUIEvent(*control.UI_Gadget_vt, eventType.i)
Declare UI_MVVM_UnregisterAll(*targetObj)

Procedure UI_BindingEngine_OnVMPropertyChanged(*vm, *pKeyPtr)
  If Not *pKeyPtr : ProcedureReturn : EndIf
  Protected pKey.s = LCase(PeekS(*pKeyPtr))
  ForEach UI_ActivePropertyBindings()
    If UI_ActivePropertyBindings()\viewModel = *vm
      If LCase(UI_ActivePropertyBindings()\sourceProp) = pKey
        If Not UI_ActivePropertyBindings()\isUpdating
          UI_ActivePropertyBindings()\isUpdating = #True
          Protected *ctrl.UI_Gadget_vt = UI_ActivePropertyBindings()\control
          Protected *vmObj.MVVM_ViewModelBase_vt = *vm
          If *ctrl And IsGadget(*ctrl\GetID())
            Protected valStr.s = *vmObj\GetValueAsString(pKey)
            Protected tProp.s = LCase(UI_ActivePropertyBindings()\targetProp)
            
            Select tProp
              Case "text", "value"
                SetGadgetText(*ctrl\GetID(), valStr)
              Case "checked", "state"
                Protected bVal.b = #False
                If UCase(valStr) = "TRUE" Or valStr = "1" : bVal = #True : EndIf
                SetGadgetState(*ctrl\GetID(), bVal)
              Case "progress", "progressvalue"
                SetGadgetState(*ctrl\GetID(), Val(valStr))
              Default:
                SetGadgetText(*ctrl\GetID(), valStr)
            EndSelect
          EndIf
          UI_ActivePropertyBindings()\isUpdating = #False
        EndIf
      EndIf
    EndIf
  Next
EndProcedure

Procedure UI_BindingEngine_OnCollectionChanged(*col, actionType.i, index.i, *pTextPtr)
  Protected itemText.s = ""
  If *pTextPtr : itemText = PeekS(*pTextPtr) : EndIf
  ForEach UI_ActiveCollectionBindings()
    If UI_ActiveCollectionBindings()\collection = *col
      Protected *ctrl.UI_Gadget_vt = UI_ActiveCollectionBindings()\control
      If *ctrl And IsGadget(*ctrl\GetID())
        Protected gId.i = *ctrl\GetID()
        Select actionType
          Case #UI_CollectionAction_Add
            AddGadgetItem(gId, index, itemText)
          Case #UI_CollectionAction_Remove
            RemoveGadgetItem(gId, index)
          Case #UI_CollectionAction_Clear
            ClearGadgetItems(gId)
          Case #UI_CollectionAction_Update
            SetGadgetItemText(gId, index, itemText)
        EndSelect
      EndIf
    EndIf
  Next
EndProcedure

Procedure UI_MVVM_RegisterBinding(*control.UI_Gadget_vt, targetProp.s, *viewModel.MVVM_ViewModelBase_vt, sourceProp.s, mode.i = #UI_BindingMode_OneWay)
  If Not *control Or Not *viewModel Or sourceProp = ""
    ProcedureReturn
  EndIf

  AddElement(UI_ActivePropertyBindings())
  UI_ActivePropertyBindings()\control = *control
  UI_ActivePropertyBindings()\targetProp = targetProp
  UI_ActivePropertyBindings()\viewModel = *viewModel
  UI_ActivePropertyBindings()\sourceProp = sourceProp
  UI_ActivePropertyBindings()\mode = mode
  UI_ActivePropertyBindings()\isUpdating = #False

  ; Subscribe to ViewModel property changes
  *viewModel\RegisterObserver(*control, @UI_BindingEngine_OnVMPropertyChanged())

  ; Initial push from ViewModel to View
  Protected initialVal.s = *viewModel\GetValueAsString(sourceProp)
  If initialVal <> "" And IsGadget(*control\GetID())
    Protected tProp.s = LCase(targetProp)
    Select tProp
      Case "text"
        SetGadgetText(*control\GetID(), initialVal)
      Case "checked", "state"
        Protected bVal.b = #False
        If UCase(initialVal) = "TRUE" Or initialVal = "1" : bVal = #True : EndIf
        SetGadgetState(*control\GetID(), bVal)
      Case "progress", "progressvalue"
        SetGadgetState(*control\GetID(), Val(initialVal))
      Default:
        SetGadgetText(*control\GetID(), initialVal)
    EndSelect
  EndIf
EndProcedure

Procedure UI_MVVM_RegisterCommandBinding(*control.UI_Gadget_vt, *viewModel.MVVM_ViewModelBase_vt, commandName.s)
  If Not *control Or Not *viewModel Or commandName = ""
    ProcedureReturn
  EndIf

  AddElement(UI_ActiveCommandBindings())
  UI_ActiveCommandBindings()\control = *control
  UI_ActiveCommandBindings()\viewModel = *viewModel
  UI_ActiveCommandBindings()\commandName = commandName
EndProcedure

Procedure UI_MVVM_RegisterCollectionBinding(*control.UI_Gadget_vt, *collection.MVVM_ObservableCollection_vt)
  If Not *control Or Not *collection
    ProcedureReturn
  EndIf

  AddElement(UI_ActiveCollectionBindings())
  UI_ActiveCollectionBindings()\control = *control
  UI_ActiveCollectionBindings()\collection = *collection

  *collection\RegisterCollectionObserver(*control, @UI_BindingEngine_OnCollectionChanged())

  ; Initial populate
  If IsGadget(*control\GetID())
    ClearGadgetItems(*control\GetID())
    Protected cCount.i = *collection\Count()
    Protected i.i
    For i = 0 To cCount - 1
      AddGadgetItem(*control\GetID(), i, *collection\GetItem(i))
    Next
  EndIf
EndProcedure

Procedure.b UI_MVVM_DispatchUIEvent(*control.UI_Gadget_vt, eventType.i)
  If Not *control : ProcedureReturn #False : EndIf

  Protected handled.b = #False

  ; 1. Check Command Bindings (Button click / Toggle change)
  ForEach UI_ActiveCommandBindings()
    If UI_ActiveCommandBindings()\control = *control
      Protected *cmdVM.MVVM_ViewModelBase_vt = UI_ActiveCommandBindings()\viewModel
      If *cmdVM
        *cmdVM\ExecuteCommand(UI_ActiveCommandBindings()\commandName, *control)
        handled = #True
      EndIf
    EndIf
  Next

  ; 2. Check Two-Way Property Bindings (TextBox change / CheckBox click)
  ForEach UI_ActivePropertyBindings()
    If UI_ActivePropertyBindings()\control = *control
      If UI_ActivePropertyBindings()\mode = #UI_BindingMode_TwoWay
        If Not UI_ActivePropertyBindings()\isUpdating
          UI_ActivePropertyBindings()\isUpdating = #True
          Protected *propVM.MVVM_ViewModelBase_vt = UI_ActivePropertyBindings()\viewModel
          If *propVM And IsGadget(*control\GetID())
            Protected curText.s = GetGadgetText(*control\GetID())
            Protected tProp.s = LCase(UI_ActivePropertyBindings()\targetProp)
            If tProp = "checked" Or tProp = "state"
              If GetGadgetState(*control\GetID())
                *propVM\SetBool(UI_ActivePropertyBindings()\sourceProp, #True)
              Else
                *propVM\SetBool(UI_ActivePropertyBindings()\sourceProp, #False)
              EndIf
            Else
              *propVM\SetString(UI_ActivePropertyBindings()\sourceProp, curText)
            EndIf
            handled = #True
          EndIf
          UI_ActivePropertyBindings()\isUpdating = #False
        EndIf
      EndIf
    EndIf
  Next

  ProcedureReturn handled
EndProcedure

Procedure UI_MVVM_UnregisterAll(*targetObj)
  ForEach UI_ActivePropertyBindings()
    If UI_ActivePropertyBindings()\control = *targetObj Or UI_ActivePropertyBindings()\viewModel = *targetObj
      DeleteElement(UI_ActivePropertyBindings())
    EndIf
  Next

  ForEach UI_ActiveCommandBindings()
    If UI_ActiveCommandBindings()\control = *targetObj Or UI_ActiveCommandBindings()\viewModel = *targetObj
      DeleteElement(UI_ActiveCommandBindings())
    EndIf
  Next

  ForEach UI_ActiveCollectionBindings()
    If UI_ActiveCollectionBindings()\control = *targetObj Or UI_ActiveCollectionBindings()\collection = *targetObj
      DeleteElement(UI_ActiveCollectionBindings())
    EndIf
  Next
EndProcedure

Namespace MVVM {

  Class BindingEngine {

    Public Method RegisterBinding(*control.UI::Gadget, targetProp.s, *viewModel.MVVM::ViewModelBase, sourceProp.s, mode.i = #UI_BindingMode_OneWay) {
      UI_MVVM_RegisterBinding(*control, targetProp, *viewModel, sourceProp, mode)
    }

    Public Method RegisterCommandBinding(*control.UI::Gadget, *viewModel.MVVM::ViewModelBase, commandName.s) {
      UI_MVVM_RegisterCommandBinding(*control, *viewModel, commandName)
    }

    Public Method RegisterCollectionBinding(*control.UI::Gadget, *collection.MVVM::ObservableCollection) {
      UI_MVVM_RegisterCollectionBinding(*control, *collection)
    }

    Public Method.b DispatchUIEvent(*control.UI::Gadget, eventType.i) {
      ProcedureReturn UI_MVVM_DispatchUIEvent(*control, eventType)
    }

    Public Method UnregisterAll(*targetObj) {
      UI_MVVM_UnregisterAll(*targetObj)
    }
  }

}

