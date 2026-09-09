#!/bin/zsh
set -eu
sample_root="${0:A:h:h}"
runner_dir="$HOME/Library/Application Support/kritarunner/pykrita"
mkdir -p "$runner_dir"
cat > "$runner_dir/rowan_retail_runner.py" <<'PY'
def main(args):
    exec(compile(open(args[0]).read(),args[0],'exec'),{'__name__':'__main__'})
PY
/Applications/krita.app/Contents/MacOS/kritarunner -s rowan_retail_runner -f main "$sample_root/scripts/krita_retail.py"
/Applications/krita.app/Contents/MacOS/kritarunner -s rowan_retail_runner -f main "$sample_root/scripts/krita_verify_retail.py"
