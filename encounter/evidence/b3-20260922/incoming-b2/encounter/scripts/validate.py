#!/usr/bin/env python3
"""Import and exercise an isolated B2 project, retaining evidence for each run."""

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
REVIEW_NAMESPACE = 'game-sim-first-week-dev-v6'
EXCLUDED = ('.godot', 'evidence', '__pycache__')


def isolate_project(source):
    """Copy sources and replace the save namespace before any engine invocation."""
    work = Path(tempfile.mkdtemp(prefix='game-sim-b2-')) / 'encounter'
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


def run_check(work, output, name, options):
    log_path = output / f'{name}.log'
    with log_path.open('w') as log:
        result = subprocess.run(
            [ENGINE, '--path', str(work), '--audio-driver', 'Dummy', *options],
            stdout=log, stderr=subprocess.STDOUT, timeout=900,
        )
    (output / f'{name}-exit.json').write_text(json.dumps({'exit': result.returncode}))
    log_text = log_path.read_text()
    # Godot can report script/engine errors despite returning a zero exit status.
    has_error = 'SCRIPT ERROR:' in log_text or any(
        line.startswith('ERROR:') for line in log_text.splitlines()
    )
    if result.returncode or has_error:
        raise RuntimeError(f'{name} failed: {output}')


def verify_capture(frames, output, mode):
    images = sorted(frames.glob('*.png'))
    assert len(images) > (3000 if mode == 'gameplay' else 1400)
    assert len({hashlib.sha256(path.read_bytes()).digest() for path in images}) > 500
    shutil.copy(images[-1], output / f'{mode}-final-frame.png')
    trace = json.loads((frames / 'trace.json').read_text())
    final = trace[-1]
    assert final['action'] == 'capture-final'
    if mode != 'gameplay':
        assert final['report']['sold'] == (3 if mode == 'stocked' else 2)
        assert final['report']['revenue'] == (5497 if mode == 'stocked' else 4198)
        assert final['report']['unavailable'] == (0 if mode == 'stocked' else 1)
        assert final['report']['missed'] == 0
        prep = next(row['data'] for row in trace if row['action'] == 'comparison-prep')
        assert sum(item['location'] == 'shelf' for item in prep['items'].values()) == 4
    (output / f'{mode}-verified.json').write_text(json.dumps(
        {'pass': True, 'report': final['report']}, indent=2
    ))


def capture_runs(work, output):
    project = work / 'project.godot'
    project.write_text(project.read_text().replace(
        'window_width_override=2560', 'window_width_override=1280'
    ).replace('window_height_override=1440', 'window_height_override=720'))
    frame_root = work / 'evidence/frames'
    for mode in ('gameplay', 'stocked', 'missing'):
        options = ['--fixed-fps', '30', '--resolution', '1280x720', '--', '--capture']
        if mode != 'gameplay':
            options.append('--assortment-demo=' + mode)
        existing = set(frame_root.iterdir()) if frame_root.exists() else set()
        run_check(work, output, 'capture-' + mode, options)
        frames = next(iter(set(frame_root.iterdir()) - existing))
        subprocess.run([
            'ffmpeg', '-v', 'error', '-framerate', '30', '-i', str(frames / '%05d.png'),
            '-c:v', 'libx264', '-crf', '18', '-pix_fmt', 'yuv420p',
            str(output / f'r5-{mode}.mp4'),
        ], check=True)
        shutil.copy(frames / 'trace.json', output / f'{mode}-trace.json')
        verify_capture(frames, output, mode)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--render', action='store_true', help='Add normal and Retina scene checks')
    parser.add_argument('--capture', action='store_true', help='Record gameplay and comparisons')
    args = parser.parse_args()
    source = Path(__file__).resolve().parents[1]
    stamp = datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
    output = source / 'evidence' / ('validation-' + stamp)
    output.mkdir(parents=True)
    work = isolate_project(source)
    write_context(source, work, output)

    run_check(work, output, 'import', ['--headless', '--editor', '--import', '--quit'])
    run_check(work, output, 'assortment-state', [
        '--headless', '--script', 'res://scripts/test_assortment.gd',
    ])
    run_check(work, output, 'layout-state', ['--headless', '--script', 'res://scripts/test_layout.gd'])
    run_check(work, output, 'price-request', [
        '--headless', '--fixed-fps', '30', '--script', 'res://scripts/test_price_request.gd',
    ])
    scene_options = ['--fixed-fps', '30', '--script', 'res://scripts/test_assortment_scene.gd']
    run_check(work, output, 'assortment-scene', ['--headless', *scene_options])
    layout_options = ['--fixed-fps', '30', '--script', 'res://scripts/test_layout_scene.gd']
    run_check(work, output, 'layout-scene', ['--headless', *layout_options])
    if args.render:
        run_check(work, output, 'assortment-normal', scene_options)
        run_check(work, output, 'assortment-retina', [*scene_options, '--', '--retina'])
        run_check(work, output, 'layout-normal', layout_options)
        run_check(work, output, 'layout-retina', [*layout_options, '--', '--retina'])
        subprocess.run(['ffmpeg', '-v', 'error', '-framerate', '6', '-i',
                        str(work / 'evidence/frames/b2/%05d.png'), '-c:v', 'libx264',
                        '-crf', '20', '-pix_fmt', 'yuv420p', str(output / 'b2-interaction.mp4')], check=True)
    if args.capture:
        capture_runs(work, output)
    shutil.copytree(
        work / 'evidence', output / 'results',
        ignore=shutil.ignore_patterns('frames'), dirs_exist_ok=True,
    )
    print(output)


if __name__ == '__main__':
    main()
