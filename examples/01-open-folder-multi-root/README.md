# Example 01: Open Folder Multi-Root Workspace

This lab explores the `.code-workspace` flow that Visual Studio now supports for opening multiple folders at once.

## What This Example Covers

- folder aliases in a workspace file
- per-folder `.vscode/settings.json` file exclusion
- per-folder `tasks.vs.json`
- a launch configuration scoped to one workspace folder

## Open In Visual Studio

Open [vsf-layers.code-workspace](workspace/vsf-layers.code-workspace).

Expected folders in Solution Explorer:

- `Client`
- `Service`
- `Shared Notes`

## Manual Validation

1. Open the workspace file through `File > Open > Workspace`.
2. Confirm the aliases listed above appear instead of raw folder names.
3. In `Client`, right-click [render.ps1](frontend/app/render.ps1) and verify a task named `Run Describe Client Script` appears.
4. In `Service`, right-click [serve.ps1](backend/app/serve.ps1) and verify a task named `Run Describe Service Script` appears.
5. In `Client`, confirm [placeholder.json](frontend/generated/placeholder.json) is hidden by default because of `.vscode/settings.json`.
6. In `Service`, confirm [service.log](backend/logs/service.log) is hidden by default because of `.vscode/settings.json`.
7. In `Service`, set the `Run service script - diagnostic` launch target and confirm it starts PowerShell against [serve.ps1](backend/app/serve.ps1).
8. Note the path resolution behavior for this sample: `${workspaceRoot}` resolves to the example root folder, so the launch config must reference `backend\app\serve.ps1`, not just `app\serve.ps1`.

## Local Preflight

Run:

```powershell
pwsh -File .\tests\validate.ps1
```
