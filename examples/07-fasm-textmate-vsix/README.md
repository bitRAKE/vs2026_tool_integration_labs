# Example 07: VSIX-Packaged FASM Syntax Highlighting

This lab packages real `.fasm` and `.finc` syntax support for Visual Studio 2026 by combining a TextMate grammar, Language Configuration, and a content-only VSIX.

The grammar now aligns with the richer `fasmg` syntax work previously developed outside this repo, while still registering the file extensions used by this lab: `.fasm` and `.finc`.

## What This Example Covers

- VSIX packaging for a real external language instead of the toy `.vsfdsl` sample
- TextMate colorization for `.fasm` and `.finc`
- comment and quote behavior through Language Configuration
- validation flow that pairs with the real `fasm2` Open Folder example in Example 06

## Highlighting Scope

This package now goes beyond the initial minimal token set and tracks the richer `fasmg` grammar baseline:

- line comments beginning with `;`
- line continuations ending in `\`
- strings with doubled-quote escapes and unclosed-string detection
- verified `fasmg` number formats, including `0x`, `$`-prefixed hex, suffix forms, separators, and floats
- labels, macro heads, control/data/storage directives, operators, and built-in symbols
- CALM regions from `calminstruction` through `end calminstruction`
- the real directives and keywords we already care about, including `include` and `restartout`

The TextMate scope name follows the underlying syntax family as `source.fasmg`, even though the registered file extensions remain `.fasm` and `.finc`.

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
7. Open [samples/fasmg-rich-showcase.fasm](samples/fasmg-rich-showcase.fasm).
8. Optionally open [samples/fasmg-unclosed-string.fasm](samples/fasmg-unclosed-string.fasm) to inspect the unclosed-string behavior.
9. Confirm these tokens are colorized:
   - comments beginning with `;`
   - `include`
   - `restartout`
   - numbers such as `100h`, `2Ah`, `0xDE'AD'BE'EF`, `$0F`, `77q`, and `1.0e+_10`
   - both single- and double-quoted strings, including doubled-quote escapes
   - macro and `calminstruction` headers
   - operators, labels, and built-in symbols such as `$`, `$$`, and `%`
10. Test line commenting and confirm `;` is used.
11. Test typing both `'` and `"` and confirm they auto-close.

## Notes

- This example is the real-world continuation of Example 05 rather than a replacement for it.
- The grammar content is intentionally richer than the original Example 07 baseline so future schema-backed and command-surface labs can build on a more realistic editor layer.
- The package is unsigned, so a warning about that is expected for this lab sample.
- Use both the Example 06 files and the `samples\` files here for manual validation. Example 06 exercises the real build flow, while `samples\` exercises richer grammar coverage.

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
