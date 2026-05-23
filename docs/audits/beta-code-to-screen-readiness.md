# Beta Code-To-Screen Readiness Audit

Date: 2026-05-23

This audit answers a narrower question than "do tests pass?": for each intended
player beat, can we point to the screen object, input target, state mutation,
player feedback, next enabled action, and regression coverage?

## Audit Model

A beat is build-ready only when all seven columns are true:

| Gate | Meaning |
| --- | --- |
| Screen object | The player can see the thing they are supposed to care about. |
| Input affordance | The prompt appears from normal play distance and pressing the key reaches the intended script. |
| Code owner | One controller or system owns the behavior; no duplicate owner competes for the beat. |
| State mutation | Pressing the input changes durable game state, not only text. |
| Screen feedback | The player sees the consequence without reading logs. |
| Next beat | The prior interaction disables and the next interaction enables. |
| Test or capture | A test or recorded manual pass proves the full chain still works. |

If a beat only satisfies code owner and state mutation, it is scaffold. If it
also satisfies screen object, input, feedback, and next beat, it is gameplay.

## Current Result

| Beat | Status | Evidence | Gap |
| --- | --- | --- | --- |
| Boot into Shelf Life | Ready | Runtime log now reaches `AUDIT: PASS day1_playable_ready store_id=retro_games`; `Day1ReadinessAudit` checks active store, player, camera, input focus, stockable shelf, backroom stock, and active objective. | Entry readiness is not the same as loop readiness. |
| Opening manager | Ready but thin | `BetaDayOneCustomer/Interactable` is reused as manager, prompt copy changes to manager, and tests cover objective/proxy copy. | The conversation is a one-press completion, so it teaches controls but not decision-making. |
| Register check | Wired but thin | `BetaDayEndTrigger/Interactable` advances `training_check_register`, grants register access, and shows a toast. | The register does not yet have an inspectable screen or visible state change beyond checklist/toast. |
| Back-room pickup | Wired | `BetaBackroomPickup/Interactable` advances to shelf stock, emits carry/backroom count changes, and swaps the stock box visual. | Needs a manual capture that starts at register check and reaches the pickup in one continuous run. |
| Stock shelf | Buildable | `BetaRestockShelf/Interactable` drains carry/backroom state, emits shelf count, hides empty overlay, and renders visible shelf items. | The act is still instant; there is no stocking mini-loop or placement choice. |
| First customer decision | Wired, not proven by latest run | Day 1 content has one customer event with three choices; choice selection mutates cash/reputation/manager trust, inventory effects, customer exit, sale signals, HUD counters, and outcome toast. | Latest manual log stopped after register. Need a capture that proves the decision card, result panel, customer exit, sale stats, and next objective all appear in one run. |
| Close day | Wired, needs capture | Close-day target is gated until required objectives complete, summary payload includes sales, rent, profit, inventory, customers helped, skipped-objective notes, and reinvest options. | Need an end-to-end capture from first customer through summary. |
| Repeatable gameplay | Not ready | There are production systems for inventory, queueing, customer purchase, reports, day summary, and beta events. | The beta slice is still a single authored chain. It does not yet express a repeatable shelf -> customer -> queue -> checkout -> restock loop on screen. |

## What Is Actually Ready

- Store entry is ready: boot, scene routing, active-store state, player spawn,
  input focus, and Day 1 readiness now have a passing audit.
- Day 1 scripted progression is mostly ready: manager, register, back room,
  shelf, first customer, and close day all have code owners and tests.
- HUD ownership is mostly coherent: right panel owns stats/checklist, event log
  owns recent event copy, interaction prompt owns the bottom-right affordance,
  and toasts own transient feedback.

## What Is Not Ready

- A repeatable gameplay spine is not chosen clearly enough. The repo currently
  mixes a first-person store, a scripted checklist, modal decision cards,
  inventory effects, and customer/queue systems. All are plausible, but the
  player-facing loop is not yet one obvious grammar.
- The screen does not yet prove consequences strongly enough. Logs and state
  changes are ahead of visual feedback.
- "More visual pass" is now low leverage. The missing progress is not another
  shelf prop; it is an end-to-end interaction loop that can be replayed.

## Recommended Next Milestone

Build one vertical Day 1 loop and stop treating this as a general beta polish
problem:

1. Customer is visible at the counter with a readable need.
2. Player talks to customer and sees the decision card.
3. Player chooses an option.
4. Customer visibly reacts and exits or stays.
5. Register/shelf/HUD change visibly.
6. Back-room or shelf work becomes the next physical task.
7. Closing summary reflects exactly what happened.

The target validation should be one automated critical-path test plus one
manual capture checklist. The manual checklist should not be "look around the
store"; it should be:

```text
New Game -> manager -> register -> back room -> stock shelf -> customer choice
-> result acknowledgement -> visible customer exit -> stats tick -> close day
-> summary values match the choice
```

## Build Decision

Before adding more features, choose the primary gameplay grammar:

| Option | What the game becomes | Why it helps |
| --- | --- | --- |
| Retail sim loop | Customers browse, queue, buy; player stocks/prices/handles register pressure. | Best if the core fun is spatial retail management. |
| Narrative decision loop | Store is a walkable frame around customer cases and consequences. | Best if the core fun is making retail calls with story fallout. |

Right now the project is trying to be both. The quickest way out of beta is to
pick one as the spine and demote the other to support.

