from krita import Krita, InfoObject
from PyQt5.QtGui import QImage,QPainter,QPolygonF,QColor,QPen
from PyQt5.QtCore import QPointF,Qt,QByteArray
from pathlib import Path
import json,traceback
R=Path('/Users/michaelfuscoletti/Desktop/game-sim/samples/b-retail-v4')
def run():
 src=Krita.instance().openDocument(str(R/'source/originals/rowan-master-v1.png'));src.waitForDone()
 w,h=src.width(),src.height();raw=bytearray(src.pixelData(0,0,w,h));alpha={raw[i+3] for i in range(0,len(raw),4)};removed=0
 for i in range(0,len(raw),4):
  b,g,r=raw[i:i+3]
  if min(r,g,b)>225 and max(r,g,b)-min(r,g,b)<12:raw[i+3]=0;removed+=1
 clean=QImage(bytes(raw),w,h,QImage.Format_ARGB32).copy()
 front={'far_leg':[(238,516),(348,516),(348,605),(315,900),(310,960),(186,967),(189,927),(232,871)],'near_leg':[(349,516),(455,516),(467,881),(510,934),(510,966),(384,965),(380,885),(348,601)],'far_arm':[(236,259),(254,278),(241,398),(224,442),(171,520),(164,567),(139,610),(113,610),(114,565),(184,376),(178,363)],'near_arm':[(457,254),(491,278),(524,367),(508,378),(544,465),(570,523),(586,605),(567,613),(538,578),(529,524),(476,431),(459,399)],'torso':[(306,215),(393,215),(458,250),(452,390),(464,550),(374,555),(320,543),(233,549),(245,389),(239,258)],'head':[(267,32),(425,32),(426,175),(393,216),(387,249),(316,249),(311,209),(274,179)]}
 back={k:[(x+832,y) for x,y in v] for k,v in front.items()}
 back['head']=[(1102,30),(1255,30),(1255,185),(1225,209),(1134,209),(1102,176)]
 back['torso']=[(1135,196),(1224,197),(1298,252),(1284,396),(1295,548),(1065,548),(1077,395),(1063,258)]
 back['far_arm']=[(1066,259),(1081,281),(1078,389),(1054,398),(1025,466),(989,531),(981,581),(955,610),(946,602),(954,554),(986,470),(1021,377),(1008,365)]
 back['near_arm']=[(1294,253),(1320,287),(1354,366),(1334,381),(1374,475),(1400,531),(1417,603),(1399,611),(1373,573),(1361,523),(1318,442),(1292,393)]
 back['far_leg']=[(1074,524),(1180,535),(1172,632),(1139,911),(1138,958),(1030,963),(1030,923),(1054,894)]
 back['near_leg']=[(1180,535),(1287,525),(1297,902),(1323,935),(1323,963),(1216,963),(1216,908),(1182,626)]
 side={'far_leg':[(705,524),(803,524),(806,740),(787,884),(861,913),(864,940),(778,949),(707,931)],'near_leg':[(708,527),(817,527),(810,752),(782,898),(844,931),(845,965),(739,965),(705,946),(705,898)],'far_arm':[(721,259),(766,259),(789,290),(790,372),(772,393),(793,507),(816,578),(807,622),(768,624),(747,578),(747,536),(715,429),(704,374),(697,305)],'near_arm':[(721,259),(766,259),(789,290),(790,372),(772,393),(793,507),(816,578),(807,622),(768,624),(747,578),(747,536),(715,429),(704,374),(697,305)],'torso':[(733,204),(789,219),(813,257),(842,357),(848,530),(691,543),(691,312),(707,249)],'head':[(695,31),(850,31),(850,118),(863,155),(854,195),(821,212),(801,234),(738,208),(738,184),(704,157)]}
 side['near_leg']=[(708,527),(817,527),(810,752),(782,898),(803,919),(840,944),(845,965),(739,965),(705,946),(705,898)]
 side['far_leg']=side['near_leg']
 configs={'front':(front,[349,960],{'far_leg':[288,550],'near_leg':[402,550],'far_arm':[232,283],'near_arm':[467,283],'torso':[349,533],'head':[349,219]},50),'side':(side,[778,960],{'far_leg':[763,548],'near_leg':[755,548],'far_arm':[744,286],'near_arm':[744,286],'torso':[771,532],'head':[770,213]},480),'back':(back,[1180,960],{'far_leg':[1126,551],'near_leg':[1234,551],'far_arm':[1074,285],'near_arm':[1295,285],'torso':[1180,533],'head':[1180,204]},880)}
 records={}
 for facing,(polys,foot,pivots,ox) in configs.items():
  doc=Krita.instance().createDocument(600,1024,'Rowan '+facing,'RGBA','U8','sRGB-elle-V2-srgbtrc.icc',72);doc.setBatchmode(True)
  for n in doc.rootNode().childNodes():n.remove()
  layers=[]
  for name in ['far_leg','near_leg','far_arm','torso','head','near_arm']:
   img=QImage(w,h,QImage.Format_ARGB32);img.fill(Qt.transparent);p=QPainter(img);p.setRenderHint(QPainter.Antialiasing)
   poly=QPolygonF([QPointF(x,y) for x,y in polys[name]])
   # Reconstructed shoulder/hip caps overlap behind the preserved visible ink.
   px,py=pivots[name]
   if 'arm' in name or 'leg' in name:
    p.setPen(Qt.NoPen);p.setBrush(QColor('#76918a' if 'arm' in name else '#44433f'));p.drawEllipse(QPointF(px,py),12 if 'arm' in name else 42,18 if 'arm' in name else 35)
   p.setClipRegion(__import__('PyQt5.QtGui',fromlist=['QRegion']).QRegion(poly.toPolygon()))
   if name=='torso':p.fillRect(0,0,w,h,QColor('#76918a'))
   p.drawImage(0,0,clean)
   if facing=='side' and name=='torso':
    p.fillRect(695,265,98,275,QColor('#76918a'));p.drawImage(800,235,clean.copy(800,235,49,300))
   if facing=='side' and 'leg' in name:
    p.fillRect(706,530,113,107,QColor('#44433f'))
   p.end();img=img.copy(ox,0,600,1024)
   node=doc.createNode(name,'paintlayer');doc.rootNode().addChildNode(node,None);node.setPixelData(QByteArray(img.bits().asstring(600*1024*4)),0,0,600,1024);layers.append(node)
  ref=doc.createNode('identity reference - hidden','paintlayer');doc.rootNode().addChildNode(ref,None);refimg=clean.copy(ox,0,600,1024);ref.setPixelData(QByteArray(refimg.bits().asstring(600*1024*4)),0,0,600,1024);ref.setVisible(False)
  doc.refreshProjection();doc.waitForDone();master=R/'source/masters'/('rowan-'+facing+'.kra');assert doc.saveAs(str(master))
  cfg=InfoObject();cfg.setProperty('alpha',True);cfg.setProperty('forceSRGB',True)
  dest=R/'art'/facing;dest.mkdir(exist_ok=True)
  for node in layers:
   for other in layers:other.setVisible(node==other)
   doc.refreshProjection();doc.waitForDone();assert doc.exportImage(str(dest/(node.name()+'.png')),cfg)
  for node in layers:node.setVisible(True)
  doc.refreshProjection();doc.waitForDone();assert doc.save();assert doc.exportImage(str(dest/'assembled.png'),cfg)
  check=Krita.instance().openDocument(str(master));check.waitForDone();assert len(check.rootNode().childNodes())==7;check.close()
  records[facing]={'foot':[foot[0]-ox,foot[1]],'pivots':{k:[v[0]-ox,v[1]] for k,v in pivots.items()},'dimensions':[600,1024]}
  doc.close()
 src.close();(R/'art/rig.json').write_text(json.dumps(records,indent=2));(R/'evidence/krita-build.json').write_text(json.dumps({'version':Krita.instance().version(),'input_alpha_values':sorted(alpha),'neutral_background_removed':removed,'masters_reopened':True,'rig':records},indent=2))
try:run()
except: (R/'evidence/krita-error.txt').write_text(traceback.format_exc());raise
