# Example 09: VSIX FASMG Selection Commands

This lab is the first step beyond pure TextMate highlighting for `fasmg`.

Instead of trying to fake a full language service, it adds explicit selection-scoped editor commands for common assembly editing tasks that are useful today and do not require a semantic engine yet.

## What This Example Covers

- an in-process `VisualStudio.Extensibility` VSIX command surface
- command activation limited to `.fasm` and `.finc`
- multi-selection editor transforms
- reusable text-transform logic that can be validated outside the IDE

## Commands Added

The extension contributes an `Extensions > FASMG Selection Utilities` menu with:

- `Rename Register In Selection`
- `Uppercase Registers In Selection`
- `Lowercase Registers In Selection`
- `Convert h-Suffix Hex To 0x In Selection`

These commands intentionally operate only on the current selection ranges.

They also intentionally skip:

- `;` line comments
- single-quoted strings
- double-quoted strings

That makes them safer for assembly editing than a blind find/replace pass, while still keeping the implementation well below a full parser or LSP.

## Open In Visual Studio

Open [FasmgSelectionCommands.csproj](FasmgSelectionCommands.csproj) or the containing folder.

## Manual Validation

1. Build the project in Visual Studio 2026 or run the local validation script.
2. Install the generated `.vsix` by either:
   - double-clicking `bin\Release\FasmgSelectionCommands.vsix`
   - running `pwsh -File .\tests\install-vsix.ps1`
3. Restart Visual Studio 2026 if prompted.
4. Open [samples/selection-playground.fasm](samples/selection-playground.fasm).
5. Select the `start:` block but include the nearby comment and string lines as part of the selection.
6. Run `Extensions > FASMG Selection Utilities > Uppercase Registers In Selection`.
7. Confirm register tokens such as `eax`, `ebx`, `r10d`, and `xmm1` become uppercase only in code.
8. Confirm the command does not change:
   - `eax` inside the `;` comment
   - `eax` or `2Ah` inside the quoted strings
9. Run `Lowercase Registers In Selection` on the same selection and confirm the code registers return to lowercase.
10. Select the same block again and run `Rename Register In Selection`.
11. Enter:
    - source register: `eax`
    - destination register: `r11d`
12. Confirm only whole register tokens are renamed in the selection.
13. Confirm `eax` embedded in comments, strings, or larger identifier-like text is not renamed.
14. Select the numeric block and run `Convert h-Suffix Hex To 0x In Selection`.
15. Confirm values such as `2Ah` and `100h` become `0x2A` and `0x100`.

## Notes

- This is a command-utility lab, not a semantic language-service lab.
- It demonstrates the Level 3 integration tier described in [../../docs/fasmg_langauge_integration.md](../../docs/fasmg_langauge_integration.md).
- Requested features such as scope-aware local-symbol highlighting or unused-label diagnostics still require parser-backed or LSP-backed work.
- The register rename command uses a simple input dialog and validates the register names against a built-in register list.
- The transform logic is intentionally conservative and only edits selected text, not the full document by default.

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
