# 03 — Configuration VS Code Optimale pour Python sous Windows

Ce guide décrit l'installation minimale, propre et performante de Microsoft Visual Studio Code pour le développement Python sous Windows, avec Ruff comme formateur/linter et Pylance pour l'analyse de code statique, sans extensions superflues. Il intègre un retour d'expérience complet sur la résolution de l'erreur d'interpréteur invalide.

---

## 1. Installation de VS Code en Scope Utilisateur

### Pourquoi le Scope Utilisateur ?
L'installateur *User Setup* de VS Code s'installe dans `%LOCALAPPDATA%\Programs\Microsoft VS Code`.
- **Aucun droit administrateur requis** ;
- N'interfère pas avec les stratégies de sécurité machine de l'entreprise ;
- Mises à jour automatiques transparentes sans élévation de privilèges.

### Méthode 1 : Via Winget (Recommandée sous Windows 11)
Dans un terminal PowerShell :
```powershell
winget install --id Microsoft.VisualStudioCode --exact --scope user --source winget --accept-package-agreements --accept-source-agreements --override "/VERYSILENT /NORESTART /MERGETASKS=!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath"
```

Les options `/MERGETASKS` permettent d'ajouter automatiquement :
- L'action *Ouvrir avec Code* dans l'Explorateur Windows pour les fichiers et dossiers ;
- L'entrée dans la variable `PATH` pour utiliser la commande `code`.

