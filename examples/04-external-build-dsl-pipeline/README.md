# Example 04: Custom DSL Build Pipeline

This lab treats a fake `.vsfdsl` file as the source of truth and uses Open Folder tasks to compile it into JSON.

## What This Example Covers

- a custom external tool implemented as PowerShell
- `tasks.vs.json` for build and clean flows
- `launch.vs.json` for previewing generated output
- a DSL shape that also feeds the syntax-highlighting sample in Example 05

## Open In Visual Studio

Open the folder [examples/04-external-build-dsl-pipeline](.).

## Manual Validation

1. Open the folder with `File > Open > Folder`.
2. Right-click [pipeline.vsfdsl](specs/pipeline.vsfdsl) and confirm these tasks appear:
   - `Compile VSF DSL`
   - `Clean Generated JSON`
3. Run `Compile VSF DSL` and confirm `generated\pipeline.json` appears.
4. Open the generated JSON and confirm it contains the `restore` and `smoke` tasks from the DSL source.
5. Select the `Preview generated pipeline` launch target and confirm it prints a short summary to the Output window or console.

## Notes

- This example uses custom file tasks rather than built-in `build/clean/rebuild` context types.
- If Visual Studio prefixes the menu text with `Run `, treat that as expected UI presentation rather than a mismatch in the task file.

## Local Preflight

Run:

```powershell
pwsh -File .\tests\validate.ps1
```
