from krita import Krita,InfoObject
from pathlib import Path
import hashlib,json
R=Path('/Users/michaelfuscoletti/Desktop/game-sim/samples/b-retail-v4');results=[]
cfg=InfoObject();cfg.setProperty('alpha',True);cfg.setProperty('forceSRGB',True)
for view in ['front','side','back']:
 doc=Krita.instance().openDocument(str(R/'source/masters'/('rowan-'+view+'.kra')));doc.waitForDone();doc.setBatchmode(True)
 layers=[n for n in doc.rootNode().childNodes() if n.name()!='identity reference - hidden']
 for node in layers:
  path=R/'art'/view/(node.name()+'.png');before=hashlib.sha256(path.read_bytes()).hexdigest()
  for n in layers:n.setVisible(n==node)
  doc.refreshProjection();doc.waitForDone();assert doc.exportImage(str(path),cfg)
  results.append({'path':str(path.relative_to(R)),'identical':before==hashlib.sha256(path.read_bytes()).hexdigest()})
 doc.setModified(False);doc.close()
(R/'evidence/roundtrip.json').write_text(json.dumps(results,indent=2))
