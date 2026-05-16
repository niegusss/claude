#requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Repo = 'https://github.com/niegusss/claude.git'
$Target = Join-Path $env:USERPROFILE '.claude'

# Items to install. Anything not in this list is ignored.
$InstallItems = @(
    'skills',
    'agents',
    'docs',
    'MANIFEST.md',
    'SKILLS_AND_AGENTS.md',
    'SECURITY.md'
)

# --- Pre-flight: git available? ---
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host 'Error: git is not installed or not in PATH.' -ForegroundColor Red
    Write-Host 'Install git: https://git-scm.com/downloads'
    exit 1
}

# --- Temp dir with cleanup ---
$tempDir = Join-Path $env:TEMP ("claude-install-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

try {
    # --- Clone (shallow, single branch) ---
    # Note: git writes progress to stderr by design. We relax ErrorActionPreference
    # locally so that stderr lines don't abort the script.
    Write-Host 'Fetching latest skills, agents, and docs...' -ForegroundColor White

    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    git clone --depth 1 --single-branch $Repo $tempDir 2>&1 | Out-Host
    $cloneExitCode = $LASTEXITCODE
    $ErrorActionPreference = $previousErrorActionPreference

    if ($cloneExitCode -ne 0) {
        Write-Host ''
        Write-Host "Error: Failed to clone $Repo (exit code $cloneExitCode)" -ForegroundColor Red
        Write-Host ''
        Write-Host 'If this is a private repository, make sure you are authenticated:'
        Write-Host '  - GitHub CLI:        gh auth login'
        Write-Host '  - Git credential:    git credential-manager configure'
        Write-Host '  - HTTPS token:       git config --global credential.helper manager-core'
        exit 1
    }

    # --- Ensure target exists ---
    if (-not (Test-Path $Target)) {
        New-Item -ItemType Directory -Path $Target -Force | Out-Null
    }

    # --- Copy whitelisted items only ---
    $copied = @()
    $missing = @()

    foreach ($name in $InstallItems) {
        $src = Join-Path $tempDir $name
        if (Test-Path $src) {
            Copy-Item -Path $src -Destination $Target -Recurse -Force
            $copied += $name
        } else {
            $missing += $name
        }
    }

    # --- Summary ---
    Write-Host ''
    Write-Host 'Done' -ForegroundColor Green -NoNewline
    Write-Host " - $Target updated."

    if ($copied.Count -gt 0) {
        Write-Host ''
        Write-Host 'Installed:'
        foreach ($name in $copied) {
            $path = Join-Path $Target $name
            if ((Get-Item $path).PSIsContainer) {
                $count = (Get-ChildItem -Path $path -Recurse -File | Measure-Object).Count
                Write-Host "  $name/ ($count files)"
            } else {
                Write-Host "  $name"
            }
        }
    }

    if ($missing.Count -gt 0) {
        Write-Host ''
        Write-Host 'Skipped (not in source):' -ForegroundColor Yellow
        foreach ($name in $missing) {
            Write-Host "  $name"
        }
    }

    Write-Host ''
    Write-Host 'Next:' -ForegroundColor White -NoNewline
    Write-Host ' restart Claude Code so the new skills load.'
    Write-Host 'Usage (Windows):    irm https://raw.githubusercontent.com/niegusss/claude/main/install.ps1 | iex'
    Write-Host 'Usage (mac/linux):  curl -fsSL https://raw.githubusercontent.com/niegusss/claude/main/install.sh | bash'

} finally {
    if (Test-Path $tempDir) {
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
