; ============================================================================
; PureBasic OOP GUI Framework - ObservableCollection.pbi
; Synchronized Dynamic Collection with Change Notifications
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "ObservableObject.pbi"

#UI_CollectionAction_Add    = 1
#UI_CollectionAction_Remove = 2
#UI_CollectionAction_Clear  = 3
#UI_CollectionAction_Update = 4

Structure UI_CollectionObserver
  *observer
  *callback
EndStructure

Namespace MVVM {

  Class ObservableCollection Extends ObservableObject {
    Protected List items.s()
    Protected List colObservers.UI_CollectionObserver()

    Public Method Init() {
      Super\Init()
    }

    Public Method Free() {
      ClearList(This\items())
      ClearList(This\colObservers())
      Super\Free()
    }

    ; ------------------------------------------------------------------------
    ; Observer Registration
    ; ------------------------------------------------------------------------
    Public Method RegisterCollectionObserver(*observer, *cb) {
      If *observer And *cb
        ForEach This\colObservers()
          If This\colObservers()\observer = *observer
            This\colObservers()\callback = *cb
            ProcedureReturn
          EndIf
        Next

        AddElement(This\colObservers())
        This\colObservers()\observer = *observer
        This\colObservers()\callback = *cb
      EndIf
    }

    Public Method UnregisterCollectionObserver(*observer) {
      If *observer
        ForEach This\colObservers()
          If This\colObservers()\observer = *observer
            DeleteElement(This\colObservers())
            Break
          EndIf
        Next
      EndIf
    }

    Protected Method NotifyCollectionChanged(actionType.i, index.i, itemText.s) {
      ForEach This\colObservers()
        If This\colObservers()\callback
          CallFunctionFast(This\colObservers()\callback, This, actionType, index, @itemText)
        EndIf
      Next
      This\NotifyPropertyChanged("Count")
    }

    ; ------------------------------------------------------------------------
    ; Collection Operations
    ; ------------------------------------------------------------------------
    Public Method Add(item.s) {
      AddElement(This\items())
      This\items() = item
      Protected idx.i = ListIndex(This\items())
      This\NotifyCollectionChanged(#UI_CollectionAction_Add, idx, item)
    }

    Public Method Insert(index.i, item.s) {
      If index >= 0 And index <= ListSize(This\items())
        SelectElement(This\items(), index)
        InsertElement(This\items())
        This\items() = item
        This\NotifyCollectionChanged(#UI_CollectionAction_Add, index, item)
      Else
        This\Add(item)
      EndIf
    }

    Public Method Remove(index.i) {
      If index >= 0 And index < ListSize(This\items())
        SelectElement(This\items(), index)
        Protected removedText.s = This\items()
        DeleteElement(This\items())
        This\NotifyCollectionChanged(#UI_CollectionAction_Remove, index, removedText)
      EndIf
    }

    Public Method Clear() {
      ClearList(This\items())
      This\NotifyCollectionChanged(#UI_CollectionAction_Clear, 0, "")
    }

    Public Method.i Count() {
      ProcedureReturn ListSize(This\items())
    }

    Public Method.s GetItem(index.i) {
      If index >= 0 And index < ListSize(This\items())
        SelectElement(This\items(), index)
        ProcedureReturn This\items()
      EndIf
      ProcedureReturn ""
    }

    Public Method SetItem(index.i, item.s) {
      If index >= 0 And index < ListSize(This\items())
        SelectElement(This\items(), index)
        This\items() = item
        This\NotifyCollectionChanged(#UI_CollectionAction_Update, index, item)
      EndIf
    }
  }

}
