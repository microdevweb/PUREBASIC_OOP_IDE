# PureBasic OOP Reference Manual (English)

Welcome to the official documentation for the PureBasic Object-Oriented transpiler and language layer.

---

## 1. Foundations of Object-Oriented Programming (OOP)

Object-Oriented Programming (OOP) is a programming paradigm organized around **data** and their **associated operations**, packaged into self-contained units called **Objects**.

It is built on 5 fundamental pillars:

### 1.1 Classes and Objects
- **Class**: The blueprint defining the structure (fields/attributes) and behavior (methods).
- **Object (Instance)**: A concrete entity instantiated in memory based on a class (e.g., class `Dog` instantiates the object `Buddy`).

### 1.2 Encapsulation
Encapsulation bundles data and the functions that manipulate them, restricting unauthorized external access:
- **`Public`**: Accessible anywhere (both inside and outside the object).
- **`Protected`**: Accessible only within the declaring class and its derived (child) subclasses.
- **`Private`**: Accessible strictly inside the declaring class.

### 1.3 Inheritance (`Extends`)
Inheritance enables a derived (child) class to reuse and extend fields and methods from a base (parent) class, promoting code reuse and clear hierarchies.

### 1.4 Polymorphism (Dynamic VTable Dispatch)
Polymorphism allows manipulating various derived objects uniformly via a reference to their common base class. Method calls dynamically resolve at runtime to the real object's implementation through the Virtual Method Table (*VTable*).

### 1.5 Abstraction (Abstract Classes & Abstract Methods)
Abstraction defines a generalized contract without supplying all implementation details:
- **Abstract Class** (`Abstract Class`): An incomplete class serving as a blueprint/contract. It **cannot be instantiated directly**.
- **Abstract Method** (`Abstract Method`): A method prototype without a body. Any concrete child class **must** implement this method.
- **Concrete / Default Method**: An abstract class can also provide methods with default implementation, which child classes can inherit as-is, override completely, or override partially using `Super::`.

---

## 2. PureBasic OOP Syntax & Grammar (.pbo)

### 2.1 Declaring Abstract and Concrete Classes

```oop
; ----------------------------------------------------------------------------
; 1. ABSTRACT CLASS (Base contract / blueprint)
; ----------------------------------------------------------------------------
Abstract Class Shape
  Protected name.s
  Protected color.s

  ; Constructor
  Public Method Init(name_p.s, color_p.s)

  ; Abstract Methods (Contract: mandatory in concrete child classes)
  Public Abstract Method.d CalculateArea()
  Public Abstract Method.d CalculatePerimeter()
  Public Abstract Method Draw()

  ; Concrete Method with default implementation in abstract class
  Public Method DisplayInfo()
  
  ; Destructor
  Public Method Free()
EndClass

; ----------------------------------------------------------------------------
; 2. CONCRETE CLASS (Inherits from Abstract Class)
; ----------------------------------------------------------------------------
Class Rectangle Extends Shape
  Protected width.d
  Protected height.d

  Public Method Init(name_p.s, color_p.s, w.d, h.d)
  
  ; Mandatory implementations of abstract methods
  Public Method.d CalculateArea()
  Public Method.d CalculatePerimeter()
  Public Method Draw()
  
  ; Overriding the default method
  Public Method DisplayInfo()
  
  Public Method Free()
EndClass
```

---

### 2.2 Method Implementation, `This`, and `Super::`

Methods access instance attributes and internal methods using `This`.
To invoke a parent class's behavior (partial override), use `Super::`.

