#!/usr/bin/env python3
"""Record every engine frame of the two-day R5 shift in an isolated project."""
from pathlib import Path
from validate import isolate_project
import datetime,hashlib,json,shutil,subprocess,tempfile,plistlib
r=Path(__file__).resolve().parents[1]
out=r/'evidence'/('r5-movie-'+datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S%fZ'));out.mkdir()
w=isolate_project(r)
p=w/'project.godot';p.write_text(p.read_text().replace('window_width_override=2560','window_width_override=1280').replace('window_height_override=1440','window_height_override=720'))
app=w.parent/'R5 Capture.app';shutil.copytree('/Applications/Godot.app',app)
plist=app/'Contents/Info.plist';meta=plistlib.loads(plist.read_bytes());meta['CFBundleIdentifier']='local.game-sim.r5-capture';meta['CFBundleName']='R5 Capture';plist.write_bytes(plistlib.dumps(meta));subprocess.run(['codesign','--force','--deep','--sign','-',str(app)],check=True,capture_output=True)
engine=str(app/'Contents/MacOS/Godot')
(out/'capture-app.json').write_text(json.dumps({'bundle':str(app),'id':'local.game-sim.r5-capture','purpose':'Separate capture identity; explicit drawing does not depend on window focus.'},indent=2))
(out/'context.json').write_text(json.dumps({'project':str(w),'namespace':w.parent.name,'capture_profile':'1280x720 window override, unchanged 1280x720 logical viewport; isolated save namespace','source':{str(p.relative_to(r)):hashlib.sha256(p.read_bytes()).hexdigest() for p in r.rglob('*') if p.is_file() and not any(x in p.relative_to(r).parts for x in ['.godot','evidence','__pycache__'])}},indent=2))
for name,args in [('import',['--headless','--editor','--import','--quit']),('movie',['--fixed-fps','30','--resolution','1280x720','--','--capture'])]:
 with (out/(name+'.log')).open('w') as f:result=subprocess.run([engine,'--path',str(w)]+args,stdout=f,stderr=subprocess.STDOUT,timeout=900)
 log=(out/(name+'.log')).read_text();assert result.returncode==0 and 'SCRIPT ERROR:' not in log and '\nERROR:' not in log
frame_dir=next((w/'evidence/frames').iterdir());frames=sorted(frame_dir.glob('*.png'));assert len(frames)>3000
unique_frames=len({hashlib.sha256(p.read_bytes()).digest() for p in frames});assert unique_frames>500
subprocess.run(['ffmpeg','-v','error','-framerate','30','-pattern_type','glob','-i',str(frame_dir/'*.png'),'-c:v','libx264','-crf','18','-pix_fmt','yuv420p',str(out/'r5-full-shift.mp4')],check=True)
trace=json.loads(next((w/'evidence/frames').glob('*/trace.json')).read_text());(out/'trace.json').write_text(json.dumps(trace,indent=2));assert trace[-1]['data']['day']==2 and trace[-1]['data']['phase']=='report'
info=json.loads(subprocess.check_output(['ffprobe','-v','error','-show_entries','format=duration:stream=width,height,r_frame_rate,nb_frames','-of','json',str(out/'r5-full-shift.mp4')],text=True));assert int(info['streams'][0]['nb_frames'])==len(frames)
(out/'verified.json').write_text(json.dumps({'pass':True,'engine_frame_count':len(frames),'unique_frame_count':unique_frames,'media':info,'report':trace[-1]['report']},indent=2))
shutil.copy(frames[-1],out/'final-frame.png')
print(out)
