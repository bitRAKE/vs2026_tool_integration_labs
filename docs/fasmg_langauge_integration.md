# FASMG Language Integration Levels

This note describes the practical levels of `fasmg` language integration in Visual Studio 2026, moving from lightweight editor support to full semantic tooling.

The current repo already proves the lower layers:

- [Example 07](../examples/07-fasm-textmate-vsix/README.md) shows TextMate plus Language Configuration support for `.fasm` and `.finc`.
- [Example 08](../examples/08-open-folder-fasm-profiles/README.md) shows schema-backed configuration for the toolchain around the language.

The question here is what comes after syntax highlighting, and what each step can realistically afford.

## Integration Ladder

### Level 1: File Identity, TextMate, and Language Configuration

What this includes:

- file extension registration
- TextMate grammar scopes
- comment toggling
- bracket matching
- auto-closing and surrounding pairs
- `wordPattern`, indentation rules, and snippets

What it is good at:

- fast lexical highlighting
- making directives, strings, numbers, labels, and comments readable
- lightweight editing ergonomics

What it is not good at:

- true symbol understanding
- cross-reference features
- diagnostics such as "unused label"
- semantics-aware rename

`fasmg` features possible here:

- richer highlighting for directives, operators, built-ins, registers, labels, and macro forms
- approximate highlighting for local symbols inside `macro` or `calminstruction` regions if they can be recognized lexically
- snippets for common `fasmg` patterns

`fasmg` features not reliable here:

- distinguishing a local symbol because it is truly local rather than merely text-shaped
- proving whether a label is unused
- rename of any symbol-like construct

Assessment:

- this is the right layer for "make code readable"
- it is not the right layer for "understand code"

### Level 2: Parser-Backed Classification and Structural Editor Features

What this includes:

- a real parser or structural analyzer for `fasmg`
- scope tracking for macros, `calminstruction`, labels, blocks, and includes
- custom classification/tagging in the editor
- outlining or structure-aware navigation

What it is good at:

- context-sensitive highlighting
- distinguishing the same token differently based on scope
- editor structure features that need more than regex-style matching

What it is not yet:

- a full language server by itself
- necessarily cross-file navigation or diagnostics unless extra analysis is added

`fasmg` features possible here:

- different highlighting for local symbols inside `macro` and `calminstruction`
- distinct treatment for local labels versus global labels
- region folding for macro or `calminstruction` bodies
- more reliable classification of directive-like tokens that are ambiguous lexically

Assessment:

- this is the first layer where the local-symbol highlighting request can be done well
- it likely depends on a reusable analysis core, not just more grammar work

### Level 3: VSIX Commands and Refactoring Utilities

What this includes:

- commands in editor or context menus
- selection-scoped edits
- one-shot transforms
- previews or utility dialogs

What it is good at:

- focused editing actions that do not need a full always-on language service
- operations the user invokes explicitly

What it is not best at:

- continuous diagnostics
- background semantic model maintenance

`fasmg` features possible here:

- rename register within a selection
- normalize register casing within a selection or document
- convert numeric literal style in a selection
- expand a macro invocation into a preview buffer
- open generated listing, dump symbols, or inspect active output

Assessment:

- "rename register within a selection" fits this layer very well
- it is more of a targeted editor utility than a classic language-service rename

### Level 4: LSP-Based Semantic Language Features

What this includes:

- diagnostics
- completion
- hover
- signature help
- definitions and references
- document/workspace symbols
- rename
- formatting
- code actions

What it is good at:

- background semantic understanding
- cross-file analysis
- a consistent language tooling model across editors

What it needs:

- a real parse/bind/analyze pipeline
- stable symbol identity across includes, macros, and generated scopes
- a strategy for how `fasmg` expansion affects source-facing features

`fasmg` features possible here:

- flag unused labels
- go to definition for labels, macros, and included files
- find references for labels and macro names
- document outline for labels, macros, namespaces, and `calminstruction`
- hover for directive meaning, numeric interpretation, or symbol origin
- completion for directives, known built-ins, and workspace symbols
- semantic rename for actual symbols where identity is well defined

