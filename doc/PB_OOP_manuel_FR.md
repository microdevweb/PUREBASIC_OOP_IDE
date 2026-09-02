# Manuel de Référence PureBasic OOP (Français)

Bienvenue dans la documentation officielle du transpileur et de la couche Orientée Objet pour PureBasic.

---

## 1. Les Fondements de la Programmation Orientée Objet (POO)

La Programmation Orientée Objet (POO) est un paradigme de programmation qui structure une application autour de **données** et de **traitements associés**, regroupés en entités cohérentes appelées **Objets**.

Elle repose sur 5 piliers fondamentaux :

### 1.1 Les Classes et les Objets
- **La Classe** : C'est le plan de construction (ou moule) qui définit la structure (attributs / champs) et le comportement (méthodes).
- **L'Objet (ou Instance)** : C'est une occurrence concrète créée en mémoire à partir d'une classe (par exemple, la classe `Chien` permet de créer l'objet `Médor`).

### 1.2 L'Encapsulation
L'encapsulation permet de regrouper les données et les fonctions qui les manipulent, tout en protégeant les données internes contre les accès extérieurs non autorisés :
- **`Public`** : Accessible depuis n'importe où (à l'intérieur et à l'extérieur de l'objet).
- **`Protected`** : Accessible uniquement par la classe qui le déclare et par ses classes filles (héritières).
- **`Private`** : Strictement réservé à la classe qui le déclare.

### 1.3 L'Héritage (`Extends`)
L'héritage permet à une classe dérivée (fille) de réutiliser et d'étendre les attributs et les méthodes d'une classe de base (parente). Cela favorise la réutilisation du code et l'organisation hiérarchique.

### 1.4 Le Polymorphisme (Dispatch Dynamique via VTable)
Le polymorphisme permet de manipuler différents types d'objets dérivés à travers une référence commune vers leur classe parente. Lors de l'appel d'une méthode, le programme exécute dynamiquement la version spécifique à la classe réelle de l'objet grâce à la table des méthodes virtuelles (*VTable*).

### 1.5 L'Abstraction (Classes et Méthodes Abstraites)
L'abstraction permet de définir un concept général sans en fournir toute l'implémentation :
- **Classe Abstraite** (`Abstract Class`) : Une classe incomplète servant de modèle ou de contrat. Elle **ne peut pas être instanciée directement**.
- **Méthode Abstraite** (`Abstract Method`) : Un prototype de méthode sans corps d'implémentation. Toute classe fille concrète a **l'obligation** d'implémenter cette méthode.
- **Méthode Concrète / Par Défaut** : Une classe abstraite peut aussi contenir des méthodes avec un code par défaut, que la classe fille peut conserver, surcharger totalement ou surcharger partiellement via `Super::`.

---

## 2. Syntaxe & Grammaire Objet PureBasic (.pbo)

### 2.1 Déclaration des Classes Abstraites et Concrètes

```oop
; ----------------------------------------------------------------------------
; 1. CLASSE ABSTRAITE (Modèle de base / Contrat)
; ----------------------------------------------------------------------------
Abstract Class FormeGeometrique
  Protected nom.s
  Protected couleur.s

  ; Constructeur
  Public Method Init(nom_p.s, couleur_p.s)

  ; Méthodes Abstraites (Obligatoires dans les classes filles concrètes)
  Public Abstract Method.d CalculerAire()
  Public Abstract Method.d CalculerPerimetre()
  Public Abstract Method Dessiner()

  ; Méthode concrète avec implémentation par défaut dans la classe abstraite
  Public Method AfficherInfos()
  
  ; Destructeur
  Public Method Free()
EndClass

; ----------------------------------------------------------------------------
; 2. CLASSE CONCRÈTE (Hérite de la classe abstraite)
; ----------------------------------------------------------------------------
Class Rectangle Extends FormeGeometrique
  Protected largeur.d
  Protected hauteur.d

  Public Method Init(nom_p.s, couleur_p.s, l.d, h.d)
  
  ; Implémentation obligatoire des méthodes abstraites du parent
  Public Method.d CalculerAire()
  Public Method.d CalculerPerimetre()
  Public Method Dessiner()
  
  ; Surcharge de la méthode concrète
  Public Method AfficherInfos()
  
  Public Method Free()
EndClass
```

---

### 2.2 Implémentation des Méthodes, `This` et `Super::`

Chaque méthode accède à ses membres internes via l'identifiant `This`.
Pour appeler le comportement de la classe parente (surcharge partielle), on utilise `Super::`.

