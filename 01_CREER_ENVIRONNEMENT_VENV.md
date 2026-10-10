# 01 — Créer et Gérer un Environnement Virtuel Python (`.venv`) sous Windows

Ce guide présente la méthode standard et pérenne pour créer, utiliser et administrer un environnement virtuel Python (`.venv`) unique et partagé au sein d'un dépôt Git, sans recourir à des outils tiers (ni uv, ni Poetry, ni Conda).

---

## 1. Rôle et Principe d'Isolation

### Pourquoi un `.venv` par projet ?
Sous Windows, installer des bibliothèques directement avec le Python global (`C:\Python3x` ou `AppData\Local\Programs\Python`) pollue l'environnement système et entraîne des conflits de versions entre projets.

Un environnement virtuel (`.venv`) résout ce problème en créant un dossier local contenant :
- Un interpréteur Python dédié (copie ou lien vers le binaire système) ;
- Un dossier `Lib\site-packages` isolé où sont installées les dépendances du projet ;
- Ses propres scripts exécutables (`Scripts\python.exe`, `Scripts\pip.exe`).

### Règle d'or : Un SEUL `.venv` à la racine Git
Pour un projet structuré en plusieurs sous-dossiers (modules, leçons, exercices), **il ne faut jamais créer de `.venv` imbriqué dans chaque sous-dossier**.
Un unique `.venv` situé à la racine du dépôt Git suffit pour tous les dossiers enfants. Tous les scripts de tous les sous-dossiers partagent ainsi les mêmes bibliothèques installées.

---

## 2. Prérequis et Diagnostic Préalable

Avant de manipuler l'environnement, vérifiez les versions et l'emplacement de votre dépôt :

```powershell
# 1. Vérifier la version du lanceur Windows py
py --version

# 2. Lister les interpréteurs CPython installés sur la machine
py -0p

# 3. Vérifier que vous êtes bien dans un dépôt Git et identifier la racine
git rev-parse --show-toplevel
```

Si `git rev-parse --show-toplevel` renvoie une erreur *"fatal: not a git repository"*, initialisez ou identifiez d'abord votre dépôt Git. Ne créez pas de `.venv` dans un dossier quelconque.

---

## 3. Création du `.venv` à la Racine du Projet

### A. Créer l'environnement
Placez-vous impérativement à la racine du dépôt Git :

```powershell
# Se positionner à la racine du projet
cd (git rev-parse --show-toplevel)

# Créer le dossier .venv avec le module standard venv de CPython 3
py -3 -m venv .venv
```

> **Attention — Préservation :** Si un dossier `.venv` existe déjà et fonctionne, **ne le supprimez pas** et ne le recréez pas sans raison. Réutilisez l'environnement existant.

### B. Vérifier que pip est présent
Certains outils ou configurations créent un venv allégé sans `pip`. Vérifiez immédiatement :

```powershell
& ".\.venv\Scripts\python.exe" -m pip --version
```

Si le message `No module named pip` apparaît, installez pip avec le module standard `ensurepip` :

```powershell
& ".\.venv\Scripts\python.exe" -m ensurepip --upgrade
```

---

## 4. Exécuter Python Sans Activation (Méthode Recommandée en Entreprise)

L'activation d'un environnement (`Activate.ps1`) est facultative. Elle se contente de modifier temporairement la variable `PATH` de votre session shell. Sur un poste d'entreprise, les restrictions de stratégie de script (`ExecutionPolicy Restricted`) bloquent souvent les fichiers `.ps1`.

**La méthode la plus robuste et la plus prévisible consiste à appeler directement le binaire du `.venv`.**

### A. Depuis la racine du dépôt Git

**PowerShell :**
```powershell
& ".\.venv\Scripts\python.exe" .\app.py
```

**CMD.exe :**
```cmd
.venv\Scripts\python.exe app.py
```

### B. Depuis N'IMPORTE QUEL sous-dossier (ex. `lesson_01\`)

**PowerShell :**
```powershell
# Résolution dynamique de la racine Git
$root = (git rev-parse --show-toplevel).Trim()

# Exécution du script local avec le Python de la racine
& (Join-Path $root '.venv\Scripts\python.exe') .\app.py
```