### Méthode 2 : Téléchargement Manuel
Sur le site officiel [code.visualstudio.com](https://code.visualstudio.com/), téléchargez l'installateur **Windows User Installer**. Cochez les options d'intégration à l'Explorateur Windows et d'ajout au `PATH`.

---

## 2. Les 4 Extensions Indispensables (Et Rien d'Autre)

Installez uniquement ces 4 extensions officielles. Évitez d'installer conjointement Black, isort, Flake8 ou autopep8 qui entreraient en conflit avec Ruff.

| Extension | ID Unique | Rôle |
| :--- | :--- | :--- |
| **Python** | `ms-python.python` | Détection d'interpréteur, debugging, exécution |
| **Pylance** | `ms-python.vscode-pylance` | Autocomplétion intelligente, vérification de types |
| **Ruff** | `charliermarsh.ruff` | Linter ultra-rapide et formateur conforme PEP 8 |
| **Jupyter** | `ms-toolsai.jupyter` | Fenêtre interactive, exécution de cellules `# %%` |

### Commande d'installation rapide en ligne de commande :
```powershell
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension charliermarsh.ruff
code --install-extension ms-toolsai.jupyter
```

---

## 3. Configuration Dossier Racine (`.vscode/settings.json`)

**Règle essentielle :** Créez le dossier `.vscode` **uniquement à la racine de votre dépôt Git**, jamais dans les sous-dossiers.

Contenu validé pour `.vscode/settings.json` :
```json
{
  "python.defaultInterpreterPath": "${workspaceFolder}/.venv/Scripts/python.exe",
  "python.terminal.activateEnvironment": true,
  "python.terminal.executeInFileDir": true,
  "python.analysis.typeCheckingMode": "basic",
  "jupyter.interactiveWindow.textEditor.executeSelection": true,
  "ruff.lint.extendSelect": [
    "I"
  ],
  "[python]": {
    "editor.defaultFormatter": "charliermarsh.ruff",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.fixAll": "explicit",
      "source.organizeImports": "explicit"
    }
  }
}
```

### Explication des paramètres :
- `python.defaultInterpreterPath` : Pointeur direct vers le `.venv` de la racine via `${workspaceFolder}`.
- `python.analysis.typeCheckingMode`: `"basic"` : Pylance vérifie les types sans être trop restrictif.
- `ruff.lint.extendSelect`: `["I"]` : Active l'organisation et le tri automatique des imports (équivalent isort).
- `editor.formatOnSave` + `editor.defaultFormatter`: `"charliermarsh.ruff"` : Formatage instantané du code à chaque sauvegarde (`Ctrl+S`).
- `jupyter.interactiveWindow.textEditor.executeSelection`: `true` : Permet d'exécuter du code sélectionné ou une cellule `# %%` dans une fenêtre Jupyter interactive avec `Shift+Enter`.

### Recommandations d'extensions du dépôt (`.vscode/extensions.json`) :
```json
{
  "recommendations": [
    "ms-python.python",
    "ms-python.vscode-pylance",
    "charliermarsh.ruff",
    "ms-toolsai.jupyter"
  ]
}
```

---

## 4. Bonnes Pratiques d'Utilisation au Quotidien

### Ouvrir TOUJOURS la racine Git
Ouvrez VS Code à la racine du projet :
```powershell
cd "$HOME\projets\mon_projet"
code .
```
> **Attention :** Si vous ouvrez un sous-dossier directement (ex. `code mon_projet\subfolder`), VS Code ne lira pas le dossier `.vscode/` de la racine et ne détectera pas votre `.venv`. Ouvrez toujours la racine et naviguez dans les fichiers via l'Explorateur de VS Code.

### Sélectionner l'interpréteur Python
Si VS Code ne sélectionne pas automatiquement l'environnement :
1. Pressez `Ctrl+Shift+P` ;
2. Tapez `Python: Select Interpreter` ;
3. Choisissez l'interpréteur correspondant à `./.venv/Scripts/python.exe`.

### Utiliser Jupyter et les cellules `# %%`
Vous pouvez découper n'importe quel fichier `.py` standard en cellules exécutables grâce au commentaire `# %%` :
```python
# %% Cellule 1 : imports
import math
print("Imports chargés")

# %% Cellule 2 : calcul
x = math.sqrt(16)
print(f"Résultat : {x}")
```
Pressez `Shift+Enter` pour exécuter la cellule courante dans la fenêtre interactive. Sélectionnez le kernel Python de votre `.venv` si VS Code vous le demande lors du premier lancement.

---

## 5. Distinction Importante : Extension Ruff vs Package Python `ruff`

- **L'extension VS Code (`charliermarsh.ruff`)** : s'exécute dans l'éditeur et fournit le formatage visuel à la sauvegarde et les soulignements d'erreurs en temps réel.
- **Le package Python (`pip install ruff`)** : s'installe dans le `.venv` pour permettre les vérifications en ligne de commande ou dans un pipeline CI/CD (`python -m ruff format .` ou `python -m ruff check .`).

Les deux sont complémentaires et doivent être utilisés ensemble.

---

## 6. Créer un Fichier Workspace Portable (`.code-workspace`)

Un fichier `.code-workspace` permet d'enregistrer la configuration d'un espace de travail complet et de l'ouvrir d'un simple double-clic ou via un raccourci.

### Règle d'or : Éviter les duplications entre `.vscode/settings.json` et `.code-workspace`

Il existe une hiérarchie stricte des paramètres dans VS Code :
1. **User Settings** (Global machine / utilisateur)
2. **Workspace Settings** (Fichier `.code-workspace`, section `"settings"`)
3. **Folder Settings** (Dossier `.vscode/settings.json`)

> **Piège fréquent :** Si vous définissez `"python.defaultInterpreterPath"` à la fois dans `.vscode/settings.json` et dans le bloc `"settings"` du fichier `.code-workspace`, une ambiguïté survient. De plus, au niveau racine d'un multi-root workspace, `${workspaceFolder}` n'a pas de dossier de rattachement évident et peut être traité comme une **chaîne littérale non résolue** `${workspaceFolder}/.venv/Scripts/python.exe` par l'extension Python.

### Exemple de configuration portable recommandée

Laissez la configuration d'interpréteur Python spécifique au dossier dans `.vscode/settings.json` (ou portez les réglages généraux dans le workspace sans redéfinir `defaultInterpreterPath` s'il est déjà dans le dossier) :

```json
{
  "folders": [
    {
      "name": "Mon Projet",
      "path": "."
    }
  ],
  "settings": {
    "python.terminal.activateEnvironment": true,
    "python.terminal.executeInFileDir": true,
    "python.analysis.typeCheckingMode": "basic",
    "jupyter.interactiveWindow.textEditor.executeSelection": true,
    "ruff.lint.extendSelect": [
      "I"
    ],
    "[python]": {
      "editor.defaultFormatter": "charliermarsh.ruff",
      "editor.formatOnSave": true,
      "editor.codeActionsOnSave": {
        "source.fixAll": "explicit",
        "source.organizeImports": "explicit"
      }
    }
  },
  "extensions": {
    "recommendations": [
      "ms-python.python",
      "ms-python.vscode-pylance",
      "charliermarsh.ruff",
      "ms-toolsai.jupyter"
    ]
  }
}
```

Ouvrir le workspace en ligne de commande :
```powershell
code mon_projet.code-workspace
```

---

## 7. Créer un Raccourci Bureau Windows (`.lnk`)

