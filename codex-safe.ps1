$ErrorActionPreference = "Stop"

function Write-Info($m) { Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Write-Ok($m)   { Write-Host "[ OK ] $m" -ForegroundColor Green }
function Write-Warn($m) { Write-Host "[WARN] $m" -ForegroundColor Yellow }

$projectInput = Read-Host "file path laragon/www"

if ([string]::IsNullOrWhiteSpace($projectInput)) {
    throw "Input tidak boleh kosong."
}

if ([System.IO.Path]::IsPathRooted($projectInput)) {
    $repoPath = $projectInput
}
else {
    $repoPath = Join-Path "C:\laragon\www" $projectInput
}

$repoPath = [System.IO.Path]::GetFullPath($repoPath)

if (-not (Test-Path $repoPath)) {
    throw "Folder repo tidak ditemukan: $repoPath"
}

$gitCheck = & git -C $repoPath rev-parse --is-inside-work-tree 2>$null
if ($LASTEXITCODE -ne 0 -or $gitCheck.Trim() -ne "true") {
    throw "Folder ini bukan repo git: $repoPath"
}

$scriptsDir = "C:\scripts"
$scriptPath = Join-Path $scriptsDir "codex-safe.ps1"
New-Item -ItemType Directory -Path $scriptsDir -Force | Out-Null

$mainScript = @'
param(
    [ValidateSet("run", "check", "cleanup", "watch", "uninstall", "dir")]
    [string]$Mode = "run",

    [string]$RepoPath = "__REPO_PATH__",
    [string]$CodexHome = "C:\codex-temp",
    [int]$WatchIntervalSeconds = 3,
    [string]$CodexArgs = "",
    [switch]$RemoveUserCodexFolder = $true
)

$ErrorActionPreference = "Stop"

function Write-Info($msg) { Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "[ OK ] $msg" -ForegroundColor Green }
function Write-WarnMsg($msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-ErrMsg($msg) { Write-Host "[ERR ] $msg" -ForegroundColor Red }

function Test-CommandExists($cmd) {
    return $null -ne (Get-Command $cmd -ErrorAction SilentlyContinue)
}

function Assert-GitRepo($path) {
    if (-not (Test-Path $path)) {
        throw "Repo path tidak ditemukan: $path"
    }

    Push-Location $path
    try {
        $inside = git rev-parse --is-inside-work-tree 2>$null
        if ($LASTEXITCODE -ne 0 -or $inside.Trim() -ne "true") {
            throw "Folder ini bukan repo git: $path"
        }
    }
    finally {
        Pop-Location
    }
}

function Get-WorktreeLines($path) {
    Push-Location $path
    try {
        $output = git worktree list --porcelain 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "Gagal membaca worktree list."
        }
        return $output
    }
    finally {
        Pop-Location
    }
}

function Get-AllWorktrees($path) {
    $lines = Get-WorktreeLines $path
    $items = @()

    foreach ($line in $lines) {
        if ($line -match '^worktree\s+(.+)$') {
            $items += $Matches[1].Trim()
        }
    }

    return $items
}

function Get-CodexWorktrees($path) {
    $all = Get-AllWorktrees $path
    $codex = @()

    foreach ($wt in $all) {
        if (
            $wt -match '[\\/]\.codex[\\/]worktrees[\\/]' -or
            $wt -match '[\\/]codex-temp[\\/]worktrees[\\/]' -or
            $wt -match '[\\/]Users[\\/][^\\/]+[\\/]\.codex[\\/]worktrees[\\/]' -or
            $wt -like "*\.codex\worktrees\*" -or
            $wt -like "*/.codex/worktrees/*"
        ) {
            $codex += $wt
        }
    }

    return $codex
}

function Get-WorktreeConfigValue($path) {
    Push-Location $path
    try {
        $value = git config --local --get extensions.worktreeconfig 2>$null
        if ($LASTEXITCODE -eq 0) {
            return $value.Trim()
        }
        return ""
    }
    finally {
        Pop-Location
    }
}

function Remove-WorktreeConfigIfNeeded($path) {
    Push-Location $path
    try {
        $value = git config --local --get extensions.worktreeconfig 2>$null
        if ($LASTEXITCODE -eq 0 -and $value) {
            Write-WarnMsg "extensions.worktreeconfig terdeteksi: $value"
            git config --local --unset extensions.worktreeconfig
            if ($LASTEXITCODE -eq 0) {
                Write-Ok "extensions.worktreeconfig berhasil dihapus."
            }
        }
        else {
            Write-Ok "extensions.worktreeconfig tidak ada."
        }
    }
    finally {
        Pop-Location
    }
}

function Remove-CodexWorktrees($path) {
    $codexWorktrees = Get-CodexWorktrees $path

    if ($codexWorktrees.Count -eq 0) {
        Write-Ok "Tidak ada worktree Codex yang aktif."
    }
    else {
        foreach ($wt in $codexWorktrees) {
            Write-Info "Menghapus worktree Codex: $wt"
            Push-Location $path
            try {
                git worktree remove --force "$wt" 2>$null
                if ($LASTEXITCODE -eq 0) {
                    Write-Ok "Worktree dihapus: $wt"
                }
                else {
                    Write-WarnMsg "Gagal hapus via git worktree remove: $wt"
                }
            }
            finally {
                Pop-Location
            }
        }
    }

    Push-Location $path
    try {
        Write-Info "Menjalankan git worktree prune..."
        git worktree prune
        if ($LASTEXITCODE -eq 0) {
            Write-Ok "Prune selesai."
        }
        else {
            Write-WarnMsg "Prune gagal."
        }
    }
    finally {
        Pop-Location
    }
}

function Remove-CodexFolders($codexHome, [switch]$RemoveUserCodexFolder) {
    $targets = @()

    if ($codexHome) {
        $targets += $codexHome
    }

    if ($RemoveUserCodexFolder) {
        $targets += "C:\Users\$env:USERNAME\.codex"
    }

    $targets = $targets | Select-Object -Unique

    foreach ($target in $targets) {
        if ([string]::IsNullOrWhiteSpace($target)) { continue }

        if (Test-Path $target) {
            try {
                Write-Info "Menghapus folder: $target"
                Remove-Item -LiteralPath $target -Recurse -Force -ErrorAction Stop
                Write-Ok "Folder dihapus: $target"
            }
            catch {
                Write-WarnMsg "Gagal hapus folder: $target"
            }
        }
        else {
            Write-Ok "Folder tidak ada: $target"
        }
    }
}

function Show-RepoStatus($path) {
    $allWorktrees = Get-AllWorktrees $path
    $codexWorktrees = Get-CodexWorktrees $path
    $wtConfig = Get-WorktreeConfigValue $path

    Write-Host ""
    Write-Host "===== STATUS REPO =====" -ForegroundColor Magenta
    Write-Host "RepoPath : $path"
    Write-Host "Worktrees:"
    foreach ($wt in $allWorktrees) {
        Write-Host " - $wt"
    }

    if ([string]::IsNullOrWhiteSpace($wtConfig)) {
        Write-Ok "extensions.worktreeconfig: tidak ada"
    }
    else {
        Write-WarnMsg "extensions.worktreeconfig: $wtConfig"
    }

    if ($codexWorktrees.Count -eq 0) {
        Write-Ok "Tidak ada worktree Codex tersisa."
    }
    else {
        Write-WarnMsg "Worktree Codex terdeteksi:"
        foreach ($wt in $codexWorktrees) {
            Write-Host " - $wt" -ForegroundColor Yellow
        }
    }

    if ([string]::IsNullOrWhiteSpace($wtConfig) -and $codexWorktrees.Count -eq 0) {
        Write-Ok "Repo aman untuk Antigravity."
        return $true
    }
    else {
        Write-WarnMsg "Repo belum aman untuk Antigravity."
        return $false
    }
}

function Ensure-CodexHome($codexHome) {
    if (-not (Test-Path $codexHome)) {
        New-Item -Path $codexHome -ItemType Directory -Force | Out-Null
        Write-Ok "Folder CODEX_HOME dibuat: $codexHome"
    }
    $env:CODEX_HOME = $codexHome
    Write-Info "CODEX_HOME = $env:CODEX_HOME"
}

function Start-CodexSafe($path, $codexHome, $codexArgs) {
    if (-not (Test-CommandExists "codex")) {
        throw "Command 'codex' tidak ditemukan di PATH."
    }

    Ensure-CodexHome $codexHome

    Push-Location $path
    try {
        Write-Host ""
        Write-Host "===== MENJALANKAN CODEX =====" -ForegroundColor Magenta
        Write-Info "Repo: $path"

        if ([string]::IsNullOrWhiteSpace($codexArgs)) {
            & codex
        }
        else {
            $argList = $codexArgs -split '\s+'
            & codex @argList
        }

        $exitCode = $LASTEXITCODE
        Write-Info "Codex selesai. Exit code: $exitCode"
    }
    finally {
        Pop-Location
    }

    Write-Host ""
    Write-Host "===== CLEANUP OTOMATIS =====" -ForegroundColor Magenta
    Remove-CodexWorktrees $path
    Remove-WorktreeConfigIfNeeded $path
    [void](Show-RepoStatus $path)
}

function Invoke-CleanupOnly($path) {
    Write-Host ""
    Write-Host "===== CLEANUP REPO =====" -ForegroundColor Magenta
    Remove-CodexWorktrees $path
    Remove-WorktreeConfigIfNeeded $path
    [void](Show-RepoStatus $path)
}

function Start-WatchMode($path, $intervalSeconds) {
    Write-Host ""
    Write-Host "===== WATCH MODE =====" -ForegroundColor Magenta
    Write-Info "Monitoring repo tiap $intervalSeconds detik. Tekan Ctrl+C untuk berhenti."

    $lastFingerprint = ""

    while ($true) {
        try {
            $wtConfig = Get-WorktreeConfigValue $path
            $codexWorktrees = Get-CodexWorktrees $path
            $allWorktrees = Get-AllWorktrees $path

            $fingerprint = (($allWorktrees -join '|') + '||' + $wtConfig)

            if ($fingerprint -ne $lastFingerprint) {
                Clear-Host
                Write-Host "===== WATCH MODE =====" -ForegroundColor Magenta
                Write-Host "Waktu   : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
                Write-Host "Repo    : $path"
                Write-Host ""

                foreach ($wt in $allWorktrees) {
                    Write-Host " - $wt"
                }

                Write-Host ""
                if ([string]::IsNullOrWhiteSpace($wtConfig)) {
                    Write-Ok "extensions.worktreeconfig: tidak ada"
                }
                else {
                    Write-WarnMsg "extensions.worktreeconfig: $wtConfig"
                }

                if ($codexWorktrees.Count -eq 0) {
                    Write-Ok "Tidak ada worktree Codex."
                }
                else {
                    Write-WarnMsg "Worktree Codex terdeteksi:"
                    foreach ($wt in $codexWorktrees) {
                        Write-Host " - $wt" -ForegroundColor Yellow
                    }
                }

                $lastFingerprint = $fingerprint
            }
        }
        catch {
            Write-ErrMsg $_.Exception.Message
        }

        Start-Sleep -Seconds $intervalSeconds
    }
}

function Remove-ProfileAlias {
    $profilePath = $PROFILE
    if (-not (Test-Path $profilePath)) {
        Write-Ok "PowerShell profile belum ada."
        return
    }

    $content = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
    if ($null -eq $content) { $content = "" }

    $pattern = '(?ms)^\s*function\s+codex-safe\s*\{.*?codex-safe\.ps1.*?\}\s*$'
    $newContent = [regex]::Replace($content, $pattern, '').Trim()

    Set-Content -Path $profilePath -Value $newContent -Encoding UTF8
    Write-Ok "Alias codex-safe dihapus dari profile."
}

function Invoke-SelfDestruct {
    $selfPath = $MyInvocation.PSCommandPath
    if (-not $selfPath) {
        Write-WarnMsg "Path script saat ini tidak ditemukan. Self delete dilewati."
        return
    }

    $cleanupScript = @"
Start-Sleep -Seconds 2
try {
    Remove-Item -LiteralPath '$selfPath' -Force -ErrorAction Stop
} catch {}
"@

    $tempFile = Join-Path $env:TEMP ("codex-safe-selfdelete-" + [guid]::NewGuid().ToString() + ".ps1")
    $cleanupScript | Set-Content -Path $tempFile -Encoding UTF8

    Start-Process -WindowStyle Hidden powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$tempFile`""
    Write-Ok "Self destroy dijadwalkan untuk: $selfPath"
}

function Invoke-UpdateDir {
    param([string]$ScriptPath)

    $input = Read-Host "edit www"

    if ([string]::IsNullOrWhiteSpace($input)) {
        throw "Input tidak boleh kosong."
    }

    if ([System.IO.Path]::IsPathRooted($input)) {
        $newPath = $input
    } else {
        $newPath = Join-Path "C:\laragon\www" $input
    }

    $newPath = [System.IO.Path]::GetFullPath($newPath)

    if (-not (Test-Path $newPath)) {
        throw "Folder tidak ditemukan: $newPath"
    }

    $inside = git -C $newPath rev-parse --is-inside-work-tree 2>$null
    if ($LASTEXITCODE -ne 0 -or $inside.Trim() -ne "true") {
        throw "Bukan repo git: $newPath"
    }

    $content = Get-Content $ScriptPath -Raw
    $escaped = $newPath.Replace('\', '\\')
    $content = $content -replace '(?<=\[string\]\$RepoPath = ")[^"]*(?=")', $escaped
    Set-Content -Path $ScriptPath -Value $content -Encoding UTF8

    Write-Ok "RepoPath diupdate ke: $newPath"
}

function Invoke-Uninstall {
    param(
        [string]$Path,
        [string]$CodexHomePath,
        [switch]$RemoveUserCodex
    )

    Write-Host ""
    Write-Host "===== UNINSTALL / FULL CLEANUP =====" -ForegroundColor Magenta

    Remove-CodexWorktrees $Path
    Remove-WorktreeConfigIfNeeded $Path
    Remove-CodexFolders -codexHome $CodexHomePath -RemoveUserCodexFolder:$RemoveUserCodex
    Remove-ProfileAlias
    [void](Show-RepoStatus $Path)
    Invoke-SelfDestruct
}

# MAIN
if (-not (Test-CommandExists "git")) {
    throw "Git tidak ditemukan di PATH."
}

Assert-GitRepo $RepoPath

Write-Host ""
Write-Host "===== CODEX SAFE RUNNER =====" -ForegroundColor Magenta
Write-Info "Mode      = $Mode"
Write-Info "RepoPath  = $RepoPath"
Write-Info "CodexHome = $CodexHome"

switch ($Mode) {
    "run" { Start-CodexSafe -path $RepoPath -codexHome $CodexHome -codexArgs $CodexArgs }
    "check" { [void](Show-RepoStatus $RepoPath) }
    "cleanup" { Invoke-CleanupOnly $RepoPath }
    "watch" { Start-WatchMode -path $RepoPath -intervalSeconds $WatchIntervalSeconds }
    "uninstall" { Invoke-Uninstall -Path $RepoPath -CodexHomePath $CodexHome -RemoveUserCodex:$RemoveUserCodexFolder }
    "dir" { Invoke-UpdateDir -ScriptPath $PSCommandPath }
}
'@

$mainScript = $mainScript.Replace("__REPO_PATH__", $repoPath.Replace('\', '\\'))
$mainScript | Set-Content -Path $scriptPath -Encoding UTF8

if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

$profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
if ($null -eq $profileContent) { $profileContent = "" }

$aliasLine = 'function codex-safe { powershell -ExecutionPolicy Bypass -File "C:\scripts\codex-safe.ps1" @args }'

if ($profileContent -notmatch [regex]::Escape($aliasLine)) {
    Add-Content -Path $PROFILE -Value ""
    Add-Content -Path $PROFILE -Value $aliasLine
    Write-Ok "Alias codex-safe ditambahkan ke PowerShell profile."
}
else {
    Write-Ok "Alias codex-safe sudah ada."
}

Write-Host ""
Write-Ok "Instalasi selesai."
Write-Host "Repo default : $repoPath"
Write-Host "Script       : $scriptPath"
Write-Host ""
Write-Host "Tutup PowerShell lalu buka lagi."
Write-Host "Perintah yang tersedia:"
Write-Host "  codex-safe -Mode check"
Write-Host "  codex-safe -Mode run"
Write-Host "  codex-safe -Mode cleanup"
Write-Host "  codex-safe -Mode watch"
Write-Host "  codex-safe -Mode uninstall"
Write-Host "  codex-safe -Mode dir"