# Recolors the Claude Code extension in VSCodium to blue (VSCodium focus blue).
# Safe to run again after a Claude Code update (it patches the newest installed version).
# Originals are kept as *.orig next to each changed file.
# Close VSCodium before running, so the webview cache can be cleared.

$green = "#0078d4"            # the new color (variable name kept from claude-code-mint)
$greenRgb = @(0, 120, 212)
$oldColors = @("#2ec767", "#d97757", "#3eb489", "#c6613f", "#2ecc71", "#00ff00", "#1fda45")

# ---- 1. find the Claude Code extension folders (newest version per install dir)
$roots = @("$env:USERPROFILE\.vscode-oss\extensions", "$env:USERPROFILE\.vscodium\extensions")
$exts = foreach ($r in $roots) {
    if (Test-Path $r) {
        Get-ChildItem $r -Directory -Filter "anthropic.claude-code-*" -ErrorAction SilentlyContinue
    }
}
if (-not $exts) {
    Write-Host "No Claude Code extension found in VSCodium extension folders." -ForegroundColor Red
    exit 1
}

foreach ($ext in $exts) {
    Write-Host "Patching $($ext.FullName)" -ForegroundColor Cyan

    # ---- 2. CSS and JS colors
    $files = @(
        "$($ext.FullName)\webview\index.css",
        "$($ext.FullName)\webview\index.js"
    ) + (Get-ChildItem "$($ext.FullName)\resources" -Filter *.svg -ErrorAction SilentlyContinue | ForEach-Object FullName)

    foreach ($f in $files) {
        if (-not (Test-Path $f)) { continue }
        if (-not (Test-Path "$f.orig")) { Copy-Item $f "$f.orig" }
        $text = [System.IO.File]::ReadAllText($f)
        $new = $text
        foreach ($old in $oldColors) {
            $new = [System.Text.RegularExpressions.Regex]::Replace($new, [regex]::Escape($old), $green, 'IgnoreCase')
        }
        # auto / bypass permission mode: focus ring, send button and icon used the theme error color
        $new = $new.Replace(
            '.inputContainer_cKsPxg[data-permission-mode=bypassPermissions]:focus-within,.inputContainer_cKsPxg[data-permission-mode=auto]:focus-within{--focus-ring-color:var(--app-error-foreground)}',
            '.inputContainer_cKsPxg[data-permission-mode=bypassPermissions]:focus-within,.inputContainer_cKsPxg[data-permission-mode=auto]:focus-within{--focus-ring-color:var(--app-claude-orange)}')
        $new = $new.Replace(
            '.sendButton_gGYT1w[data-permission-mode=auto]{color:var(--app-button-foreground);background-color:var(--app-error-foreground)}',
            '.sendButton_gGYT1w[data-permission-mode=auto]{color:var(--app-button-foreground);background-color:var(--app-claude-orange)}')
        $new = $new.Replace(
            '.container_hc5dvw[data-permission-mode=auto] .icon_hc5dvw{color:var(--app-error-foreground)}',
            '.container_hc5dvw[data-permission-mode=auto] .icon_hc5dvw{color:var(--app-claude-orange)}')
        if ($new -ne $text) {
            [System.IO.File]::WriteAllText($f, $new)
            Write-Host "  updated $(Split-Path $f -Leaf)"
        }
    }

    # ---- 3. tab / header PNG (recolor the orange pixels, keep transparency)
    $png = "$($ext.FullName)\resources\claude-logo.png"
    if (Test-Path $png) {
        if (-not (Test-Path "$png.orig")) { Copy-Item $png "$png.orig" }
        Add-Type -AssemblyName System.Drawing
        $src = [System.Drawing.Bitmap]::FromFile($png)
        $w = $src.Width; $h = $src.Height
        $out = New-Object System.Drawing.Bitmap $w, $h
        for ($x = 0; $x -lt $w; $x++) {
            for ($y = 0; $y -lt $h; $y++) {
                $c = $src.GetPixel($x, $y)
                $isOrange = $c.A -gt 0 -and $c.R -gt ($c.B + 40) -and $c.R -gt $c.G
                $isMint = $c.A -gt 0 -and $c.G -gt ($c.R + 40) -and $c.G -gt ($c.B + 20)
                if ($isOrange -or $isMint) {
                    $out.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($c.A, $greenRgb[0], $greenRgb[1], $greenRgb[2]))
                } else { $out.SetPixel($x, $y, $c) }
            }
        }
        $src.Dispose()
        $tmp = "$png.tmp.png"
        $out.Save($tmp, [System.Drawing.Imaging.ImageFormat]::Png)
        $out.Dispose()
        Move-Item -Force $tmp $png
        Write-Host "  updated claude-logo.png"
    }
}

# ---- 4. theme colors for the input border (VSCodium user settings)
$settingsPath = "$env:APPDATA\VSCodium\User\settings.json"
$snippet = @"
"workbench.colorCustomizations": {
    "inputOption.activeBorder": "$green",
    "focusBorder": "$green"
}
"@
if (Test-Path $settingsPath) {
    try {
        $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
        $cc = [ordered]@{ "inputOption.activeBorder" = $green; "focusBorder" = $green }
        if ($settings.'workbench.colorCustomizations') {
            foreach ($k in $settings.'workbench.colorCustomizations'.PSObject.Properties.Name) { $cc[$k] = $settings.'workbench.colorCustomizations'.$k }
            $cc["inputOption.activeBorder"] = $green; $cc["focusBorder"] = $green
        }
        $settings | Add-Member -NotePropertyName 'workbench.colorCustomizations' -NotePropertyValue $cc -Force
        Copy-Item $settingsPath "$settingsPath.bak" -Force
        $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Encoding utf8
        Write-Host "settings.json updated (backup: settings.json.bak)"
    } catch {
        Write-Host "Could not edit settings.json automatically (it may contain comments). Add this manually:" -ForegroundColor Yellow
        Write-Host $snippet
    }
} else {
    Write-Host "No settings.json at $settingsPath. Create it with:" -ForegroundColor Yellow
    Write-Host "{ $snippet }"
}

# ---- 5. clear the webview cache (only if VSCodium is closed)
if (Get-Process -Name VSCodium -ErrorAction SilentlyContinue) {
    Write-Host "VSCodium is running: close it, then run this script again to clear the cache." -ForegroundColor Yellow
} else {
    $base = "$env:APPDATA\VSCodium"
    foreach ($d in 'Cache', 'Code Cache', 'GPUCache') { Remove-Item -Recurse -Force (Join-Path $base $d) -ErrorAction SilentlyContinue }
    Remove-Item -Recurse -Force "$base\WebStorage\7\CacheStorage", "$base\WebStorage\7\ScriptCache" -ErrorAction SilentlyContinue
    Write-Host "Cache cleared." -ForegroundColor Green
}

Write-Host "Done. Start VSCodium and check the Claude Code panel." -ForegroundColor Green