```oop
; --- Implémentation de la Classe Abstraite ---

Method FormeGeometrique::Init(nom_p.s, couleur_p.s)
  This\nom = nom_p
  This\couleur = couleur_p
EndMethod

Method FormeGeometrique::AfficherInfos()
  PrintN("[Forme: " + This\nom + " | Couleur: " + This\couleur + "]")
EndMethod

Method FormeGeometrique::Free()
  FreeStructure(This)
EndMethod

; --- Implémentation de la Classe Fille Rectangle ---

Method Rectangle::Init(nom_p.s, couleur_p.s, l.d, h.d)
  Super::Init(nom_p, couleur_p) ; Initialise les attributs hérités
  This\largeur = l
  This\hauteur = h
EndMethod

Method.d Rectangle::CalculerAire()
  ProcedureReturn This\largeur * This\hauteur
EndMethod

Method.d Rectangle::CalculerPerimetre()
  ProcedureReturn 2 * (This\largeur + This\hauteur)
EndMethod

Method Rectangle::Dessiner()
  PrintN("   ==> [DESSIN] Rectangle " + StrD(This\largeur, 2) + "x" + StrD(This\hauteur, 2) + " (" + This\couleur + ")")
EndMethod

; Surcharge Partielle : appel du parent Super:: puis enrichissement
Method Rectangle::AfficherInfos()
  Super::AfficherInfos()
  PrintN("       Dimensions : " + StrD(This\largeur, 2) + " x " + StrD(This\hauteur, 2) + " | Aire=" + StrD(This\CalculerAire(), 2))
EndMethod

Method Rectangle::Free()
  Super::Free()
EndMethod
```

---

### 2.3 Utilisation et Polymorphisme

```oop
OpenConsole()

; 1. Instanciations concrètes
Define *rect.Rectangle = New Rectangle("MonRectangle", "Bleu", 10.0, 5.0)
Define *cercle.Cercle = New Cercle("MonCercle", "Rouge", 4.0)

; NB: L'instanciation directe d'une classe abstraite est strictement interdite :
; Define *err.FormeGeometrique = New FormeGeometrique(...) ; -> ERREUR de transpilation !

; 2. Polymorphisme dynamique via liste de type parent abstrait
NewList *formes.FormeGeometrique()

AddElement(*formes()) : *formes() = *rect
AddElement(*formes()) : *formes() = *cercle
AddElement(*formes()) : *formes() = New Rectangle("GrandRectangle", "Vert", 20.0, 15.0)

; 3. Parcours polymorphe : dispatch automatique vers la classe concrète réelle
ForEach *formes()
  *formes()\AfficherInfos()
  *formes()\Dessiner()
  PrintN("   Aire = " + StrD(*formes()\CalculerAire(), 2))
  PrintN("")
Next

; 4. Nettoyage mémoire polymorphe
ForEach *formes()
  *formes()\Free()
Next
ClearList(*formes())

CloseConsole()
```

---

## 3. Espaces de Noms (Namespaces) et Projets Multi-Fichiers

### 3.1 Déclaration de Namespace et Imbrication
Les espaces de noms permettent d'organiser les classes logiquement et d'éviter tout conflit de noms :

```oop
Namespace Game::Graphics
  Class Renderer
    Protected width.i, height.i
    Public Method Init(w.i, h.i)
    Public Method Render()
  EndClass
EndNamespace
```

### 3.2 Utilisation, Directive `Using` et Alias
Vous pouvez utiliser une classe soit via son nom pleinement qualifié, soit en important son namespace avec `Using`, soit en définissant un alias :

```oop
; 1. Nom pleinement qualifié
Define *r1.Game::Graphics::Renderer = New Game::Graphics::Renderer(1920, 1080)

; 2. Directive Using
Using Game::Graphics
Define *r2.Renderer = New Renderer(1280, 720)

; 3. Alias de Namespace
Namespace GFX = Game::Graphics
Define *r3.GFX::Renderer = New GFX::Renderer(800, 600)
```

### 3.3 Organisation Multi-Fichiers (1 Fichier par Classe)
Le transpileur gère nativement `IncludeFile` et `XIncludeFile` de manière récursive avec mapping de source complet :

**Fichier `entities/Animal.pbo` :**
```oop
Namespace Game::Entities
Abstract Class Animal
  Protected nom.s
  Public Method Init(nom_p.s)
  Public Abstract Method Crier()
EndClass
EndNamespace
```

