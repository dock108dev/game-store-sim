from pathlib import Path
import json,hashlib
r=Path(__file__).resolve().parents[3];e=Path(__file__).parent;b=r/'artifacts/b9-personal-mac';summary={'artifact':json.loads((b/'identity.json').read_text())['artifact_sha256'],'runs':[],'arithmetic':{}}
for run in sorted((r/'encounter/evidence').glob('b9-package-*')):
 p=json.loads((run/'parameters.json').read_text())
 if p['artifact']!=str(b):continue
 exit=json.loads((run/'exit.json').read_text())['exit'];log=(run/'run.log').read_text();warnings=[s for s in log.splitlines() if 'ERROR:' in s or 'WARNING:' in s]
 assert exit==0 and not warnings,(run,exit,warnings)
 summary['runs'].append({'directory':str(run.relative_to(r)),'script':p['script'],'strategy':p['strategy'],'retina':p['retina'],'exit':exit,'warnings':warnings,'instrumented_zip_sha256':hashlib.sha256((run/'Instrumented.zip').read_bytes()).hexdigest()})
 if p['script']!='test_balance_scene.gd':continue
 f=next((run/'results').glob('b8-*.json'));d=json.loads(f.read_text());assert all(c['pass'] for c in d['checks']);assert not any(a['type']=='aisle_detour' for a in d['actions']);days=[]
 for s,day in zip(d['snapshots'],d['days']):
  events=s['events'];sales=s['sales'];items=s['items'];rep=day['report'];today=int(s['day']);ev=[x for x in events if x['day']==today];sold=[x for x in sales if x['day']==today]
  receipts=sum(x['amount'] for x in ev if x['kind']=='sale');cost=sum(items[x['item']]['cost'] for x in sold);inventory=sum(x['cost'] for x in items.values() if x['location']!='sold');paid=sum(x['amount'] for x in ev if x['kind']!='sale' and x['status']=='paid');cash=rep['opening_cash']+receipts-paid
  assert all(x['cost']==items[x['item']]['cost'] for x in sales)
  assert cash==s['cash']==rep['cash']==day['retail']['cash']
  assert cost==rep['cost_of_sales']==day['retail']['cost'] and receipts==rep['receipts']==day['retail']['revenue'] and inventory==rep['inventory_cost']
  assert len({x['id'] for x in events})==len(events)
  days.append({'day':today,'cash':cash,'receipts':receipts,'sold_copy_cost':cost,'ending_inventory_cost':inventory,'report_matches_original_copies_and_events':True})
 summary['arithmetic'][p['strategy']]={'checks':len(d['checks']),'no_helper_detours':True,'final':d['final'],'days':days,'terminal':d['terminal']}
ordinary=['final-ordinary-new.log','final-ordinary-resume.log','final-ordinary-navigation.log','final-ordinary-invalid-retry.log','final-ordinary-terminal.log']
summary['ordinary_logs']={}
for name in ordinary:
 text=(e/name).read_text();warn=[s for s in text.splitlines() if 'WARNING:' in s or 'ERROR:' in s];assert not warn,(name,warn)
 summary['ordinary_logs'][name]={'CoreAudio_startup':'CoreAudio: output sampling rate: 48000 Hz' in text,'teardown':'XR: Clearing primary interface' in text,'warnings':warn}
(e/'final-verification-summary.json').write_text(json.dumps(summary,indent=2));print(json.dumps({k:v['final'] for k,v in summary['arithmetic'].items()},indent=2))
