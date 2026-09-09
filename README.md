# Game Store Sim

Current direction: an illustrated 2.5D early-2000s mall game shop, using Kardboard Kings as the primary composition reference and **B-ROWAN-01 / retail-v4** as the current visual baseline. The owner has given strong positive feedback on its appearance. The retail loop remains the product: receive, price, stock, serve, sell, close, review, and decide what comes next.

## Start here

1. [Master plan](docs/MASTER_PLAN.md): current direction and scope.
2. [Slices and backlog](docs/03-production/milestones-and-backlog.md): status, dependencies and completion criteria.
3. [Task checklist](docs/03-production/visual-first-task-list.md): current actionable todos.
4. [Owner feedback](docs/03-production/retail-v4-owner-feedback.md): exact response and its scope.
5. [Retail-v4 sample and launch](samples/b-retail-v4/README.md): retained build report, source assets and evidence. Its pending-review wording is a frozen handoff; the owner-feedback record above is current.
6. [Validation](docs/04-validation/local-validation-plan.md): baseline isolation and evidence rules.

**R1–R4 are accepted within scope.** Owner R4 feedback: **“yes”**, confirming that handling several customers is clear and enjoyable enough to build on. R5 adds three fictional products, separate prices, mixed orders, four-space assortment decisions, backroom returns and per-product reports. See [R5 delivery](docs/03-production/r5-delivery.md) for qualification and owner-review status, and [launch and controls](encounter/README.md). This is not complete-game or release acceptance.

Checkout branch: `main`, incoming HEAD `4b91108fa3cd8d9a2829524c6cf5baed55a236d0`. The two existing local commits and incoming uncommitted R4 work are preserved. No commit, push or publication. The R5 manifest binds the uncommitted candidate; HEAD alone does not identify it.

The old samples and retail-state prototype are preserved separately. The new `encounter/` project integrates the retail-v4 overview with replacement transaction state. Historical documents and retained build reports are evidence, not current work orders. Keep `/Users/michaelfuscoletti/Desktop/game_sim_next_steps.md` synchronized with the master plan.
