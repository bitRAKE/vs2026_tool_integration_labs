# Example 02: C++ Open Folder Environments

This lab focuses on the Open Folder C++ files that Visual Studio uses when you are not loading a `.sln` or `.vcxproj`.

## What This Example Covers

- `CppProperties.json`
- `tasks.vs.json` with `inheritEnvironments`
- `launch.vs.json` with explicit debug targets
- output folders that change by environment name

## Open In Visual Studio

Open the folder [examples/02-open-folder-cpp-environments](.).

## Manual Validation

1. Open the folder with `File > Open > Folder`.
2. Open [CppProperties.json](CppProperties.json) and confirm schema-aware editing is available.
3. Right-click the folder root in Solution Explorer and inspect the build section of the menu.
4. On Visual Studio 2026, expect the commands to surface like this:
   - `Build`
   - `Run TraceLike Build`
   - a clean command
5. `Build` maps to the task that inherits `LabMSVC-DebugLike`, so run `Build` and confirm `out\debuglike\vsf-environments.exe` is created.
6. Run `Run TraceLike Build` and confirm `out\tracelike\vsf-environments.exe` is created.
7. In Solution Explorer, expand `out\debuglike`, right-click `vsf-environments.exe`, and choose `Set as Startup Item`.
8. Use the standard debug target dropdown on the main toolbar, next to the green Start button.
9. If you only see `Current Document`, Visual Studio has not bound a startup item yet. After setting the generated `.exe` as the startup item, open the dropdown again.
10. If the target names are still hidden, open the dropdown and use `Show/Hide Debug Targets`.
11. Select `VSF Env Probe (DebugLike)` and press `F5`, `Ctrl+F5`, or the green Start button. Confirm the program reports `profile=debuglike`.
12. Repeat the same process for `out\tracelike\vsf-environments.exe`, then select `VSF Env Probe (TraceLike)` and confirm the program reports `profile=tracelike`.

## Notes

- `Build` is the default build because it is the only task with `contextType: "build"`.
- `Run TraceLike Build` is a custom alternate build because it uses `contextType: "custom"`.
- The launch targets come from [launch.vs.json](launch.vs.json), not from the right-click build menu.
- Visual Studio Open Folder debugging is startup-item driven. Microsoft’s documented flow is: create debug settings for an executable, then set that executable as the startup item so it appears in the Startup Item dropdown.

## Local Preflight

Run:

```powershell
pwsh -File .\tests\validate.ps1
```
