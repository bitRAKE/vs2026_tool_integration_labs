# Example 05: VSIX-Packaged DSL Syntax Highlighting

This lab packages a fake `.vsfdsl` language for Visual Studio 2026 by combining:

- a TextMate grammar
- a Language Configuration file
- a content-only VSIX project

## What This Example Covers

- VSIX packaging without a full custom editor
- TextMate scope registration through `.pkgdef`
- comment, bracket, and auto-closing behavior through language configuration

## Open In Visual Studio

Open [VsfDslSyntaxHighlighting.csproj](VsfDslSyntaxHighlighting.csproj) or the containing folder.

## Manual Validation

1. Build the project in Visual Studio 2026 or run the local validation script.
2. Install the generated `.vsix` by either:
   - double-clicking `bin\Debug\VsfDslSyntaxHighlighting.vsix` or `bin\Release\VsfDslSyntaxHighlighting.vsix`
   - running `pwsh -File .\tests\install-vsix.ps1`
3. If the VSIX Installer shows `Blocking processes: MSBuild.exe`, wait for the build to finish or close Visual Studio and retry. Those messages do not mean the package itself is invalid.
4. Treat these lines as the success marker:
   - `Install to Visual Studio Community 2026 completed successfully`
   - `The extension has been installed to C:\Users\<you>\AppData\Local\Microsoft\VisualStudio\18.0_<instance>\Extensions\...`
5. Restart Visual Studio 2026 if prompted.
6. Open [pipeline.vsfdsl](../04-external-build-dsl-pipeline/specs/pipeline.vsfdsl).
7. Confirm these tokens are colorized:
   - comments starting with `#`
   - keywords such as `pipeline`, `stage`, `task`, `uses`
   - quoted command strings
8. Test line commenting on a DSL line and confirm `#` is used.
9. Test quote auto-closing by typing a double quote in the file.

## Notes

- Opening the `.vsix` file in Windows Explorer and letting `VSIXInstaller.exe` run is the normal install path.
- The package is unsigned, so a warning about that is expected for this lab sample.
- Your build may produce either `bin\Debug\VsfDslSyntaxHighlighting.vsix` or `bin\Release\VsfDslSyntaxHighlighting.vsix`, depending on how you built it.

## Cleanup

- Manual uninstall path:
  - `Extensions > Manage Extensions` inside Visual Studio
- Scripted uninstall path:

  ```powershell
  pwsh -File .\tests\uninstall-vsix.ps1
  ```

- Quiet uninstall for automation:

  ```powershell
  pwsh -File .\tests\uninstall-vsix.ps1 -Quiet
  ```

- Quiet uninstall that also force-closes blocking processes:

  ```powershell
  pwsh -File .\tests\uninstall-vsix.ps1 -Quiet -ShutdownProcesses
  ```

- Local build-artifact cleanup:

  ```powershell
  pwsh -File .\tests\clean-local-artifacts.ps1
  ```

- The uninstall script targets the specific current Visual Studio instance by `instanceId`, rather than uninstalling from every matching product.
- The installer syntax for this behavior comes from the local `VSIXInstaller.exe` usage dialog:
  - `/uninstall:<vsixID>`
  - `/instanceIds:<instanceId>`
  - `/quiet`
  - `/shutdownprocesses`

## Local Preflight

Run:

```powershell
pwsh -File .\tests\validate.ps1
```