`fasmg` caveat:

- rename of registers is usually not a semantic-symbol feature; registers are language-defined tokens, so selection-scoped command behavior is often a better fit than LSP rename

Assessment:

- "flag unused labels" belongs here or higher
- this is the main path for turning `fasmg` support into a real language experience

### Level 5: Native Visual Studio Editor Extensions

What this includes:

- custom taggers and classifiers
- custom QuickInfo or adornments
- custom margins, glyphs, and inline UI
- editor behaviors that go beyond standard LSP affordances

What it is good at:

- highly tailored Visual Studio experiences
- features that are awkward or impossible to express through standard LSP messages

What it costs:

- the most Visual Studio-specific implementation work
- less portability to other editors

`fasmg` features possible here:

- inline expansion or provenance views for macro-generated constructs
- custom glyphs for unresolved or shadowed labels
- editor-only visualizations for local/global symbol boundaries
- special highlighting overlays for selected expansion scopes

Assessment:

- use this when LSP and commands are no longer enough
- this should follow, not precede, a reusable semantic core

### Level 6: Project-System and Property-Page Integration

This is mostly outside language support proper, but it is worth naming because it often gets confused with language integration.

What this includes:

- property pages
- project capabilities
- project-level settings UI

What it is good at:

- build and configuration management
- target-level settings

What it does not solve by itself:

- symbol analysis
- rename
- diagnostics
- semantic highlighting

Assessment:

- useful for toolchain integration
- not the next move for better `fasmg` language support

## Feature-to-Level Mapping

| Desired feature | Lowest reasonable level | Best-fit level | Notes |
| --- | --- | --- | --- |
| Different highlighting for local symbols in `macro` / `calminstruction` | Level 1 with approximation | Level 2 | TextMate can fake some cases, but real scope-aware highlighting needs parsing. |
| Rename register within a selection | Level 3 | Level 3 | This is a user-invoked transform, not really a semantic rename problem. |
| Flag unused labels | Level 4 | Level 4 | Requires reference analysis and diagnostics. |
| Go to definition for labels/macros | Level 4 | Level 4 | Needs symbol identity and file/scope awareness. |
| Outline of labels/macros/`calminstruction` | Level 4 | Level 4 | Could start in Level 2 structurally, but LSP document symbols are the better long-term fit. |
| Snippets for `macro`, `calminstruction`, `match`, `virtual`, `format` | Level 1 | Level 1 | Cheap and high value. |
| Folding for macro / `calminstruction` bodies | Level 2 | Level 2 | Structural parsing gives more reliable boundaries than lexical rules. |
| Unresolved include or symbol diagnostics | Level 4 | Level 4 | Best surfaced as diagnostics. |

## Recommended Roadmap

### Near term

- continue improving TextMate and Language Configuration
- add `fasmg` snippets
- add a few command-style editing utilities

Why:

- low implementation risk
- immediate editing benefit
- no need to finish a full semantic engine first

### Mid term

- build a reusable `fasmg` analysis core that can parse enough structure to understand scopes, labels, macros, and includes
- use that core first for targeted features such as scope-aware highlighting and document structure

Why:

- both commands and LSP features will depend on this anyway
- it prevents IDE features from becoming a pile of regexes

### Long term

- expose the semantic core through LSP for diagnostics, symbols, definitions, references, and code actions
- add Visual Studio-specific editor features only where LSP is insufficient

Why:

- this gives the highest feature ceiling
- it keeps the semantic investment portable

## Recommendation for the Next Labs

1. Add more editor affordances that stay cheap:
   - snippets
   - a few more language-configuration improvements
   - grammar refinements where they are clearly lexical
2. Add command-style utilities:
   - rename register within selection
   - numeric-style conversion in selection
   - macro expansion or listing preview
3. Start a semantic-core experiment aimed at:
   - local symbol classification in `macro` / `calminstruction`
   - unused-label detection
   - document symbol extraction

That sequence keeps the repo aligned with the existing Open Folder and VSIX work while building toward the features that actually require language understanding.
