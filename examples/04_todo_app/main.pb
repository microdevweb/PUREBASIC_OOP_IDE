; ============================================================================
; Application Gestionnaire de Tâches (TodoApp) - Point d'Entrée Principal
; Fichier : main.pb
; ============================================================================

EnableExplicit

; 1. Inclusion de la Vue Principale (Le Framework UI & MVVM est auto-inclus par le transpileur !)
XIncludeFile "views/MainWindow.pbi"

; 2. Instanciation de l'Application PureBasic OOP
Define *app.UI::Application = New UI::Application("TodoApp MVVM")

; 3. Instanciation du ViewModel (État réactif et logique métier)
Define *vm.TodoApp::TaskViewModel = New TodoApp::TaskViewModel()

; 4. Instanciation de la Vue (Injection du ViewModel en DataContext)
Define *mainWindow.TodoApp::MainWindow = New TodoApp::MainWindow(*vm)

; 5. Définition de la fenêtre principale et lancement de la boucle d'événements
*app\SetMainWindow(*mainWindow)
*app\Run()
