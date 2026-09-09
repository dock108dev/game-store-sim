# Extends the existing native, editable Krita package system; no retained art overwritten.
from krita import Krita,InfoObject
from PyQt5.QtGui import QImage,QPainter,QColor,QPen,QFont,QPolygonF
from PyQt5.QtCore import Qt,QByteArray,QPointF
from pathlib import Path
import json,hashlib
R=Path(__file__).resolve().parents[1];K=Krita.instance();cfg=InfoObject();cfg.setProperty('alpha',True);cfg.setProperty('forceSRGB',True)
def rect(p,x,y,w,h,c):p.fillRect(x,y,w,h,QColor(c))
def text(p,x,y,s,size,c='#fff3d6'):
 p.setPen(QColor(c));p.setFont(QFont('Arial',size,QFont.Bold));p.drawText(QPointF(x,y),s)
def poly(p,pts,c):
 p.setPen(QPen(QColor('#333b46'),.8));p.setBrush(QColor(c));p.drawPolygon(QPolygonF([QPointF(*a) for a in pts]))
def base(p,c):
 rect(p,0,0,38,52,'#293442');rect(p,3,3,32,46,c);rect(p,3,3,32,6,'#e3e9de');text(p,5,8,'VECTOR 2',4,'#293442')
def tide(p):
 poly(p,[(4,38),(10,30),(16,38),(22,30),(28,38),(35,30),(35,46),(4,46)],'#89cbbb')
 poly(p,[(12,29),(26,29),(22,35),(16,35)],'#e8bc78');poly(p,[(19,16),(19,28),(29,28)],'#fff0c4');poly(p,[(17,19),(17,28),(10,28)],'#cd6b49')
 p.setPen(QPen(QColor('#f1d59b'),1));p.drawEllipse(QPointF(29,19),3,3)
def orbit(p):
 p.setPen(QPen(QColor('#ecd995'),1.2));p.drawEllipse(QPointF(19,32),13,8)
 p.setBrush(QColor('#e88949'));p.drawEllipse(QPointF(19,31),7,7)
 poly(p,[(18,24),(22,18),(28,20),(22,25)],'#99c48f')
 for x,y in [(7,22),(30,26),(9,43),(29,43)]:rect(p,x,y,2,2,'#fff2cd')
def title(p,a,b):text(p,5,16,a,5);text(p,5,22,b,5)
rows=[]
for name,color,art,a,b in [('case-tide','#297971',tide,'TIDEBOUND','ATLAS'),('case-orbit','#744764',orbit,'ORBIT','ORCHARD')]:
 d=K.createDocument(152,208,name,'RGBA','U8','',120);d.setBatchmode(True)
 for old in d.rootNode().childNodes():old.remove()
 for label,fn in [('01 case and platform band',lambda p:base(p,color)),('02 original cover illustration',art),('03 editable painted title',lambda p:title(p,a,b))]:
  im=QImage(152,208,QImage.Format_ARGB32);im.fill(Qt.transparent);p=QPainter(im);p.setRenderHint(QPainter.Antialiasing);p.scale(4,4);fn(p);p.end()
  n=d.createNode(label,'paintlayer');d.rootNode().addChildNode(n,None);n.setPixelData(QByteArray(im.bits().asstring(152*208*4)),0,0,152,208)
 d.refreshProjection();d.waitForDone();assert d.saveAs(str(R/'source'/(name+'.kra')));assert d.exportImage(str(R/'art'/(name+'.png')),cfg);d.close()
 d=K.openDocument(str(R/'source'/(name+'.kra')));d.waitForDone();d.setBatchmode(True);out=R/'evidence/r5'/(name+'-roundtrip.png');assert d.exportImage(str(out),cfg);d.close()
 original=hashlib.sha256((R/'art'/(name+'.png')).read_bytes()).hexdigest();assert original==hashlib.sha256(out.read_bytes()).hexdigest();rows.append({'asset':name,'sha256':original,'reopened_export_identical':True,'layers':3})
(R/'evidence/r5/art-roundtrip.json').write_text(json.dumps(rows,indent=2))
