# Rowan — B overview motion proof

**B-ROWAN-01 / review-v3. Working review sample; visual acceptance pending.**

Double-click **Launch Rowan.command**, or run from any directory:

```sh
'/Users/michaelfuscoletti/Desktop/game-sim/samples/b-motion/Launch Rowan.command'
```

Godot 4.6.2 Standard, GDScript, Compatibility. Separate project, separate user-data namespace, no retail scripts, no saves, no remote operations.

- **WASD / arrows:** walk eight directions; release to stop.
- **1 / 2 / 3 / 4:** turn toward / right / away / left without moving.
- **E:** stand at the outlined circle at the shelf's left end, then reach and return to idle.
- **R:** reset position. **T:** toggle the recorded demonstration route. **F:** compare authored side frames with cutouts; front/back retain cutouts.

The default window is 1280×720 macOS points (2560×1440 framebuffer pixels on the tested 2× Retina display). Character is 110 logical pixels high, about 220 framebuffer pixels. The capture command below uses 1280×720 framebuffer pixels to produce a 1:1 logical-resolution recording; it is not the live Retina window measurement.

## Four separate records

**Technical behavior:** nine scripted input checks pass; display-backed route captures cover toward/away, mirrored side directions, planted root stops, shelf occlusion and reach/return. Root does not move after released input. Shelf footprint blocks travel through the fixture; feet-based sorting hides the character behind it and shows the character in front. Reach arm temporarily renders above the shelf to show contact. This is one fixture-specific alignment, not a general interaction system.

**Visual assessment by engineer:** recognizable curls, face, teal shirt, ochre tee and rust shoes persist across views. No extra neighboring limbs in the final separated exports. Initial seam/stride problems were reduced in one focused repair. Still not a finished animation treatment: rigid legs stretch in depth travel; stops settle abruptly; four facing groups switch instantly; straight-arm reach is stiff; flat hidden-surface repair patches and small outline discontinuities remain visible when enlarged. Small residual sliding is plausible because the foot constraint uses estimated sole anchors rather than drawn ankle/knee articulation. No claim of perfect planted feet or visual acceptance.

**Production repeatability:** original generation sheets, three seven-layer directional KRA masters, six-layer authored trial KRA, transparent PNGs, joint positions, dimensions and import records retained. Krita 5.3.3 script-assisted cleanup/reconstruction ran inside Krita. Reopened all three cutout masters and re-exported 18 limbs; all PNG hashes identical. Godot import and display-backed relaunch reproduced. This demonstrates this sample's round trip, not economical production of a full cast. Total authoring/owner time and generation model/seed/credit count were not exposed or timed.

**Owner feedback:** pending for this exact sample. Direction selection B is already recorded; it is not acceptance of this motion. No retail encounter or publication is authorized by this handoff.

## What was tried

1. Built-in generation created one three-view identity sheet, retained as `source/originals/rowan-master-v1.png`. It requested transparency but the actual alpha was uniformly 255: the checkerboard was painted pixels.
2. Krita removed bright neutral background pixels, separated six parts per view, painted shirt/trouser continuations under the side arm, and exported RGBA. First cutout had shoulder seams, too-short stride/foot sliding, contaminated overlapping shoe boundaries and a prematurely advancing demonstration route. Failed source, KRA, parts and movie retained under `evidence/cutout-v1/`.
3. One focused repair isolated the near shoe and reused it for the far leg; added concealed hip/shoulder coverage, reduced protruding shoulder caps after contrast inspection, and painted hidden surfaces. AnimationPlayer drives gait phase and arm swing. Foot-target transforms match travel distance during stance; the rigid single-piece leg therefore stretches, which remains a quality limit. Route now waits for each destination and stop. Reach angle aligns the hand with the left shelf edge. `evidence/cutout-v2/` preserves an intermediate motion capture.
4. Because the rigid cutout still missed the motion target, built-in generation derived six authored side poses from the SAME identity master. Krita normalized crown/sole alignment into six editable frame layers and RGBA exports. The running F comparison bends knees more naturally but repeats similar contact poses, lacks convincing opposite-phase arm motion, and shows proportion/pose variation. It is a bounded failed alternative, not a replacement production pipeline. See `evidence/rowan-authored-comparison.mp4`; this earlier capture predates only the visible reach-circle layering correction.

