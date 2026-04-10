# Example 08: Open Folder FASM Profiles With JSON Schema

This lab pushes the external-tool integration story one level deeper by moving the real build and utility intent into a schema-backed JSON file instead of hard-coding every behavior in `tasks.vs.json`.

## What This Example Covers

- a checked-in JSON profile file with a local `$schema`
- fixed Open Folder tasks that delegate to named build, syntax-check, and inspect profiles
- real `fasmg` option surfaces, including:
  - max errors
  - max passes
  - recursion depth
  - verbosity
  - frontend preference (`fasm2` vs direct `fasmg`)
- profile-driven binary generation and utility actions for a real assembler workflow

## Open In Visual Studio

Open the folder [examples/08-open-folder-fasm-profiles](.).

## Profile File

The main configuration file is [fasm-profiles.json](fasm-profiles.json).

It uses [schemas/fasm-profiles.schema.json](schemas/fasm-profiles.schema.json) to describe:

- the active build, syntax, and inspect profile slots
- shared tool defaults
- named utility profiles

The fixed task surface stays small, while the profile file becomes the development-time configuration surface.

## Manual Validation

1. Open the folder with `File > Open > Folder`.
2. Open [fasm-profiles.json](fasm-profiles.json) and confirm Visual Studio treats it as JSON.
3. Confirm the profile file loads as JSON without an unsupported-schema warning. If Visual Studio offers schema-driven descriptions or enum-like choices, inspect fields such as:
   - `frontendPreference`
   - `verbose`
   - profile `kind`
4. Right-click the folder background or root node and confirm these tasks appear:
   - `Build`
   - `Clean`
   - `Run Validate FASM Profile File`
   - `Run Show Active FASM Profiles`
   - `Run Active Syntax Profile`
   - `Run Inspect Active FASM Output`
5. Run `Run Validate FASM Profile File` and confirm it prints the active slots and named profiles.
6. Run `Build` and confirm [out/profiles/hello.com](out/profiles/hello.com) appears.
7. Run `Run Inspect Active FASM Output` and confirm it reports:
   - the artifact path
   - the artifact size
   - a hex preview
   - the resolved `fasm2` and `fasmg` paths
8. Right-click [src/showcase.finc](src/showcase.finc) and run `Run Active Syntax Profile For This FINC File`.
9. Right-click [src/hello.fasm](src/hello.fasm) and run `Run Active Syntax Profile For This FASM File`.
10. Edit [fasm-profiles.json](fasm-profiles.json) and change:
    - `activeProfiles.build` from `hello-com` to `restartout-com`
11. Run `Build` again and confirm [out/profiles/restartout.com](out/profiles/restartout.com) is produced instead.
12. Edit [fasm-profiles.json](fasm-profiles.json) and change:
    - `activeProfiles.syntax` from `hello-syntax` to `broken-syntax`
13. Run `Run Active Syntax Profile` and confirm it fails on [src/broken-quote.fasm](src/broken-quote.fasm).
14. Restore the original active profile values when done.

## Notes

- Open Folder tasks remain static. Visual Studio does not dynamically generate context-menu commands from the JSON profile file.
- This example therefore separates:
  - task presentation in `tasks.vs.json`
  - tool configuration in `fasm-profiles.json`
- The profile file is where tool-specific options now live, which is closer to how compiler and linker configuration feels in traditional project systems.
- This example builds directly on Example 06 and uses the richer editor layer from Example 07.

## Local Preflight

Run:

```powershell
pwsh -File .\tests\validate.ps1
```
