; ============================================================================
; PureBasic OOP MVVM - SimpleViewModel.pbi
; Simple ViewModel for testing MVVM DataBinding and Commands
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "../SimpleConstants.pbi"

Namespace Demo::ViewModels {

  ; --------------------------------------------------------------------------
  ; ViewModel Class
  ; Extends ViewModelBase which provides DataBinding and Command dispatching.
  ; --------------------------------------------------------------------------
  Class SimpleViewModel Extends MVVM::ViewModelBase {
    ; Strongly-typed Observable Property objects:
    ; Calling Set() or Increment() automatically updates the bound UI.
    Public *ClickMessage.MVVM::StringProperty
    Public *StatusText.MVVM::StringProperty
    Public *ClickCount.MVVM::IntProperty
    Public *TotalClicksText.MVVM::StringProperty

    Public Method Init() {
      Super\Init()

      ; ----------------------------------------------------------------------
      ; Property Registration
      ; Bind each typed property to its corresponding shared constant.
      ; ----------------------------------------------------------------------
      This\*ClickMessage    = This\BindString(#PROP_CLICK_MESSAGE, "No button clicked yet")
      This\*StatusText      = This\BindString(#PROP_STATUS_TEXT, "Status: Ready")
      This\*ClickCount       = This\BindInt(#PROP_CLICK_COUNT, 0)
      This\*TotalClicksText = This\BindString(#PROP_TOTAL_CLICKS_TEXT, "Total Clicks: 0")
    }

    ; ------------------------------------------------------------------------
    ; Helper Method: formats the integer click count into a display string
    ; ------------------------------------------------------------------------
    Public Method.s GetClickCountFormatted() {
      ProcedureReturn "Total Clicks: " + This\*ClickCount\GetString()
    }

    ; ------------------------------------------------------------------------
    ; Command Dispatcher (OnCommand)
    ; Triggered automatically when the user clicks a Button with Click="#CMD_..."
    ; ------------------------------------------------------------------------
    Public Method.b OnCommand(cmd.s, *param = 0) {
      Select cmd
        Case #CMD_CLICK_BTN1
          This\*ClickCount\Increment()
          This\*ClickMessage\Set("You clicked on Button 1")
          This\*TotalClicksText\Set(This\GetClickCountFormatted())
          This\*StatusText\Set("Status: Button 1 clicked")
          ProcedureReturn #True

        Case #CMD_CLICK_BTN2
          This\*ClickCount\Increment()
          This\*ClickMessage\Set("You clicked on Button 2")
          This\*TotalClicksText\Set(This\GetClickCountFormatted())
          This\*StatusText\Set("Status: Button 2 clicked")
          ProcedureReturn #True

        Case #CMD_CLICK_BTN3
          This\*ClickCount\Increment()
          This\*ClickMessage\Set("You clicked on Button 3")
          This\*TotalClicksText\Set(This\GetClickCountFormatted())
          This\*StatusText\Set("Status: Button 3 clicked")
          ProcedureReturn #True

        Case #CMD_RESET
          This\*ClickCount\Set(0)
          This\*ClickMessage\Set("Values reset to default")
          This\*TotalClicksText\Set(This\GetClickCountFormatted())
          This\*StatusText\Set("Status: Reset completed")
          ProcedureReturn #True
      EndSelect

      ProcedureReturn #False
    }
  }

}