**Fichier `entities/Dog.pbo` :**
```oop
Namespace Game::Entities
Class Dog Extends Animal
  Public Method Crier()
    PrintN(This\nom + " aboie !")
  EndMethod
EndClass
EndNamespace
```

**Fichier principal `main.pbo` :**
```oop
XIncludeFile "entities/Animal.pbo"
XIncludeFile "entities/Dog.pbo"

Using Game::Entities

OpenConsole()
Define *d.Dog = New Dog("Rex")
*d\Crier()
CloseConsole()
```

---

## 4. Double Syntaxe : PureBasic Classique vs Style C/C# (`{ }`)

Pour combiner la **vitesse native fulgurante de PureBasic** avec une **syntaxe moderne et non verbeuse**, le transpileur prend en charge une double syntaxe complète. Vous pouvez utiliser indifféremment les mots-clés classiques ou les accolades `{ }`, et même mélanger les deux styles dans un même projet !

### 4.1 Équivalence des Blocs

| Structure | Syntaxe Classique | Syntaxe C-Style `{ }` |
| :--- | :--- | :--- |
| **Namespace** | `Namespace MonEspace ... EndNamespace` | `Namespace MonEspace { ... }` |
| **Classe** | `Class MaClasse ... EndClass` | `Class MaClasse { ... }` |
| **Méthode** | `Method MaMethode() ... EndMethod` | `Method MaMethode() { ... }` |
| **Procédure** | `Procedure Calculer(x.i) ... EndProcedure` | `Procedure Calculer(x.i) { ... }` |
| **Condition If** | `If a > 0 ... Else ... EndIf` | `If (a > 0) { ... } Else { ... }` |
| **Boucle For** | `For i = 0 To 10 ... Next` | `For i = 0 To 10 { ... }` |
| **Boucle While** | `While x < 100 ... Wend` | `While x < 100 { ... }` |
| **Boucle Repeat** | `Repeat ... Until x = 0` | `Repeat { ... } Until x = 0` |
| **Structure** | `Structure Point ... EndStructure` | `Structure Point { ... }` |

### 4.2 Exemple en Syntaxe C-Style Moderne

```oop
Namespace Game::Entities {

  Class Dog Extends Animal {
    Protected race.s

    Public Method Init(nom.s, race_p.s) {
      Super::Init(nom)
      This\race = race_p
    }

    Public Method Crier() {
      If (This\race = "Husky") {
        PrintN("Aouuuu !")
      } Else {
        PrintN("Wouaf !")
      }
    }
  }

}

Procedure TesterChien() {
  Using Game::Entities
  Define *d.Dog = New Dog("Rex", "Husky")
  *d\Crier()
}
```

---

---

## 5. Framework GUI Objet PureBasic (`src/ui/UI.pbo`)

Toutes les fenêtres et tous les gadgets PureBasic peuvent désormais être manipulés comme des objets natifs avec gestionnaires d'événements virtuels (`OnClick()`, `OnChange()`, `OnPaint()`, `OnClose()`, etc.), héritage de classes et création de **Custom Gadgets** personnalisés sur Canvas.

### 5.1 Architecture des Classes GUI

- **`UI::Component`** : Classe abstraite racine commune (propriétés `id`, `tag`, `x`, `y`, `width`, `height`, `isVisible`, `isEnabled`, `userData`).
- **`UI::Gadget`** : Classe abstraite de base pour tous les gadgets (méthodes `SetText`, `GetText`, `SetPosition`, `SetVisible`, `SetEnabled`, `SetToolTip`, `SetColor`, `SetFont`, `SetFocus`, et callbacks virtuels `OnClick`, `OnChange`, `OnFocus`, `OnLostFocus`, `OnRightClick`, `OnCustomEvent`).
- **`UI::Window`** : Encapsulation d'une fenêtre (`OpenWindow`, `Close`, `SetTitle`, `SetPosition`, et événements `OnClose`, `OnResize`, `OnMove`, `OnMinimize`, `OnMaximize`, `OnRestore`).
- **`UI::Application`** : Gestionnaire global d'application et boucle d'événements centralisée (`Run()`, `Quit()`).
- **`UI::CustomGadget`** : Gadget propriétaire moderne basé sur `CanvasGadget` avec méthode virtuelle `OnPaint(w, h)` et gestion de la souris (`OnMouseEnter`, `OnMouseDown`, `OnMouseUp`, `OnMouseMove`, `OnKeyDown`, `Redraw()`).

### 5.2 Contrôles Standard Disponibles