**CMD.exe :**
```cmd
for /f "delims=" %R in ('git rev-parse --show-toplevel') do "%R\.venv\Scripts\python.exe" app.py
```
*(Dans un fichier `.bat` ou `.cmd`, doublez le signe pourcentage : `%%R`)*

---

## 5. Activation Optionnelle (Raccourci de session)

Si votre politique de sécurité locale l'autorise et que vous préférez taper simplement `python app.py` :

### PowerShell
```powershell
# Activer
.\.venv\Scripts\Activate.ps1

# Utiliser
python app.py
python -m pip list

# Désactiver en fin de session
deactivate
```

### CMD
```cmd
REM Activer
.venv\Scripts\activate.bat

REM Utiliser
python app.py
python -m pip list

REM Désactiver
deactivate
```

> **Avertissement Sécurité :** Si PowerShell affiche une erreur de restriction (`execution of scripts is disabled on this system`), **ne modifiez pas la politique système** (`Set-ExecutionPolicy`). Utilisez l'appel direct `& ".\.venv\Scripts\python.exe"` ou un lanceur personnalisé (voir Guide 02).

---

## 6. Gestion des Dépendances avec Pip

Toutes les installations doivent se faire exclusivement à travers l'exécutable du `.venv` pour ne jamais polluer le système :

```powershell
# Installer un package
& ".\.venv\Scripts\python.exe" -m pip install requests

# Installer depuis un fichier requirements.txt
& ".\.venv\Scripts\python.exe" -m pip install -r requirements.txt

# Lister les packages installés
& ".\.venv\Scripts\python.exe" -m pip list

# Vérifier la cohérence des dépendances (détection de conflits)
& ".\.venv\Scripts\python.exe" -m pip check
```

---

## 7. Interpréteur vs Current Working Directory (CWD)

Une distinction fondamentale à maîtriser :

| Concept | Définition | Impact |
| :--- | :--- | :--- |
| **Interpréteur (`sys.executable`)** | Le binaire Python qui exécute le code. | Détermine quelles bibliothèques (`site-packages`) sont disponibles. Toujours `<git-root>\.venv\Scripts\python.exe`. |
| **Répertoire de travail (`CWD`)** | Le dossier dans lequel le terminal se trouve au lancement. | Détermine comment les chemins relatifs (`open('fichier.txt')`) sont résolus. |

Pour que vos scripts fonctionnent quel que soit le dossier de lancement, ancrez toujours vos chemins de fichiers :
```python
from pathlib import Path

# Chemin relatif au fichier de script lui-même (idéal pour les fichiers locaux)
SCRIPT_DIR = Path(__file__).resolve().parent
local_file = SCRIPT_DIR / "donnees.json"

# Chemin relatif à la racine du dépôt Git (idéal pour charger .env ou requirements)
ROOT_DIR = next(p for p in Path(__file__).resolve().parents if (p / ".git").exists())
config_file = ROOT_DIR / ".env"
```

---

## 8. Diagnostic et Erreurs Fréquentes

### Vérifier que vous êtes bien dans le `.venv`
Exécutez ce test à tout moment :
```powershell
& ".\.venv\Scripts\python.exe" -c "import sys; print('Executable:', sys.executable); print('In venv:', sys.prefix != sys.base_prefix)"
```
- `Executable` doit pointer vers votre dossier `.venv`.
- `In venv` doit afficher `True`.

### Erreurs classiques

| Symptôme | Cause | Solution |
| :--- | :--- | :--- |
| `No module named pip` | Environnement créé sans pip. | Exécuter `& ".\.venv\Scripts\python.exe" -m ensurepip --upgrade`. |
| `ImportError: No module named xxx` | Le package a été installé dans le Python global ou un autre venv. | Lancer `& ".\.venv\Scripts\python.exe" -m pip install xxx`. |
| `Activate.ps1 cannot be loaded...` | Restriction de politique Windows PowerShell. | Utiliser l'appel direct sans activation : `& ".\.venv\Scripts\python.exe"`. |
| Chemins de fichiers non trouvés dans les sous-dossiers | Le script utilise des chemins relatifs au CWD. | Utiliser `Path(__file__).resolve().parent` dans le code Python. |
