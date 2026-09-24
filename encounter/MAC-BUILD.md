# Personal Mac build

From the repository root, run:

```sh
python3 encounter/scripts/build_mac.py --output artifacts/my-personal-mac-build
```

The output directory must not already exist. The script copies the active `encounter/` source (including uncommitted assets), imports it in a temporary project, then uses **Personal Mac** from `encounter/export_presets.cfg`. It does not run the game or access saves. It requires `/Applications/Godot.app` version **4.6.2.stable.official.71f334935** and matching `4.6.2.stable/macos.zip` export templates under the local Godot application-support directory. The build uses Python 3, macOS `ditto`, and Godot’s built-in ad-hoc signing; no identity credentials or notarization service are needed.

Outputs: launchable universal app, ZIP, full source snapshot and SHA-256 manifest, engine/template hashes, bundle-file hashes, import/export logs and `identity.json`. The ZIP hash identifies a particular export; ZIP timestamps/signing mean repeated exports need not have identical hashes. Archive each tested artifact instead of overwriting it.

The custom export feature `personal_beta` selects `game-sim-personal-beta-v10` and the personal app name. Ordinary development retains `game-sim-first-week-dev-v10`. The namespace is separate even though business meaning remains schema 10 / `b6-retail-1`. No migration is performed. Tests, evidence and editable art masters are excluded from the shipped resource pack; required runtime art is included.

The relevant source regression matrix is `python3 encounter/scripts/validate.py --render`, plus `python3 -m unittest discover -s encounter/scripts -p test_validation_runner.py`. It uses unique synthetic namespaces and Dummy audio, so it does not qualify the delivered package or real audio.

`qualify_mac.py ARTIFACT_DIRECTORY` creates a separately identified **instrumented release export** from the frozen artifact source archive. It changes only the test scene, harness, export inclusion and synthetic namespace, verifies runtime/art equality, and binds results to the ordinary ZIP hash. It is never the owner app. Normal-speed navigation uses `--script test_b9_navigation.gd`; accelerated whole-week runs use `--strategy growth`, `lean` or `bankruptcy`. Scripted inputs and synthetic setup must remain labeled. Ordinary launch/quit/resume and targeted navigation/audio must also be checked on the delivered app itself.