| Classe | Gadget PureBasic Sous-Jacent | Caractéristiques Principales |
| :--- | :--- | :--- |
| **`UI::Button`** | `ButtonGadget` | Gestion du clic via `OnClick()` |
| **`UI::TextBox`** | `StringGadget` | `IsReadOnly()`, `SetReadOnly()`, `OnChange()` |
| **`UI::Label`** | `TextGadget` | Affichage de texte |
| **`UI::CheckBox`** | `CheckBoxGadget` | `IsChecked()`, `SetChecked(state)` |
| **`UI::ProgressBar`** | `ProgressBarGadget` | `GetValue()`, `SetValue()`, `SetRange()` |
| **`UI::Slider`** | `TrackBarGadget` | `GetValue()`, `SetValue()` |
| **`UI::ComboBox`** | `ComboBoxGadget` | `AddItem()`, `GetSelectedIndex()`, `GetSelectedItem()`, `Clear()` |
| **`UI::Controls::ToggleSwitch`** | `UI::CustomGadget` *(Canvas)* | Interrupteur moderne style iOS avec animation d'état |

### 5.3 Exemple d'Application GUI OOP Complète

```oop
XIncludeFile "ui/UI.pbo"

Using UI

; 1. Création d'un bouton personnalisé avec logique métier
Class MonBouton Extends UI::Button {
  Protected *champSaisie.UI::TextBox

  Public Method LierSaisie(*txt.UI::TextBox) {
    This\*champSaisie = *txt
  }

  Public Method OnClick() {
    If (This\*champSaisie) {
      MessageRequester("Bonjour", "Bonjour " + This\*champSaisie\GetText() + " !")
    }
  }
}

; 2. Fenêtre Principale Orientée Objet
Class MaFenetre Extends UI::Window {
  Protected *saisie.UI::TextBox
  Protected *btn.MonBouton
  Protected *switch.UI::Controls::ToggleSwitch

  Public Method Init() {
    Super::Init("Mon Application OOP", #PB_Ignore, #PB_Ignore, 400, 200, #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
    UI::RegisterWindow(This\id, This)

    This\*saisie = New UI::TextBox(20, 20, 200, 25, "Alice")
    This\*btn = New MonBouton(230, 18, 140, 28, "Valider")
    This\*btn\LierSaisie(This\*saisie)

    This\*switch = New UI::Controls::ToggleSwitch(20, 70, 50, 26, #True)
  }

  Public Method.b OnClose() {
    ProcedureReturn #True ; Autorise la fermeture
  }
}

; 3. Point d'entrée
Define *app.UI::Application = New UI::Application()
Define *win.MaFenetre = New MaFenetre()

*app\Run()
```

---

## 6. Plomberie PureBasic Générée

Le transpileur convertit automatiquement la syntaxe haut niveau `.pbo` en code natif PureBasic `.pb` ultra-performant :
1. **Interfaces VTable (`_vt`)** : Définition des prototypes de méthodes avec préfixage complet (ex: `Game_Graphics_Renderer_vt`).
2. **Structures d'Instance (`_Inst`)** : Structures mémoires contenant le pointeur `*VTable` en en-tête suivi des champs de la classe.
3. **Dispatch Interne Sécurisé (`*This_vt`)** : Les appels internes `This\Methode()` sont automatiquement résolus via le pointeur d'interface polymorphe `*This_vt`.
4. **DataSections VTable** : Générées pour toutes les classes concrètes (les classes abstraites n'allouent pas de VTable inutile).
5. **Constructeurs Factory (`New_<Classe>`)** : Générés pour les classes concrètes avec héritage automatique des paramètres constructeur.
6. **Validation Sémantique & Source Mapping** :
   - Interdiction d'instancier une classe abstraite.
   - Obligation pour une classe fille concrète d'implémenter toutes les méthodes abstraites héritées.
   - Fichier `.pb.map` pour remapper chaque avertissement/erreur `pbcompiler` vers le fichier et la ligne `.pbo` d'origine.

---

## 7. Guide d'Exécution & Compilation

### Transpiler un fichier `.pbo` vers `.pb` :
```cmd
"compiler/transpiler.exe" "src/mon_fichier.pbo" "src/mon_fichier_generated.pb"
```

### Vérifier la syntaxe en ligne de commande :
```cmd
"compiler/transpiler.exe" --check "src/mon_fichier.pbo"
```

### Compiler le code PureBasic généré :
```cmd
"C:\Program Files\PureBasic\Compilers\pbcompiler.exe" "src/mon_fichier_generated.pb" /EXE "src/mon_fichier.exe"
```