```oop
; --- Abstract Class Implementation ---

Method Shape::Init(name_p.s, color_p.s)
  This\name = name_p
  This\color = color_p
EndMethod

Method Shape::DisplayInfo()
  PrintN("[Shape: " + This\name + " | Color: " + This\color + "]")
EndMethod

Method Shape::Free()
  FreeStructure(This)
EndMethod

; --- Concrete Subclass Rectangle Implementation ---

Method Rectangle::Init(name_p.s, color_p.s, w.d, h.d)
  Super::Init(name_p, color_p) ; Initialize inherited base attributes
  This\width = w
  This\height = h
EndMethod

Method.d Rectangle::CalculateArea()
  ProcedureReturn This\width * This\height
EndMethod

Method.d Rectangle::CalculatePerimeter()
  ProcedureReturn 2 * (This\width + This\height)
EndMethod

Method Rectangle::Draw()
  PrintN("   ==> [DRAW] Rectangle " + StrD(This\width, 2) + "x" + StrD(This\height, 2) + " (" + This\color + ")")
EndMethod

; Partial Override: invoke Super::DisplayInfo() then add details
Method Rectangle::DisplayInfo()
  Super::DisplayInfo()
  PrintN("       Dimensions : " + StrD(This\width, 2) + " x " + StrD(This\height, 2) + " | Area=" + StrD(This\CalculateArea(), 2))
EndMethod

Method Rectangle::Free()
  Super::Free()
EndMethod
```

---

### 2.3 Usage and Polymorphism

```oop
OpenConsole()

; 1. Concrete Instantiations
Define *rect.Rectangle = New Rectangle("MyRectangle", "Blue", 10.0, 5.0)
Define *circle.Circle = New Circle("MyCircle", "Red", 4.0)

; Note: Direct instantiation of an abstract class is strictly forbidden:
; Define *err.Shape = New Shape(...) ; -> Transpilation error!

; 2. Dynamic Polymorphism using a List of Abstract Class type
NewList *shapes.Shape()

AddElement(*shapes()) : *shapes() = *rect
AddElement(*shapes()) : *shapes() = *circle
AddElement(*shapes()) : *shapes() = New Rectangle("BigRectangle", "Green", 20.0, 15.0)

; 3. Polymorphic loop: dynamically dispatches to the concrete class methods
ForEach *shapes()
  *shapes()\DisplayInfo()
  *shapes()\Draw()
  PrintN("   Area = " + StrD(*shapes()\CalculateArea(), 2))
  PrintN("")
Next

; 4. Polymorphic memory cleanup
ForEach *shapes()
  *shapes()\Free()
Next
ClearList(*shapes())

CloseConsole()
```

---

## 3. Namespaces & Multi-File Projects

### 3.1 Namespace Declaration & Nesting
Namespaces logically group classes and avoid naming collisions across large projects:

```oop
Namespace Game::Graphics
  Class Renderer
    Protected width.i, height.i
    Public Method Init(w.i, h.i)
    Public Method Render()
  EndClass
EndNamespace
```

### 3.2 Usage, `Using` Directive & Aliases
Classes inside namespaces can be accessed via full qualification, `Using` imports, or aliases:

```oop
; 1. Fully Qualified Name
Define *r1.Game::Graphics::Renderer = New Game::Graphics::Renderer(1920, 1080)

; 2. Using Directive
Using Game::Graphics
Define *r2.Renderer = New Renderer(1280, 720)

; 3. Namespace Alias
Namespace GFX = Game::Graphics
Define *r3.GFX::Renderer = New GFX::Renderer(800, 600)
```

### 3.3 Multi-File Projects (One File Per Class)
The transpiler natively and recursively processes `IncludeFile` and `XIncludeFile`:

**File `entities/Animal.pbo`:**
```oop
Namespace Game::Entities
Abstract Class Animal
  Protected name.s
  Public Method Init(name_p.s)
  Public Abstract Method Speak()
EndClass
EndNamespace
```

**File `entities/Dog.pbo`:**
```oop
Namespace Game::Entities
Class Dog Extends Animal
  Public Method Speak()
    PrintN(This\name + " barks!")
  EndMethod
EndClass
EndNamespace
```