Pour lancer directement votre workspace VS Code depuis le Bureau Windows sans ouvrir de terminal :

### Script PowerShell de création de raccourci :
```powershell
$desktopPath   = [Environment]::GetFolderPath("Desktop")
$shortcutPath  = Join-Path $desktopPath "Mon Projet - VS Code.lnk"
$targetExe     = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe"
$projectRoot   = "$HOME\projets\mon_projet"
$workspacePath = Join-Path $projectRoot "mon_projet.code-workspace"

$wshShell = New-Object -ComObject WScript.Shell
$shortcut = $wshShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath       = $targetExe
$shortcut.Arguments        = "`"$workspacePath`""
$shortcut.WorkingDirectory = $projectRoot
$shortcut.Description      = "Ouvrir l'espace de travail VS Code du projet"
$shortcut.IconLocation     = "$targetExe,0"
$shortcut.Save()
```

Le raccourci apparaît instantanément sur votre Bureau avec l'icône officielle de VS Code et ouvre l'ensemble du dépôt avec son environnement `.venv` associé en un seul clic.

---

## 8. Dépannage Approfondi : Résoudre l'Erreur "An Invalid Python interpreter is selected"

### Anatomie d'un incident réel

Dans un environnement de développement Windows comportant à la fois un Python système (ex. Python 3.14.4 dans `AppData\Local\Programs\Python`) et un environnement virtuel de projet (ex. Python 3.14.7 dans `.venv`), le message d'erreur suivant peut bloquer VS Code :

> **"An Invalid Python interpreter is selected. Please try changing it to enable features such as IntelliSense, linting, and debugging."**

Pendant ce temps, un test dans le terminal montre que :
- Le binaire `.\.venv\Scripts\python.exe` fonctionne parfaitement ;
- Les scripts et commandes en ligne de commande s'exécutent sans aucune anomalie ;
- `pip check` confirme que toutes les dépendances sont saines.

**Le problème ne vient pas de l'environnement Python lui-même, mais de la manière dont VS Code résout et mémorise l'interpréteur actif.**

---

### Analyse des causes racines

L'investigation technique de cet incident met en lumière trois facteurs conjugués :

1. **Un `.venv` valide ne garantit pas sa sélection dans VS Code** :
   Le moteur de découverte de l'extension `ms-python.python` s'exécute de façon asynchrone au démarrage. La simple présence d'un dossier `.venv` sur le disque ne suffit pas si l'état interne de VS Code pointe vers un identifiant d'interpréteur invalide.

2. **Duplication de `python.defaultInterpreterPath` et variables non résolues** :
   Lorsque la directive `"python.defaultInterpreterPath": "${workspaceFolder}/.venv/Scripts/python.exe"` est inscrite simultanément dans `.vscode/settings.json` et dans la section `"settings"` globale d'un fichier `.code-workspace`, VS Code tente de réconcilier les deux portées. Au niveau workspace, `${workspaceFolder}` n'est pas toujours résolu immédiatement et se retrouve persisté sous forme de chaîne de caractères littérale non développée.

3. **Persistance de l'état d'interpréteur (`state.vscdb`)** :
   VS Code maintient une base de données SQLite locale (`state.vscdb` dans le dossier de cache de l'espace de travail sous `%APPDATA%\Code\User\workspaceStorage\...`). L'extension Python et l'extension Python Environments y enregistrent :
   - `lastKnownActiveInterpreter` ;
   - `autoSelectedWorkspacePythonPath` ;
   - Le chemin absolu du dernier interpréteur testé.
   Si un interpréteur système antérieur (ou un chemin littéral non substitué) y a été stocké, VS Code continue de tenter de le charger à chaque démarrage du workspace, ignorant le chemin valide tant que le cache n'est pas invalidé.

> **Important — Distinctions méthodologiques :**
> Lors de l'investigation approfondie de cet incident, la correction a été prouvée en examinant les tables de `state.vscdb`. **Cependant, la modification directe de la base SQLite interne de VS Code ne doit JAMAIS être la procédure standard.** Elle est fragile, dépendante des versions internes de VS Code et risque de corrompre le profil utilisateur. La solution pérenne repose sur les commandes natives de l'interface VS Code et une architecture de configuration saine.

---

### Procédure de résolution recommandée (Via les commandes officielles VS Code)

Suivez cette procédure structurée pour réinitialiser proprement la sélection d'interpréteur :

#### Étape 1 : Nettoyer la configuration du workspace
Vérifiez vos fichiers de configuration :
- Dans le fichier `.code-workspace`, **supprimez** toute occurrence de `python.defaultInterpreterPath`.
- Dans `.vscode/settings.json` à la racine du dossier, assurez-vous de n'avoir qu'une seule définition propre :
  ```json
  "python.defaultInterpreterPath": "${workspaceFolder}/.venv/Scripts/python.exe"
  ```

#### Étape 2 : Réinitialiser la sélection persistée dans VS Code
Ouvrez le projet ou l'espace de travail dans VS Code, puis :
1. Ouvrez la palette de commandes avec `Ctrl+Shift+P` ;
2. Exécutez la commande :
   ```
   Python: Clear Workspace Interpreter Setting
   ```
3. Ouvrez à nouveau la palette (`Ctrl+Shift+P`) et exécutez :
   ```
   Python: Select Interpreter
   ```
4. Sélectionnez expressément l'environnement virtuel du projet :
   `Python 3.14.x ('.venv': venv) .\.venv\Scripts\python.exe`
   *(Si l'environnement n'apparaît pas dans la liste, choisissez "Enter interpreter path..." puis parcourez jusqu'à `.\.venv\Scripts\python.exe`)*.

#### Étape 3 : Recharger la fenêtre
Appliquez immédiatement le changement d'état :
1. `Ctrl+Shift+P` -> `Developer: Reload Window`.
2. Laissez VS Code recharger l'ensemble des services de langage.

---

### Inspection des journaux (Logs de validation)

Pour valider que l'interpréteur est correctement reconnu par toutes les couches de l'outillage, inspectez les canaux de sortie de VS Code :

Ouvrez le panneau Sortie via `Ctrl+Shift+U`, puis sélectionnez successivement dans la liste déroulante à droite :

| Canal de sortie | Ce qu'il faut vérifier | Indicateur de succès |
| :--- | :--- | :--- |
| **Python** | Journal d'activation du service Python | Détection de l'interpréteur `.venv\Scripts\python.exe` sans erreur `Invalid interpreter`. |
| **Python Environments** | Gestionnaire des environnements virtuels | L'environnement `.venv` est identifié avec son statut `workspace` actif. |
| **Pylance** | Moteur de typage et d'analyse statique | Initialisation réussie, pointant vers les `site-packages` de `.venv`. |
| **Ruff** | Linter et formateur | Démarrage du serveur de langage Ruff sans avertissement de binaire manquant. |

Si un notebook ou une cellule interactive `# %%` est utilisée, vérifiez également dans la barre d'état en haut à droite du document que le **Kernel Jupyter** indique bien `.venv (Python 3.14.x)`.

