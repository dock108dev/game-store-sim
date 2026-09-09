#!/bin/zsh
set -eu
r1_root="${0:A:h:h}"
runner_dir="$HOME/Library/Application Support/kritarunner/pykrita"
mkdir -p "$runner_dir"
cat > "$runner_dir/r1_encounter_runner.py" <<'PY'
def main(args):
    exec(compile(open(args[0]).read(),args[0],'exec'),{'__name__':'__main__','__file__':args[0]})
PY
/Applications/krita.app/Contents/MacOS/kritarunner -s r1_encounter_runner -f main "$r1_root/scripts/build_art.py"
