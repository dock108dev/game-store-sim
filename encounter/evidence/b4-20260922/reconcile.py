from pathlib import Path
import hashlib,json,subprocess,tarfile,datetime,re
root=Path(__file__).resolve().parents[3]
out=Path(__file__).resolve().parent
run=root/'encounter/evidence/validation-20260922T211118646937Z'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
context=json.loads((run/'context.json').read_text())
mismatches=[k for k,h in context['source'].items() if sha(root/'encounter'/k)!=h]
assert not mismatches,mismatches
exits={p.name:json.loads(p.read_text())['exit'] for p in run.glob('*exit.json')}
assert len(exits)==18 and all(v==0 for v in exits.values()),exits
logs={p.name:[line for line in p.read_text().splitlines() if line.startswith(('ERROR:','SCRIPT ERROR:','WARNING:'))] for p in run.glob('*.log')}
assert all(not v for v in logs.values()),logs
incoming=json.loads((out/'incoming-manifest.json').read_text())
art={k:h for k,h in incoming['files'].items() if '/encounter/art/' in k}
art_diff=[k for k,h in art.items() if sha(Path(k))!=h]
assert not art_diff,art_diff
# Validate the immutable bytes stored at intake, not the intentionally extended working tree.
with tarfile.open(out/'incoming-b1-b3.tar.gz') as t:
 snapshots=[]
 for path,h in incoming['files'].items():
  p=Path(path);name=str(p.relative_to(root)) if p.is_relative_to(root) else 'root-tracker.md'
  if hashlib.sha256(t.extractfile(name).read()).hexdigest()!=h:snapshots.append(path)
assert not snapshots,snapshots
counts={}
for p in (run/'results').glob('*json'):
 if 'motion' in p.name:continue
 d=json.loads(p.read_text())
 rows=d.get('checks') if isinstance(d,dict) else d
 if isinstance(rows,list) and rows and all(isinstance(r,dict) and 'pass' in r for r in rows):
  assert all(r['pass'] for r in rows),p
  counts[p.name]=len(rows)
# Retain one staff-dialog frame from the actual normal input recording.
work=Path(context['project']);motion=json.loads((run/'results/employees-motion-normal.json').read_text())
row=next(r for r in motion if len(r['workers'])==2 and not r['jobs'])
frame=work/'evidence/frames/b4'/('%05d.png'%(row['frame']//5-1))
(run/'results/b4-employees-dialog-normal.png').write_bytes(frame.read_bytes())
files=[p for folder in ['encounter','docs'] for p in (root/folder).rglob('*') if p.is_file() and not any(x in p.relative_to(root).parts for x in ['evidence','.godot','__pycache__'])]
files.append(root.parent/'game_sim_next_steps.md')
manifest={'created_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip(),'branch':subprocess.check_output(['git','branch','--show-current'],cwd=root,text=True).strip(),'identity':'HEAD plus uncommitted B1-B4 source; validated runtime matches exactly; documentation finalized afterward','files':{str(p.relative_to(root)) if p.is_relative_to(root) else str(p):sha(p) for p in sorted(files)}}
(out/'source-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
with tarfile.open(out/'source-snapshot.tar.gz','w:gz') as t:
 for p in files:t.add(p,arcname=str(p.relative_to(root)) if p.is_relative_to(root) else 'external/game_sim_next_steps.md')
report={'head':manifest['head'],'validation_context':str(run.relative_to(root)/'context.json'),'source_files_compared':len(context['source']),'source_mismatches':mismatches,'incoming_snapshot_mismatches':snapshots,'incoming_artwork_files':len(art),'artwork_mismatches':art_diff,'engine_exits':exits,'log_errors_warnings':logs,'check_counts':counts,'source_manifest_sha256':sha(out/'source-manifest.json'),'source_snapshot_sha256':sha(out/'source-snapshot.tar.gz'),'incoming_snapshot_sha256':sha(out/'incoming-b1-b3.tar.gz'),'audio':'Dummy; unqualified','acceptance':'Technical verification only; owner acceptance pending'}
(out/'preservation-check.json').write_text(json.dumps(report,indent=2)+'\n')
(out/'final-status.txt').write_text(subprocess.check_output(['git','status','--short'],cwd=root,text=True))
print(json.dumps({'processes':len(exits),'counts':counts,'source_files':len(context['source']),'art_files':len(art)},indent=2))
