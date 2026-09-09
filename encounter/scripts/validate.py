#!/usr/bin/env python3
"""Preserve evidence, import and exercise an isolated R1 project."""
from pathlib import Path
import argparse,datetime,hashlib,json,shutil,subprocess,tempfile
p=argparse.ArgumentParser();p.add_argument('--render',action='store_true');p.add_argument('--capture',action='store_true');args=p.parse_args()
r=Path(__file__).resolve().parents[1]
stamp=datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
out=r/'evidence'/('validation-'+stamp);out.mkdir(parents=True)
work=Path(tempfile.mkdtemp(prefix='game-sim-r4-'))/'encounter'
shutil.copytree(r,work,ignore=shutil.ignore_patterns('.godot','evidence','__pycache__'))
(work/'evidence').mkdir()
f=work/'project.godot';f.write_text(f.read_text().replace('game-sim-r4-review-isolated',work.parent.name))
engine='/Applications/Godot.app/Contents/MacOS/Godot'
context={'project':str(work),'namespace':work.parent.name,'engine':subprocess.check_output([engine,'--version'],text=True).strip(),'source':{str(f.relative_to(r)):hashlib.sha256(f.read_bytes()).hexdigest() for f in r.rglob('*') if f.is_file() and not any(x in f.relative_to(r).parts for x in ['.godot','evidence','__pycache__'])}}
(out/'context.json').write_text(json.dumps(context,indent=2))
def run(name,options):
 with (out/(name+'.log')).open('w') as log:
  result=subprocess.run([engine,'--path',str(work)]+options,stdout=log,stderr=subprocess.STDOUT,timeout=240)
 (out/(name+'-exit.json')).write_text(json.dumps({'exit':result.returncode}))
 text=(out/(name+'.log')).read_text()
 if result.returncode or 'SCRIPT ERROR:' in text or '\nERROR:' in text:raise RuntimeError(f'{name} failed: {out}')
run('import',['--headless','--editor','--import','--quit'])
run('wave-state',['--headless','--script','res://scripts/test_wave.gd'])
run('wave-scene',['--headless','--fixed-fps','30','--script','res://scripts/test_wave_scene.gd'])
if args.render:
 run('wave-normal',['--fixed-fps','30','--script','res://scripts/test_wave_scene.gd'])
 run('wave-retina',['--fixed-fps','30','--script','res://scripts/test_wave_scene.gd','--','--retina'])
if args.capture:
 run('capture',['--fixed-fps','30','--resolution','1280x720','--','--capture'])
 frames=next((work/'evidence/frames').iterdir())
 subprocess.run(['ffmpeg','-v','error','-framerate','30','-i',str(frames/'%05d.png'),'-c:v','libx264','-crf','18','-pix_fmt','yuv420p',str(out/'r4-gameplay.mp4')],check=True)
 shutil.copy(frames/'trace.json',out/'gameplay-trace.json')
shutil.copytree(work/'evidence',out/'results',ignore=shutil.ignore_patterns('frames'),dirs_exist_ok=True)
print(out)
