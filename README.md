# PureBasic OOP IDE & Toolchain — Version ALPHA 1.2

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Status: Alpha](https://img.shields.io/badge/Status-Alpha%201.2-orange.svg)](#avertissement--disclaimer)
[![Language: PureBasic](https://img.shields.io/badge/Language-PureBasic%206.x-green.svg)](https://www.purebasic.com)

---

## 🇫🇷 Français

### ⚠️ Avertissement — Version ALPHA 1.2

> **IMPORTANT :** Il s'agit d'une version **ALPHA 1.2**. Ce projet apporte des évolutions majeures : surcharge de méthodes (*Method Overload*), inclusion automatique du framework (*Zero-Include*), architecture réactive **MVVM** complète, système de Layouts WPF et aide contextuelle F1 dans l'IDE. Des évolutions peuvent survenir dans les versions ultérieures. Vos retours et tests sont les bienvenus !

---

### 1. Présentation

**PureBasic OOP IDE** est un environnement de développement complet basé sur l'IDE officiel de PureBasic (sous licence GPL v3), étendu pour intégrer nativement la **Programmation Orientée Objet (POO)**, une **Double Syntaxe** moderne et un écosystème applicatif complet.

#### Fonctionnalités Majeures (ALPHA 1.2) :
- **Classes & Objets** : Définition de classes avec champs (`Public`, `Protected`, `Private`), méthodes, constructeurs (`Init()`) et destructeurs (`Free()`).
- **Surcharge de Méthodes (Overloading)** : Définition de plusieurs méthodes portant le même nom avec des signatures d'arguments distinctes.
- **Héritage Simple & Polymorphisme Dynamique** : Héritage avec `Extends`, interfaces VTable polymorphiques haute performance, résolution automatique `This\...` et appels de classe mère avec `Super\...`.
- **Classes Abstraites & Méthodes Abstraites** : `Abstract Class` et `Public Abstract Method` avec contrôle sémantique strict à la compilation.
- **Namespaces Imbriqués & `Using`** : Organisation modulaire (`Namespace MonModule::SousModule`), directives d'importation `Using` et alias.
- **Framework Zéro-Include** : Le transpileur détecte automatiquement les usages de `UI::` ou `MVVM::` et injecte le framework sans avoir à écrire de `XIncludeFile` manuel vers le SDK.
- **Architecture Réactive MVVM** : Sous-système complet `MVVM` avec `MVVM::ViewModelBase`, propriétés observables fortement typées (`MVVM::StringProperty`, `MVVM::IntProperty`, `MVVM::BoolProperty`, `MVVM::DoubleProperty`), commandes `MVVM::RelayCommand` et moteur de liaison bidirectionnelle `MVVM::BindingEngine`.
- **Layouts Réactifs & Boîte WPF** : Modèle de disposition moderne avec `UI::StackPanel`, `UI::DockPanel` et `UI::Grid` pour des interfaces qui s'adaptent instantanément aux redimensionnements.
- **Vues Déclaratives XML (`UI::XMLLoader`)** : Définition de l'interface en XML avec expressions de liaison `{Binding NomPropriete, Mode=TwoWay}`.
- **Aide Contextuelle F1 Intégrée** : Placez le curseur sur n'importe quel mot-clé ou composant dans l'IDE et appuyez sur **F1** pour ouvrir sa documentation avec exemples et hiérarchie de classes.
- **Source Mapping Précis (`.pb.map`)** : Toutes les erreurs du compilateur natif PureBasic sont automatiquement remappées vers les numéros de ligne exacts des fichiers sources `.pbo`.

---

### 2. Démarrage Rapide avec les Exemples Recommandés

Ouvrez l'un des exemples pertinents situés dans le dossier `examples/` :
- **`examples/01_basics_oop/main.pb`** : Fondamentaux POO (classes, héritage, polymorphisme, constructeurs/destructeurs).
- **`examples/02_responsive_layout/main.pb`** : Layouts réactifs WPF (StackPanel, DockPanel, Grid).
- **`examples/03_simple_mvvm/Main.pb`** : Modèle MVVM minimal réactif avec propriétés liées.
- **`examples/04_todo_app/main.pb`** : Application complète de gestion de tâches réactive avec vue XML et DataBinding bidirectionnel.

Appuyez sur **`F5`** (ou menu *Compiler -> Compiler / Exécuter*) pour lancer immédiatement l'exemple.

---

### 3. Guide de Compilation et d'Installation

#### 3.1 Sous Windows

1. **Utilisation directe (sans compilation) :**
   Lancez simplement l'exécutable pré-compilé `pbo_ide.exe` situé à la racine.

2. **Recompilation complète depuis les sources :**
   - Double-cliquez sur `build_ide.exe` ou exécutez dans un terminal :
     ```cmd
     build_ide.exe
     ```
   - Ou compilez manuellement le script de build avec PureBasic :
     ```cmd
     "C:\Program Files\PureBasic\Compilers\pbcompiler.exe" build_ide.pb /CONSOLE /EXE build_ide.exe
     build_ide.exe
     ```

#### 3.2 Sous Linux (Marche à suivre)

1. Assurez-vous que les paquets de développement GTK3 et Scintilla sont installés :
   ```bash
   sudo apt update
   sudo apt install build-essential libgtk-3-dev libwebkit2gtk-4.0-dev
   ```
2. Définissez la variable d'environnement `PUREBASIC_HOME` vers votre dossier PureBasic :
   ```bash
   export PUREBASIC_HOME=/opt/purebasic
   export PATH=$PUREBASIC_HOME/compilers:$PATH
   ```
3. Compilez le transpileur OOP :
   ```bash
   pbcompiler compiler/transpiler.pb -e compiler/transpiler
   ```
4. Compilez le script de build ou lancez la chaîne de construction de l'IDE :
   ```bash
   pbcompiler build_ide.pb -e build_ide
   ./build_ide
   ```

---

## 🇬🇧 English

### ⚠️ Disclaimer — ALPHA 1.2 Release

> **IMPORTANT:** This is an **ALPHA 1.2** release. Major additions include: **Method Overloading**, **Zero-Include Framework Automation**, **Complete Reactive MVVM Subsystem**, **WPF-Style Responsive Box Layouts**, and **Integrated F1 Contextual Help**. Feedback and contributions are warmly welcome!

---

### 1. Overview

**PureBasic OOP IDE** is a full-featured integrated development environment derived from the official PureBasic IDE (licensed under GPL v3), extended to provide native **Object-Oriented Programming (OOP)**, modern **Dual Syntax**, and a comprehensive enterprise application framework.

#### Core Features (ALPHA 1.2):
- **Classes & Objects**: Encapsulation with `Public`, `Protected`, `Private` members, constructors (`Init()`), destructors (`Free()`).
- **Method Overloading**: Define multiple methods with the same name and distinct parameter signatures.
- **Inheritance & Dynamic Polymorphism**: `Extends` keyword, high-speed VTables, automatic polymorphic dispatch via `This\...`, and parent calls via `Super\...`.
- **Abstract Classes & Methods**: `Abstract Class` and `Public Abstract Method` with compile-time enforcement.
- **Nested Namespaces & `Using`**: Modular organization (`Namespace App::ViewModels`), `Using` imports, and aliases.
- **Zero-Include Framework**: The transpiler automatically detects `UI::` or `MVVM::` namespaces and injects the framework transparently into memory.
- **Reactive MVVM Architecture**: Full `MVVM` subsystem featuring `MVVM::ViewModelBase`, typed observable properties (`MVVM::StringProperty`, `MVVM::IntProperty`, `MVVM::BoolProperty`, `MVVM::DoubleProperty`), `MVVM::RelayCommand`, and two-way `MVVM::BindingEngine`.
- **WPF-Style Responsive Layouts**: Modern box model with `UI::StackPanel`, `UI::DockPanel`, and `UI::Grid` for layouts that adapt instantly to window resizing.
- **Declarative XML Views (`UI::XMLLoader`)**: Define views in clean XML with `{Binding PropertyName, Mode=TwoWay}` expressions.
- **Integrated F1 Contextual Help**: Place your cursor on any OOP keyword or UI component in the IDE and press **F1** to open its documentation.
- **Source Line Mapping (`.pb.map`)**: Automatically maps all native PureBasic compiler warnings and errors back to original `.pbo` line numbers.

---

### 2. Quick Start with Featured Examples

Open any of the curated examples in the `examples/` directory:
- **`examples/01_basics_oop/main.pb`**: OOP fundamentals (classes, inheritance, polymorphism, lifecycle).
- **`examples/02_responsive_layout/main.pb`**: WPF responsive box models (StackPanel, DockPanel, Grid).
- **`examples/03_simple_mvvm/Main.pb`**: Minimal reactive MVVM pattern with observable bindings.
- **`examples/04_todo_app/main.pb`**: Real-world reactive task management app with declarative XML view and two-way DataBinding.

Press **`F5`** (or *Compiler -> Compile/Run*) to build and launch immediately.

---

### 3. Build & Installation Instructions

#### 3.1 On Windows
- **Direct Usage:** Run the pre-compiled `pbo_ide.exe` located in the root directory.
- **Rebuilding from source:** Run `build_ide.exe` or compile `build_ide.pb`.

#### 3.2 On Linux
1. Install dependencies:
   ```bash
   sudo apt install build-essential libgtk-3-dev libwebkit2gtk-4.0-dev
   ```
2. Set `PUREBASIC_HOME`:
   ```bash
   export PUREBASIC_HOME=/opt/purebasic
   export PATH=$PUREBASIC_HOME/compilers:$PATH
   ```
3. Compile transpiler and IDE:
   ```bash
   pbcompiler compiler/transpiler.pb -e compiler/transpiler
   pbcompiler build_ide.pb -e build_ide
   ./build_ide
   ```

---

### 4. License

This project is licensed under the **GNU General Public License v3 (GPL v3)** — see the [LICENSE](LICENSE) file for complete details.