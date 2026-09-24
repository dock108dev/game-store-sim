#!/usr/bin/env python3
"""Independently reconcile retained balance-evaluation cents and summarize observed workload."""
from pathlib import Path
import collections,hashlib,json
root=Path(__file__).resolve().parents[1];base=root/'evidence/b8-20260923'
screen_source=root/'evidence/b8-run-20260923T015208111676Z/results/b8-screen.json'
screen=json.loads(screen_source.read_text())['strategies']
summary={'screen_source':str(screen_source.relative_to(root)),'screen':{},'scene_runs':[]}
for name,entry in screen.items():
 rows=[];prior_inventory=5000
 for day in entry['days']:
  r=day['report'];d=day['state'];n=day['day'];events=[e for e in d['events'] if e['day']==n]
  assert r['cash']==r['opening_cash']+r['receipts']-r['inventory_purchases']-r['paid_overhead']-r['investment']
  assert r['inventory_cost']==prior_inventory+r['inventory_purchases']-r['cost_of_sales'];prior_inventory=r['inventory_cost']
  rows.append({'day':n,**r,'wages':sum(c['amount'] for c in d['wage_commitments'] if c['day']==n),'rent':sum(e['amount'] for e in events if e['kind']=='rent'),'sales':day['retail']['sold'],'stock_misses':day['retail']['unavailable'],'price_refusals':day['retail']['missed']})
 f=entry['final'];assert f['cash']+f['inventory_cost']+f['investment']-f['unpaid_liabilities']==60000+f['operating_result']
 summary['screen'][name]={'days':rows,'final':f}
for p in sorted((root/'evidence').glob('b8-run-*/results/b8-*.json')):
 d=json.loads(p.read_text())
 if 'strategy' not in d or 'final' not in d:continue
 assert all(c['pass'] for c in d['checks']),p
 assert d['final']==screen[d['strategy']]['final'],p
 last=d['snapshots'][-1]
 if d['strategy'] in ['growth','one_worker']:
  assert last['layout']['space_level']==1
  assert {sale['product'] for sale in last['sales']}=={'curb','tide','orbit','signal','rally'}
  assert sum(last['items'][sale['item']]['kind']=='used' for sale in last['sales'])==5
  assert all(any(j['actor']!='player' and j['kind']==kind and j['status']=='committed' for j in last['jobs']) for kind in ['stock','sale'])
 if d['strategy']=='recovery':
  assert d['days'][0]['retail']['missed']==3 and d['days'][0]['report']['receipts']==0
  assert d['days'][1]['retail']['missed']==1 and d['final']['operating_result']>0
 if d['strategy']=='lean':
  assert len(last['sales'])==41 and all(j['actor']=='player' for j in last['jobs'])
 if d['strategy']=='bankruptcy':
  assert last['phase']=='bankrupt' and d['terminal']['shortfall']==8000
  assert d['final']['paid_overhead']==12000 and d['final']['unpaid_liabilities']==15000
  assert len([e for e in last['events'] if e['kind']=='rent' and e['status']=='due'])==1
 days=[]
 for day,snap in zip(d['days'],d['snapshots']):
  n=day['day'];expected=screen[d['strategy']]['days'][n-1]
  assert day['report']==expected['report'],(p,n)
  assert day['retail']==expected['retail'],(p,n)
  events=snap['events'];sales=snap['sales']
  cash=55000+sum((1 if e['kind']=='sale' else -1)*e['amount'] for e in events if e['status']=='paid')
  inventory=sum(i['cost'] for i in snap['items'].values() if i['location']!='sold')
  assert cash==snap['cash']==day['report']['cash']
  assert inventory==day['report']['inventory_cost']
  assert sum(s['cost'] for s in sales if s['day']==n)==day['report']['cost_of_sales']
  jobs=collections.Counter((j['actor']+':'+j['kind']) for j in snap['jobs'] if j['status']=='committed' and j['day']==n)
  actions=day['actions'];queues=list(day['queue_seconds'].values())
  days.append({'day':n,'jobs':dict(jobs),'button_activations':sum(a['type']=='button' for a in actions),'field_changes':sum(a.get('count',0) for a in actions),'keys':sum(a['type']=='key' for a in actions),'floor_clicks':sum(a['type']=='floor' for a in actions),'queue_max':day['queue_max'],'queue_seconds_mean':sum(queues)/len(queues) if queues else 0,'queue_seconds_max':max(queues,default=0),'wall_seconds':day['wall_seconds'],'last_open_clock':max((t['clock'] for t in d['telemetry'] if t['day']==n),default=0)})
 summary['scene_runs'].append({'path':str(p.relative_to(root)),'strategy':d['strategy'],'mode':d['mode'],'checks':len(d['checks']),'pace':d.get('pace_days_1_6',d.get('pace_day1',False)),'days':days})
(base/'arithmetic-workload.json').write_text(json.dumps(summary,indent=2))
print('Reconciled',len(summary['screen']),'screens and',len(summary['scene_runs']),'scene runs')
for r in summary['scene_runs']:
 print(r['strategy'],r['mode'],'buttons',sum(x['button_activations'] for x in r['days']),'fields',sum(x['field_changes'] for x in r['days']),'queue max',max(x['queue_max'] for x in r['days']))
