from pathlib import Path
from PIL import Image,ImageDraw
import json,hashlib,zipfile
R=Path(__file__).resolve().parents[1]
rows=[]
for p in sorted((R/'art').rglob('*.png')):
 im=Image.open(p).convert('RGBA');a=im.getchannel('A');hist=a.histogram()
 rows.append({'path':str(p.relative_to(R)),'dimensions':im.size,'alpha_extrema':a.getextrema(),'transparent_pixels':hist[0],'opaque_pixels':hist[255],'partial_alpha_pixels':sum(hist[1:255]),'alpha_bounds':a.getbbox(),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
(R/'evidence/alpha-report.json').write_text(json.dumps(rows,indent=2))
canvas=Image.new('RGB',(1260,900),'#e8e2d5');d=ImageDraw.Draw(canvas)
for col,view in enumerate(['front','side','back']):
 for row,bg in enumerate(['#182b36','#ffffff']):
  im=Image.open(R/'art'/view/'assembled.png').convert('RGBA');im.thumbnail((230,390))
  box=Image.new('RGBA',(280,410),bg);box.alpha_composite(im,((280-im.width)//2,10));canvas.paste(box.convert('RGB'),(col*310,row*440+20));d.text((col*310,row*440),view+' on '+bg,fill='black')
# Individual limb exports over light contrast background; useful to detect stray neighbors.
for i,part in enumerate(['near_arm','far_arm','near_leg','far_leg']):
 im=Image.open(R/'art/side'/(part+'.png')).convert('RGBA');im.thumbnail((140,200));canvas.paste(Image.new('RGB',(150,215),'#f0ccdb'),(960,i*220));canvas.paste(im,(960,i*220),im);d.text((1100,i*220+40),part,fill='black')
canvas.save(R/'evidence/alpha-contact-sheet.jpg')
masters=[]
for p in sorted((R/'source/masters').glob('*.kra')):
 with zipfile.ZipFile(p) as z:
  xml=z.read('maindoc.xml').decode();masters.append({'file':p.name,'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'layer_names':__import__('re').findall('name="([^"]+)"',xml)})
(R/'evidence/kra-inventory.json').write_text(json.dumps(masters,indent=2))
print('Inspected',len(rows),'PNGs and',len(masters),'Krita masters')