**Main Entry File `main.pbo`:**
```oop
XIncludeFile "entities/Animal.pbo"
XIncludeFile "entities/Dog.pbo"

Using Game::Entities

OpenConsole()
Define *d.Dog = New Dog("Rex")
*d\Speak()
CloseConsole()
```

---

## 4. Dual Syntax: Classic PureBasic vs C/C# Style (`{ }`)

To combine PureBasic's **blazing-fast native execution** with a **clean, modern, non-verbose syntax**, the transpiler supports a comprehensive dual syntax mode. You can write classic PureBasic keywords or modern C-style curly braces `{ }` seamlessly!

### 4.1 Block Equivalences

| Block | Classic PureBasic | C-Style `{ }` |
| :--- | :--- | :--- |
| **Namespace** | `Namespace MyNS ... EndNamespace` | `Namespace MyNS { ... }` |
| **Class** | `Class MyClass ... EndClass` | `Class MyClass { ... }` |
| **Method** | `Method MyMethod() ... EndMethod` | `Method MyMethod() { ... }` |
| **Procedure** | `Procedure Compute(x.i) ... EndProcedure` | `Procedure Compute(x.i) { ... }` |
| **Condition If** | `If a > 0 ... Else ... EndIf` | `If (a > 0) { ... } Else { ... }` |
| **For Loop** | `For i = 0 To 10 ... Next` | `For i = 0 To 10 { ... }` |
| **While Loop** | `While x < 100 ... Wend` | `While x < 100 { ... }` |
| **Repeat Loop** | `Repeat ... Until x = 0` | `Repeat { ... } Until x = 0` |
| **Structure** | `Structure Point ... EndStructure` | `Structure Point { ... }` |

### 4.2 Modern C-Style Example

```oop
Namespace Game::Entities {

  Class Dog Extends Animal {
    Protected breed.s

    Public Method Init(name.s, breed_p.s) {
      Super::Init(name)
      This\breed = breed_p
    }

    Public Method Speak() {
      If (This\breed = "Husky") {
        PrintN("Howl!")
      } Else {
        PrintN("Woof!")
      }
    }
  }

}

Procedure TestDog() {
  Using Game::Entities
  Define *d.Dog = New Dog("Rex", "Husky")
  *d\Speak()
}
```

---

## 5. Object-Oriented PureBasic GUI Framework (`src/ui/UI.pbo`)

All PureBasic windows and gadgets can now be manipulated as native objects with virtual event dispatchers (`OnClick()`, `OnChange()`, `OnPaint()`, `OnClose()`, etc.), class inheritance, and custom **Canvas-based Custom Gadgets**.

### 5.1 GUI Architecture

- **`UI::Component`**: Common root abstract class (`id`, `tag`, `x`, `y`, `width`, `height`, `isVisible`, `isEnabled`, `userData`).
- **`UI::Gadget`**: Abstract base class for all gadgets (`SetText`, `GetText`, `SetPosition`, `SetVisible`, `SetEnabled`, `SetToolTip`, `SetColor`, `SetFont`, `SetFocus`, and virtual callbacks `OnClick`, `OnChange`, `OnFocus`, `OnLostFocus`, `OnRightClick`, `OnCustomEvent`).
- **`UI::Window`**: OOP Window encapsulation (`OpenWindow`, `Close`, `SetTitle`, `SetPosition`, and virtual callbacks `OnClose`, `OnResize`, `OnMove`, `OnMinimize`, `OnMaximize`, `OnRestore`).
- **`UI::Application`**: Global application manager and centralized event loop dispatcher (`Run()`, `Quit()`).
- **`UI::CustomGadget`**: CanvasGadget owner-drawn base class with virtual `OnPaint(w, h)` and mouse/keyboard hooks (`OnMouseEnter`, `OnMouseDown`, `OnMouseUp`, `OnMouseMove`, `OnKeyDown`, `Redraw()`).

### 5.2 Built-in Controls

