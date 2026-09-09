from krita import Krita,InfoObject
from PyQt5.QtGui import QImage,QPainter,QColor,QPen,QFont,QPolygonF
from PyQt5.QtCore import Qt,QByteArray,QPointF
from pathlib import Path
import json,hashlib
R=Path(__file__).resolve().parents[1]; K=Krita.instance(); cfg=InfoObject();cfg.setProperty('alpha',True);cfg.setProperty('forceSRGB',True)
def paint(w,h,fn):
 im=QImage(w*4,h*4,QImage.Format_ARGB32);im.fill(Qt.transparent);p=QPainter(im);p.setRenderHint(QPainter.Antialiasing);p.scale(4,4);fn(p);p.end();return im
def poly(p,pts,c):
 p.setPen(QPen(QColor('#333b46'),1));p.setBrush(QColor(c));p.drawPolygon(QPolygonF([QPointF(*a) for a in pts]))
def rect(p,x,y,w,h,c):
 p.fillRect(x,y,w,h,QColor(c))
def text(p,x,y,s,size,c='#f9f1dd'):
 p.setPen(QColor(c));p.setFont(QFont('Arial',size,QFont.Bold));p.drawText(QPointF(x,y),s)
def make(name,w,h,layers):
 d=K.createDocument(w*4,h*4,name,'RGBA','U8','',120);d.setBatchmode(True)
 for old in d.rootNode().childNodes(): old.remove()
 for label,fn in layers:
  im=paint(w,h,fn);n=d.createNode(label,'paintlayer');d.rootNode().addChildNode(n,None);n.setPixelData(QByteArray(im.bits().asstring(im.width()*im.height()*4)),0,0,im.width(),im.height())
 d.refreshProjection();d.waitForDone();assert d.saveAs(str(R/'source'/(name+'.kra')));assert d.exportImage(str(R/'art'/(name+'.png')),cfg);d.close()
def counter(p):
 poly(p,[(0,35),(180,35),(205,10),(25,10)],'#d6d8d2');poly(p,[(0,35),(180,35),(180,108),(0,108)],'#dad2bd');poly(p,[(180,35),(205,10),(205,83),(180,108)],'#9ea29c')
 for y in range(40,100,8):rect(p,3,y,174,1,'#c3baa6')
 rect(p,0,98,180,10,'#343e4b');rect(p,16,52,144,30,'#bc4039');text(p,23,71,'REPLAY JUNCTION',12)
def register(p):
 poly(p,[(117,30),(159,30),(165,24),(124,24)],'#394651');poly(p,[(125,24),(155,24),(153,0),(127,0)],'#29333e');rect(p,130,4,19,12,'#8dbab5');rect(p,86,26,26,5,'#f6ebcf');text(p,89,30,'SALE',3,'#343c45')
def case(p):
 rect(p,0,0,38,52,'#293442');rect(p,3,3,32,46,'#315e90');rect(p,3,3,32,6,'#e3e9de');text(p,5,8,'VECTOR 2',4,'#293442');poly(p,[(6,44),(20,18),(32,44)],'#d0d4cc');poly(p,[(18,44),(21,25),(25,44)],'#3d474b');text(p,5,17,'CURB',7);text(p,5,24,'CIRCUIT',5);rect(p,22,29,12,7,'#efce51');text(p,24,34,'USED',3,'#303842')
def box(p):
 poly(p,[(0,20),(60,20),(78,0),(18,0)],'#d3b486');poly(p,[(0,20),(60,20),(60,60),(0,60)],'#b99060');poly(p,[(60,20),(78,0),(78,40),(60,60)],'#937247');rect(p,21,22,16,36,'#dfcba3');rect(p,5,32,45,16,'#f6edce');text(p,8,43,'2 × USED',7,'#343a43')
make('counter',205,110,[('laminate and red shop fascia',counter),('register and receipt pad',register)])
make('case',38,52,[('original Curb Circuit 02 used case',case)])
make('shipment',78,62,[('fixed consignment box',box)])
d=K.openDocument(str(R.parent/'samples/b-retail-v4/source/masters/retail-shelf.kra'));d.waitForDone();d.setBatchmode(True)
for n in d.rootNode().childNodes():
 if n.name().startswith('02'):n.setVisible(False)
d.refreshProjection();d.waitForDone();assert d.saveAs(str(R/'source/retail-shelf-empty.kra'));assert d.exportImage(str(R/'art/retail-shelf-empty.png'),cfg);d.close()
# Reopen saved masters; byte-identical PNG export is the production round-trip gate.
rows=[]
for name in ['counter','case','shipment','retail-shelf-empty']:
 d=K.openDocument(str(R/'source'/(name+'.kra')));d.waitForDone();d.setBatchmode(True);out=R/'evidence'/(name+'-roundtrip.png');assert d.exportImage(str(out),cfg);d.close()
 a=hashlib.sha256((R/'art'/(name+'.png')).read_bytes()).hexdigest();b=hashlib.sha256(out.read_bytes()).hexdigest();rows.append({'asset':name,'match':a==b,'sha256':a});assert a==b
(R/'evidence/art-roundtrip.json').write_text(json.dumps(rows,indent=2))
