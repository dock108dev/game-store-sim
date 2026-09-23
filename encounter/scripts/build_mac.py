#!/usr/bin/env python3
"""Export only the active encounter. Never launches or reads any save directory."""
import argparse,datetime,hashlib,json,subprocess,shutil,tempfile,tarfile
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--output',type=Path);a=p.parse_args()
s=Path(__file__).resolve().parents[1]; engine=Path('/Applications/Godot.app/Contents/MacOS/Godot')
stamp=datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ')
out=(a.output or s.parent/'artifacts'/('b9-'+stamp)).resolve();out.mkdir(parents=True,exist_ok=False)
work=Path(tempfile.mkdtemp(prefix='replay-junction-export-'))/'encounter'
shutil.copytree(s,work,ignore=shutil.ignore_patterns('.godot','evidence','__pycache__'))
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
files={str(p.relative_to(work)):sha(p) for p in sorted(work.rglob('*')) if p.is_file()}
(out/'source-manifest.json').write_text(json.dumps(files,indent=2))
with tarfile.open(out/'source.tar.gz','w:gz') as t:t.add(work,arcname='encounter')
version=subprocess.check_output([str(engine),'--version'],text=True).strip()
if version!='4.6.2.stable.official.71f334935':raise SystemExit('Expected Godot 4.6.2.stable.official.71f334935; requalify any toolchain change')
template=Path.home()/'Library/Application Support/Godot/export_templates/4.6.2.stable/macos.zip'
identity={'engine':version,'engine_sha256':sha(engine),'template':str(template),'template_sha256':sha(template),'source_manifest_sha256':sha(out/'source-manifest.json'),'source_archive_sha256':sha(out/'source.tar.gz'),'head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=s,text=True).strip(),'namespace':'game-sim-personal-beta-v10','save_schema':10,'ruleset':'b6-retail-1','build_project':str(work),'export':'release, universal, local ad-hoc, no notarization'}
for name,args in [('import',['--editor','--import','--quit']),('export',['--export-release','Personal Mac',str(out/'Replay Junction.zip')])]:
 with (out/(name+'.log')).open('w') as f:
  r=subprocess.run([str(engine),'--headless','--path',str(work),*args],stdout=f,stderr=subprocess.STDOUT)
 if r.returncode or 'ERROR:' in (out/(name+'.log')).read_text():raise SystemExit(name+' failed; inspect retained log')
subprocess.run(['ditto','-x','-k',str(out/'Replay Junction.zip'),str(out)],check=True)
identity['artifact_sha256']=sha(out/'Replay Junction.zip')
identity['bundle_files']={str(p.relative_to(out)):sha(p) for p in sorted(out.rglob('*')) if '.app/' in str(p) and p.is_file()}
(out/'identity.json').write_text(json.dumps(identity,indent=2));print(out)