| Class | Underlying PureBasic Gadget | Main Features |
| :--- | :--- | :--- |
| **`UI::Button`** | `ButtonGadget` | Left click handling via `OnClick()` |
| **`UI::TextBox`** | `StringGadget` | `IsReadOnly()`, `SetReadOnly()`, `OnChange()` |
| **`UI::Label`** | `TextGadget` | Static and dynamic text display |
| **`UI::CheckBox`** | `CheckBoxGadget` | `IsChecked()`, `SetChecked(state)` |
| **`UI::ProgressBar`** | `ProgressBarGadget` | `GetValue()`, `SetValue()`, `SetRange()` |
| **`UI::Slider`** | `TrackBarGadget` | `GetValue()`, `SetValue()` |
| **`UI::ComboBox`** | `ComboBoxGadget` | `AddItem()`, `GetSelectedIndex()`, `GetSelectedItem()`, `Clear()` |
| **`UI::Controls::ToggleSwitch`** | `UI::CustomGadget` *(Canvas)* | Modern iOS-style toggle switch with animated states |

### 5.3 Complete GUI OOP Example

```oop
XIncludeFile "ui/UI.pbo"

Using UI

; 1. Custom Button with business logic
Class GreetButton Extends UI::Button {
  Protected *nameInput.UI::TextBox

  Public Method BindInput(*txt.UI::TextBox) {
    This\*nameInput = *txt
  }

  Public Method OnClick() {
    If (This\*nameInput) {
      MessageRequester("Hello", "Hello " + This\*nameInput\GetText() + "!")
    }
  }
}

; 2. Encapsulated OOP Window
Class MainWindow Extends UI::Window {
  Protected *input.UI::TextBox
  Protected *btn.GreetButton
  Protected *switch.UI::Controls::ToggleSwitch

  Public Method Init() {
    Super::Init("My OOP Application", #PB_Ignore, #PB_Ignore, 400, 200, #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
    UI::RegisterWindow(This\id, This)

    This\*input = New UI::TextBox(20, 20, 200, 25, "Alice")
    This\*btn = New GreetButton(230, 18, 140, 28, "Greet")
    This\*btn\BindInput(This\*input)

    This\*switch = New UI::Controls::ToggleSwitch(20, 70, 50, 26, #True)
  }

  Public Method.b OnClose() {
    ProcedureReturn #True ; Allow window closing
  }
}

; 3. Main entry point
Define *app.UI::Application = New UI::Application()
Define *win.MainWindow = New MainWindow()

*app\Run()
```

---

## 6. Generated PureBasic Mechanics

The transpiler turns `.pbo` source files into fast, clean PureBasic `.pb` code:
1. **Interfaces (`_vt`)**: Method prototypes with full namespace prefixes (e.g. `Game_Graphics_Renderer_vt`).
2. **Instance Structures (`_Inst`)**: Memory structures with `*VTable` pointer header followed by class fields.
3. **Safe Internal Dispatch (`*This_vt`)**: Method calls `This\Method()` resolve through the polymorph interface pointer `*This_vt`.
4. **DataSections**: Generated for concrete classes only (abstract classes skip allocating unused VTables).
5. **Constructors (`New_<Class>`)**: Auto-generated with constructor parameter inheritance from parent classes.
6. **Semantic Validation & Source Mapping**:
   - Forbids instantiation of abstract classes.
   - Enforces implementation of all inherited abstract methods in concrete subclasses.
   - Generates `.pb.map` file for mapping compiler messages back to `.pbo` source line numbers.

---

## 7. Execution & Compilation Guide

### Transpile `.pbo` to `.pb`:
```cmd
"compiler/transpiler.exe" "src/my_file.pbo" "src/my_file_generated.pb"
```

### Validate Syntax via CLI:
```cmd
"compiler/transpiler.exe" --check "src/my_file.pbo"
```

### Compile Generated PureBasic Executable:
```cmd
"C:\Program Files\PureBasic\Compilers\pbcompiler.exe" "src/my_file_generated.pb" /EXE "src/my_file.exe"
```
