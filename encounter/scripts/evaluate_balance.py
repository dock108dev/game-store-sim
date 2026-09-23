#!/usr/bin/env python3
"""Isolated B8 policy screening / ordinary-control scene evidence; never owner data."""
import argparse,datetime,json,shutil
from pathlib import Path
import validate
p=argparse.ArgumentParser();p.add_argument('--mode',choices=['headless','normal','retina'],default='headless');p.add_argument('--strategy',choices=['growth','lean','recovery','one_worker','bankruptcy'],default='growth');p.add_argument('--pace',action='store_true');p.add_argument('--screen',action='store_true');a=p.parse_args()
if a.pace and a.mode=='headless':p.error('--pace requires normal or retina rendering')
s=Path(__file__).resolve().parents[1]
o=s/'evidence'/('b8-run-'+datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S%fZ'));o.mkdir()
w=validate.isolate_project(s);validate.write_context(s,w,o)
(o/'parameters.json').write_text(json.dumps(vars(a),indent=2));print(o,flush=True)
try:
 validate.run_check(w,o,'import',['--headless','--editor','--import','--quit'])
 options=(['--headless'] if a.mode=='headless' else [])+([] if a.pace else ['--fixed-fps','30'])+['--script','res://scripts/test_balance_scene.gd','--','--strategy='+a.strategy]+(['--retina'] if a.mode=='retina' else [])+(['--pace'] if a.pace else [])
 validate.run_check(w,o,'screen' if a.screen else 'scene',['--headless','--script','res://scripts/test_balance_state.gd'] if a.screen else options)
finally:
 shutil.copytree(w/'evidence',o/'results',dirs_exist_ok=True)

# Retain raw frames and encode segments using measured wall times.
if a.pace:
 from capture_balance_pacing import encode
 encode(o)
