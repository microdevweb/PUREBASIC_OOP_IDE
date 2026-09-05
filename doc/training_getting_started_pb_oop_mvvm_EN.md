# Training Guide: Getting Started with OOP & the MVVM Pattern in PureBasic

*Step-by-step creation of your first modern reactive application*  
**Author:** MicrodevWeb  
**Framework:** PureBasic OOP v1.2 / v2.0  
**Compatibility:** PureBasic 6.x (Windows, Linux, macOS)  

---

## 📦 Module 1: Why OOP & MVVM in PureBasic?

PureBasic has always excelled at raw execution speed, compact binary footprints, and straightforward procedural syntax. However, as graphical applications grow in complexity, procedural code often runs into familiar hurdles:

- **Spaghetti Event Loops**: Massive `WaitWindowEvent()` loops containing dozens of nested `Select EventGadget()` blocks.
- **Tight Coupling**: Business calculation logic gets intertwined with `SetGadgetText()` and `GetGadgetText()` calls.
- **Tedious Coordinate Math**: Manual calculation of pixel coordinates and sizes during `#PB_Event_SizeWindow` events.

> **💡 The PureBasic OOP Solution**  
> This framework brings enterprise software design standards: **reusable classes (.pbo)**, **WPF-style responsive box models (StackPanel, Grid)**, and **MVVM (Model-View-ViewModel)** with automatic two-way data synchronization without manual boilerplate.

### 1.2. What We Will Build Together
Throughout this tutorial, we will construct a clean, practical application: **"Mini Reactive Task Manager & Counter"**.

The app lets users type task descriptions, click an Add button, and see live counter metrics and status feedback update automatically via *DataBinding*.

---

## 📁 Module 2: Project Directory Layout & Zero-Include Framework

A professional MVVM architecture relies on a clean separation of concerns in your project tree. Here is the recommended directory structure:

```text
MyMVVMProject/
├── constants/
│   └── AppConstants.pbi         <-- Shared Property & Command Identifiers
│
├── models/
│   └── TaskModel.pbi            <-- Data structures & pure business logic (optional)
│
├── viewmodels/
│   └── TaskViewModel.pbo        <-- ViewModel class inheriting MVVM::ViewModelBase
│
├── views/
│   └── MainView.xml             <-- Declarative XML User Interface
│
└── main.pb                      <-- Main Application Entry Point
```

### 2.1. Zero-Include Framework Architecture
Thanks to the intelligent PBO Transpiler, **you no longer need to manually write framework includes**. As soon as the transpiler encounters `UI::`, `MVVM::`, or XML view declarations, it automatically injects the framework into memory.

### 2.2. Standard Include Order in `main.pb`
You only need to include your own project files:

```purebasic
EnableExplicit

; 1. Shared Property and Command Constants
XIncludeFile "constants/AppConstants.pbi"

; 2. Data Models (if any)
; XIncludeFile "models/TaskModel.pbi"

; 3. ViewModel Classes (.pbo transpiled)
XIncludeFile "viewmodels/TaskViewModel.pbo"
```

---

## 🧩 Module 3: Understanding MVVM in 5 Minutes

The **MVVM** architecture neatly divides your application into three distinct responsibilities:

```text
┌─────────────────────────┐         ┌─────────────────────────┐
│       VIEW (UI)         │         │   VIEWMODEL (Engine)    │
│  MainView.xml or OOP UI │ ◄─────► │  Observable Properties  │
│   TextBox, Button, List │ Binding │  MVVM::StringProperty...│
└─────────────────────────┘         └────────────┬────────────┘
                                                 │ Logic
                                    ┌────────────▼────────────┐
                                    │       MODEL (Data)      │
                                    │    Structures / DB      │
                                    └─────────────────────────┘
```

- **Model**: Raw business entities, database records, and file storage.
- **ViewModel**: The reactive brain. Inherits from `MVVM::ViewModelBase` and manages **Observable Properties** (`MVVM::StringProperty`, `MVVM::IntProperty`). It automatically notifies listeners when values change.
- **View**: Declarative user interface written in XML or constructed using OOP controls. Controls bind to ViewModel properties using `{Binding PropertyName}`.
- **BindingEngine**: The synchronizer. Handles two-way binding (*TwoWay*): user keystrokes update the ViewModel, and ViewModel modifications automatically refresh the UI!

---

## 1️⃣ Module 4: Step 1 — Shared Constants

To eliminate typos between XML templates and ViewModel code, we place constants in `constants/AppConstants.pbi`:

```purebasic
; ============================================================================
; AppConstants.pbi - Declarative Identifiers for Bindings & Commands
; ============================================================================

; Observable Property Names (Bound to UI)
#PROP_TASK_TITLE  = "TaskTitle"
#PROP_TASK_COUNT  = "TaskCount"
#PROP_STATUS_MSG  = "StatusMessage"

; Command Names (Triggered by Buttons)
#CMD_ADD_TASK     = "AddTaskCommand"
#CMD_CLEAR_ALL    = "ClearAllCommand"
```

---

## 2️⃣ Module 5: Step 2 — Building the Reactive ViewModel

The ViewModel manages state and processes user commands. It has **zero coupling** to UI gadget IDs or window handles.

