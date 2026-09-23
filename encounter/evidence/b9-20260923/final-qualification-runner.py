#!/usr/bin/env python3
"""Explicit instrumented Mac export of the frozen delivered source; no owner saves."""
import argparse,datetime,json,shutil,subprocess,tarfile,tempfile,hashlib
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('artifact',type=Path);p.add_argument('--script',default='test_balance_scene.gd');p.add_argument('--strategy',default='lean');p.add_argument('--normal-speed',action='store_true');p.add_argument('--retina',action='store_true');a=p.parse_args()
b=a.artifact.resolve();stamp=datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S%fZ');out=Path(__file__).resolve().parents[1]/'evidence'/('b9-package-'+stamp);out.mkdir();w=Path(tempfile.mkdtemp(prefix='b9-packaged-qa-'))
with tarfile.open(b/'source.tar.gz') as t:t.extractall(w,filter='data')
w=w/'encounter'
if not (w/'scripts'/a.script).exists():shutil.copy2(Path(__file__).resolve().parent/a.script,w/'scripts'/a.script)
ns='b9-packaged-qa-'+stamp
s=(w/'project.godot').read_text().replace('Replay Junction Personal Beta','B9 Instrumented').replace('game-sim-personal-beta-v10',ns).replace('run/main_scene="res://main.tscn"','run/main_scene="res://qa.tscn"')
s=s.replace('[application]', '[application]\nrun/flush_stdout_on_print=true')
(w/'project.godot').write_text(s)
preset=(w/'export_presets.cfg').read_text().replace('scripts/*,','').replace('local.replayjunction.personalbeta','local.replayjunction.b9instrumented');(w/'export_presets.cfg').write_text(preset)
for f in (w/'scripts').glob('*.gd'):
 s=f.read_text().replace('res://evidence',str(out/'results'))
 s=s.replace('extends SceneTree', 'extends Node\nvar root: Window:\n get:return get_tree().root\nvar process_frame: Signal:\n get:return get_tree().process_frame\nfunc quit(code=0):get_tree().quit(code)').replace('func _initialize():','func _ready():')
 if f.name=='test_balance_scene.gd':
  start=s.index('  # Ordinary visible correction:');end=s.index(' check("action route finishes",false)',start)
  s=s[:start]+s[end:]
  if a.normal_speed:s=s.replace('Engine.time_scale=1.0 if pace else 3.0','Engine.time_scale=1.0').replace('if pace:Engine.time_scale=1.0 if day in [1,6] else 3.0','Engine.time_scale=1.0')
 f.write_text(s)
(w/'qa.tscn').write_text('[gd_scene load_steps=2 format=3]\n[ext_resource type="Script" path="res://scripts/'+a.script+'" id="1"]\n[node name="ExplicitB9Instrumentation" type="Node"]\nscript=ExtResource("1")\n')
(out/'results').mkdir();(out/'parameters.json').write_text(json.dumps({'artifact':str(b),'artifact_sha256':hashlib.sha256((b/'Replay Junction.zip').read_bytes()).hexdigest(),'namespace':ns,'setup':'instrumented package; same frozen runtime/assets, test main-loop, isolated namespace; no automatic keyboard detours','script':a.script,'strategy':a.strategy,'normal_speed':a.normal_speed,'retina':a.retina,'work':str(w)},indent=2))
original=json.loads((b/'source-manifest.json').read_text())
changed=[k for k,v in original.items() if (w/k).exists() and hashlib.sha256((w/k).read_bytes()).hexdigest()!=v]
(out/'instrumentation-diff.json').write_text(json.dumps({'changed':changed,'runtime_and_art_equal':all(k in ['project.godot','export_presets.cfg'] or k.startswith('scripts/') for k in changed),'extra_scene':'qa.tscn','mode':'instrumented release export; fixed-fps30 and 3x scene simulation unless normal-speed/navigation'},indent=2))
engine='/Applications/Godot.app/Contents/MacOS/Godot'
print(out,flush=True)
for name,args in [('import',['--editor','--import','--quit']),('export',['--export-release','Personal Mac',str(out/'Instrumented.zip')])]:
 with (out/(name+'.log')).open('w') as f:r=subprocess.run([engine,'--headless','--path',str(w),*args],stdout=f,stderr=subprocess.STDOUT)
 if r.returncode:raise SystemExit(name+' failed')
subprocess.run(['ditto','-x','-k',str(out/'Instrumented.zip'),str(out)],check=True)
exe=next(out.glob('*.app/Contents/MacOS/*'))
with (out/'run.log').open('w') as f:
 r=subprocess.run([str(exe),'--verbose']+([] if a.normal_speed or a.script=='test_b9_navigation.gd' else ['--fixed-fps','30'])+['--','--strategy='+a.strategy]+(['--retina'] if a.retina else []),stdout=f,stderr=subprocess.STDOUT,timeout=1800)
(out/'exit.json').write_text(json.dumps({'exit':r.returncode}));print('EXIT',r.returncode,flush=True)

if r.returncode or "ERROR:" in (out/"run.log").read_text():raise SystemExit("Packaged check failed; inspect retained evidence")
