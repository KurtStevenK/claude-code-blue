---
name: claude-code-blue
description: Recolor the Claude Code extension in VSCodium from Anthropic orange to VSCodium blue (logo, mascot, input border, send button, focus ring), then clear the webview cache and restart. Use when the user asks to make Claude Code blue, match it to the VSCodium blue, undo the orange or the mint, or fix it turning back to orange after a restart or an extension update.
---

# claude-code-blue

Recolors the Claude Code VSCodium extension to VSCodium blue (`#0078d4`). It is the blue twin of `claude-code-mint`. Only colors change. Originals are kept as `*.orig` next to each file, and the settings file is backed up as `settings.json.bak`.

## Tested with

- VSCodium **1.143.17232** (commit `c072cf642cbbadabefa22f39c58cc902a8b7427f`)
- Claude Code extension **2.1.316** (`anthropic.claude-code-2.1.316-win32-x64`), Windows

Other versions may work. The script looks for `anthropic.claude-code-*` folders, so it also patches newer versions, but a future version can change its CSS, so check the result after an update.

## What to do

1. **Color.** The default is VSCodium blue. For another blue, edit the top of `make-claude-code-blue.ps1` in this skill folder:
   ```powershell
   $green = "#0078d4"           # the new color (the variable name is kept from claude-code-mint)
   $greenRgb = @(0, 120, 212)   # the same color as RGB, used for the PNG logo
   ```
   Add the previous value to `$oldColors` so a re-run replaces it. Orange and the mint of `claude-code-mint` (`#2ec767`) are already in the list, so switching from mint to blue works.
2. **Ask the user to close VSCodium completely** (File → Exit, and check the taskbar). Do not kill it yourself unless the user says so. If VSCodium is still running, the script skips the cache step and the old color comes back after a restart.
3. **Run the script** from this skill folder:
   ```powershell
   powershell -ExecutionPolicy Bypass -File ".\make-claude-code-blue.ps1"
   ```
   The script:
   - patches `webview/index.css`, `webview/index.js` and the SVGs in `resources/` of every `anthropic.claude-code-*` folder under `%USERPROFILE%\.vscode-oss\extensions` and `%USERPROFILE%\.vscodium\extensions`;
   - changes the auto / bypass-mode focus ring, send button and mode icon, which otherwise use the theme's error color;
   - recolors the orange (or mint) pixels in `resources/claude-logo.png`;
   - sets `workbench.colorCustomizations` (`inputOption.activeBorder`, `focusBorder`) in `%APPDATA%\VSCodium\User\settings.json`;
   - clears the webview cache when VSCodium is closed.
4. **Restart VSCodium** and ask the user to check the logo, the mascot, the input border (click into it) and the send button.
5. **Report the result.** Say whether the script printed `Cache cleared.`. If it printed `VSCodium is running`, tell the user to close VSCodium and run the script again.

## Back to mint

Run `claude-code-mint`. It knows the blue and replaces it.

## Undo

Rename each `*.orig` file back to its original name in the extension's `webview` and `resources` folders, and copy `settings.json.bak` back to `settings.json`.

## Notes

- Re-run the script after every Claude Code update, because the update installs a new folder without the changes.
- Pairs with `claude-code-blue-mega` (blue dividers, mint while resizing).
- The extension is proprietary (© Anthropic PBC). These are local edits to your own copy only.
