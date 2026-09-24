# Glass UI adoption verification

September 21, 2026 · source implementation and engineering review only.

The isolated encounter validator passed, including 110 assortment-state checks and 54 assortment-scene checks plus its price-request/import checks. Evidence: encounter/evidence/validation-20260921T161936955273Z. A fresh disposable-copy 1280×720 render was inspected. No retained owner save or evidence was overwritten.

## Retained review

The shared [review gallery](../../ui-templates/review.html) contains screenshots and browser check results. Browser specimens are local fixtures or isolated startup states. Web review checked representative 1440px/390px layouts, page exceptions, and page-level horizontal overflow; it is not an exhaustive audit of every state, contrast pair, screen reader, browser, installed build, or physical phone.

Template gallery search, form submit feedback, dialog opening, and Escape dismissal were exercised. Shared styles include keyboard focus, reduced-motion, and reduced-transparency handling. Native Godot is a basic translucent fallback, not a true blur material. Native games retain their desktop layout and illustrated artwork.

See [design and future template use](ui-design.md). No owner acceptance or release qualification is inferred. Rebuild/relaunch the appropriate source application to see the change; installed or frozen copies remain their original versions.

## September 23 clarity review

Current source cleanup, based on clean `3e7d3ed05068a68fd2df9431ee4c0006e8f92b8b`, directly on main. The September 21 record above is historical. Frozen B9/B10 remains unchanged. All fresh previews used disposable projects with unique synthetic save namespaces through the existing validator; no owner saves or installed app were accessed.

### Matched views (1280 × 720)

| Screen | Before | After | Observation |
| --- | --- | --- | --- |
| Preparation | [Before](../encounter/evidence/ui-clarity-20260923/before-normal-matched/prep.png) | [After](../encounter/evidence/ui-clarity-20260923/verified-normal/prep.png) | Field precedes Apply; primary action is emphasized; Rack 1 replaces rack-0001. Same actions and playable area. |
| Finances | [Before](../encounter/evidence/ui-clarity-20260923/before-normal-matched/finances.png) | [After](../encounter/evidence/ui-clarity-20260923/verified-normal/finances.png) | Content height 554 → 330 logical pixels. Cash/result/unpaid bills first; detailed arithmetic remains one secondary action away. |
| Copy list | [Before](../encounter/evidence/ui-clarity-20260923/before-normal-matched/copies.png) | [After](../encounter/evidence/ui-clarity-20260923/verified-normal/copies.png) | Same 1040 × 464 window now shows all six starter copies without scrolling; formerly the sixth row was cut off. Row type increases from 15 to 16px. Unset price reads “Not set,” not $0.00. |

These are fresh same-state source captures, not historical product screenshots. Capture setup uses ordinary controls for receiving/pricing/stocking/opening/closing, then synthetic empty days for terminal/history views. It is not a complete owner playthrough. Copy/run IDs necessarily differ between isolated runs. Measurements support layout review, not a measured usability percentage.

### Checks and limits

- Existing isolated headless validator: import, week state/regressions, SSOT, security, storage, pending-price, presentation and restart checks passed on final source. [Exact context and logs](../encounter/evidence/ui-clarity-20260923/verified-checks/context.json). Nine Python tests passed; whitespace checked.
- Current native 1280 × 720 and 2560 × 1440 captures exercised entry, preparation, supplier empty/locked releases, pricing, stocking, trading/closing, reports, empty/full history, copies, record disclosure, calculation details and returning to Finances, save failure, surviving week and bankruptcy. [Normal observations](../encounter/evidence/ui-clarity-20260923/verified-normal/observations.json) · [Retina observations](../encounter/evidence/ui-clarity-20260923/verified-retina/observations.json). No script/engine errors in these completed runs.
- [Bankruptcy](../encounter/evidence/ui-clarity-20260923/verified-normal/bankruptcy-finances.png) keeps cash $40, the full unpaid $150 rent and $110 shortfall visible. The synthetic fixture uses $450 stock purchases plus a $60 rack, not the historical B8 bankruptcy policy. Earlier deliberate save failure remains visible in this sequential stress capture; it does not indicate an owner save failure.
- Keyboard Space opens copy records; mouse closes them; calculation dismissal returns to Finances. Existing presentation suite covers Tab focus, reload cancellation, save retry and menu recovery. Close admission, Cancel, Save/Retry and Menu remain in their existing positions. A separate terminal Tab probe found no root focus in both baseline and revised native runs; see follow-up below.
- [20% larger-text preparation](../encounter/evidence/ui-clarity-20260923/text-scale/font-120-prep-normal.png) and [Finances](../encounter/evidence/ui-clarity-20260923/text-scale/font-120-finances-normal.png) were inspected using test-only font overrides. Both stay readable, though adjacent HUD controls have little spare width. This is not a new font-size setting or exhaustive large-text qualification. Retina scaling is separately verified.
- Full integrated seven-day staffing/seller replay, real audio, package/native-exit qualification, screen-reader audit and owner acceptance were not rerun. UI work changes no business sources, persistence, data contracts, art or frozen package. Intermediate failed capture logs are retained: harness lookup/setup issues and a repaired secondary-dialog conflict are not passing evidence.

### Separate follow-up

The native terminal Tab probe returned no root focus after closing history, both before and after this cleanup (`main.gd` dialogs; observation files above). Keyboard-only return to the shop needs manual verification; this could be a native-window test limitation. A bounded next task is to reproduce with physical Tab/Shift-Tab after Finances and Daily closes, then adjust dialog focus return only if confirmed. A wider keyboard-routing change is outside this presentation pass.
