# 05 — Maîtrise de `.gitignore` et Gestion des Artefacts Git sous Windows

Ce guide explique comment configurer un fichier `.gitignore` robuste pour un projet Python, et détaille la procédure précise pour désindexer des fichiers accidentellement suivis sans les supprimer du disque dur.

---

## 1. Modèle Standard `.gitignore` pour un Projet Python

Créez le fichier `.gitignore` dès la commande `git init` à la racine de votre projet :

```gitignore
# ==========================================
# Fichiers et Dossiers d'Environnement
# ==========================================
.venv/
env/
venv/
ENV/

# ==========================================
# Caches Python et Bytecode
# ==========================================
__pycache__/
*.py[cod]
*$py.class
*.so

# ==========================================
# Outils de Test, Linting et Formatage
# ==========================================
.pytest_cache/
.mypy_cache/
.ruff_cache/
.coverage
htmlcov/

# ==========================================
# Jupyter Notebooks & Outils Interactifs
# ==========================================
.ipynb_checkpoints/

# ==========================================
# Secrets et Variables d'Environnement
# ==========================================
.env
.env.local
.env.*.local

# Conserver les fichiers d'exemples publics
!.env.example
!.env.template

# ==========================================
# Fichiers Système et OS (Windows / macOS)
# ==========================================
Thumbs.db
Desktop.ini
.DS_Store

# ==========================================
# Artefacts Temporaires et Logs
# ==========================================
*.log
*.tmp
.agent-tmp/
.playwright-mcp/
```

---

## 2. Le Principe Fondamental : `.gitignore` n'est pas Rétroactif

> **Règle capitale de Git :**
> Si un fichier ou dossier est **déjà suivi (indexé)** dans Git avant d'ajouter son motif dans `.gitignore`, **Git continuera à suivre ses modifications !**
> L'ajout d'une ligne dans `.gitignore` ne désindexe pas un fichier déjà commité ou déjà stagé.

---

## 3. Comment Désindexer Proprement Sans Supprimer le Fichier du Disque ?

Pour qu'un fichier déjà suivi soit retiré de Git **tout en restant intact sur votre machine**, vous devez utiliser la commande `git rm --cached`.

### A. Désindexer un fichier unique (ex. un `.env` commité par erreur) :
```powershell
# 1. Enlever de l'index Git (le fichier reste intact sur votre disque)
git rm --cached -- .env

# 2. Vérifier que la règle est bien dans .gitignore
# Si ce n'est pas fait, ajoutez la ligne '.env' dans .gitignore

# 3. Stage du .gitignore
git add .gitignore

# 4. Vérifier l'état avant commit
git status --short
# Résultat attendu :
# D  .env           (D vert = Deleted from index)
# M  .gitignore     (M vert = Modified staged)

# 5. Committer la désindexation
git commit -m "Désindexer le fichier .env local"
```

### B. Désindexer un dossier entier (ex. un `.venv/` ou `.playwright-mcp/`) :
```powershell
# Enlever récursivement de l'index
git rm -r --cached -- .venv/
```

> **Attention — Sécurité :** Ne lancez **JAMAIS** `git rm -r --cached .` (avec un point) ! Cette commande viderait entièrement l'index de tout votre dépôt Git. Ciblez toujours précisément le fichier ou dossier concerné.

---

## 4. Que se passe-t-il lors du prochain `git push` ?

Il est crucial de comprendre l'impact sur vos collègues ou votre dépôt distant :

1. **Sur votre machine locale :** Le fichier reste présent sur votre disque dur (ex. votre fichier local `.env` ou `.venv` continue de fonctionner normalement).
2. **Sur le dépôt distant (GitHub/GitLab) :** Au prochain commit et push, le fichier est **supprimé de la branche courante**. Si un collègue fait `git pull`, le fichier sera supprimé de sa copie locale de travail.
3. **Dans l'historique Git passé :** Les commits précédents contiennent toujours le fichier s'il a déjà été poussé !
   - *Règle de sécurité impérative :* Si une vraie clé API ou un mot de passe a été commité et poussé sur GitHub, **considérez le secret comme compromis**. Révoquez immédiatement la clé sur le tableau de bord du fournisseur (rotation de clé) plutôt que de vous fier uniquement à un nettoyage d'historique.

---

## 5. Commandes de Diagnostic Git Utiles

### Vérifier si un fichier est ignoré et par quelle règle :
```powershell
git check-ignore -v --no-index .env
```
Affiche le fichier `.gitignore` et le numéro de ligne responsable de l'exclusion.

### Vérifier si un fichier est actuellement suivi par Git :
```powershell
git ls-files -- .env
```
- Si la commande ne retourne rien : le fichier n'est **pas** suivi par Git (situation normale pour un `.env`).
- Si la commande affiche `.env` : le fichier est actuellement suivi par Git et doit être désindexé avec `git rm --cached`.

### Vérifier précisément ce qui va être commité :
Avant tout commit, inspectez toujours :
```powershell
# Statut synthétique (fichiers stagés en vert, unstaged en rouge)
git status --short

# Noms et statuts exacts des fichiers stagés
git diff --cached --name-status
```
Ne committez jamais à l'aveugle avec `git add -A` ou `git commit -a`. Ajoutez spécifiquement vos fichiers par nom (`git add <fichier>`).
