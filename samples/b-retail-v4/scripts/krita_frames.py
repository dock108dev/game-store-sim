from krita import Krita,InfoObject
from PyQt5.QtGui import QImage,QPainter
from PyQt5.QtCore import Qt,QByteArray
from pathlib import Path
import json
R=Path('/Users/michaelfuscoletti/Desktop/game-sim/samples/b-retail-v4')
src=Krita.instance().openDocument(str(R/'source/originals/rowan-authored-v1.png'));src.waitForDone();w,h=src.width(),src.height();raw=bytearray(src.pixelData(0,0,w,h));alpha=sorted(set(raw[3::4]))
for i in range(0,len(raw),4):
 b,g,r=raw[i:i+3]
 if min(r,g,b)>225 and max(r,g,b)-min(r,g,b)<12:raw[i+3]=0
img=QImage(bytes(raw),w,h,QImage.Format_ARGB32).copy()
doc=Krita.instance().createDocument(512,512,'Rowan authored frame trial','RGBA','U8','sRGB-elle-V2-srgbtrc.icc',72);doc.setBatchmode(True)
for n in doc.rootNode().childNodes():n.remove()
layers=[]
# Align crown at y32, sole at y480, body center x256; source centers differ between cells.
centers=[307,769,1210,311,762,1123];tops=[27,27,27,533,533,534];bottoms=[479,479,479,980,980,980]
for i in range(6):
 tile=QImage(512,512,QImage.Format_ARGB32);tile.fill(Qt.transparent);p=QPainter(tile)
 height=bottoms[i]-tops[i];cut=img.copy(centers[i]-230,tops[i],460,height+1).scaledToHeight(449,Qt.SmoothTransformation)
 p.drawImage(int(256-230*449/(height+1)),32,cut);p.end()
 node=doc.createNode(['contact-A','passing-A','contact-B','passing-B','idle','reach'][i],'paintlayer');doc.rootNode().addChildNode(node,None);node.setPixelData(QByteArray(tile.bits().asstring(512*512*4)),0,0,512,512);layers.append(node)
for n in layers:n.setVisible(n==layers[4])
doc.refreshProjection();doc.waitForDone();assert doc.saveAs(str(R/'source/masters/rowan-authored-trial.kra'))
cfg=InfoObject();cfg.setProperty('alpha',True);cfg.setProperty('forceSRGB',True);(R/'art/authored').mkdir(exist_ok=True)
for i,n in enumerate(layers):
 for o in layers:o.setVisible(o==n)
 doc.refreshProjection();doc.waitForDone();assert doc.exportImage(str(R/'art/authored'/('%d.png'%i)),cfg)
for n in layers:n.setVisible(n==layers[4])
doc.refreshProjection();doc.waitForDone();doc.save();doc.close();src.close()
check=Krita.instance().openDocument(str(R/'source/masters/rowan-authored-trial.kra'));check.waitForDone();assert len(check.rootNode().childNodes())==6;check.close()
(R/'evidence/authored-export.json').write_text(json.dumps({'input_alpha':alpha,'dimensions':[512,512],'crown':[256,32],'foot':[256,480],'layer_count':6,'reopened':True}))