---

### Validation après redémarrage complet

Pour vous assurer que le problème est résolu de manière définitive et ne réapparaîtra pas au prochain lancement :

1. Fermez complètement VS Code (`Fichier` -> `Quitter`).
2. Rouvrez l'espace de travail via votre raccourci ou en ligne de commande :
   ```powershell
   code mon_projet.code-workspace
   ```
3. Vérifiez la barre d'état inférieure de VS Code :
   - En bas à droite, la mention `3.14.x ('.venv': venv)` doit s'afficher immédiatement en bleu ou gris foncé sans popup d'avertissement.
4. Ouvrez un fichier Python (ex. `app.py`) :
   - Pylance doit fournir l'autocomplétion sans latence anormale ;
   - La sauvegarde (`Ctrl+S`) doit déclencher Ruff sans message d'erreur.

---

### Prévention : Bonnes pratiques pour les nouveaux projets

Pour éviter que cet incident ne se reproduise lors de la création d'un nouveau projet :

1. **Créer le `.venv` AVANT d'ouvrir VS Code** :
   ```powershell
   mkdir nouveau_projet
   cd nouveau_projet
   git init
   py -3 -m venv .venv
   code .
   ```
   Lorsque VS Code s'ouvre sur un dossier contenant déjà `.venv\Scripts\python.exe`, son heuristique de découverte automatique sélectionne le venv local en priorité et évite d'enregistrer le Python système dans son cache.
2. **Ne jamais dupliquer les chemins d'interpréteurs** entre les paramètres utilisateur, de dossier (`.vscode/settings.json`) et d'espace de travail (`.code-workspace`).
3. **Conserver `.vscode/settings.json` à la racine Git** : un seul fichier de configuration d'éditeur pour l'ensemble du dépôt.
