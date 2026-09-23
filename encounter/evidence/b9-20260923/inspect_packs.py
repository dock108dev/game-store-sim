from pathlib import Path
import struct,hashlib,json
root=Path(__file__).resolve().parents[3]
def read(p):
 d=p.read_bytes();assert d[:4]==b'GDPC';assert struct.unpack_from('<I',d,4)[0]==3
 base,idx=struct.unpack_from('<QQ',d,24);count=struct.unpack_from('<I',d,idx)[0];idx+=4;out={}
 for _ in range(count):
  n=struct.unpack_from('<I',d,idx)[0];idx+=4;name=d[idx:idx+n].rstrip(b'\x00').decode();idx+=n
  off,size=struct.unpack_from('<QQ',d,idx);idx+=16;md5=d[idx:idx+16];idx+=16;flags=struct.unpack_from('<I',d,idx)[0];idx+=4
  payload=d[base+off:base+off+size];assert len(payload)==size and hashlib.md5(payload).digest()==md5,(name,off,size)
  out[name]={'sha256':hashlib.sha256(payload).hexdigest(),'size':size,'flags':flags}
  if name.endswith('main.scn'):
   pos=payload.index(b'node_ids\x00')+len(b'node_ids\x00');assert struct.unpack_from('<II',payload,pos)==(32,1);pos+=8
   out[name]['generated_node_id']=struct.unpack_from('<I',payload,pos)[0]
   out[name]['without_generated_node_id_sha256']=hashlib.sha256(payload[:pos]+b'\x00'*4+payload[pos+4:]).hexdigest()
 return out
b=root/'artifacts/b9-personal-mac';final=read(next(b.glob('*.app/Contents/Resources/*.pck')))
(b/'pack-manifest.json').write_text(json.dumps(final,indent=2))
reports=[]
for run in (root/'encounter/evidence').glob('b9-package-*'):
 par=json.loads((run/'parameters.json').read_text())
 if par['artifact']!=str(b):continue
 packs=list(run.glob('*.app/Contents/Resources/*.pck'))
 if not packs:continue
 other=read(packs[0]);(run/'pack-manifest.json').write_text(json.dumps(other,indent=2))
 keys=[k for k in final if k.endswith('.gdc') or k.startswith(('art/','.godot/imported/','.godot/exported/'))]
 raw_diff=[k for k in keys if final[k]!=other.get(k)]
 diff=[k for k in raw_diff if not (k.endswith('main.scn') and final[k]['without_generated_node_id_sha256']==other.get(k,{}).get('without_generated_node_id_sha256'))]
 reports.append({'run':str(run.relative_to(root)),'compared_runtime_scene_art_resources':len(keys),'raw_differences':raw_diff,'explained_scene_difference':'Godot-generated node_ids integer only; all other scene bytes equal','unexplained_differences':diff})
assert all(not x['unexplained_differences'] for x in reports),reports
(root/'encounter/evidence/b9-20260923/pack-equivalence.json').write_text(json.dumps({'delivered_resources':len(final),'test_scripts_in_delivered_pack':[k for k in final if k.startswith('scripts/')],'runs':reports},indent=2))
print(json.dumps(reports,indent=2))
