import pathlib,importlib.util,shutil,subprocess,json
r=pathlib.Path(__file__).resolve().parents[2];spec=importlib.util.spec_from_file_location('v',r/'encounter/scripts/validate.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v)
o=r/'encounter/evidence/b7-20260923/motion';o.mkdir(exist_ok=True)
for variant in ['before','after']:
 w=v.isolate_project(r/'encounter')
 if variant=='before':
  for name in ['main.gd','state.gd','actor.gd']:shutil.copy2(r/'encounter/evidence/b7-20260923/incoming'/name,w/name)
 ctx=o/variant;ctx.mkdir(exist_ok=True)
 v.write_context(w,w,ctx)
 v.run_check(w,ctx,'import',['--headless','--editor','--import','--quit'])
 for layout in ['base','expanded']:
  v.run_check(w,ctx,layout,['--fixed-fps','30','--script','res://scripts/capture_b7_motion.gd','--']+(['--expanded'] if layout=='expanded' else []))
  frames=w/('evidence/motion-'+layout)
  subprocess.run(['ffmpeg','-v','error','-framerate','30','-i',str(frames/'%05d.jpg'),'-c:v','libx264','-crf','19','-pix_fmt','yuv420p',str(ctx/(layout+'.mp4'))],check=True)
  shutil.copy2(frames/'trace.json',ctx/(layout+'-trace.json'))
print(o)