```purebasic
; ============================================================================
; TaskViewModel.pbo - Reactive Task Manager ViewModel
; ============================================================================
XIncludeFile "../constants/AppConstants.pbi"

Class TaskViewModel Extends MVVM::ViewModelBase {
  Public *TaskTitle.MVVM::StringProperty
  Public *TaskCount.MVVM::IntProperty
  Public *StatusMessage.MVVM::StringProperty

  ; --- Constructor: Register observable properties ---
  Public Method Init() {
    Super\Init()
    
    ; Register properties in the MVVM property registry
    This\*TaskTitle     = This\BindString(#PROP_TASK_TITLE, "")
    This\*TaskCount     = This\BindInt(#PROP_TASK_COUNT, 0)
    This\*StatusMessage = This\BindString(#PROP_STATUS_MSG, "Ready - No tasks registered.")
  }

  ; --- UI Command Dispatcher ---
  Public Method OnCommand(cmdName.s) {
    Select cmdName
      Case #CMD_ADD_TASK
        Protected title.s = Trim(This\*TaskTitle\GetValue())
        
        If title <> ""
          Protected currentCount.i = This\*TaskCount\GetValue() + 1
          
          ; Update properties -> UI automatically refreshes!
          This\*TaskCount\SetValue(currentCount)
          This\*StatusMessage\SetValue("Task added: " + title)
          This\*TaskTitle\SetValue("") ; Automatically clears input box
        Else
          This\*StatusMessage\SetValue("Please enter a task title first!")
        EndIf

      Case #CMD_CLEAR_ALL
        This\*TaskCount\SetValue(0)
        This\*TaskTitle\SetValue("")
        This\*StatusMessage\SetValue("All tasks have been cleared.")
    EndSelect
  }
}
```

---

## 3️⃣ Module 6: Step 3 — Designing the XML View

Using `XMLLoader`, the user interface is defined in `views/MainView.xml`:

```xml
<Window Title="PureBasic OOP Task Manager" Width="480" Height="300">
  <!-- Vertical StackPanel with outer margin and child spacing -->
  <StackPanel Margin="20" Spacing="12">
    
    <!-- Static Label -->
    <Label Text="Add a new task:" />

    <!-- Input box bound two-way to TaskTitle -->
    <TextBox Text="{Binding TaskTitle, Mode=TwoWay}" />

    <!-- Horizontal button action panel -->
    <StackPanel Orientation="Horizontal" Spacing="10">
      <Button Text="➕ Add Task" Command="AddTaskCommand" />
      <Button Text="🗑️ Clear All" Command="ClearAllCommand" />
    </StackPanel>

    <!-- Group Box dashboard with bound labels -->
    <GroupBox Text="Task Dashboard">
      <StackPanel Margin="12" Spacing="6">
        <Label Text="{Binding StatusMessage}" />
        <Label Text="Total Tasks Count: {Binding TaskCount}" />
      </StackPanel>
    </GroupBox>

  </StackPanel>
</Window>
```

---

## 4️⃣ Module 7: Step 4 — Main Entry Point

Bootstrapping the app in `main.pb` takes only a few lines:

```purebasic
; ============================================================================
; main.pb - Launching PureBasic OOP / MVVM Application
; ============================================================================
EnableExplicit

XIncludeFile "constants/AppConstants.pbi"
XIncludeFile "viewmodels/TaskViewModel.pbo"

; 1. Create Core Application
Protected *app.UI::Application = NewObject(UI::Application)

; 2. Instantiate and initialize ViewModel
Protected *vm.TaskViewModel = NewObject(TaskViewModel)
*vm\Init()

; 3. Load XML View and bind to ViewModel
Protected *window.UI::Window = UI::XMLLoader::LoadView("views/MainView.xml", *vm)

If *window
  ; 4. Show Window and Run Event Loop
  *window\Show()
  *app\Run()
  *window\Free()
EndIf

*vm\Free()
*app\Free()
```

> **🎉 Live Reactive Behavior!**  
> When running `main.pb`:  
> - Typing into the `TextBox` immediately updates the ViewModel's `TaskTitle`.  
> - Clicking "Add Task" invokes `OnCommand()`, increments the counter, updates the status message, and clears the input box automatically!  

---

## 📚 Module 8: UI Controls Reference & F1 Help

### 8.1. 18 Encapsulated UI Controls

| OOP Control | Native PB Gadget | Primary Use Case |
| :--- | :--- | :--- |
| `UI::Button` | `ButtonGadget` | Clickable action buttons with MVVM commands |
| `UI::TextBox` | `StringGadget` | Single-line text input with two-way binding |
| `UI::Editor` | `EditorGadget` | Multiline plain or formatted text editor |
| `UI::CheckBox` | `CheckBoxGadget` | Boolean checked state toggle |
| `UI::RadioButton` | `OptionGadget` | Mutually exclusive choice in a group |
| `UI::ComboBox` | `ComboBoxGadget` | Dropdown selection menu |
| `UI::ListView` | `ListViewGadget` | Vertical list of string items |
| `UI::ListIcon` | `ListIconGadget` | Multi-column grid with icons and row selection |
| `UI::TreeView` | `TreeGadget` | Hierarchical tree view with expandable nodes |
| `UI::DatePicker` | `DateGadget` | Date picker and calendar dropdown |
| `UI::SpinBox` | `SpinGadget` | Numeric entry field with up/down stepper buttons |
| `UI::Slider` | `TrackBarGadget` | Continuous numerical range slider |
| `UI::ProgressBar` | `ProgressBarGadget` | Task execution progress bar |
| `UI::GroupBox` | `FrameGadget` | Visual titled container frame |
| `UI::Label` | `TextGadget` | Static or bound informative text |
| `UI::ToggleSwitch` | `CanvasGadget` | Animated modern ON/OFF switch |
| `UI::TabControl` | `PanelGadget` | Tabbed multi-view container |

### 8.2. F1 Contextual Help in the IDE
In the PureBasic IDE, place your cursor on any OOP keyword (`Class`, `Method`, `Super`, `Property`...) or UI component (`Button`, `Editor`, `Grid`, `ObservableObject`...) and press **F1** to open its documentation page with full inheritance trees and examples.
