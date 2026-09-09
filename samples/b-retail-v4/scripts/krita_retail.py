from krita import Krita,InfoObject
from PyQt5.QtGui import QImage,QPainter,QColor,QPen,QFont,QPolygonF
from PyQt5.QtCore import Qt,QByteArray,QPointF
from pathlib import Path
import json,hashlib,traceback
R=Path('/Users/michaelfuscoletti/Desktop/game-sim/samples/b-retail-v4')
OLD=R.parent/'b-motion'
K=Krita.instance(); cfg=InfoObject();cfg.setProperty('alpha',True);cfg.setProperty('forceSRGB',True)
records=[]
def recolor(img,tee=False,denim=False):
 raw=bytearray(img.bits().asstring(img.width()*img.height()*4))
 for i in range(0,len(raw),4):
  b,g,r,a=raw[i:i+4]
  if not a:continue
  # Cool cloth only; skin is warm, with red > green. Preserve all source alpha.
  if g>r*1.025 and b>r*1.015 and g>b*.92:
   lum=(r+g+b)/3; r,g,b=[int(min(255,lum*v)) for v in (.48,.70,1.06)]
  elif denim and abs(r-g)<15 and r-b<23 and max(r,g,b)<125:
   lum=(r+g+b)/3;r,g,b=[int(min(255,lum*v)) for v in (.72,1.02,1.43)]
  # Yellow undershirt; threshold excludes warm skin.
  elif tee and i//(img.width()*4)>260 and r>g*1.12 and g>b*1.55 and g>85 and b<100:
   lum=(r+g+b)/3;r,g,b=[int(min(248,lum*v)) for v in (1.55,1.55,1.49)]
  raw[i:i+3]=bytes([b,g,r])
 return QImage(bytes(raw),img.width(),img.height(),QImage.Format_ARGB32).copy()
def layer(doc,name,img,visible=True):
 n=doc.createNode(name,'paintlayer');doc.rootNode().addChildNode(n,None);n.setPixelData(QByteArray(img.bits().asstring(img.width()*img.height()*4)),0,0,img.width(),img.height());n.setVisible(visible);return n
def export(doc,layers,dest):
 dest.mkdir(parents=True,exist_ok=True)
 for n in layers:
  for o in layers:o.setVisible(o==n)
  doc.refreshProjection();doc.waitForDone();assert doc.exportImage(str(dest/(n.name()+'.png')),cfg)
 for n in layers:n.setVisible(True)
 doc.refreshProjection();doc.waitForDone()
def run():
 for view in ['front','side','back']:
  doc=K.openDocument(str(OLD/'source/masters'/('rowan-'+view+'.kra')));doc.waitForDone();doc.setBatchmode(True)
  layers=[n for n in doc.rootNode().childNodes() if n.name()!='identity reference - hidden']
  for n in layers:
   raw=n.pixelData(0,0,600,1024);img=QImage(bytes(raw),600,1024,QImage.Format_ARGB32).copy();img=recolor(img,n.name()=='torso','leg' in n.name())
   # Shoe upper becomes charcoal canvas; sole/laces retained. Restrict to shoe area.
   if 'leg' in n.name():
    data=bytearray(img.bits().asstring(600*1024*4))
    for y in range(887,980):
     for x in range(600):
      i=(y*600+x)*4;b,g,r,a=data[i:i+4]
      if a and r>g*1.2 and r>b*1.25:
       v=int((r+g+b)/3*.65);data[i:i+3]=bytes([v+8,v+3,v])
    img=QImage(bytes(data),600,1024,QImage.Format_ARGB32).copy()
   n.setPixelData(QByteArray(img.bits().asstring(600*1024*4)),0,0,600,1024)
  # Badge stays attached to the torso; no new joint edges or asymmetric side lettering.
  torso=next(n for n in layers if n.name()=='torso')
  if view=='front':
   img=QImage(bytes(torso.pixelData(0,0,600,1024)),600,1024,QImage.Format_ARGB32).copy();p=QPainter(img);p.setRenderHint(QPainter.Antialiasing)
   p.setPen(QPen(QColor('#263343'),3));p.setBrush(QColor('#f8f1d9'));p.drawRoundedRect(350,322,51,33,3,3);p.fillRect(354,326,43,8,QColor('#c94537'));p.setPen(QColor('#263343'));p.setFont(QFont('Arial',7,QFont.Bold));p.drawText(354,347,'ROWAN');p.end();torso.setPixelData(QByteArray(img.bits().asstring(600*1024*4)),0,0,600,1024)
  export(doc,layers,R/'art'/view);assert doc.exportImage(str(R/'art'/view/'assembled.png'),cfg)
  assert doc.saveAs(str(R/'source/masters'/('rowan-'+view+'.kra')));doc.close()
 # Retain F's historical authored trial geometry with the new cloth palette.
 doc=K.openDocument(str(OLD/'source/masters/rowan-authored-trial.kra'));doc.waitForDone();doc.setBatchmode(True)
 ls=[n for n in doc.rootNode().childNodes() if n.visible() or 'reference' not in n.name().lower()]
 for n in ls:
  w,h=doc.width(),doc.height();img=recolor(QImage(bytes(n.pixelData(0,0,w,h)),w,h,QImage.Format_ARGB32).copy());n.setPixelData(QByteArray(img.bits().asstring(w*h*4)),0,0,w,h)
 # Export by known original layer order/name, recorded below.
 for n in ls:
  for o in ls:o.setVisible(n==o)
  doc.refreshProjection();doc.waitForDone()
  name=n.name();digits=str(['contact-A','passing-A','contact-B','passing-B','idle','reach'].index(name))
  if digits and int(digits)<6:assert doc.exportImage(str(R/'art/authored'/(str(int(digits))+'.png')),cfg)
 for n in ls:n.setVisible(True)
 assert doc.saveAs(str(R/'source/masters/rowan-authored-trial.kra'));records.append({'authored_layers':[n.name() for n in ls]});doc.close()
 build_environment()
 (R/'evidence/krita-retail-build.json').write_text(json.dumps({'krita':K.version(),'records':records,'method':'native layered source revision; alpha-preserving cloth recolor; original QPainter retail illustration'},indent=2))
