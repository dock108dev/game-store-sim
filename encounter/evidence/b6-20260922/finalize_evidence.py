"""Finalize B6 evidence after all selected processes and visual review finish."""
from pathlib import Path
import hashlib, json, subprocess, tarfile, re
ROOT=Path(__file__).resolve().parents[3]
OUT=Path(__file__).resolve().parent
TRACKER=ROOT.parent/'game_sim_next_steps.md'
RUN=ROOT/'encounter/evidence/validation-20260923T003918484574Z'
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
ctx=json.loads((RUN/'context.json').read_text())
exits={p.name:json.loads(p.read_text())['exit'] for p in RUN.glob('*-exit.json')}
assert len(exits)==10 and all(v==0 for v in exits.values()),exits
logs={p.name:p.read_text() for p in RUN.glob('*.log')}
assert all('SCRIPT ERROR:' not in x and not any(y.startswith('ERROR:') for y in x.splitlines()) for x in logs.values())
source_changes=[name for name,h in ctx['source'].items() if digest(ROOT/'encounter'/name)!=h]
assert all(Path(n).suffix=='.md' for n in source_changes),source_changes
incoming=json.loads((OUT/'incoming-manifest.json').read_text())
removed=[name for name in incoming if not Path(name).exists()];assert not removed
art=[name for name in incoming if '/encounter/art/' in name or '/encounter/source/' in name or '/samples/' in name]
assert all(digest(Path(name))==incoming[name] for name in art)
historical=[ROOT/'docs/03-production'/f'b{n}-delivery.md' for n in range(2,6)]
assert all(digest(p)==incoming[str(p)] for p in historical)
results={}
for name in ['week-state','week-regressions','price-request','week-scene-headless','week-scene-normal','week-scene-retina','breadth-scene-headless','breadth-scene-normal','breadth-scene-retina']:
 value=json.loads((RUN/'results'/f'{name}.json').read_text());checks=value['checks'] if isinstance(value,dict) else value
 assert all(c['pass'] for c in checks),name
 row={'checks':len(checks),'all_pass':True}
 if name.startswith('week-scene'):
  d=value['days'][-1];assert d['cash']==57040 and d['phase']=='week_complete';row.update(cash=d['cash'],sales=len(d['sales']),max_buyers=value['max_buyers'])
 if name.startswith('breadth-scene'):row.update(cash=value['final']['cash'],max_buyers=value['max_buyers'])
 results[name]=row
files=[p for p in ROOT.rglob('*') if p.is_file() and not any(x in p.relative_to(ROOT).parts for x in ['.git','.godot','evidence','__pycache__'])]+[TRACKER]
manifest={'head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),'branch':subprocess.check_output(['git','branch','--show-current'],cwd=ROOT,text=True).strip(),'ruleset':'b6-retail-1','schema':10,'files':{str(p):digest(p) for p in files}}
(OUT/'source-manifest.json').write_text(json.dumps(manifest,indent=2))
with tarfile.open(OUT/'source-snapshot.tar.gz','w:gz') as archive:
 for p in files:archive.add(p,arcname=str(p.relative_to(ROOT)) if p!=TRACKER else 'external/game_sim_next_steps.md')
(OUT/'final-status.txt').write_text(subprocess.check_output(['git','status','--short'],cwd=ROOT,text=True))
review=json.loads((OUT/'visible-work-review.json').read_text());assert review['normal_reviewed'] and review['retina_reviewed'] and review['motion_reviewed']
report={'incoming_files':len(incoming),'final_files':len(files),'removed_incoming_files':removed,'original_art_and_sample_files_unchanged':len(art),'historical_delivery_documents_unchanged':[str(p) for p in historical],'validation':str(RUN),'isolated_project':ctx['project'],'namespace':ctx['namespace'],'engine':ctx['engine'],'source_changes_after_execution':source_changes,'executable_source_match':True,'exits':exits,'results':results,'warnings':{n:[line for line in t.splitlines() if line.startswith('WARNING:')] for n,t in logs.items()},'audio':'Dummy; unqualified','owner_acceptance':'pending','stop':'B7 not started'}
(OUT/'preservation-check.json').write_text(json.dumps(report,indent=2))
# Check actual destinations after artifacts exist; old source/candidate links remain historical.
from urllib.parse import unquote
missing=[];count=0
for p in [ROOT/'README.md',ROOT/'encounter/README.md',ROOT/'docs/MASTER_PLAN.md',ROOT/'docs/02-technical/encounter-architecture.md',ROOT/'docs/02-technical/local-development.md',ROOT/'docs/04-validation/local-validation-plan.md',ROOT/'docs/03-production/b6-delivery.md',ROOT/'docs/03-production/first-week-implementation-packet.md',TRACKER]:
 for link in re.findall(r'\]\(([^)]+)\)',p.read_text()):
  if link.startswith(('https:','http:','#')):continue
  name=unquote(link.split('#')[0]);dest=Path(name) if name.startswith('/') else p.parent/name;count+=1
  if not dest.exists():missing.append({'file':str(p),'link':link})
assert not missing,missing
(OUT/'documentation-check.json').write_text(json.dumps({'local_destinations_checked':count,'missing':missing,'whitespace_check':subprocess.run(['git','diff','--check'],cwd=ROOT,capture_output=True,text=True).stdout},indent=2))
print(json.dumps(report,indent=2))
