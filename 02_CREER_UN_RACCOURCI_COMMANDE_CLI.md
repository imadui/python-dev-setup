# 02 — Créer un Lanceur CLI Windows Universel (`pyproj` / Raccourci de Projet)

Ce guide explique le fonctionnement d'un lanceur Windows pour projet Python et fournit une méthode robuste et généralisable pour créer n'importe quel raccourci en ligne de commande sous Windows sans dépendre d'outils tiers.

---

## 1. Pourquoi un Lanceur Dédié ?

Dans un dépôt structuré avec de multiples sous-dossiers (`src\`, `scripts\`, `tests\`), devoir taper à chaque fois le chemin complet :
```powershell
$root = (git rev-parse --show-toplevel).Trim(); & (Join-Path $root '.venv\Scripts\python.exe') app.py
```
est verbeux et source d'erreurs.

Un lanceur dédié résout ce problème en offrant une commande courte :
```powershell
pyproj python app.py
pyproj pip install requests
```
qui fonctionne **depuis la racine comme depuis n'importe quel sous-dossier**.

---

## 2. Anatomie de la Solution à Deux Fichiers

Sous Windows, faire suivre des arguments complexes en pur script batch (`.cmd` / `shift` / `%*`) est notoirement fragile : les points d'exclamation `!`, les guillemets imbriqués et les chemins avec espaces sont souvent tronqués ou corrompus par `cmd.exe`.

La solution éprouvée repose sur **deux petits fichiers complémentaires** (disponibles comme modèles dans le dossier `templates/`) :
1. **Un script lanceur `.cmd`** : très court, il utilise Git pour trouver la racine du dépôt et vérifie l'existence du `.venv`.
2. **Un helper Python `_runner.py`** : situé juste à côté du `.cmd`, il reçoit les arguments intacts et utilise le module standard `subprocess` pour les transmettre fidèlement à l'interpréteur du `.venv`.

```
%USERPROFILE%\.local\bin\
├── pyproj.cmd           <- Résout la racine Git et appelle pyproj_runner.py avec le bon Python
└── pyproj_runner.py     <- Transmet les arguments de manière fiable (subprocess)
```

### Le fichier `pyproj.cmd`
```cmd
@echo off
setlocal DisableDelayedExpansion
set "GIT_ROOT="
for /f "delims=" %%R in ('git rev-parse --show-toplevel 2^>nul') do set "GIT_ROOT=%%R"
if not defined GIT_ROOT (
    >&2 echo ERROR: Run this command from inside a Git repository.
    exit /b 1
)
set "GIT_ROOT=%GIT_ROOT:/=\%"
set "VENV_PYTHON=%GIT_ROOT%\.venv\Scripts\python.exe"
if not exist "%VENV_PYTHON%" (
    >&2 echo ERROR: Missing Git-root virtual environment: "%VENV_PYTHON%"
    exit /b 1
)
if not exist "%~dp0pyproj_runner.py" (
    >&2 echo ERROR: pyproj_runner.py is missing beside this script.
    exit /b 1
)
"%VENV_PYTHON%" "%~dp0pyproj_runner.py" %*
exit /b %ERRORLEVEL%
```

**Rôles de `pyproj.cmd` :**
- `DisableDelayedExpansion` : protège les caractères spéciaux comme `!` dans les arguments ;
- `git rev-parse --show-toplevel` : découvre dynamiquement la racine du dépôt sans jamais coder de chemin absolu en dur ;
- Vérifie la présence de `.venv\Scripts\python.exe` à cette racine (aucun risque de basculer silencieusement sur le Python système) ;
- `exit /b %ERRORLEVEL%` : propage exactement le code retour du sous-processus vers le terminal de l'utilisateur.

### Le fichier `pyproj_runner.py`
```python
import subprocess
import sys

if len(sys.argv) < 2 or sys.argv[1].lower() not in ("python", "pip"):
    print("Usage: pyproj python <args> | pyproj pip <args>", file=sys.stderr)
    raise SystemExit(2)

command = [sys.executable]
if sys.argv[1].lower() == "pip":
    command += ["-m", "pip"]
command += sys.argv[2:]

raise SystemExit(subprocess.run(command, check=False).returncode)
```

**Rôles de `pyproj_runner.py` :**
- Limite l'exécution aux sous-commandes attendues (`python` et `pip`) pour éviter tout contournement involontaire ;
- Transforme automatiquement `pyproj pip ...` en `python.exe -m pip ...` garantissant qu'aucun pip externe n'est appelé ;
- `sys.argv[2:]` : transmet les arguments avec leurs guillemets, espaces et caractères spéciaux sans aucune altération ;
- `check=False` + `returncode` : propage le code de retour exact (0 pour succès, code d'erreur si échec).

---

## 3. Emplacement et Intégration dans le `PATH`

### Dossier standard utilisateur : `%USERPROFILE%\.local\bin`
Placez vos scripts utilitaires utilisateur dans :
```
%USERPROFILE%\.local\bin
```
*(soit typiquement `C:\Users\<NomUtilisateur>\.local\bin`)*. Ce dossier a l'avantage d'être propre à votre compte Windows et ne nécessite aucun droit administrateur.

### Vérifier si le dossier est dans le PATH
Dans PowerShell :
```powershell
($env:PATH -split ';') -contains "$env:USERPROFILE\.local\bin"
```
- Si **True** : vous pouvez simplement taper `pyproj python ...` depuis n'importe où.
- Si **False** : vous pouvez appeler le lanceur via son chemin complet sans modifier la machine :
  ```powershell
  & "$HOME\.local\bin\pyproj.cmd" python app.py
  ```
  Ou ajouter ce dossier à votre variable `PATH` utilisateur dans Windows (Paramètres système -> Variables d'environnement utilisateur).

---

## 4. Exemples d'Utilisation Concrets

Toutes ces commandes fonctionnent à l'identique depuis la racine du dépôt ou depuis un sous-dossier :

```powershell
# 1. Vérifier quel interpréteur est actif
pyproj python -c "import sys; print(sys.executable)"

# 2. Vérifier la version de pip du .venv
pyproj pip --version

# 3. Exécuter un script situé dans le dossier courant
pyproj python app.py

# 4. Exécuter un script avec un chemin relatif depuis la racine
pyproj python src\app.py

# 5. Installer une dépendance
pyproj pip install requests

# 6. Installer toutes les dépendances du projet
pyproj python -m pip install -r requirements.txt

# 7. Tester un code avec caractères spéciaux et guillemets
pyproj python -c "print('Hello, world!')"
```

---

## 5. Comment Personnaliser le Nom du Lanceur pour Vos Projets

Pour créer un lanceur avec un autre nom (par exemple `myproj` ou `devcli`) :

1. Copiez les modèles depuis le dossier `templates/` de ce dépôt :
   - `templates/launcher.cmd` -> `%USERPROFILE%\.local\bin\<nom>.cmd`
   - `templates/launcher_runner.py` -> `%USERPROFILE%\.local\bin\<nom>_runner.py`
2. Dans `<nom>.cmd`, mettez à jour la référence au fichier python :
   Remplacez `launcher_runner.py` par `<nom>_runner.py`.
3. Dans `<nom>_runner.py`, ajustez le message d'aide avec votre nom de commande :
   `Usage: <nom> python <args> | <nom> pip <args>`.
4. Aucun redémarrage n'est requis : tapez immédiatement `<nom> python app.py` dans votre projet.

---

## 6. Limitations et Bonnes Pratiques

- **Dépôt Git obligatoire** : Le lanceur utilise `git rev-parse` pour repérer la racine. Il refuse de s'exécuter hors d'un dépôt Git.
- **`.venv` à la racine obligatoire** : Si le dossier `.venv` est manquant ou déplacé, le lanceur affiche un message d'erreur clair et refuse d'exécuter un Python système non isolé.
- **Répertoire de travail (CWD)** : Le lanceur préserve le CWD de l'utilisateur. Si vous lancez `pyproj python app.py` depuis un sous-dossier, `app.py` est cherché dans ce sous-dossier.
