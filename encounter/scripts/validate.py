#!/usr/bin/env python3
"""Preserve evidence, import and exercise an isolated R1 project."""
from pathlib import Path
import argparse,datetime,hashlib,json,shutil,subprocess,tempfile
p=argparse.ArgumentParser();p.add_argument('--render',action='store_true');p.add_argument('--capture',action='store_true');args=p.parse_args()
r=Path(__file__).resolve().parents[1]
stamp=datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
out=r/'evidence'/('validation-'+stamp);out.mkdir(parents=True)
work=Path(tempfile.mkdtemp(prefix='game-sim-r5-'))/'encounter'
shutil.copytree(r,work,ignore=shutil.ignore_patterns('.godot','evidence','__pycache__'))
(work/'evidence').mkdir()
f=work/'project.godot';f.write_text(f.read_text().replace('game-sim-r5-review-isolated',work.parent.name))
engine='/Applications/Godot.app/Contents/MacOS/Godot'
context={'project':str(work),'namespace':work.parent.name,'engine':subprocess.check_output([engine,'--version'],text=True).strip(),'source':{str(f.relative_to(r)):hashlib.sha256(f.read_bytes()).hexdigest() for f in r.rglob('*') if f.is_file() and not any(x in f.relative_to(r).parts for x in ['.godot','evidence','__pycache__'])}}
(out/'context.json').write_text(json.dumps(context,indent=2))
def run(name,options):
 with (out/(name+'.log')).open('w') as log:
  result=subprocess.run([engine,'--path',str(work)]+options,stdout=log,stderr=subprocess.STDOUT,timeout=900)
 (out/(name+'-exit.json')).write_text(json.dumps({'exit':result.returncode}))
 text=(out/(name+'.log')).read_text()
 if result.returncode or 'SCRIPT ERROR:' in text or '\nERROR:' in text:raise RuntimeError(f'{name} failed: {out}')
run('import',['--headless','--editor','--import','--quit'])
run('assortment-state',['--headless','--script','res://scripts/test_assortment.gd'])
run('price-request',['--headless','--fixed-fps','30','--script','res://scripts/test_price_request.gd'])
run('assortment-scene',['--headless','--fixed-fps','30','--script','res://scripts/test_assortment_scene.gd'])
if args.render:
 run('assortment-normal',['--fixed-fps','30','--script','res://scripts/test_assortment_scene.gd'])
 run('assortment-retina',['--fixed-fps','30','--script','res://scripts/test_assortment_scene.gd','--','--retina'])
if args.capture:
 f=work/'project.godot';f.write_text(f.read_text().replace('window_width_override=2560','window_width_override=1280').replace('window_height_override=1440','window_height_override=720'))
 for mode in ['gameplay','stocked','missing']:
  options=['--fixed-fps','30','--resolution','1280x720','--','--capture']
  if mode!='gameplay':options+=['--assortment-demo='+mode]
  existing=set((work/'evidence/frames').iterdir()) if (work/'evidence/frames').exists() else set()
  run('capture-'+mode,options)
  frames=next(iter(set((work/'evidence/frames').iterdir())-existing))
  subprocess.run(['ffmpeg','-v','error','-framerate','30','-i',str(frames/'%05d.png'),'-c:v','libx264','-crf','18','-pix_fmt','yuv420p',str(out/('r5-'+mode+'.mp4'))],check=True)
  shutil.copy(frames/'trace.json',out/(mode+'-trace.json'))
  images=sorted(frames.glob('*.png'))
  assert len(images)>(3000 if mode=='gameplay' else 1400)
  assert len({hashlib.sha256(p.read_bytes()).digest() for p in images})>500
  shutil.copy(images[-1],out/(mode+'-final-frame.png'))
  trace=json.loads((frames/'trace.json').read_text());final=trace[-1]
  assert final['action']=='capture-final'
  if mode!='gameplay':
   assert final['report']['sold']==(3 if mode=='stocked' else 2)
   assert final['report']['revenue']==(5497 if mode=='stocked' else 4198)
   assert final['report']['unavailable']==(0 if mode=='stocked' else 1)
   assert final['report']['missed']==0
   prep=next(row['data'] for row in trace if row['action']=='comparison-prep')
   assert sum(i['location']=='shelf' for i in prep['items'].values())==4
  (out/(mode+'-verified.json')).write_text(json.dumps({'pass':True,'report':final['report']},indent=2))
shutil.copytree(work/'evidence',out/'results',ignore=shutil.ignore_patterns('frames'),dirs_exist_ok=True)
print(out)
