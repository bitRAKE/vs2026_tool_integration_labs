# Example 03: External Build Integration With Ninja

This lab keeps Visual Studio in Open Folder mode and routes all builds through `ninja`.

## What This Example Covers

- `tasks.vs.json` driving an external build orchestrator
- `build.ninja` as the source of truth for build edges
- a smoke test task outside the native C++ project system

## Open In Visual Studio

Open the folder [examples/03-external-build-ninja](.).

## Manual Validation

1. Open the folder with `File > Open > Folder`.
2. Right-click the folder root and verify these commands appear:
   - `Build`
   - `Clean`
   - `Rebuild`
   - `Run Ninja Smoke Test`
   - `Run List Ninja Outputs`
3. Run `Build` and confirm [ninja-lab.exe](out/ninja-lab.exe) is created.
4. Run `Run List Ninja Outputs` and confirm the Output window lists files from `out`.
5. Run `Run Ninja Smoke Test` and confirm the Output window reports a passing message.
6. Select the `ninja-lab` launch target and confirm the debugger launches the generated executable.

## Notes

- Visual Studio reduces built-in `contextType` values to stock command names in the context menu.
- In practice, `contextType: "build"` shows as `Build`, `clean` shows as `Clean`, and `rebuild` shows as `Rebuild`, even when `taskLabel` contains more words.
- This example now has two custom tasks:
  - `Ninja Smoke Test` uses `type: "launch"`
  - `List Ninja Outputs` uses `type: "default"`
- If Visual Studio renders both as `Run ...`, that suggests the menu prefix is tied to the task being custom rather than specifically to `type: "launch"`.

## Files

- Menu-shaping tasks live in [tasks.vs.json](tasks.vs.json).
- The presentation-probe helper lives in [tests/list-outputs.ps1](tests/list-outputs.ps1).

## Local Preflight

Run:

```powershell
pwsh -File .\tests\validate.ps1
```
