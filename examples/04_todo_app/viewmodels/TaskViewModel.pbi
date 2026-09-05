; ============================================================================
; Application Gestionnaire de Tâches (TodoApp) - ViewModel Réactif
; Fichier : viewmodels/TaskViewModel.pbi
; ============================================================================

XIncludeFile "../constants/AppConstants.pbi"
XIncludeFile "../models/TaskModel.pbi"

Namespace TodoApp {

  Class TaskViewModel Extends MVVM::ViewModelBase {
    Public *TaskTitle.MVVM::StringProperty
    Public *TaskCount.MVVM::IntProperty
    Public *StatusMessage.MVVM::StringProperty
    Public *TaskListContent.MVVM::StringProperty

    ; --- Constructeur : Initialisation et enregistrement des propriétés ---
    Public Method Init() {
      Super\Init()
      
      ; Enregistrement des propriétés observables dans le registre MVVM
      This\*TaskTitle       = This\BindString(#PROP_TASK_TITLE, "")
      This\*TaskCount       = This\BindInt(#PROP_TASK_COUNT, 0)
      This\*StatusMessage   = This\BindString(#PROP_STATUS_MSG, "Prêt - Aucune tâche enregistrée.")
      This\*TaskListContent = This\BindString(#PROP_LIST_CONTENT, "")
    }

    ; --- Gestionnaire des Commandes UI ---
    Public Method.b OnCommand(cmdName.s, *param = 0) {
      Select cmdName
        Case #CMD_ADD_TASK
          Protected title.s = Trim(This\*TaskTitle\GetValue())
          
          If title <> ""
            Protected currentCount.i = This\*TaskCount\GetValue() + 1
            
            ; Mise à jour des propriétés -> Notification automatique de la Vue !
            This\*TaskCount\SetValue(currentCount)
            This\*StatusMessage\SetValue("Tâche ajoutée avec succès : '" + title + "'")
            
            Protected curList.s = This\*TaskListContent\GetValue()
            If curList <> "" : curList + #CRLF$ : EndIf
            curList + "• [" + Str(currentCount) + "] " + title
            This\*TaskListContent\SetValue(curList)
            
            ; Réinitialise le champ de saisie
            This\*TaskTitle\SetValue("")
            ProcedureReturn #True
          Else
            This\*StatusMessage\SetValue("Erreur : Veuillez saisir un libellé de tâche.")
            ProcedureReturn #True
          EndIf

        Case #CMD_CLEAR_ALL
          This\*TaskCount\SetValue(0)
          This\*TaskTitle\SetValue("")
          This\*TaskListContent\SetValue("")
          This\*StatusMessage\SetValue("Toutes les tâches ont été réinitialisées.")
          ProcedureReturn #True
      EndSelect
      
      ProcedureReturn #False
    }
  }

}
