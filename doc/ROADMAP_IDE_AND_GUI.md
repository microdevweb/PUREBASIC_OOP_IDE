# Feuille de Route : Éditeur Scintilla Dédié & Bibliothèque GUI Objet pour PureBasic OOP

Document de référence pour la reprise des développements futurs.

---

## 1. Vision Globale

Développer un écosystème 100% autonome et natif PureBasic composé de :
1. **Une suite de classes GUI Objet (`src/gui/`)** encapsulant les fenêtres et gadgets PureBasic (`UIWindow`, `UIButton`, `UITextBox`, etc.) pour programmer les interfaces graphiques en POO sans manipulation manuelle d'identifiants numériques `#PB_Any`.
2. **Un éditeur de code / IDE dédié (`ide/pbo_ide.pb`)** basé sur le composant natif `ScintillaGadget()`, intégrant la coloration syntaxique POO, la transpilation automatique, l'autocomplétion contextuelle et la compilation en un clic (F5).

---

## 2. Architecture Technique

### A. Hiérarchie du Framework GUI Objet

```
                              ┌────────────────────────┐
                              │      UIComponent       │
                              │ (ID, X, Y, W, H, Free) │
                              └───────────┬────────────┘
                                          │
                ┌─────────────────────────┴─────────────────────────┐
                ▼                                                   ▼
     ┌─────────────────────┐                             ┌─────────────────────┐
     │     UIWindow        │                             │      UIGadget       │
     │ - SetTitle()        │                             │ - SetText()         │
     │ - AddGadget()       │                             │ - SetColor()        │
     │ - EventLoop()       │                             │ - SetVisible()      │
     └─────────────────────┘                             └──────────┬──────────┘
                                                                    │
                                   ┌────────────────────────────────┼────────────────────────────────┐
                                   ▼                                ▼                                ▼
                        ┌─────────────────────┐          ┌─────────────────────┐          ┌─────────────────────┐
                        │      UIButton       │          │     UITextBox       │          │     UICanvas        │
                        │ - OnClick()         │          │ - OnChange()        │          │ - OnPaint()         │
                        └─────────────────────┘          └─────────────────────┘          └─────────────────────┘
```

#### Exemple de Syntaxe Cible (`.pbo`) :
```oop
Define *win.UIWindow = New UIWindow("Gestion de Stock", 800, 600)
Define *btn.UIButton = New UIButton(20, 20, 120, 35, "Enregistrer")
Define *txt.UITextBox = New UITextBox(150, 20, 250, 35, "Produit ABC")

*btn\SetColor($008000, $FFFFFF)
*win\AddGadget(*btn)
*win\AddGadget(*txt)

*win\ShowModal()
```

---

### B. Éditeur Scintilla Dédié (`ide/pbo_ide.pb`)

1. **Interface Utilisateur** :
   - Barre d'outils : *Nouveau*, *Ouvrir*, *Enregistrer*, *Transpiler*, *Exécuter (F5)*.
   - Zone d'édition principale : `ScintillaGadget()` avec numérotation des lignes, pliage de code (*code folding*) et coloration syntaxique (mots-clés PB + mots-clés POO `Class`, `Method`, `Extends`, `Super`, `This`, etc.).
   - Panneau inférieur : Sortie console, logs de transpilation et erreurs de compilation `pbcompiler.exe`.
2. **Autocomplétion Contextuelle (`SCI_AUTOCSHOW`)** :
   - Analyse dynamique des symboles du fichier ouvert via le transpileur.
   - Affichage instantané des méthodes et propriétés dès la frappe de `\` ou `::`.
3. **Pipeline de Compilation en un Clic** :
   - F5 ➔ Sauvegarde temporaire ➔ Transpilation en mémoire ➔ `pbcompiler.exe /CONSOLE /EXE` ➔ Lancement immédiat de l'exécutable.

---

## 3. Plan d'Implémentation par Phases

### Phase 1 : Bibliothèque GUI Objet (`src/gui/`)
- [ ] Création de `src/gui/ui_base.pbo` : `UIComponent`, `UIGadget`, `UIWindow`.
- [ ] Création de `src/gui/ui_controls.pbo` : `UIButton`, `UITextBox`, `UILabel`, `UICheckBox`, `UIListView`.
- [ ] Système d'événements et callbacks orienté objet.
- [ ] Exemple d'application graphique complète en `.pbo`.

### Phase 2 : Prototype de l'Éditeur Scintilla (`ide/pbo_ide.pb`)
- [ ] Création de la fenêtre IDE et initialisation de Scintilla (`InitScintilla()`).
- [ ] Configuration du Lexer (coloration des mots-clés PB et POO).
- [ ] Gestion des fichiers (Nouveau, Ouvrir, Enregistrer).
- [ ] Intégration du bouton Compiler & Exécuter (F5) appelant le transpileur et le compilateur PB.

### Phase 3 : Intellisense & Autocomplétion
- [ ] Extraction de la table des symboles (Classes / Méthodes) par le transpileur en tâche de fond.
- [ ] Déclenchement de la complétion Scintilla lors de la saisie de `\` sur un pointeur d'objet.
- [ ] Navigation vers la définition (`Go To Definition`).

---

## 4. Statut Actuel du Projet
- ✅ **Moteur de Transpilation** ([compiler/transpiler.pb](file:///c:/PB/PUREBASIC_OOP_WORKSPACE/compiler/transpiler.pb)) opérationnel avec héritage (`Extends`), polymorphisme VTable ordonnée, `Super::` et constructeurs.
- ✅ **Tests Polymorphisme** ([src/test_polymorphisme.pbo](file:///c:/PB/PUREBASIC_OOP_WORKSPACE/src/test_polymorphisme.pbo)) validés à 100% avec `pbcompiler.exe`.
- ✅ **Manuels & Documentation PDF/MD** à jour ([doc/PB_OOP_manuel_FR.pdf](file:///c:/PB/PUREBASIC_OOP_WORKSPACE/doc/PB_OOP_manuel_FR.pdf)).
