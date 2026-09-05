; ============================================================================
; PureBasic OOP - Manuel de Reference (Francais)
; Documentation officielle du transpileur, du framework GUI et du moteur MVVM
; Author:      MicrodevWeb
; ============================================================================

# Manuel de Reference PureBasic OOP (Francais)

Bienvenue dans la documentation officielle du transpileur Objet PureBasic, du framework d'interface graphique responsive et du moteur MVVM (Model-View-ViewModel).

---

## 1. Les Fondements de la Programmation Oriente Objet (POO)

La Programmation Oriente Objet (POO) structure une application autour de **donnees** et de leurs **traitements associes**, regroupes dans des entites appelees **Objets**.

### 1.1 Classes et Objets
- **Classe** : Le modele ou plan definissant les attributs (champs) et les comportements (methodes).
- **Objet (Instance)** : Une entite concrete instanciee en memoire avec `New NomClasse(...)`.

### 1.2 Encapsulation et Visibilite
- **`Public`** : Accessible partout (a l'interieur et a l'exterieur de l'objet).
- **`Protected`** : Accessible uniquement par la classe qui le declare et ses classes filles.
- **`Private`** : Strictement reserve a la classe qui le declare.

### 1.3 Heritage (`Extends`)
L'heritage permet a une classe fille de reutiliser et d'etendre les attributs et methodes d'une classe parente :
```oop
Class Chien Extends Animal {
  Public Method Aboyer() {
    MessageRequester("Chien", "Wouf !")
  }
}
```

### 1.4 Polymorphisme (Dispatch Dynamique par VTable)
Les objets derives peuvent etre manipules de maniere uniforme a travers une reference vers leur classe parente. L'appel de methode s'execute dynamiquement selon le type reel de l'objet via sa table de methodes virtuelles (*VTable*).

### 1.5 Abstraction (Classes et Methodes Abstraites)
- **`Abstract Class`** : Une classe de base qui ne peut pas etre instanciee directement.
- **`Public Abstract Method`** : Un prototype que toute sous-classe concrete **doit** obligatoirement implementer.

---

## 2. Syntaxe et Grammaire PureBasic OOP

### 2.1 Declaration d'une Classe
```oop
Namespace App::Models {

  Abstract Class Forme {
    Protected nom.s
    Protected couleur.s

    Public Method Init(nom_p.s, couleur_p.s) {
      This\nom = nom_p
      This\couleur = couleur_p
    }

    Public Abstract Method.d CalculerAire()
    
    Public Method AfficherInfos() {
      Debug "Forme: " + This\nom + " | Couleur: " + This\couleur
    }

    Public Method Free() {
    }
  }

  Class Rectangle Extends Forme {
    Protected largeur.d
    Protected hauteur.d

    Public Method Init(nom_p.s, couleur_p.s, l.d, h.d) {
      Super\Init(nom_p, couleur_p)
      This\largeur = l
      This\hauteur = h
    }

    Public Method.d CalculerAire() {
      ProcedureReturn This\largeur * This\hauteur
    }
  }

}
```

### 2.2 Surcharge des Constructeurs (`Init`)
Une meme classe peut definir plusieurs constructeurs avec des signatures de parametres differentes :
```oop
Class Personne {
  Protected nom.s
  Protected age.i

  Public Method Init() {
    This\nom = "Anonyme" : This\age = 0
  }

  Public Method Init(nom_p.s) {
    This\nom = nom_p : This\age = 0
  }

  Public Method Init(nom_p.s, age_p.i) {
    This\nom = nom_p : This\age = age_p
  }
}
```

---

## 3. Framework GUI Responsive (`framework/`)

Le framework GUI de PureBasic OOP permet de construire des interfaces graphiques automatiques sans aucun calcul manuel de coordonnees (X, Y).

### 3.1 Tableau des Controles Graphiques

| Composant | Constructeurs Courants | Description |
| :--- | :--- | :--- |
| **`UI::Button`** | `Init(text.s)`<br>`Init(text.s, w.i, h.i)` | Bouton poussoir standard cliquable. 120x30 par defaut. |
| **`UI::TextBox`** | `Init()`<br>`Init(defaultText.s)`<br>`Init(defaultText.s, w.i, h.i)` | Champ de saisie de texte mono-ligne. |
| **`UI::Label`** | `Init(text.s)`<br>`Init(text.s, w.i, h.i)` | Texte statique d'affichage. |
| **`UI::CheckBox`** | `Init(text.s)`<br>`Init(text.s, checked.b)` | Case a cocher avec etat booleen. |
| **`UI::RadioButton`** | `Init(text.s)`<br>`Init(text.s, checked.b)` | Bouton radio avec exclusion mutuelle. |
| **`UI::ComboBox`** | `Init()`<br>`Init(w.i, h.i)` | Liste deroulante de selection. |
| **`UI::SpinBox`** | `Init(min.i, max.i)`<br>`Init(min.i, max.i, current.i)` | Compteur numerique avec fleches haut/bas. |
| **`UI::Editor`** | `Init()`<br>`Init(w.i, h.i)`<br>`Init(text.s, w.i, h.i)` | Zone d'edition de texte multi-lignes. |
| **`UI::ListView`** | `Init()`<br>`Init(w.i, h.i)` | Liste simple d'elements (ListBox). |
| **`UI::TreeView`** | `Init()`<br>`Init(w.i, h.i)` | Arborescence hierarchique (Tree). |
| **`UI::DatePicker`** | `Init()`<br>`Init(mask.s)`<br>`Init(dateVal.i, mask.s)` | Selecteur visuel de date et calendrier. |
| **`UI::GroupBox`** | `Init(caption.s)`<br>`Init(caption.s, w.i, h.i)` | Cadre de regroupement avec titre. |
| **`UI::TabControl`** | `Init()`<br>`Init(w.i, h.i)` | Conteneur d'onglets (Panel). |
| **`UI::ProgressBar`** | `Init()` *(0..100)*<br>`Init(min.i, max.i)` | Barre de progression visuelle. |
| **`UI::Slider`** | `Init()` *(0..100)*<br>`Init(min.i, max.i)` | Curseur coulissant (TrackBar). |
| **`UI::ListIcon`** | `Init(title.s, colWidth.i)` | Tableau multi-colonnes / grille de donnees. |
| **`UI::ToggleSwitch`** | `Init()`<br>`Init(checked.b)` | Interrupteur moderne rendu en vectoriel (Canvas). |

### 3.2 Panneaux de Disposition (Layout Panels)

| Panneau | Constructeurs | Comportement |
| :--- | :--- | :--- |
| **`UI::StackPanel`** | `Init()`<br>`Init(orientation.i, spacing.i)` | Alignement lineaire horizontal ou vertical. |
| **`UI::DockPanel`** | `Init(lastChildFill.b = #True)` | Ancrage sur les bords (`#UI_Dock_Top`, `#UI_Dock_Bottom`, `#UI_Dock_Left`, `#UI_Dock_Right`, `#UI_Dock_Fill`). |
| **`UI::Grid`** | `Init()` | Grille flexible en 2D avec tailles fixes, Auto ou etoilees (`*`, `2*`). |
| **`UI::Window`** | `Init(title.s, w.i, h.i)` | Fenetre principale responsive avec redimensionnement automatique. |

---

## 4. Moteur Declaratif XML / XAML

Les interfaces peuvent etre decrites de maniere declarative dans des fichiers XML ou directement en memoire sous forme de chaines.

### 4.1 Methodes de Chargement
- **Depuis un fichier** : `This\LoadView(cheminFichier.s, *dataContext = 0)`
- **Depuis la memoire (Chaine)** : `This\LoadViewFromString(xmlString.s, *dataContext = 0)`

### 4.2 Exemple de Syntaxe XML
```xml
<Window Title="Mon Application" Width="600" Height="400">
  <DockPanel LastChildFill="true">
    <StackPanel Dock="Top" Orientation="Horizontal" Margin="10,5" Spacing="8">
      <Button Text="Actualiser" Click="RefreshCmd" Width="100" Height="30"/>
    </StackPanel>
    <StackPanel Dock="Fill" Orientation="Vertical" Margin="15" Spacing="10">
      <Label Text="Nom d'utilisateur :" Height="20"/>
      <TextBox Text="{Binding UserName}" Height="28"/>
      <Label Text="{Binding StatusMessage}" Height="20"/>
    </StackPanel>
  </DockPanel>
</Window>
```

---

## 5. Le Pattern Architectural MVVM

Le pattern **MVVM (Model-View-ViewModel)** separe rigoureusement la logique metier et l'affichage :
- **Model** : Les donnees et la logique metier pure.
- **ViewModel** : Gere l'etat et les commandes. **Ne fait jamais reference aux fenetres ou gadgets directement**.
- **View** : La presentation visuelle observant le ViewModel via son `DataContext` et les expressions `{Binding ...}`.

### 5.0 Organisation des Dossiers & Stratégie des Includes

Une structure standard recommandée pour tout projet PureBasic OOP / MVVM est la suivante :

```text
MonProjetMVVM/
│
├── src/                          <-- Framework PureBasic OOP
│   └── ui/
│       └── UI.pbi               <-- POINT D'ENTRÉE UNIQUE du Framework UI & MVVM
│
├── constants/
│   └── AppConstants.pbi         <-- Constantes partagées (Propriétés & Commandes)
│
├── models/
│   └── MonModel.pbi             <-- Données et logique métier pure
│
├── viewmodels/
│   └── MonViewModel.pbo         <-- Classe ViewModel (.pbo) héritant de MVVM::ViewModelBase
│
├── views/
│   └── MainView.xml             <-- Vue déclarative XML ou classe Window
│
└── main.pb                      <-- Point d'entrée exécutable
```

**Ordre obligatoire des Includes dans `main.pb` :**
```purebasic
EnableExplicit

; 1. En premier : Le Framework UI & MVVM (embarque tout le moteur)
IncludeFile "framework/UI.pbi"

; 2. En second : Les constantes partagées de Bindings
IncludeFile "constants/AppConstants.pbi"

; 3. En troisième : Les ViewModels
IncludeFile "viewmodels/MonViewModel.pbo"
```

### 5.1 Proprietes Observables Fortement Typees (`framework/mvvm/Property.pbi`)

| Classe de Propriete | Methodes | Notification |
| :--- | :--- | :--- |
| **`StringProperty`** | `Get()`, `Set(val.s)`, `ToString()` | Automatique sur `Set()` |
| **`IntProperty`** | `Get()`, `Set(val.i)`, `Increment()`, `Decrement()`, `GetString()`, `ToString()` | Automatique sur `Set()`, `Increment()`, `Decrement()` |
| **`BoolProperty`** | `Get()`, `Set(val.b)`, `Toggle()`, `GetString()`, `ToString()` | Automatique sur `Set()`, `Toggle()` |
| **`DoubleProperty`** | `Get()`, `Set(val.d)`, `GetString()`, `ToString(decimals.i)` | Automatique sur `Set()` |

### 5.2 Methodes d'Aide dans le ViewModel
Dans toute classe heritant de `MVVM::ViewModelBase` :
- `This\BindString(nom.s, defaut.s = "")`
- `This\BindInt(nom.s, defaut.i = 0)`
- `This\BindBool(nom.s, defaut.b = #False)`
- `This\BindDouble(nom.s, defaut.d = 0.0)`

### 5.3 Gestion des Commandes
Un clic sur un bouton avec `Command="NomCommande"` declenche automatiquement la methode `OnCommand(cmd.s)` dans le ViewModel :
```purebasic
Public Method OnCommand(cmd.s) {
  Select cmd
    Case "MonAction"
      This\*MaPropriete\SetValue("Mis a jour !")
  EndSelect
}
```

---

## 6. Exemple Complet MVVM Pas a Pas

### 1. `SimpleConstants.pbi` (Contrat Partage)
```purebasic
#PROP_MESSAGE = "Message"
#PROP_COUNT   = "Count"
#CMD_CLICK    = "ClickCmd"
#CMD_RESET    = "ResetCmd"
```

### 2. `SimpleViewModel.pbi` (Etat et Logique)
```purebasic
XIncludeFile "SimpleConstants.pbi"

Namespace Demo {

  Class SimpleViewModel Extends MVVM::ViewModelBase {
    Public *Message.MVVM::StringProperty
    Public *Count.MVVM::IntProperty

    Public Method Init() {
      Super\Init()
      This\*Message = This\BindString(#PROP_MESSAGE, "Cliquez sur le bouton")
      This\*Count   = This\BindInt(#PROP_COUNT, 0)
    }

    Public Method OnCommand(cmd.s) {
      Select cmd
        Case #CMD_CLICK
          Protected newCount.i = This\*Count\GetValue() + 1
          This\*Count\SetValue(newCount)
          This\*Message\SetValue("Nombre de clics: " + Str(newCount))

        Case #CMD_RESET
          This\*Count\SetValue(0)
          This\*Message\SetValue("Reinitialise a 0")
      EndSelect
    }
  }

}
```

### 3. `SimpleView.xml` (Vue Declarative)
```xml
<Window Title="Exemple MVVM" Width="450" Height="250">
  <StackPanel Margin="20" Spacing="12">
    <Label Text="Demo PureBasic OOP MVVM" />
    <TextBox Text="{Binding Message}" />
    <StackPanel Orientation="Horizontal" Spacing="10">
      <Button Text="Cliquez ici" Command="ClickCmd" Width="110" Height="32" />
      <Button Text="Reset"       Command="ResetCmd" Width="90"  Height="32" />
    </StackPanel>
  </StackPanel>
</Window>
```

### 4. `Main.pb` (Point d'Entree)
```purebasic
EnableExplicit

XIncludeFile "SimpleConstants.pbi"
XIncludeFile "SimpleViewModel.pbi"

Protected *app.UI::Application = NewObject(UI::Application)
Protected *vm.Demo::SimpleViewModel = NewObject(Demo::SimpleViewModel)
*vm\Init()

Protected *win.UI::Window = UI::XMLLoader::LoadView("SimpleView.xml", *vm)
If *win
  *win\Show()
  *app\Run()
  *win\Free()
EndIf

*vm\Free()
*app\Free()
```

---

## 7. Guide de Compilation et Build

### Etape 1 : Transpilation du fichier `.pb` avec le Transpileur Natif
```cmd
compiler\transpiler.exe "examples/03_simple_mvvm/Main.pb" "examples/03_simple_mvvm/Main_transpiled.pb" --base-dir "examples/03_simple_mvvm"
```

### Etape 2 : Compilation Binaire avec le Compilateur PureBasic
```cmd
"C:\Program Files\PureBasic\Compilers\pbcompiler.exe" "examples/03_simple_mvvm/Main_transpiled.pb" /CONSOLE /DEBUGGER /EXE "examples/03_simple_mvvm/simple_mvvm.exe" /THREAD /UNICODE /XP /USER /DPIAWARE
```
