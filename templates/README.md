# Templates pour Lanceur CLI Windows

Ce dossier contient des modèles prêts à l'emploi pour créer une commande de projet personnalisée sous Windows.

## Fichiers disponibles

- [`launcher.cmd`](launcher.cmd) : script batch qui détecte dynamiquement la racine du dépôt Git via `git rev-parse --show-toplevel` et exécute `launcher_runner.py` avec l'interpréteur Python du `.venv` racine.
- [`launcher_runner.py`](launcher_runner.py) : script Python qui relaie fidèlement les arguments (avec espaces et guillemets) via le module standard `subprocess`.

## Utilisation

1. Copiez ces deux fichiers dans un dossier utilisateur de votre `PATH` (ex. `%USERPROFILE%\.local\bin`).
2. Renommez-les selon le nom de commande souhaité (ex. `pyproj.cmd` et `pyproj_runner.py`).
3. Mettez à jour le nom du runner dans le fichier `.cmd`.
4. Consultez le guide complet : [02 — Créer un Lanceur CLI Windows Universel](../02_CREER_UN_RACCOURCI_COMMANDE_CLI.md).
