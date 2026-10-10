import subprocess
import sys

if len(sys.argv) < 2 or sys.argv[1].lower() not in ("python", "pip"):
    print("Usage: <launcher> python <args> | <launcher> pip <args>", file=sys.stderr)
    raise SystemExit(2)

command = [sys.executable]
if sys.argv[1].lower() == "pip":
    command += ["-m", "pip"]
command += sys.argv[2:]

raise SystemExit(subprocess.run(command, check=False).returncode)
