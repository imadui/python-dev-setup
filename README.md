# Python Development Environment Setup — VS Code, venv, Ruff, pip & Git

A practical, robust, and reproducible guide to setting up a modern Python development environment on Windows using Visual Studio Code, standard `venv`, pip, Ruff, Pylance, Jupyter, and Git.

Stop repeating environment configuration from scratch or wrestling with broken interpreters. This repository documents a production-ready workflow for developers who want a reliable local Python workspace without relying on third-party environment managers.

---

## Overview: What This Repository Provides

- **Deterministic Virtual Environments**: Standard `python -m venv` configuration rooted at your Git repository.
- **Enterprise-Safe Execution**: Running scripts and pip directly via `.venv\Scripts\python.exe` without fighting PowerShell execution policies.
- **Modern VS Code Integration**: Seamless configuration for Ruff (linting and formatting), Pylance (static typing), and Jupyter interactive computing.
- **Real-World Troubleshooting**: Complete post-mortem and resolution for the common *"Invalid Python interpreter is selected"* error in VS Code multi-root workspaces.
- **Dependency Hygiene**: Clean `requirements.txt` workflows separating direct dependencies from transitive sub-packages.
- **Git Security & Tracking Control**: Production `.gitignore` templates and exact commands to untrack sensitive files (`.env`, `.venv`) from Git's index without deleting local data.
- **Reusable CLI Launcher Templates**: Portable Windows command-line shortcuts that dynamically locate the active repository root and its virtual environment.

---

## Technical Guides

This repository provides comprehensive, dedicated technical documentation (available in French):

| Guide | Focus Area | Key Topics |
| :--- | :--- | :--- |
| [**01 — Python Virtual Environments**](01_CREER_ENVIRONNEMENT_VENV.md) | `.venv` Creation & Management | `py -3 -m venv`, running without activation, interpreter vs. CWD, `ensurepip` |
| [**02 — Reusable CLI Launcher**](02_CREER_UN_RACCOURCI_COMMANDE_CLI.md) | Custom Command Shortcuts | Dual-file pattern (`.cmd` + `_runner.py`), argument forwarding, `%USERPROFILE%\.local\bin` |
| [**03 — VS Code Python Setup & Troubleshooting**](03_VSCODE_SETUP_PYTHON.md) | Editor, Ruff, Pylance & Fixes | User-scope install, `.vscode/settings.json`, `.code-workspace`, **Invalid interpreter post-mortem** |
| [**04 — Pip & Dependency Management**](04_REQUIREMENTS_DEPENDANCES_PIP.md) | `requirements.txt` & Hygiene | Direct vs. transitive packages, version constraints, `pip check`, new project onboarding |
| [**05 — Git Tracking & .gitignore**](05_GITIGNORE_ET_SUIVI_GIT.md) | Version Control Hygiene | `.gitignore` rules, `git rm --cached`, secret exposure mitigation, staged diff inspection |

