#!/usr/bin/env python3
"""Encode retained automated 1x interaction samples with their actual wall timing."""
import json
import math
import re
import subprocess
import sys
from pathlib import Path


def validated_captures(output, captures):
    """Only generated PNG basenames inside this evidence folder enter ffconcat."""
    if not isinstance(captures, list):
        raise ValueError('Capture records must be a list')
    previous = {}
    for capture in captures:
        if not isinstance(capture, dict):
            raise ValueError('Invalid capture record')
        day, name, wall = (capture.get(key) for key in ('day', 'file', 'wall_msec'))
        if type(day) is not int or not 1 <= day <= 7:
            raise ValueError('Invalid capture day')
        if not isinstance(name, str) or re.fullmatch('[0-9]{5,}\\.png', name) is None:
            raise ValueError('Invalid capture filename')
        frame = output / 'results' / 'pace' / name
        if frame.resolve(strict=True) != frame or not frame.is_file():
            raise ValueError('Capture must be a regular file without symlink redirection')
        if type(wall) not in (int, float) or not math.isfinite(wall) or wall < 0 or (wall <= previous.get(day, -1)):
            raise ValueError('Invalid capture timing')
        previous[day] = wall
    return captures


def encode(output):
    output = Path(output).resolve()
    for result in (output / 'results').glob('b8-*.json'):
        if result.resolve(strict=True) != result:
            raise ValueError('Capture metadata cannot be a symlink')
        with result.open('rb') as source:
            contents = source.read(16 * 1024 * 1024 + 1)
        if len(contents) > 16 * 1024 * 1024:
            raise ValueError('Capture metadata exceeds 16 MiB')
        data = json.loads(contents)
        captures = validated_captures(output, data.get('capture_times', []))
        for day in sorted({c['day'] for c in captures}):
            segment = [c for c in captures if c['day'] == day]
            lines = []
            for i, c in enumerate(segment):
                lines.append("file 'results/pace/" + c['file'] + "'")
                if i + 1 < len(segment):
                    lines.append('duration ' + str((segment[i + 1]['wall_msec'] - c['wall_msec']) / 1000))
            concat = output / ('day' + str(day) + '-wall-time.txt')
            concat.write_text('\n'.join(lines) + '\n')
            movie = output / ('automated-day' + str(day) + '-1x.mp4')
            if not movie.exists():
                subprocess.run([
                    'ffmpeg', '-v', 'error', '-f', 'concat', '-safe', '1',
                    '-i', str(concat), '-vf', 'fps=30', '-c:v', 'libx264',
                    '-threads', '2', '-crf', '22', '-pix_fmt', 'yuv420p', str(movie),
                ], check=True)
            movie.with_suffix('.json').write_text(json.dumps({
                'strategy': data['strategy'],
                'day': day,
                'automation': 'Scripted ordinary controls, no human owner play',
                'setup': data['setup'],
                'time_scale': 1,
                'timing': 'Measured wall timestamps; sampled every third rendered frame, encoded at 30 fps',
                'samples': len(segment),
                'sampled_wall_seconds': (segment[-1]['wall_msec'] - segment[0]['wall_msec']) / 1000,
                'audio': 'Dummy, unqualified',
            }, indent=2))
            print(movie, flush=True)

if __name__ == '__main__':
    encode(sys.argv[1])
