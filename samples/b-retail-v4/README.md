# Rowan — early-2000s retail art pass

**B-ROWAN-01 / retail-v4. Bounded art revision ready for owner review.**

Owner feedback on **review-v3**, verbatim: **“Yea it’s fine. Graphics look too much like the space opera though. Need more 2000s GameStop vibe.”**

This authorizes moving forward with the sample’s motion while revising the art direction. It is not complete-game acceptance, approval of this new art revision, or a claim that every animation defect is resolved. The selected illustrated 2.5D shop overview and **Kardboard Kings** reference remain. Space-opera informs production techniques only: Krita cleanup, editable layers, exports, alpha checks and animation; never visual styling.

## Launch and compare

Double-click [Launch Rowan.command](Launch%20Rowan.command), or run from any directory:

```sh
'/Users/michaelfuscoletti/Desktop/game-sim/samples/b-retail-v4/Launch Rowan.command'
```

WASD / arrows walk; release stops; **1/2/3/4** turn toward/right/away/left; **E** reaches from the circle at the shelf's left end and returns; **R** resets; **T** toggles the demonstration; **F** toggles the retained authored-side-frame experiment. F remains a historical motion comparison, with ochre tee/dark trousers/rust shoes and the updated blue overshirt; it is not the adopted outfit or finished animation set.

Godot 4.6.2 Standard/GDScript/Compatibility. Normal live window: 1280×720 logical points, measured 2560×1440 framebuffer pixels at 2× Retina. Rowan stays 110 logical pixels high. Separate sample project and user-data namespace; no retail code or owner saves.

- [Revised motion](evidence/rowan-retail-v4.mp4): actual Godot capture, 1280×720, 30 fps, 25 seconds.
- [Synchronized review-v3 / retail-v4 comparison](evidence/review-v3-vs-retail-v4.mp4): each viewport retains its original 1280×720 pixels, side by side; no character enlargement.
- [Same-frame comparison still](evidence/review-v3-vs-retail-v4.png): shelf reach, old left / revised right.
- Original working project, source, layered masters, exports, report and all review-v3 evidence remain intact in `../b-motion/`. Its report is a frozen historical handoff, so its pending-feedback wording describes the earlier handoff, not current status.

## What changed and why

Actual owner-supplied store photographs were inspected before art changes and copied byte-for-byte into [reference/period](reference/period/README.md). They show compact category-based shelving, face-out game cases, white/yellow price labels, cream slatwall, laminate panels, fluorescent retail lighting and commercial carpet. Exact original photographer/date/URL metadata was not supplied, so these are visually period-consistent sources rather than independently dated photographs. The source README records each observation and the web cross-checks. No third-party pixels or branding appear in the runtime.

Rowan's default outfit now reads as ordinary shop staff: blue short-sleeved overshirt, white tee, denim trousers, charcoal canvas sneakers, and a clipped name badge. Face/hair, silhouette, source alpha, separated limb boundaries, pivots and animation remain intact. Native Krita edits preserve the ink and cloth texture; no new image generation was used.

The existing shelf retains its exact outline and root location. New original layered art adds cream laminate ends, powder-coated wire backing, silver/acrylic shelf lips, 48 tightly arranged case faces, yellow used-game labels, and fictional VECTOR 2 / CUBE / HANDHELD category strips. Original racing, sports and trail packaging motifs accompany fictional **Replay Junction** branding and **Curb Circuit 02** promotional copy. A small slatwall and burgundy commercial-carpet/tile patch provide bright, everyday retail context. No full shop, new fixture collision, gameplay, transaction or simulation was added.

## Verification and limits

- **Controls:** all 13 real input-adapter checks pass, including walking, stop, reach/recovery, shelf blocking, F, and four turn keys (`evidence/behavior-checks.json`). Motion code from input handling onward is unchanged from review-v3.
- **Motion:** all 751 recorded state entries exactly match review-v3; rig JSON is byte-identical (`motion-regression.json`). The movies contain the first 750 frames. This demonstrates unchanged motion, not resolved stiffness or foot sliding.
- **Alpha:** all 27 corresponding character PNG alpha masks and dimensions match review-v3 exactly (`alpha-regression.json`). Light/dark and separated-limb inspection is retained in `alpha-contact-sheet.jpg`; environment alpha counts are in `alpha-report.json`.
- **Overlap:** actual overview frames 0030/0360/0440/0565 show foreground travel, behind-shelf occlusion, a stopped pose, and shelf-end reach. Shelf footprint, sorting root and arm overlay behavior are unchanged. No new alpha fringe or overlap regression was observed in those views.
- **Krita:** all six revised masters reopen; 26 exports from saved masters match the shipped PNG bytes exactly (`retail-roundtrip.json`). Three seven-layer directional masters, a six-layer authored trial, two-layer context and three-layer shelf are retained. Source dimensions: directional 600×1024, authored 512×512, context 5120×2880, shelf 1000×460. Environment sprites display at 0.25 scale, preserving the original geometry. PNGs use sRGB, straight RGBA, lossless import, linear filtering, mipmaps off, alpha border fix on.
- **Launch:** fresh import and installed-engine launcher from `/tmp` pass. Live overview inspected in a separately identified clone of the same installed Godot app, avoiding the other project's window. Logs: `import-final.log`, `launcher-verification.log`, `owner-window.log`.
- **Preservation:** hashes of all prior sample files, retail game files and original period references match the before-pass snapshot (`preservation-result.json`). Current identity is in `identity.json` / `source-manifest.json`.

Remaining: rigid-leg/depth stretching, abrupt stop/turn changes, stiff straight-arm reach, flat concealed-surface patches and small outline discontinuities on enlargement, possible residual foot sliding, mirrored side lighting, and the authored experiment's uneven pose proportions/phasing. Tiny case text and badge lettering function as detail rather than readable interface at overview scale. Packaging motifs repeat; this is one stocked fixture, not a qualified full-store art set. The wall/context remain deliberately simple. Owner approval of retail-v4 is pending.

The four existing retail defects remain unchanged for their separate task: sale after close, duplicate customer item selection, sold item still carried, and reversed old first-person forward movement. Nothing was committed, pushed or published.

## Reproduce

Native Krita build recipe and saved-master verification:

```sh
'/Users/michaelfuscoletti/Desktop/game-sim/samples/b-retail-v4/scripts/Rebuild Art.command'
```

This uses Krita's separate `kritarunner`, with a small uniquely named bootstrap in its own user resource folder; it does not manipulate the shared Krita scripting window. It reads the preserved review-v3 masters and rebuilds only retail-v4. `scripts/krita_retail.py` records every color rule, original packaging motif and sign string. Retained older scripts are historical production recipes; the command above is the current entry point. Krita logs retain nonfatal Fontconfig/profile/swap/tile diagnostics; successful exports/reopens and matching bytes establish the bounded result, not a warning-free Krita session.

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path /Users/michaelfuscoletti/Desktop/game-sim/samples/b-retail-v4 --fixed-fps 30 --script res://scripts/behavior_check.gd
```

Capture only after moving the existing `evidence/frames` aside to preserve it:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path /Users/michaelfuscoletti/Desktop/game-sim/samples/b-retail-v4 --fixed-fps 30 --resolution 1280x720 -- --capture
```

Next: owner reviews the retail art direction at normal overview scale. Motion permission carries forward with its recorded limits; no full-game acceptance or gameplay expansion is inferred.
