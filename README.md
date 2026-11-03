# claude-code-blue

Changes the Claude Code extension in VSCodium from Anthropic orange to VSCodium blue (`#0078d4`). It recolors the logo, the mascot, the input border, the send button and the focus ring, then clears VSCodium's webview cache so the new color sticks after a restart.

It is the blue twin of [claude-code-mint](https://github.com/KurtStevenK/claude-code-mint). Only colors change. Every changed file gets a `*.orig` backup.

## Tested with

| Component | Version |
|---|---|
| VSCodium | 1.143.17232 (commit `c072cf642cbbadabefa22f39c58cc902a8b7427f`) |
| Claude Code extension | 2.1.316 (`anthropic.claude-code-2.1.316-win32-x64`) |
| OS | Windows 11 |

Other versions may work. A future Claude Code update installs a new folder, so run the script again after an update.

## Install

Install it with the [skills CLI](https://skills.sh/) (the same one `find-skills` uses):

```bash
npx skills add KurtStevenK/claude-code-blue --skill claude-code-blue
```

Then ask your agent to "make Claude Code blue". The skill tells it when to ask you to close VSCodium, what to run and how to verify.

Without the CLI, copy the folder `skills/claude-code-blue` (it holds `SKILL.md` and the script) to `%USERPROFILE%\.claude\skills\`:

```powershell
Copy-Item .\skills\claude-code-blue "$env:USERPROFILE\.claude\skills\" -Recurse -Force
```

The matching dividers are [claude-code-blue-mega](https://github.com/KurtStevenK/claude-code-blue-mega): blue at rest, mint while resizing.

## Run the script yourself

The script is `skills/claude-code-blue/make-claude-code-blue.ps1`. Run the commands below in that folder.

1. Close VSCodium completely (File → Exit, and check the taskbar).
2. Run it:

   ```powershell
   powershell -ExecutionPolicy Bypass -File ".\make-claude-code-blue.ps1"
   ```

3. Start VSCodium and open the Claude Code panel.

If the script prints `VSCodium is running`, it skipped the cache step. Close VSCodium and run it again.

## Switch between blue and mint

Each script knows the other's color. Run `claude-code-mint` to go back to mint, or `claude-code-blue` to go to blue.

## What it changes

- `webview/index.css`, `webview/index.js` and `resources/*.svg` in every `anthropic.claude-code-*` folder under `%USERPROFILE%\.vscode-oss\extensions` and `%USERPROFILE%\.vscodium\extensions`.
- The auto / bypass-mode focus ring, send button and mode icon, which otherwise use the theme's error color.
- `resources/claude-logo.png`: orange (or mint) pixels recolored, transparency kept.
- `%APPDATA%\VSCodium\User\settings.json`: `workbench.colorCustomizations` with `inputOption.activeBorder` and `focusBorder`. The previous file is saved as `settings.json.bak`.
- Clears VSCodium's `Cache`, `Code Cache`, `GPUCache` and the webview's service-worker cache (only when VSCodium is closed).

## Undo

- Rename each `*.orig` file back to its original name.
- Copy `settings.json.bak` back to `settings.json`.

## Notes

- The Claude Code extension is proprietary (© Anthropic PBC). This only changes your local copy. Nothing is redistributed.
- If a color still looks wrong, open `Developer: Open Webview Developer Tools` in VSCodium, select the element and read the matched rule in the Styles panel.
