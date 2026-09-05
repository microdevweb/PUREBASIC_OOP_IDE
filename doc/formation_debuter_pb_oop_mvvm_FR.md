# Guide de Formation : Débuter avec la POO & le Pattern MVVM en PureBasic

*Concevoir sa première application réactive moderne pas à pas*  
**Auteur :** MicrodevWeb  
**Framework :** PureBasic OOP v1.2 / v2.0  
**Compatibilité :** PureBasic 6.x (Windows, Linux, macOS)  

---

## 📦 Module 1 : Pourquoi la POO & le MVVM en PureBasic ?

Depuis toujours, PureBasic excelle par sa rapidité d'exécution, sa légèreté et sa simplicité procédurale. Cependant, dès qu'une interface graphique grandit, le code traditionnel fait face à des limites bien connues :

- **Le syndrome du code « Spaghetti »** : Des boucles d'événements `WaitWindowEvent()` géantes contenant des dizaines de `Select EventGadget()` imbriqués.
- **Le couplage fort** : La logique de calcul est mélangée avec les appels `SetGadgetText()` et `GetGadgetText()`.
- **Le redimensionnement complexe** : Le calcul manuel des coordonnées en pixels de chaque bouton lors des événements `#PB_Event_SizeWindow`.

> **💡 La solution PureBasic OOP**  
> Ce framework apporte les standards modernes du développement d'entreprise : **classes réutilisables (.pbo)**, **modèle de boîte WPF (StackPanel, Grid)** et **MVVM (Model-View-ViewModel)** avec mise à jour automatique sans aucun code de rafraîchissement manuel.

### 1.2. Ce que nous allons construire ensemble
Dans ce guide pratique, nous allons concevoir une application complète : **« Mini Gestionnaire de Tâches & Compteur Réactif »**.

L'application permettra de saisir un titre, de cliquer sur un bouton pour l'ajouter, et verra son compteur et son message d'état se mettre à jour instantanément grâce au *DataBinding*.

---

## 📁 Module 2 : Organisation des Dossiers & Framework Zéro-Include

Une architecture MVVM professionnelle repose sur une séparation claire des responsabilités dans l'arborescence de votre projet. Voici la structure recommandée :

```text
MonProjetMVVM/
├── constants/
│   └── AppConstants.pbi         <-- Noms des propriétés et commandes partagées
│
├── models/
│   └── TaskModel.pbi            <-- Structures de données et logique métier pure (optionnel)
│
├── viewmodels/
│   └── TaskViewModel.pbo        <-- Classe ViewModel héritant de MVVM::ViewModelBase
│
├── views/
│   └── MainView.xml             <-- Définition déclarative de l'interface
│
└── main.pb                      <-- Point d'entrée principal exécutable
```

### 2.1. Zéro-Include Framework
Grâce au transpilateur PBO intelligent, **vous n'avez plus besoin d'inclure manuellement les fichiers du framework**. Dès que le transpilateur rencontre les namespaces `UI::` ou `MVVM::`, il injecte automatiquement les modules nécessaires en mémoire.

### 2.2. L'ordre d'inclusion dans votre `main.pb`
Vous n'incluez que les fichiers de votre propre projet :

```purebasic
EnableExplicit

; 1. EN PREMIER : Les constantes partagées de Bindings et de Commandes
XIncludeFile "constants/AppConstants.pbi"

; 2. EN SECOND : Les Modèles de données (si existants)
; XIncludeFile "models/TaskModel.pbi"

; 3. EN TROISIÈME : Les classes ViewModels (.pbo transpilées)
XIncludeFile "viewmodels/TaskViewModel.pbo"
```

---

## 🧩 Module 3 : Comprendre le Pattern MVVM en 5 Minutes

Le pattern **MVVM** sépare clairement votre programme en trois responsabilités distinctes :

```text
┌─────────────────────────┐         ┌─────────────────────────┐
│       VUE (View)        │         │   VIEWMODEL (Moteur)    │
│  MainView.xml ou UI POO │ ◄─────► │  Propriétés Observables │
│   TextBox, Button, List │ Binding │  MVVM::StringProperty...│
└─────────────────────────┘         └────────────┬────────────┘
                                                 │ Métier
                                    ┌────────────▼────────────┐
                                    │      MODÈLE (Data)      │
                                    │    Structures / BDD     │
                                    └─────────────────────────┘
```

