# 04 — Gestion Propre des Dépendances avec Pip et `requirements.txt`

Ce guide présente les règles de gestion des dépendances en Python standard pour maintenir un projet reproductible, sans pollution de packages et sans dépendre d'outils tiers (sans uv, sans Poetry).

---

## 1. Dépendances Directes vs Dépendances Transitives

Un piège classique consiste à exécuter `pip freeze > requirements.txt` sans discernement.

### Dépendances Directes (À spécifier)
Ce sont les bibliothèques que votre code importe directement :
```python
import requests
from dotenv import load_dotenv
```
Dans votre `requirements.txt`, vous ne devez inscrire que ces dépendances directes, ainsi que vos outils de développement nécessaires :
- `requests>=2.31.0`
- `python-dotenv>=1.0.0`
- `ipykernel>=6.29.0` (outil de dev pour notebooks et cellules interactives)
- `ruff>=0.8.0` (outil de dev linter/formateur)

### Dépendances Transitives (Sous-dépendances automatiques)
Ce sont les packages dont ont besoin vos bibliothèques pour fonctionner (par exemple `urllib3`, `certifi`, `idna`, `charset-normalizer` pour `requests`).
Pip les installe et les gère automatiquement. Les inscrire manuellement dans un `requirements.txt` de développement alourdit la maintenance et complique les montées de versions futures.

---

## 2. Syntaxe des Versions dans `requirements.txt`

| Syntaxe | Exemple | Signification | Quand l'utiliser |
| :--- | :--- | :--- | :--- |
| **Minimum compatible** | `requests>=2.31.0` | Installe la version 2.31.0 ou toute version ultérieure compatible. | **Recommandé pour les projets et bibliothèques** |
| **Borne de sécurité** | `requests>=2.31.0,<3.0.0` | Accepte les mises à jour mineures mais bloque les changements majeurs d'API. | Recommandé en production |
| **Version stricte** | `requests==2.31.0` | Fige la version exacte au bit près. | Recommandé pour des déploiements critiques ou conteneurs Docker |

---

## 3. Commandes Fondamentales d'Administration Pip

Toutes les commandes s'exécutent via l'interpréteur du `.venv` ou via votre lanceur de projet personnalisé (`pyproj`) :

### Installer les dépendances du projet
```powershell
# Appel direct standard (recommandé)
& ".\.venv\Scripts\python.exe" -m pip install -r requirements.txt

# Avec le lanceur de projet
pyproj pip install -r requirements.txt
```

### Vérifier la cohérence de l'environnement (Conflits)
```powershell
& ".\.venv\Scripts\python.exe" -m pip check
```
Si la sortie affiche `No broken requirements found.`, votre environnement est sain et exempt de conflits de versions.

### Inspecter un package précis
```powershell
& ".\.venv\Scripts\python.exe" -m pip show requests
```
Affiche la version installée, son emplacement physique, ses dépendances et sa licence.

### Lister tous les packages installés
```powershell
& ".\.venv\Scripts\python.exe" -m pip list
```

---

## 4. Ajouter une Nouvelle Dépendance Proprement

Pip n'ajoute pas automatiquement les packages dans votre `requirements.txt` lors d'un `pip install`. Voici la procédure pas à pas :

1. **Installer le package dans le `.venv` :**
   ```powershell
   & ".\.venv\Scripts\python.exe" -m pip install requests
   ```
2. **Tester le package dans votre code :**
   ```powershell
   & ".\.venv\Scripts\python.exe" -c "import requests; print(requests.__version__)"
   ```
3. **Mettre à jour explicitement `requirements.txt` :**
   Ouvrez le fichier `requirements.txt` et ajoutez la ligne correspondante avec la version minimale testée :
   ```
   requests>=2.31.0
   ```
4. **Vérifier l'absence de conflit :**
   ```powershell
   & ".\.venv\Scripts\python.exe" -m pip check
   ```

---

## 5. Démarrer sur une Machine Neuve ou un Projet Cloné

Lorsqu'un collègue ou vous-même clonez le projet sur une nouvelle machine :

```powershell
# 1. Se placer à la racine Git du projet
cd "$HOME\projets\mon_projet"

# 2. Créer le .venv racine
py -3 -m venv .venv

# 3. Installer toutes les dépendances définies dans requirements.txt
& ".\.venv\Scripts\python.exe" -m pip install -r requirements.txt

# 4. Vérifier l'installation
& ".\.venv\Scripts\python.exe" -m pip check

# 5. Ouvrir VS Code
code .
```

---

## 6. Règles de Sécurité Absolues

1. **Jamais de secrets dans `requirements.txt`** : Aucune clé API, aucun token, aucun mot de passe ne doit jamais figurer dans ce fichier.
2. **Jamais d'URL avec identifiants** : Ne mettez pas de liens de dépôts privés avec tokens inclus (`https://token@github.com/...`).
3. **`requirements.txt` est versionné dans Git** : Ce fichier doit être commité et suivi à la racine du dépôt pour garantir la reproductibilité du projet pour tous les collaborateurs.
