; ============================================================================
; PureBasic OOP MVVM - Simple MVVM Test Application
; Main.pb - Application Entry Point
; ============================================================================

XIncludeFile "views/SimpleView.pbi"

; 1. Initialize OOP Application
Define *app.UI::Application = New UI::Application("PureBasic OOP Simple MVVM")

; 2. Instantiate ViewModel (State & Business Logic)
Define *vm.Demo::ViewModels::SimpleViewModel = New Demo::ViewModels::SimpleViewModel()

; 3. Instantiate View (Inject ViewModel as DataContext)
Define *view.Demo::Views::SimpleView = New Demo::Views::SimpleView(*vm)

; 4. Run Application Event Loop
*app\SetMainWindow(*view)
*app\Run()