Reference launcher files are also available in the [**templates/**](templates/) directory.

---

## Prerequisites

Before getting started on Windows, ensure the following tools are installed:

- **Windows 10 / 11** (64-bit)
- **Python 3.10+** (Official CPython installer from [python.org](https://www.python.org/downloads/) with the `py` launcher enabled)
- **Git for Windows** ([git-scm.com](https://git-scm.com/))
- **Visual Studio Code** (User Installer from [code.visualstudio.com](https://code.visualstudio.com/))

Verify your environment in PowerShell:
```powershell
py --version
git --version
code --version
```

---

## Quick Start (Windows PowerShell)

Choose the scenario that matches your starting point:

### Scenario A: Creating a Brand-New Python Project

Follow these steps to initialize a clean project from scratch, add packages, and generate `requirements.txt` in the correct order:

**1. Create the project directory and virtual environment**
```powershell
mkdir my-python-project
cd my-python-project
git init
py -3 -m venv .venv
```

**2. Verify the virtual environment**
Execute Python directly via the `.venv` binary (no activation required):
```powershell
& ".\.venv\Scripts\python.exe" --version
& ".\.venv\Scripts\python.exe" -m pip --version
```

**3. Install packages and declare direct dependencies**
Install packages directly into `.venv` and test them:
```powershell
& ".\.venv\Scripts\python.exe" -m pip install requests python-dotenv
& ".\.venv\Scripts\python.exe" -c "import requests, dotenv; print('Environment healthy!')"
```

Create your initial `requirements.txt` with your direct dependencies:
```powershell
@"
requests>=2.31.0
python-dotenv>=1.0.0
"@ | Out-File -Encoding utf8 requirements.txt
```

Verify that dependency resolution is consistent:
```powershell
& ".\.venv\Scripts\python.exe" -m pip check
```

**4. Open in VS Code**
Install recommended extensions and open the workspace:
```powershell
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension charliermarsh.ruff
code --install-extension ms-toolsai.jupyter
code .
```

---

### Scenario B: Cloning an Existing Repository (With `requirements.txt`)

When joining an existing project or checking out code on a new machine:

**1. Clone the repository and navigate to its root**
```powershell
git clone <repository-url>
cd <repository-folder>
```

**2. Create a fresh project-local `.venv`**
```powershell
py -3 -m venv .venv
```

**3. Restore all project dependencies from `requirements.txt`**
```powershell
& ".\.venv\Scripts\python.exe" -m pip install -r requirements.txt
& ".\.venv\Scripts\python.exe" -m pip check
```

**4. Launch VS Code**
```powershell
code .
```

In VS Code, press `Ctrl+Shift+P`, run `Python: Select Interpreter`, and select `./.venv/Scripts/python.exe`.

---

## Recommended Project Structure

Keep a single virtual environment at the Git repository root so all modules, packages, and scripts share dependencies cleanly:

```text
my-python-project/
├── .git/
├── .venv/                      # Local virtual environment (never commit)
├── .vscode/
│   ├── settings.json           # Workspace settings (Ruff, Pylance, interpreter)
│   └── extensions.json         # Recommended extensions
├── .env                        # Local secrets & variables (never commit)
├── .env.example                # Safe template for collaborators
├── .gitignore                  # Git exclusion rules
├── requirements.txt            # Declared direct dependencies
├── README.md                   # Project documentation
├── src/                        # Application source code
└── tests/                      # Automated test suite
```

---

## VS Code Configuration: Ruff, Pylance & Jupyter

Create `.vscode/settings.json` at your project root to enable automatic formatting, linting, import sorting, and interactive execution:

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

Add `.vscode/extensions.json` to prompt collaborators to install recommended extensions:
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

### Formatting and Linting with Ruff
- **Editor real-time feedback**: Handled automatically by the `charliermarsh.ruff` extension.
- **Command-line / CI execution**: Install `ruff` inside your `.venv`:
  ```powershell
  & ".\.venv\Scripts\python.exe" -m pip install ruff
  & ".\.venv\Scripts\python.exe" -m ruff format .
  & ".\.venv\Scripts\python.exe" -m ruff check .
  ```

---

## Python Interpreter Troubleshooting & Incident Post-Mortem

### Common Symptoms & Fixes

| Symptom | Root Cause | Recommended Action |
| :--- | :--- | :--- |
| **"An Invalid Python interpreter is selected"** | Conflict between `.vscode/settings.json` and `.code-workspace` or stale interpreter cache in `state.vscdb`. | Clear workspace setting and reselect interpreter (detailed below). |
| **PowerShell script execution disabled** | Windows ExecutionPolicy restriction on `.ps1` scripts. | Do not change machine policy; invoke `.\.venv\Scripts\python.exe` directly. |
| **`ModuleNotFoundError` inside VS Code** | VS Code is pointing to the global Python interpreter rather than `.venv`. | Run `Python: Select Interpreter` (`Ctrl+Shift+P`) and choose `./.venv/Scripts/python.exe`. |
| **`code` command not recognized** | VS Code installation folder is not in Windows `PATH`. | Reinstall using VS Code User Installer with "Add to PATH" checked. |
| **`.env` or `.venv` appearing in `git status`** | Files were staged or committed before adding rules to `.gitignore`. | Run `git rm --cached` (see Git section below). |

### Real Incident Post-Mortem: Invalid Interpreter Warning

During real-world development, a persistent warning can occur in VS Code:
> *"An Invalid Python interpreter is selected. Please try changing it to enable features such as IntelliSense, linting, and debugging."*

Even when this error is displayed:
- The virtual environment binary `.\.venv\Scripts\python.exe` is healthy and functional.
- Running scripts or CLI commands directly via terminal works without error.
- All packages are intact according to `pip check`.

#### Why This Occurs
1. **Duplicated Interpreter Settings**: Defining `python.defaultInterpreterPath` in both `.vscode/settings.json` and in the `"settings"` block of a `.code-workspace` file creates an ambiguous scope. Furthermore, `${workspaceFolder}` inside a workspace file's root settings may not resolve dynamically, remaining a literal string `${workspaceFolder}/.venv/Scripts/python.exe`.
2. **Stale Interpreter State Persistence**: VS Code stores previous interpreter selections inside internal SQLite caches (`state.vscdb`). If a system Python installation (e.g., Python 3.14.4) was cached during workspace initialization, VS Code continues to test it against the workspace rather than discovering the project's local `.venv` (e.g., Python 3.14.7).
3. **Valid `.venv` != Automatic VS Code Selection**: A functional `.venv` on disk does not guarantee that VS Code has bound its language server to that path.

#### Supported Recovery Procedure
1. **Remove Duplications**: Keep `python.defaultInterpreterPath` exclusively inside `.vscode/settings.json`. Avoid putting it in `.code-workspace`.
2. **Clear Workspace Setting**: In VS Code, press `Ctrl+Shift+P` and execute:
   ```
   Python: Clear Workspace Interpreter Setting
   ```
3. **Select Project Interpreter**: Press `Ctrl+Shift+P`, execute `Python: Select Interpreter`, and choose:
   `Python 3.x ('.venv': venv) .\.venv\Scripts\python.exe`
4. **Reload Window**: Press `Ctrl+Shift+P` and execute `Developer: Reload Window`.
5. **Inspect Output Channels**: Open Output (`Ctrl+Shift+U`) and verify the **Python**, **Python Environments**, and **Pylance** channels report successful initialization pointing to `.\.venv\Scripts\python.exe`.

For the complete technical breakdown, see [**03 — Configuration VS Code Optimale pour Python sous Windows (Section 8)**](03_VSCODE_SETUP_PYTHON.md#8-dépannage-approfondi--résoudre-lerreur-an-invalid-python-interpreter-is-selected).

---

## Dependency Management: `requirements.txt`

Maintain a lean, reproducible dependency file by specifying only **direct dependencies**:

```text
# Direct application dependencies
requests>=2.31.0
python-dotenv>=1.0.0

# Development tools
ipykernel>=6.29.0
ruff>=0.8.0
```

### Adding New Packages Cleanly
1. Install into `.venv`:
   ```powershell
   & ".\.venv\Scripts\python.exe" -m pip install httpx
   ```
2. Manually append the tested minimum version to `requirements.txt`:
   ```text
   httpx>=0.27.0
   ```
3. Verify dependency consistency:
   ```powershell
   & ".\.venv\Scripts\python.exe" -m pip check
   ```

Avoid uncurated `pip freeze > requirements.txt` dumps during development, as they lock hundreds of transient sub-dependencies and complicate version upgrades. See [**04 — Pip & Dependency Management**](04_REQUIREMENTS_DEPENDANCES_PIP.md) for complete details.

---

## Git Hygiene & `.gitignore`

Always initialize `.gitignore` before your initial commit to prevent local virtual environments and credentials from entering version control.

### Minimal Recommended `.gitignore`
```gitignore
# Virtual environments
.venv/
env/
venv/

# Python bytecode & caches
__pycache__/
*.py[cod]
.ruff_cache/
.pytest_cache/
.mypy_cache/

# Jupyter
.ipynb_checkpoints/

# Secrets & configuration
.env
.env.*
!.env.example

# OS artifacts
Thumbs.db
Desktop.ini
.DS_Store
```

### Removing Already-Tracked Files from Git
If `.env` or `.venv` was committed or staged before configuring `.gitignore`, adding the ignore rule alone will not stop Git from tracking changes. Remove them from Git's index while **keeping local disk files intact**:

```powershell
# Untrack a single file (keeps local file on disk)
git rm --cached -- .env

# Untrack a directory recursively
git rm -r --cached -- .venv/

# Stage the updated .gitignore and commit
git add .gitignore
git commit -m "Untrack local configuration and virtual environment"
```

> **Security Warning**: If sensitive credentials or API keys were previously committed and pushed to a remote repository, removing them from the index does not clean Git history. Revoke and rotate the credentials immediately. See [**05 — Git Tracking & .gitignore**](05_GITIGNORE_ET_SUIVI_GIT.md).

---

## Reusable Windows CLI Shortcuts

Typing the full interpreter path repeatedly can be tedious. You can create a lightweight command-line shortcut (e.g. `pyproj`) that works from any repository subfolder.

```powershell
pyproj python app.py
pyproj pip install requests
pyproj python -m pip check
```

The dual-file architecture in [`templates/`](templates/):
- **Batch wrapper (`launcher.cmd`)**: Uses `git rev-parse --show-toplevel` to resolve the repository root and locates `.venv\Scripts\python.exe`.
- **Python runner (`launcher_runner.py`)**: Uses `subprocess.run` to forward arguments, quotes, and exit codes reliably.

See the [**CLI Launcher Guide**](02_CREER_UN_RACCOURCI_COMMANDE_CLI.md) for full installation and setup instructions.

---

## Official Documentation References

- [Python Virtual Environments (`venv`)](https://docs.python.org/3/library/venv.html)
- [Python Packaging User Guide (PyPA)](https://packaging.python.org/)
- [Visual Studio Code Python Environments](https://code.visualstudio.com/docs/python/environments)
- [Pylance Language Server Documentation](https://github.com/microsoft/pylance-release)
- [Ruff Official Documentation](https://docs.astral.sh/ruff/)
- [Git SCM Documentation (`gitignore`)](https://git-scm.com/docs/gitignore)

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## Contributing

Contributions, issues, and suggestions are welcome! If you encounter edge cases on specific Windows configurations or would like to propose improvements:

1. Open an issue describing the problem or suggestion.
2. Ensure any proposed code or configuration remains portable and free of personal paths or credentials.
3. Submit a pull request with a concise description of your changes.
