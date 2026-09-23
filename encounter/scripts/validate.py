#!/usr/bin/env python3
"""Import and exercise an isolated B7 project, retaining evidence for each run."""

import argparse
import datetime
import hashlib
import json
import re
from pathlib import Path
import shutil
import subprocess
import tempfile


ENGINE = '/Applications/Godot.app/Contents/MacOS/Godot'
REVIEW_NAMESPACE = 'game-sim-first-week-dev-v10'
EXCLUDED = ('.godot', 'evidence', '__pycache__')


def isolate_project(source):
    """Copy sources and replace the save namespace before any engine invocation."""
    work = Path(tempfile.mkdtemp(prefix='game-sim-b6-')) / 'encounter'
    shutil.copytree(source, work, ignore=shutil.ignore_patterns(*EXCLUDED))
    (work / 'evidence').mkdir()
    project = work / 'project.godot'
    settings = project.read_text()
    namespace_setting = f'config/custom_user_dir_name="{REVIEW_NAMESPACE}"'
    names = re.findall(r'^config/custom_user_dir_name=(.*)$', settings, re.MULTILINE)
    enabled = re.findall(r'^config/use_custom_user_dir=(.*)$', settings, re.MULTILINE)
    if names != [f'"{REVIEW_NAMESPACE}"'] or enabled != ['true']:
        raise RuntimeError(f'Cannot isolate the project save namespace: {project}')
    project.write_text(settings.replace(
        namespace_setting, f'config/custom_user_dir_name="{work.parent.name}"'
    ))
    return work


def write_context(source, work, output):
    hashes = {
        str(path.relative_to(source)): hashlib.sha256(path.read_bytes()).hexdigest()
        for path in source.rglob('*')
        if path.is_file() and not any(part in EXCLUDED for part in path.relative_to(source).parts)
    }
    context = {
        'project': str(work),
        'namespace': work.parent.name,
        'engine': subprocess.check_output([ENGINE, '--version'], text=True).strip(),
        'source': hashes,
    }
    (output / 'context.json').write_text(json.dumps(context, indent=2))
    return context


def run_check(work, output, name, options):
    log_path = output / f'{name}.log'
    with log_path.open('w') as log:
        try:
            result = subprocess.run(
                [ENGINE, '--path', str(work), '--audio-driver', 'Dummy', *options],
                stdout=log, stderr=subprocess.STDOUT, timeout=900,
            )
        except (subprocess.TimeoutExpired, OSError, KeyboardInterrupt) as error:
            # subprocess.run kills/reaps its child before propagating interruption.
            # Do not serialize exception text: it may include commands or output.
            status = ('timeout' if isinstance(error, subprocess.TimeoutExpired) else
                      'interrupted' if isinstance(error, KeyboardInterrupt) else 'launch_failed')
            (output / f'{name}-exit.json').write_text(json.dumps({
                'exit': None, 'status': status,
            }))
            raise
    (output / f'{name}-exit.json').write_text(json.dumps({'exit': result.returncode}))
    log_text = log_path.read_text()
    # Godot can report script/engine errors despite returning a zero exit status.
    has_error = 'SCRIPT ERROR:' in log_text or any(
        line.startswith('ERROR:') for line in log_text.splitlines()
    )
    if result.returncode or has_error:
        raise RuntimeError(f'{name} failed: {output}')


def run_basic_checks(work, output, render=False):
    """Shared source checks; excludes full-week scenes, native exits and packaging."""
    run_check(work, output, 'import', ['--headless', '--editor', '--import', '--quit'])
    for name, script in [('week-state', 'test_week.gd'), ('week-regressions', 'test_week_regressions.gd')]:
        run_check(work, output, name, ['--headless', '--script', 'res://scripts/' + script])
    run_check(work, output, 'ssot', ['--headless', '--script', 'res://scripts/test_ssot.gd'])
    run_check(work, output, 'security', ['--headless', '--script', 'res://scripts/test_security.gd'])
    run_check(work, output, 'storage', ['--headless', '--script', 'res://scripts/test_storage.gd'])
    run_check(work, output, 'price-request', ['--headless', '--fixed-fps', '30', '--script', 'res://scripts/test_price_request.gd'])
    for mode in ['headless'] + (['normal', 'retina'] if render else []):
        run_check(work, output, 'presentation-' + mode, (['--headless'] if mode == 'headless' else []) + ['--fixed-fps', '30', '--script', 'res://scripts/test_presentation.gd'] + (['--', '--retina'] if mode == 'retina' else []))
    run_check(work, output, 'restart-flow', ['--headless', '--fixed-fps', '30', '--script', 'res://scripts/test_restart_flow.gd'])


def main():
    global ENGINE
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--render', action='store_true', help='Add normal and Retina scene checks')
    parser.add_argument('--capture', action='store_true', help='Record the B6 integrated week and base-shop breadth (implies render)')
    parser.add_argument('--ci', action='store_true', help='Only basic headless source checks')
    parser.add_argument('--engine', type=Path, default=Path(ENGINE), help='Explicit Godot executable')
    parser.add_argument('--output', type=Path, help='New evidence directory (must not exist)')
    args = parser.parse_args()
    if args.ci and (args.render or args.capture):
        parser.error('--ci cannot be combined with rendered/capture checks')
    ENGINE = str(args.engine.resolve())
    source = Path(__file__).resolve().parents[1]
    stamp = datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
    output = args.output.resolve() if args.output else source / 'evidence' / ('validation-' + stamp)
    output.mkdir(parents=True)
    work = isolate_project(source)
    context = write_context(source, work, output)
    if args.ci and context['engine'] != '4.6.2.stable.official.71f334935':
        raise RuntimeError('CI requires the qualified Godot 4.6.2 build')

    try:
        run_basic_checks(work, output, render=args.render or args.capture)
    finally:
        if args.ci:
            shutil.copytree(work / 'evidence', output / 'results',
                            ignore=shutil.ignore_patterns('frames'), dirs_exist_ok=True)
    if args.ci:
        print(output)
        return
    for resume in [False, True]:
        run_check(work, output, 'exit-resume' if resume else 'exit-save', ['--fixed-fps', '30', '--script', 'res://scripts/test_exit.gd'] + (['--', '--resume'] if resume else []))
    for name, script in [('week', 'test_week_scene.gd'), ('breadth', 'test_breadth_scene.gd')]:
        options = ['--fixed-fps', '30', '--script', 'res://scripts/' + script]
        run_check(work, output, name + '-headless', ['--headless', *options])
        if args.render or args.capture:
            run_check(work, output, name + '-normal', options)
            run_check(work, output, name + '-retina', [*options, '--', '--retina'])
            frames = work / 'evidence/frames' / ('b6' if name == 'week' else 'b6-breadth')
            subprocess.run(['ffmpeg', '-v', 'error', '-framerate', '6', '-i', str(frames / '%05d.png'),
                            '-c:v', 'libx264', '-crf', '20', '-pix_fmt', 'yuv420p',
                            str(output / (name + '-interaction.mp4'))], check=True)
    shutil.copytree(
        work / 'evidence', output / 'results',
        ignore=shutil.ignore_patterns('frames'), dirs_exist_ok=True,
    )
    print(output)


if __name__ == '__main__':
    main()
