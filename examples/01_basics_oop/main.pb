; ============================================================================
; PureBasic OOP - Example 01: Basics of Object-Oriented Programming
; Covers: Classes, Encapsulation, Constructors (Init), Destructors (Free),
;         Inheritance (Extends), Polymorphism and Super\Init()
; ============================================================================

EnableExplicit

; --- Abstract Base Class ---
Namespace Animals {

  Abstract Class Animal {
    Protected name.s
    Protected age.i

    Public Method Init(name_p.s, age_p.i) {
      This\name = name_p
      This\age  = age_p
    }

    Public Method.s GetName() {
      ProcedureReturn This\name
    }

    Public Method.i GetAge() {
      ProcedureReturn This\age
    }

    ; Abstract method to be overridden by derived classes
    Public Abstract Method Speak()

    Public Method DisplayInfo() {
      Debug "Animal [" + This\name + "] - Age: " + Str(This\age) + " year(s)"
    }

    Public Method Free() {
      Debug "Destroying Animal instance: " + This\name
    }
  }

  ; --- Derived Class: Dog ---
  Class Dog Extends Animal {
    Protected breed.s

    Public Method Init(name_p.s, age_p.i, breed_p.s) {
      Super\Init(name_p, age_p)
      This\breed = breed_p
    }

    Public Method Speak() {
      Debug This\name + " (" + This\breed + ") says: Woof! Woof!"
    }
  }

  ; --- Derived Class: Cat ---
  Class Cat Extends Animal {
    Protected isLazy.b

    Public Method Init(name_p.s, age_p.i, isLazy_p.b = #True) {
      Super\Init(name_p, age_p)
      This\isLazy = isLazy_p
    }

    Public Method Speak() {
      Debug This\name + " says: Meow..."
    }
  }

}

; --- Main Demonstration ---
OpenConsole("PureBasic OOP - Basics Demonstration")

PrintN("=== 1. Instantiating Objects ===")
Define *dog.Animals::Dog = New Animals::Dog("Rex", 3, "German Shepherd")
Define *cat.Animals::Cat = New Animals::Cat("Felix", 2, #True)

PrintN("=== 2. Polymorphic Calls ===")
*dog\DisplayInfo()
*dog\Speak()

PrintN("")
*cat\DisplayInfo()
*cat\Speak()

PrintN("=== 3. Memory Cleanup ===")
*dog\Free()
*cat\Free()

PrintN("")
PrintN("Press Enter to exit...")
Input()
CloseConsole()