- **Model (Modèle)** : Représente la donnée brute (fichiers, structures, base de données).
- **ViewModel (Modèle de Vue)** : C'est le « cerveau ». Il hérite de `MVVM::ViewModelBase` et expose des **Propriétés Observables** (`MVVM::StringProperty`, `MVVM::IntProperty`). Dès qu'une valeur change, il notifie les abonnés.
- **View (Vue)** : C'est l'interface visuelle déclarée en XML ou construite avec les classes UI. Elle se lie aux propriétés via la syntaxe `{Binding NomPropriete}`.
- **BindingEngine (Moteur de Liaison)** : Il assure la liaison bidirectionnelle (*TwoWay*). Lorsque l'utilisateur tape du texte, le ViewModel est mis à jour. Lorsque le ViewModel modifie une variable, le contrôle graphique change tout seul !

---

## 1️⃣ Module 4 : Étape 1 — Les Constantes Partagées

Pour éviter toute faute de frappe entre le fichier XML et le code du ViewModel, nous plaçons les constantes dans `constants/AppConstants.pbi` :

```purebasic
; ============================================================================
; AppConstants.pbi - Identifiants déclaratifs pour les Bindings & Commandes
; ============================================================================

; Noms des Propriétés Observables (Bindées à l'UI)
#PROP_TASK_TITLE  = "TaskTitle"
#PROP_TASK_COUNT  = "TaskCount"
#PROP_STATUS_MSG  = "StatusMessage"

; Noms des Commandes (Déclenchées par les Boutons)
#CMD_ADD_TASK     = "AddTaskCommand"
#CMD_CLEAR_ALL    = "ClearAllCommand"
```

---

## 2️⃣ Module 5 : Étape 2 — Créer le ViewModel Réactif

Le ViewModel encapsule l'état et réagit aux actions. Il n'a **aucune dépendance** envers les fenêtres ou les gadgets PureBasic (pas de `SetGadgetText`).

```purebasic
; ============================================================================
; TaskViewModel.pbo - ViewModel de gestion des tâches
; ============================================================================
XIncludeFile "../constants/AppConstants.pbi"

Class TaskViewModel Extends MVVM::ViewModelBase {
  Public *TaskTitle.MVVM::StringProperty
  Public *TaskCount.MVVM::IntProperty
  Public *StatusMessage.MVVM::StringProperty

  ; --- Constructeur : Initialisation et enregistrement des propriétés ---
  Public Method Init() {
    Super\Init()
    
    ; Enregistrement des propriétés observables dans le registre MVVM
    This\*TaskTitle     = This\BindString(#PROP_TASK_TITLE, "")
    This\*TaskCount     = This\BindInt(#PROP_TASK_COUNT, 0)
    This\*StatusMessage = This\BindString(#PROP_STATUS_MSG, "Prêt - Aucune tâche enregistrée.")
  }

  ; --- Gestionnaire des Commandes UI ---
  Public Method OnCommand(cmdName.s) {
    Select cmdName
      Case #CMD_ADD_TASK
        Protected title.s = Trim(This\*TaskTitle\GetValue())
        
        If title <> ""
          Protected currentCount.i = This\*TaskCount\GetValue() + 1
          
          ; Mise à jour des propriétés -> Notification automatique de la Vue !
          This\*TaskCount\SetValue(currentCount)
          This\*StatusMessage\SetValue("Tâche ajoutée : " + title)
          This\*TaskTitle\SetValue("") ; Vide automatiquement le champ de saisie
        Else
          This\*StatusMessage\SetValue("Veuillez saisir un texte pour la tâche !")
        EndIf

      Case #CMD_CLEAR_ALL
        This\*TaskCount\SetValue(0)
        This\*TaskTitle\SetValue("")
        This\*StatusMessage\SetValue("Toutes les tâches ont été effacées.")
    EndSelect
  }
}
```

---

## 3️⃣ Module 6 : Étape 3 — Concevoir la Vue en XML

Grâce au moteur `XMLLoader`, l'interface graphique est décrite dans `views/MainView.xml` :

