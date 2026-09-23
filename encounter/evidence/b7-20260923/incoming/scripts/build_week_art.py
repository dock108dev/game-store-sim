"""B6 editable vector masters. Original Krita masters/exports are never modified.
Render the SVGs with Sharp (the bundled image runtime) to produce PNG exports.
"""
from pathlib import Path
import json, subprocess
R=Path(__file__).resolve().parents[1]
NODE='/Users/michaelfuscoletti/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node'
SHARP='/Users/michaelfuscoletti/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/sharp'
def export(name,body,w,h):
 svg=f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">{body}</svg>'
 src=R/'source'/(name+'.svg');src.write_text(svg)
 subprocess.run([NODE,'-e',f'const sharp=require({json.dumps(SHARP)});sharp(process.argv[1]).png().toFile(process.argv[2]);',str(src),str(R/'art'/(name+'.png'))],check=True)
def cover(name,color,title,art):
 base=f'<g id="case-platform"><rect width="152" height="208" fill="#293442"/><rect x="12" y="12" width="128" height="184" fill="{color}"/><rect x="12" y="12" width="128" height="24" fill="#e3e9de"/><text x="20" y="31" font-family="Arial" font-size="16" font-weight="bold" fill="#293442">VECTOR 2</text></g>'
 labels='<g id="editable-title" font-family="Arial" font-size="20" font-weight="bold" fill="#fff3d6">'+''.join(f'<text x="20" y="{64+i*24}">{line}</text>' for i,line in enumerate(title))+'</g>'
 export(name,base+'<g id="cover-illustration" stroke="#333b46" stroke-width="3" stroke-linejoin="round">'+art+'</g>'+labels,152,208)
cover('case-signal','#435879',['SIGNAL','HARBOR'], '<path d="M14 159 Q40 147 68 160 T138 157 V185 H14Z" fill="#8cc9bc"/><path d="M70 91 L99 174 H41Z" fill="#e3bc7c"/><path d="M57 151 H86 L80 132 H63Z" fill="#ce6d50"/><path d="M55 93 H85 V108 H55Z" fill="#fff1bb"/><path d="M70 78 L91 93 H49Z" fill="#ce6d50"/><path d="M87 98 L134 84 V116Z" fill="#f8d995" stroke="none"/><path d="M17 177 Q42 165 65 177 T137 177" fill="none" stroke="#e3f0cb"/>')
cover('case-rally','#ac6047',['POCKET','RALLY CLUB'], '<path d="M13 140 L45 112 L70 137 L102 102 L139 135 V185 H13Z" fill="#9cba9b"/><path d="M16 184 L79 130 L139 161 V185Z" fill="#5a6265"/><path d="M39 159 L51 135 H92 L110 158 V174 H34 V159Z" fill="#eac56d"/><path d="M58 140 H86 L97 156 H49Z" fill="#91c9cd"/><rect x="36" y="168" width="16" height="13" rx="3" fill="#293442"/><rect x="91" y="168" width="16" height="13" rx="3" fill="#293442"/><path d="M36 162 H48 M95 162 H106" stroke="#fff2d0" stroke-width="6"/><path d="M116 100 V132 M116 101 L135 106 L116 116" fill="#f6e6c0"/>')
# Accessories align to the original 600x1024 head canvases; garments tint separately.
for view in ['front','side','back']:
 for n in [3,4,5]:
  if n==3: # Devon: round spectacles; back view temple line.
   art='<g fill="none" stroke="#503e56" stroke-width="9"><circle cx="275" cy="136" r="22"/><circle cx="322" cy="136" r="22"/><path d="M297 135 H301 M252 130 L239 124 M344 130 L357 124"/></g>' if view=='front' else '<g fill="none" stroke="#503e56" stroke-width="8"><path d="M245 131 H333"/>'+('<ellipse cx="332" cy="136" rx="13" ry="22"/>' if view=='side' else '')+'</g>'
  elif n==4: # Ellis: cream knit cap with green ribbing.
   art='<g stroke="#3e6256" stroke-width="4"><path d="M235 104 Q225 41 299 38 Q367 43 364 105Z" fill="#e3d6a8"/><path d="M234 92 Q295 78 364 92 L366 111 Q295 98 232 111Z" fill="#83a38d"/><path d="M256 91 V108 M278 87 V104 M301 86 V102 M325 87 V104 M346 90 V107"/></g>'
  else: # Frankie: copper headphones, distinct across all facings.
   art='<g fill="none" stroke="#56473e" stroke-width="12"><path d="M233 149 V105 Q234 34 299 34 Q369 35 369 106 V149"/></g><g fill="#dca365" stroke="#56473e" stroke-width="5"><rect x="224" y="121" width="23" height="47" rx="9"/><rect x="354" y="121" width="23" height="47" rx="9"/></g>'
  export(f'customer-{n}-{view}',art,600,1024)
