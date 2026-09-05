; ============================================================================
; PureBasic OOP GUI Framework - Example 02: Responsive Layout (WPF Style)
; Demonstrates DockPanel, StackPanel, and Grid responsive layouts
; ============================================================================

Using UI
Using UI::Layouts
Using UI::Controls

EnableExplicit

; 1. Initialize Application
Define *app.Application = New Application("PureBasic OOP Responsive Demo")

; 2. Main Window
Define *win.Window = New Window("PureBasic OOP - Responsive WPF Layout Demo", 900, 600)

; 3. Root Container: DockPanel
Define *rootDock.DockPanel = New DockPanel(#True)
*rootDock\SetPaddingAll(5)

; 4. Header (Dock Top)
Define *headerStack.StackPanel = New StackPanel(#UI_Orientation_Horizontal, 8)
*headerStack\SetPadding(5, 5, 5, 5)
*headerStack\SetHeight(45)

Define *btnNew.Button = New Button("Nouveau", 90, 32)
Define *btnOpen.Button = New Button("Ouvrir", 90, 32)
Define *btnSave.Button = New Button("Enregistrer", 100, 32)
*headerStack\AddChild(*btnNew)
*headerStack\AddChild(*btnOpen)
*headerStack\AddChild(*btnSave)

*rootDock\SetDock(*headerStack, #UI_Dock_Top)

; 5. Footer / Status Bar (Dock Bottom)
Define *statusStack.StackPanel = New StackPanel(#UI_Orientation_Horizontal, 10)
*statusStack\SetHeight(30)
Define *lblStatus.Button = New Button("Statut : Prêt - Redimensionnez la fenêtre pour tester le responsive !", 600, 24)
*statusStack\AddChild(*lblStatus)

*rootDock\SetDock(*statusStack, #UI_Dock_Bottom)

; 6. Sidebar (Dock Left)
Define *sidebar.StackPanel = New StackPanel(#UI_Orientation_Vertical, 8)
*sidebar\SetWidth(180)
*sidebar\SetPadding(5, 5, 5, 5)

Define *btnNav1.Button = New Button("Tableau de bord", 170, 32)
Define *btnNav2.Button = New Button("Projets", 170, 32)
Define *btnNav3.Button = New Button("Composants", 170, 32)
Define *btnNav4.Button = New Button("Paramètres", 170, 32)

*sidebar\AddChild(*btnNav1)
*sidebar\AddChild(*btnNav2)
*sidebar\AddChild(*btnNav3)
*sidebar\AddChild(*btnNav4)

*rootDock\SetDock(*sidebar, #UI_Dock_Left)

; 7. Main Work Area: Responsive Grid (Dock Fill)
Define *mainGrid.Grid = New Grid()
*mainGrid\SetPaddingAll(5)

; Column proportions: 3* (75%) and 1* (25%)
*mainGrid\AddColumn("3*")
*mainGrid\AddColumn("1*")

; Row sizes: 40px Top, * (Remaining)
*mainGrid\AddRow("40")
*mainGrid\AddRow("*")

; Row 0: Search bar & action
Define *searchBox.TextBox = New TextBox(0, 0, 100, 30, "Rechercher dans les composants...")
*mainGrid\SetCell(*searchBox, 0, 0)

Define *btnFilter.Button = New Button("Filtrer", 100, 30)
*mainGrid\SetCell(*btnFilter, 0, 1)

; Row 1: Main Editor and Properties panel
Define *mainEditor.TextBox = New TextBox(0, 0, 100, 100, "Zone principale de travail / Éditeur...")
*mainGrid\SetCell(*mainEditor, 1, 0)

Define *propEditor.TextBox = New TextBox(0, 0, 100, 100, "Propriétés sélectionnées...")
*mainGrid\SetCell(*propEditor, 1, 1)

*rootDock\SetDock(*mainGrid, #UI_Dock_Fill)

; 8. Attach Root Content to Window
*win\SetContent(*rootDock)

; 9. Run Application
*app\SetMainWindow(*win)
*app\Run()