```xml
<Window Title="Mon Gestionnaire Réactif PureBasic OOP" Width="480" Height="300">
  <!-- StackPanel vertical avec marge globale et espacement automatique -->
  <StackPanel Margin="20" Spacing="12">
    
    <!-- Titre statique -->
    <Label Text="Ajouter une nouvelle tâche :" />

    <!-- Saisie liée bidirectionnellement à la propriété TaskTitle -->
    <TextBox Text="{Binding TaskTitle, Mode=TwoWay}" />

    <!-- Panneau horizontal pour les boutons d'action -->
    <StackPanel Orientation="Horizontal" Spacing="10">
      <Button Text="➕ Ajouter la tâche" Command="AddTaskCommand" />
      <Button Text="🗑️ Tout effacer" Command="ClearAllCommand" />
    </StackPanel>

    <!-- Séparateur visuel / Cadre avec compteur et statut lié -->
    <GroupBox Text="Tableau de bord">
      <StackPanel Margin="12" Spacing="6">
        <Label Text="{Binding StatusMessage}" />
        <Label Text="Nombre total de tâches : {Binding TaskCount}" />
      </StackPanel>
    </GroupBox>

  </StackPanel>
</Window>
```

---

## 4️⃣ Module 7 : Étape 4 — Le Point d'Entrée Principal

L'assemblage final dans `main.pb` ne nécessite que **quelques lignes de code** :

```purebasic
; ============================================================================
; main.pb - Lancement de l'application PureBasic OOP / MVVM
; ============================================================================
EnableExplicit

XIncludeFile "constants/AppConstants.pbi"
XIncludeFile "viewmodels/TaskViewModel.pbo"

; 1. Création de l'application centrale
Protected *app.UI::Application = NewObject(UI::Application)

; 2. Instanciation et initialisation du ViewModel
Protected *vm.TaskViewModel = NewObject(TaskViewModel)
*vm\Init()

; 3. Chargement de la vue XML et liaison automatique (DataBinding)
Protected *window.UI::Window = UI::XMLLoader::LoadView("views/MainView.xml", *vm)

If *window
  ; 4. Affichage et boucle d'exécution
  *window\Show()
  *app\Run()
  *window\Free()
EndIf

*vm\Free()
*app\Free()
```

> **🎉 Résultat Immédiat !**  
> Lorsque vous lancez `main.pb` :  
> - Tapez du texte dans le `TextBox` -> la propriété `TaskTitle` du ViewModel est synchronisée en temps réel.  
> - Cliquez sur « Ajouter » -> `OnCommand()` est appelée, le compteur passe à 1, le message d'état change, et le `TextBox` se vide tout seul !  

---

## 📚 Module 8 : Tableau Récapitulatif & Aide F1

### 8.1. Les 18 Contrôles UI Disponibles

| Contrôle OOP | Gadget PureBasic | Usage Type |
| :--- | :--- | :--- |
| `UI::Button` | `ButtonGadget` | Boutons poussoirs avec commandes MVVM |
| `UI::TextBox` | `StringGadget` | Saisie de texte avec TwoWay Binding |
| `UI::Editor` | `EditorGadget` | Édition multiligne de code ou texte riche |
| `UI::CheckBox` | `CheckBoxGadget` | Coche booléenne |
| `UI::RadioButton` | `OptionGadget` | Choix exclusif parmi un groupe |
| `UI::ComboBox` | `ComboBoxGadget` | Menu déroulant de sélection |
| `UI::ListView` | `ListViewGadget` | Liste verticale d'éléments |
| `UI::ListIcon` | `ListIconGadget` | Tableau multicolonne avec icônes |
| `UI::TreeView` | `TreeGadget` | Arborescence hiérarchique avec sous-niveaux |
| `UI::DatePicker` | `DateGadget` | Sélecteur de date et calendrier |
| `UI::SpinBox` | `SpinGadget` | Saisie numérique avec flèches +/- |
| `UI::Slider` | `TrackBarGadget` | Curseur de réglage numérique continu |
| `UI::ProgressBar` | `ProgressBarGadget` | Indicateur de progression de tâche |
| `UI::GroupBox` | `FrameGadget` | Cadre visuel de regroupement |
| `UI::Label` | `TextGadget` | Texte statique ou informatif |
| `UI::ToggleSwitch` | `CanvasGadget` | Interrupteur animé ON/OFF moderne |
| `UI::TabControl` | `PanelGadget` | Conteneur à onglets modulaires |

### 8.2. Touche d'Aide F1 dans l'IDE
Dans l'IDE PureBasic, placez à tout moment votre curseur sur un mot-clé (`Class`, `Method`, `Super`, `Property`...) ou un composant UI (`Button`, `Editor`, `Grid`, `ObservableObject`...) et appuyez sur **F1** pour ouvrir directement sa fiche d'aide avec son arbre d'héritage et ses exemples.
