# PureBasic OOP IDE & Toolchain — Version ALPHA 1.0

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Status: Alpha](https://img.shields.io/badge/Status-Alpha%201.0-orange.svg)](#avertissement--disclaimer)
[![Language: PureBasic](https://img.shields.io/badge/Language-PureBasic%206.x-green.svg)](https://www.purebasic.com)

---

## 🇫🇷 Français

### ⚠️ Avertissement — Version ALPHA 1.0

> **IMPORTANT :** Il s'agit d'une version **ALPHA 1.0**. Ce projet est en cours de développement actif. Bien que l'ensemble des fonctionnalités fondamentales soient testées et opérationnelles, **un fonctionnement optimal et sans bogue ne peut être garanti pour une utilisation en production**. Des évolutions de syntaxe ou d'architecture peuvent survenir dans les versions ultérieures. Vos retours, tests et signalements de bogues sont les bienvenus !

---

### 1. Présentation

**PureBasic OOP IDE** est un environnement de développement complet basé sur l'IDE officiel de PureBasic (sous licence GPL v3), étendu pour intégrer nativement la **Programmation Orientée Objet (POO)** et une **Double Syntaxe** moderne sans verbiage.

#### Fonctionnalités Majeures de PureBasic OOP :
- **Classes & Objets** : Définition de classes avec champs (`Public`, `Protected`, `Private`), méthodes, constructeurs (`Init()`) et destructeurs (`Free()`).
- **Héritage Simple & Polymorphisme Dynamique** : Héritage avec `Extends`, interfaces VTable polymorphiques haute performance, résolution automatique `This\...` et appels de classe mère avec `Super::`.
- **Classes Abstraites & Méthodes Abstraites** : `Abstract Class` et `Public Abstract Method` avec contrôle sémantique strict à la compilation.
- **Namespaces Imbriqués & `Using`** : Organisation modulaire (`Namespace MonModule::SousModule`), directives d'importation `Using` et alias (`Namespace MonAlias = MonNamespace`).
- **Support Multi-Fichiers** : `XIncludeFile` et `IncludeFile` gérés de manière récursive avec déduplication de classes.
- **Double Syntaxe Hybride** : Possibilité d'écrire son code avec les mots-clés PureBasic classiques (`Class ... EndClass`, `Method ... EndMethod`, `If ... EndIf`) ou avec une **syntaxe moderne style C/C# à accolades `{ }`** (`Class Dog { ... }`, `Method Aboyer() { ... }`).
- **Framework GUI Objet (`lib/ui/`)** : Encapsulation complète des fenêtres (`UI::Window`), gadgets (`UI::Button`, `UI::TextBox`, `UI::Label`, `UI::CheckBox`, etc.) et création de **Custom Gadgets** vectoriels propriétaires sur Canvas (`UI::CustomGadget`, `UI::Controls::ToggleSwitch`).
- **Source Mapping Précis (`.pb.map`)** : Toutes les erreurs du compilateur natif PureBasic sont automatiquement remappées vers les numéros de ligne exacts des fichiers sources `.pbo`.

---

### 2. Prérequis Système

| Système | Version Minimale | Compilateur Recommandé |
| :--- | :--- | :--- |
| **Windows** | Windows 10 / 11 (64-bit) | PureBasic 6.00 LTS à 6.40 (x64) |
| **Linux** | Ubuntu 22.04+ / Debian 12+ / Fedora 39+ | PureBasic 6.00 LTS à 6.40 (x64) avec GTK3 et build-essential |
| **macOS** | macOS 12 Monterey ou supérieur | PureBasic 6.00 LTS à 6.40 (x64 / ARM64) avec Xcode Command Line Tools |

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

#### 3.3 Sous macOS (Marche à suivre)

1. Installez les outils de ligne de commande Xcode si ce n'est pas déjà fait :
   ```bash
   xcode-select --install
   ```
2. Définissez la variable d'environnement `PUREBASIC_HOME` :
   ```bash
   export PUREBASIC_HOME="/Applications/PureBasic.app/Contents/Resources"
   export PATH="$PUREBASIC_HOME/compilers:$PATH"
   ```
3. Compilez le transpileur OOP :
   ```bash
   pbcompiler compiler/transpiler.pb -e compiler/transpiler
   ```
4. Lancez le script de build pour générer l'application macOS `pbo_ide.app`.

---

### 4. Démarrage Rapide (Quick Start)

1. Lancez **`pbo_ide.exe`**.
2. Ouvrez un exemple dans le dossier `examples/` :
   - `examples/01_Basics_Classes/animal_hierarchy.pbo` (Classes & Polymorphisme).
   - `examples/04_Dual_Syntax_CStyle/c_style_demo.pbo` (Syntaxe à accolades `{ }`).
   - `examples/05_GUI_OOP_Modern_CStyle/demo_gui_oop.pbo` (Application GUI complète).
3. Appuyez sur **`F5`** (ou menu *Compiler -> Compiler / Exécuter*) :
   Le transpileur OOP convertit le code à la volée, le compilateur natif produit le binaire et lance l'application !

---

## 🇬🇧 English

### ⚠️ Disclaimer — ALPHA 1.0 Release

> **IMPORTANT:** This is an **ALPHA 1.0** release. This project is under active development. While core features are implemented and tested, **optimal performance and bug-free operation cannot be guaranteed for production use**. Syntax adjustments or architectural improvements may occur in subsequent releases. Feedback, bug reports, and contributions are warmly welcome!

---

### 1. Overview

**PureBasic OOP IDE** is a full-featured integrated development environment derived from the official PureBasic IDE (licensed under GPL v3), extended to provide native **Object-Oriented Programming (OOP)** and a **Dual Syntax Mode** (classic PureBasic vs clean C/C# style `{ }`).

#### Core Features:
- **Classes & Objects**: Encapsulation with `Public`, `Protected`, `Private` members, constructors (`Init()`), destructors (`Free()`).
- **Inheritance & Dynamic Polymorphism**: `Extends` keyword, high-speed VTables, automatic polymorphic dispatch via `This\...`, and parent calls via `Super::`.
- **Abstract Classes & Methods**: `Abstract Class` and `Public Abstract Method` with compile-time enforcement.
- **Nested Namespaces & `Using`**: Hierarchy management (`Namespace Game::Graphics`), `Using` imports, and aliases.
- **Multi-File Architecture**: Recursive file resolution with class deduplication via `XIncludeFile`.
- **Dual Syntax**: Choose between standard PureBasic keywords or modern C-style curly braces `{ }`.
- **GUI OOP Framework (`lib/ui/`)**: Native object-oriented Windows, Gadgets, and owner-drawn Canvas Custom Gadgets (`UI::CustomGadget`, `UI::Controls::ToggleSwitch`).
- **Source Line Mapping (`.pb.map`)**: Automatically maps all native PureBasic compiler warnings and errors back to original `.pbo` line numbers.

---

### 2. Requirements

| Platform | Minimum OS | Recommended Compiler |
| :--- | :--- | :--- |
| **Windows** | Windows 10 / 11 (64-bit) | PureBasic 6.00 LTS to 6.40 (x64) |
| **Linux** | Ubuntu 22.04+ / Debian 12+ / Fedora 39+ | PureBasic 6.00 LTS to 6.40 (x64) with GTK3 & build-essential |
| **macOS** | macOS 12 Monterey or newer | PureBasic 6.00 LTS to 6.40 (x64 / ARM64) with Xcode Tools |

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
3. Compile the transpiler and IDE:
   ```bash
   pbcompiler compiler/transpiler.pb -e compiler/transpiler
   pbcompiler build_ide.pb -e build_ide
   ./build_ide
   ```

#### 3.3 On macOS
1. Install Xcode Command Line Tools: `xcode-select --install`
2. Set `PUREBASIC_HOME`:
   ```bash
   export PUREBASIC_HOME="/Applications/PureBasic.app/Contents/Resources"
   export PATH="$PUREBASIC_HOME/compilers:$PATH"
   ```
3. Compile transpiler and IDE build scripts.

---

### 4. License

This project is licensed under the **GNU General Public License v3 (GPL v3)** — see the [LICENSE](LICENSE) file for complete details.