"""Run project policy checks, engine import, headless contracts, and bootstrap smoke."""
import argparse
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parent.parent


def run(command, timeout=120, log_path=None, expected=None):
    if log_path:
        log_path.parent.mkdir(parents=True, exist_ok=True)
        log_path.write_text("", encoding="utf-8")
        command += ["--log-file", str(log_path)]
    process = subprocess.run(command, cwd=ROOT, capture_output=True, text=True,
                             encoding="utf-8", errors="replace", timeout=timeout)
    output = process.stdout + process.stderr
    if log_path and log_path.is_file():
        output += log_path.read_text(encoding="utf-8", errors="replace")
    if process.returncode or any(marker in output for marker in ["SCRIPT ERROR:", "Parse Error:", "ERROR:"]):
        print(output.strip(), flush=True)
        raise SystemExit(f"Verification failed: {command[0]}")
    if expected and not re.search(expected, output):
        print(output.strip(), flush=True)
        raise SystemExit(f"Expected completion marker missing: {expected}")
    if log_path:
        summary = re.search(r"Headless contracts: \d+ checks; \d+ failures", output)
        print(summary[0] if summary else f"Engine {log_path.stem}: passed", flush=True)
    else:
        print(output.strip(), flush=True)


def main():
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default=os.environ.get("GODOT_PATH"))
    args = parser.parse_args()
    godot = args.godot or shutil.which("godot") or shutil.which("godot4")
    if not godot or not Path(godot).is_file():
        raise SystemExit("Provide --godot <executable> or set GODOT_PATH")
    for tool in ["check_architecture.py", "check_reference.py"]:
        run([sys.executable, "-X", "utf8", str(ROOT / "tools" / tool)])
    logs = ROOT / "artifacts/verification"
    run([godot, "--headless", "--path", str(ROOT), "--editor", "--import"],
        timeout=180, log_path=logs / "import.log")
    run([godot, "--headless", "--path", str(ROOT), "--script", "res://tests/run_tests.gd",
         "--quit-after", "300"], log_path=logs / "contracts.log",
        expected=r"Headless contracts: \d+ checks; 0 failures\b")
    run([godot, "--headless", "--path", str(ROOT), "--quit-after", "3"],
        log_path=logs / "bootstrap.log")
    print("Verification passed: policies, reference integrity, import, contracts, bootstrap smoke")


if __name__ == "__main__":
    main()
