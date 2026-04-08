# Reference Links

These are the Microsoft docs the repo is aligned to as of `2026-04-08`.

- `Develop code in Visual Studio without projects or solutions`
  - https://learn.microsoft.com/en-us/visualstudio/ide/develop-code-in-visual-studio-without-projects-or-solutions?view=visualstudio
  - Key point: Visual Studio supports opening folders directly and opening `.code-workspace` files for multiple folders.
- `Create build and debug tasks for "Open Folder" development`
  - https://learn.microsoft.com/en-us/visualstudio/ide/customize-build-and-debug-tasks-in-visual-studio?view=visualstudio
  - Key point: `tasks.vs.json`, `launch.vs.json`, `files.exclude`, and settings precedence for Open Folder.
- `Open Folder support for C++ build systems in Visual Studio`
  - https://learn.microsoft.com/en-us/cpp/build/open-folder-projects-cpp?view=msvc-170
  - Key point: `CppProperties.json`, `tasks.vs.json`, `launch.vs.json`, and environment propagation for third-party build systems.
- ``launch.vs.json` schema reference (C++)`
  - https://learn.microsoft.com/en-us/cpp/build/launch-vs-schema-reference-cpp?view=msvc-170
  - Key point: `inheritEnvironments`, debug environment variables, and `program`/`project` settings.
- `Add language-specific syntax support in a Visual Studio extension by using Language Configuration`
  - https://learn.microsoft.com/en-us/visualstudio/extensibility/language-configuration?view=visualstudio
  - Key point: packaging language configuration plus TextMate grammar files through a VSIX.
- `Adding a Language Server Protocol extension`
  - https://learn.microsoft.com/en-us/visualstudio/extensibility/adding-an-lsp-extension?view=vs-2022
  - Key point: TextMate grammar repository registration and workspace settings packaging patterns.