def newdoc(w,h,name):
 d=K.createDocument(w,h,name,'RGBA','U8','sRGB-elle-V2-srgbtrc.icc',72);d.setBatchmode(True)
 for n in d.rootNode().childNodes():n.remove()
 return d
def paint(w,h,fn):
 im=QImage(w*4,h*4,QImage.Format_ARGB32);im.fill(Qt.transparent);p=QPainter(im);p.setRenderHint(QPainter.Antialiasing);p.scale(4,4);fn(p);p.end();return im
def rect(p,x,y,w,h,c,stroke='#41464b',sw=.7):
 p.setPen(QPen(QColor(stroke),sw) if stroke else Qt.NoPen);p.setBrush(QColor(c));p.drawRect(__import__('PyQt5.QtCore',fromlist=['QRectF']).QRectF(x,y,w,h))
def poly(p,pts,c):
 p.setPen(QPen(QColor('#41464b'),.8));p.setBrush(QColor(c));p.drawPolygon(QPolygonF([QPointF(*v) for v in pts]))
def text(p,x,y,s,size,c='#fff6df'):
 p.setPen(QColor(c));p.setFont(QFont('Arial',size,QFont.Bold));p.drawText(QPointF(x,y),s)
def build_environment():
 d=newdoc(1280*4,720*4,'Replay Junction - floor and wall')
 def floor(p):
  poly(p,[(95,620),(1120,620),(1200,200),(195,200)],'#d7d6ce')
  for y in range(245,621,47):
   p.setPen(QPen(QColor('#bdbfb9'),.6));p.drawLine(QPointF(190-(y-200)*.23,y),QPointF(1200-(y-200)*.19,y))
  for x in range(230,1200,105):p.drawLine(QPointF(x,201),QPointF(x-83,620))
  poly(p,[(283,552),(942,552),(999,291),(340,291)],'#9c6668')
  # Quiet carpet fleck, deterministic and small enough not to compete with the actor.
  for i in range(2400):
   x=300+(i*47%662);y=300+(i*73%245)
   if x>340-(y-291)*.218 and x<999-(y-291)*.218:
    p.setPen(QPen(QColor('#aa7776'),.45));p.drawPoint(QPointF(x,y))
 layer(d,'01 tile and burgundy commercial carpet',paint(1280,720,floor))
 def wall(p):
  poly(p,[(195,200),(1200,200),(1200,285),(195,285)],'#f1ecdc')
  for y in range(210,283,9):p.setPen(QPen(QColor('#c5c2b8'),.7));p.drawLine(QPointF(196,y),QPointF(1199,y))
  rect(p,195,278,1005,7,'#74777a')
  rect(p,250,206,325,43,'#c7473c');text(p,262,235,'REPLAY JUNCTION',22)
  rect(p,600,207,159,52,'#fff9dc');text(p,610,228,'BUY • SELL • TRADE',11,'#373f47');text(p,610,247,'YOUR NEXT FAVORITE',9,'#b74236')
  rect(p,790,205,97,59,'#efca51');text(p,799,223,'USED GAMES',10,'#333d45');text(p,800,246,'from $9.99',13,'#333d45')
  rect(p,918,205,134,59,'#f9f8e9');text(p,926,225,'RESERVE TODAY',11,'#b74036');text(p,926,245,'CURB CIRCUIT 02',10,'#304760');text(p,926,258,'ASK AT THE COUNTER',6,'#304760')
 layer(d,'02 slatwall laminate and paper promotions',paint(1280,720,wall))
 d.refreshProjection();d.waitForDone();assert d.saveAs(str(R/'source/masters/retail-context.kra'));assert d.exportImage(str(R/'art/retail-context.png'),cfg);d.close()
 # exact old shelf silhouette: 250 x 115, sorting root stays bottom at (640,390).
 d=newdoc(1000,460,'Replay Junction - existing shelf')
 def fixture(p):
  poly(p,[(0,25),(225,25),(250,0),(25,0)],'#e3e3d8');poly(p,[(0,25),(225,25),(225,115),(0,115)],'#575e65');poly(p,[(225,25),(250,0),(250,90),(225,115)],'#babdbb')
  for y in range(32,110,7):p.setPen(QPen(QColor('#80888b'),.55));p.drawLine(QPointF(5,y),QPointF(220,y))
  for x in range(8,225,15):p.drawLine(QPointF(x,28),QPointF(x,111))
  for y in [57,89,111]:rect(p,2,y,222,4,'#b6c1c1');rect(p,3,y,220,1,'#edf2ec',None)
  rect(p,0,26,4,87,'#e7e6d8');rect(p,221,26,4,88,'#dedfd6');rect(p,3,110,217,5,'#393e42')
 layer(d,'01 powder-coated wire and laminate fixture',paint(250,115,fixture))
 def packaging(p):
  colors=['#315e90','#c34438','#ddb942','#448269','#84527b','#de8845']
  for row,y in enumerate([29,62,94]):
   for i in range(16):
    x=6+i*13.3;h=25 if row<2 else 15
    rect(p,x,y,12,h,'#222b36',None);rect(p,x+1,y+2,10,h-3,colors[(i+row*2)%6],None)
    # Original racing road, sports ball or mountain cover motifs, no licensed packaging.
    p.setPen(QPen(QColor('#f3eed5'),.6))
    if i%3==0:
     poly(p,[(x+2,y+h-3),(x+5,y+5),(x+10,y+h-3)],'#cdd3c9')
    elif i%3==1:
     p.setBrush(QColor('#e6e4cf'));p.drawEllipse(QPointF(x+6,y+9),3,3)
    else:poly(p,[(x+1,y+h-4),(x+5,y+7),(x+10,y+h-4)],'#344858')
    rect(p,x+1,y+1,10,2,'#dce3df',None)
    if (i+row)%3!=0:rect(p,x+6,y+4,5,3,'#f5d64e',None)
    if row<2:text(p,x+1,y+h-3,['CURB','KICK','TRAIL'][i%3],2)
 layer(d,'02 original case artwork and used stickers',paint(250,115,packaging))
 def signs(p):
  rect(p,4,15,217,11,'#bd3c34');text(p,9,23,'PRE-PLAYED  /  PICK YOUR NEXT GAME',6)
  for y,c,s in [(57,'#305b87','VECTOR 2'),(89,'#634782','CUBE / HANDHELD')]:rect(p,5,y,215,5,c,None);text(p,9,y+4,s,3)
  # Sticker on angled end: stays entirely inside existing silhouette.
  poly(p,[(228,45),(246,27),(246,59),(228,77)],'#efd354');text(p,230,53,'USED',3,'#333d45');text(p,231,59,'9.99',3,'#333d45')
 layer(d,'03 category strips and price signage',paint(250,115,signs))
 d.refreshProjection();d.waitForDone();assert d.saveAs(str(R/'source/masters/retail-shelf.kra'));assert d.exportImage(str(R/'art/retail-shelf.png'),cfg);d.close()
try:run()
except: (R/'evidence/krita-retail-error.txt').write_text(traceback.format_exc());raise
