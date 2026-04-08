# Example 07: VSIX-Packaged FASM Syntax Highlighting

This lab packages real `.fasm` and `.finc` syntax support for Visual Studio 2026 by combining a TextMate grammar, Language Configuration, and a content-only VSIX.

## What This Example Covers

- VSIX packaging for a real external language instead of the toy `.vsfdsl` sample
- TextMate colorization for `.fasm` and `.finc`
- comment and quote behavior through Language Configuration
- validation flow that pairs with the real `fasm2` Open Folder example in Example 06

## Highlighting Scope

This package intentionally highlights only the tokens we care about right now:

- line comments beginning with `;`
- numbers
- single-quoted strings
- double-quoted strings
- the keywords `include` and `restartout`

Keyword matching is case-insensitive.

## Open In Visual Studio

Open [FasmSyntaxHighlighting.csproj](FasmSyntaxHighlighting.csproj) or the containing folder.

## Manual Validation

1. Build the project in Visual Studio 2026 or run the local validation script.
2. Install the generated `.vsix` by either:
   - double-clicking `bin\Debug\FasmSyntaxHighlighting.vsix` or `bin\Release\FasmSyntaxHighlighting.vsix`
   - running `pwsh -File .\tests\install-vsix.ps1`
3. Restart Visual Studio 2026 if prompted.
4. Open [../06-open-folder-fasm2-build/src/hello.fasm](../06-open-folder-fasm2-build/src/hello.fasm).
5. Open [../06-open-folder-fasm2-build/src/showcase.finc](../06-open-folder-fasm2-build/src/showcase.finc).
6. Open [../06-open-folder-fasm2-build/src/restartout-demo.fasm](../06-open-folder-fasm2-build/src/restartout-demo.fasm).
7. Confirm these tokens are colorized:
   - comments beginning with `;`
   - `include`
   - `restartout`
   - numbers such as `100h`, `13`, and `2Ah`
   - both single- and double-quoted strings
8. Test line commenting and confirm `;` is used.
9. Test typing both `'` and `"` and confirm they auto-close.

## Notes

- This example is the real-world continuation of Example 05 rather than a replacement for it.
- The package is unsigned, so a warning about that is expected for this lab sample.
- Use Example 06 files for manual validation because they contain the exact token mix this VSIX is meant to support.

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

## Local Preflight

Run:

```powershell
pwsh -File .\tests\validate.ps1
```
