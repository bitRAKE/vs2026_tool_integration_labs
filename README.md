# Visual Studio 2026 Integration Exploration Repo

This repo is a lab set for validating how `Visual Studio Community 2026 (18.x)` behaves with:

- advanced Open Folder and workspace setups
- external build tool integrations
- DSL authoring and syntax-highlighting packaging

Each example lives in its own folder, includes its own `README.md`, and has a `tests/validate.ps1` preflight script. The local scripts validate file shapes and runnable paths; the Visual Studio steps validate the IDE behavior we care about.

The first five examples establish the foundation behavior. Examples 06 and 07 pivot that foundation into a real `fasm2`/`fasmg` workflow with checked-in sample sources and a real VSIX for `.fasm` and `.finc`. Example 08 starts the next tier by moving real tool configuration into a schema-backed profile file. Example 09 adds the first command-style editor utilities on top of that language foundation. Example 10 starts the native parser-core and LSP track with a buildable bootstrap parser, Tree-sitter-aligned parse-tree semantics, a synced `tree-sitter-fasmg` workspace scaffold, managed smoke-test harness, regression checks against the local `fasmg_syntax` resources, and first-pass symbol lifecycle tracking for `restore` / `purge`.

## UI Notes

- In Open Folder mode, the text in `tasks.vs.json` is not always the exact text shown in the Solution Explorer context menu.
- Built-in `contextType` values such as `build`, `clean`, and `rebuild` are often rendered by Visual Studio as stock commands like `Build`, `Clean`, and `Rebuild`.
- Custom tasks commonly appear with a `Run ` prefix in the menu even when the JSON task name does not include that word.
- The example READMEs call out the menu text we have actually observed so far. Prefer the README wording over the raw JSON label when they differ.

## Quick Start

1. Run the repo preflight:

   ```powershell
   pwsh -File .\scripts\Invoke-Validation.ps1
   ```

2. Pick one example and follow its `README.md`.
3. Report back with:
   - which example you tested
   - the exact Visual Studio 2026 build you used
   - what matched the README
   - what diverged from the README
   - screenshots or copied Output-window text when relevant

## Examples/

| Example | Focus | Primary Visual Studio surface |
| --- | --- | --- |
| `01-open-folder-multi-root` | `.code-workspace`, multi-folder views, folder-local tasks, `.vscode/settings.json` | `Workspace` |
| `02-open-folder-cpp-environments` | `CppProperties.json`, environment inheritance, build/debug JSON for C++ Open Folder | `Folder` |
| `03-external-build-ninja` | `tasks.vs.json` driving `ninja` instead of a solution/project system | `Folder` |
| `04-external-build-dsl-pipeline` | custom DSL compiler script plus Open Folder build/preview tasks | `Folder` |
| `05-dsl-textmate-vsix` | VSIX packaging for TextMate grammar + Language Configuration | `Project`/`Folder` |
| `06-open-folder-fasm2-build` | real `fasm2.cmd` build and syntax-check tasks with environment overrides | `Folder` |
| `07-fasm-textmate-vsix` | real `.fasm` and `.finc` VSIX highlighting package | `Project`/`Folder` |
| `08-open-folder-fasm-profiles` | schema-backed JSON profiles for real `fasm2`/`fasmg` build, syntax, and inspect tasks | `Folder` |
| `09-vsix-fasmg-selection-commands` | selection-scoped VSIX commands for register rename, register casing, and hex literal conversion | `Project`/`Folder` |

## Assumptions

- The examples were shaped against the current local install:
  - `Visual Studio Community 2026`
  - `18.4.3`
- Native C++ and Visual Studio extension workloads are assumed to exist for the C++ and VSIX labs.
- The DSL examples intentionally use a fake `.vsfdsl` language so we can change the grammar and pipeline freely.
- The real `fasm` examples assume the current local defaults unless overridden:
  - `FASM2_PATH`
  - `FASMG_PATH`

## Docs

Official references used to shape this repo are listed in [docs/reference-links.md](docs/reference-links.md).

Use [docs/report-template.md](docs/report-template.md) when you send results back.
