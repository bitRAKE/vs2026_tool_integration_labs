# Example 06: Open Folder FASM2 Build Integration

This lab uses the real `fasm2.cmd` frontend to assemble checked-in `.fasm` and `.finc` sources from Open Folder tasks in Visual Studio 2026.

## What This Example Covers

- folder-level build and clean tasks for a real external assembler
- file-level syntax-check tasks for `.fasm` and `.finc`
- environment override support with `FASM2_PATH` and `FASMG_PATH`
- checked-in sample sources that also feed the real syntax-highlighting VSIX in Example 07

## Tool Resolution

The scripts resolve tools in this order:

1. `FASM2_PATH`
2. default local path `C:\git\~tgrysztar\fasm2\fasm2.cmd`

For diagnostics and direct `fasmg` fallback, they also resolve:

1. `FASMG_PATH`
2. sibling `fasmg.exe` next to the resolved `fasm2.cmd`
3. default local path `C:\git\~tgrysztar\fasmg\core\fasmg.exe`

If you want to pin a specific checkout before starting Visual Studio, set:

```powershell
$env:FASM2_PATH = 'C:\path\to\fasm2.cmd'
$env:FASMG_PATH = 'C:\path\to\fasmg.exe'
```

## Open In Visual Studio

Open the folder [examples/06-open-folder-fasm2-build](.).

## Manual Validation

1. Open the folder with `File > Open > Folder`.
2. Right-click the folder background or root node and confirm these tasks appear:
   - `Build`
   - `Clean`
   - `Run Inspect FASM Output`
3. Run `Build` and confirm [out/hello.com](out/hello.com) appears.
4. Run `Run Inspect FASM Output` and confirm it reports:
   - the output path
   - the output size
   - the resolved `fasm2` and `fasmg` paths
5. Right-click [src/hello.fasm](src/hello.fasm) and run `Run Syntax Check FASM Source`.
6. Right-click [src/showcase.finc](src/showcase.finc) and run `Run Syntax Check FASM Include`.
7. Right-click [src/broken-quote.fasm](src/broken-quote.fasm) and run `Run Syntax Check FASM Source`.
8. Confirm the broken file fails with a syntax error instead of producing output.

## Notes

- The build task produces a DOS `.com` file only as a simple success signal for the external tool integration.
- The syntax-check task uses `nul` as the output target so it can validate parser failures without keeping a build artifact.
- The `Run ` prefix on custom tasks is expected Visual Studio presentation.
- [src/restartout-demo.fasm](src/restartout-demo.fasm) exists mainly as a real highlighting sample for the `restartout` keyword used by Example 07.

## Local Preflight

Run:

```powershell
pwsh -File .\tests\validate.ps1
```
