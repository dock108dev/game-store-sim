from krita import Krita,InfoObject
from pathlib import Path
import hashlib,json
R=Path('/Users/michaelfuscoletti/Desktop/game-sim/samples/b-retail-v4');O=R.parent/'b-motion';out=R/'evidence/roundtrip-exports';out.mkdir(exist_ok=True)
cfg=InfoObject();cfg.setProperty('alpha',True);cfg.setProperty('forceSRGB',True);records=[]
def verify(doc,name,path):
 doc.refreshProjection();doc.waitForDone();dest=out/name;assert doc.exportImage(str(dest),cfg)
 records.append({'export':str(path.relative_to(R)),'identical':hashlib.sha256(path.read_bytes()).digest()==hashlib.sha256(dest.read_bytes()).digest()})
for view in ['front','side','back']:
 doc=Krita.instance().openDocument(str(R/'source/masters'/('rowan-'+view+'.kra')));doc.waitForDone();doc.setBatchmode(True)
 layers=[n for n in doc.rootNode().childNodes() if n.name()!='identity reference - hidden']
 for n in layers:
  for a in layers:a.setVisible(a==n)
  verify(doc,view+'-'+n.name()+'.png',R/'art'/view/(n.name()+'.png'))
 doc.setModified(False);doc.close()
for stem in ['retail-context','retail-shelf']:
 doc=Krita.instance().openDocument(str(R/'source/masters'/(stem+'.kra')));doc.waitForDone();doc.setBatchmode(True);verify(doc,stem+'.png',R/'art'/(stem+'.png'));doc.close()
doc=Krita.instance().openDocument(str(R/'source/masters/rowan-authored-trial.kra'));doc.waitForDone();doc.setBatchmode(True);layers=doc.rootNode().childNodes()
for i,name in enumerate(['contact-A','passing-A','contact-B','passing-B','idle','reach']):
 for n in layers:n.setVisible(n.name()==name)
 verify(doc,'authored-'+str(i)+'.png',R/'art/authored'/(str(i)+'.png'))
doc.setModified(False);doc.close()
(R/'evidence/retail-roundtrip.json').write_text(json.dumps(records,indent=2));assert all(r['identical'] for r in records)