## Evidence and source map

- `evidence/rowan-review-v3.mp4`: final 25-second engine capture, logical 1280×720 at 30 fps.
- `evidence/review-v3/motion-trace.json`: recorded state alongside the final route.
- `evidence/alpha-report.json`, `alpha-contact-sheet.jpg`: actual alpha counts/bounds and light/dark composites plus individual side limbs.
- `evidence/behavior-checks.json`, `behavior.log`: nine real input-adapter checks, run headless; separate from visual observations.
- `evidence/roundtrip.json`, `kra-inventory.json`, `krita-build.json`: editable source/export evidence.
- `evidence/owner-window.log`: actual Retina window, canvas scale, renderer and engine version.
- `evidence/source-manifest.json`: exact source, art, KRA, reference and import hashes; aggregate identity in sibling `identity.json`.
- `art/rig.json`: 600×1024 full-canvas exports, foot roots and shoulder/hip/head pivots. Scaling 110/928. Side mirrored for left; no asymmetric logos/accessories, but mirrored light is a limitation.
- `main.gd`: AnimationPlayer library and motion/overlap behavior. PNG import: lossless mode 0, linear CanvasItem filtering, mipmaps off, alpha border fix on, premultiplied alpha off, sRGB PNG via Krita.
- `scripts/krita_build.py`: deterministic script-assisted cleanup in Krita Tools → Scripts → Scripter. `scripts/krita_roundtrip.py` opens saved KRA and re-exports existing layers. `scripts/krita_frames.py` creates the authored comparison master/exports.
- `source/prompts.md`, `reference/README.md`: provenance, retained identity, primary reference and exact production intentions.

Reproduce technical checks:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path /Users/michaelfuscoletti/Desktop/game-sim/samples/b-motion --fixed-fps 30 --script res://scripts/behavior_check.gd
```

Reproduce the movie in a fresh output folder by first moving any prior `evidence/frames` aside:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path /Users/michaelfuscoletti/Desktop/game-sim/samples/b-motion --fixed-fps 30 --resolution 1280x720 -- --capture
ffmpeg -framerate 30 -i /Users/michaelfuscoletti/Desktop/game-sim/samples/b-motion/evidence/frames/%04d.png -c:v libx264 -pix_fmt yuv420p /Users/michaelfuscoletti/Desktop/game-sim/samples/b-motion/evidence/new-review.mp4
```

Add `--authored` after `--capture` for the alternate side-frame comparison. Captures are actual Godot viewport frames. Contact sheets are labeled diagnostic crops/composites, not substitutes for live gameplay-scale inspection.

The live review uses an isolated, ad-hoc-signed clone of the installed Godot app at `/tmp/game-sim-b-motion-tools/RowanMotion.app` solely so macOS UI automation can select this window without touching an already running space-opera Godot process. Version and renderer are recorded. The reproducible launcher uses the unchanged official installation. This is not an exported/distributed game build.

## Remaining bounded dependency

A production-quality version needs a coherent animation pass for this identity: toward/away/right (left mirrored only if acceptable), six to eight distinct walk poses per direction at a documented 0.72-second cycle, neutral planted idle, short directional transition poses, and four-to-six reach/recover poses with hand target and sole anchors. Retain 600×1024 RGBA canvases, layered KRA, sRGB/straight alpha, full rights to edit/use source, and Godot 4.6.2 Compatibility imports. If retaining cutouts, separately articulated upper/lower legs and upper/lower arms need reconstructed joints and measured sole anchors. This names the demonstrated missing artwork/animation work; no commissioning or expansion has been undertaken.
