# PowerShell Profile for Enhanced Container Experience
# Inspired by Scott Hanselman's Ultimate PowerShell Prompt

# Prevent recursive loading
if ($Global:OhMyPoshProfileLoaded) { return }
$Global:OhMyPoshProfileLoaded = $true

# Performance: Only load modules if they're available
$ErrorActionPreference = 'SilentlyContinue'

# Oh My Posh initialization with environment variable support
# Environment Variables:
#   ENABLE_OHMYPOSH - Set to 'false' or '0' to disable Oh My Posh
#   OHMYPOSH_THEME  - Theme name (e.g., 'atomic') or URL to custom theme
#                     If empty, uses embedded Blue PSL 10K theme

# Check if Oh My Posh is disabled via environment variable
if ($env:ENABLE_OHMYPOSH -eq 'false' -or $env:ENABLE_OHMYPOSH -eq '0') {
    Write-Host "ℹ️  Oh My Posh disabled via ENABLE_OHMYPOSH environment variable" -ForegroundColor Cyan
} else {
    $ohmyposhPath = '/usr/local/bin/oh-my-posh'
    $embeddedTheme = '/home/coder/.config/powershell/ohmyposh-container.json'

    if (Test-Path $ohmyposhPath) {
        $themeConfig = $null
        $themeName = 'Blue PSL 10K (embedded)'
        $isFallback = $false

        # Determine theme configuration based on OHMYPOSH_THEME environment variable
        if ($env:OHMYPOSH_THEME) {
            if ($env:OHMYPOSH_THEME -match '^https?://') {
                # Full URL provided - use as-is
                $themeConfig = $env:OHMYPOSH_THEME
                $themeName = 'Custom URL theme'
            } else {
                # Theme name provided - construct URL to Oh My Posh built-in themes
                $themeConfig = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/$($env:OHMYPOSH_THEME).omp.json"
                $themeName = "$($env:OHMYPOSH_THEME) (built-in)"
            }
        } else {
            # Default: Use embedded Blue PSL 10K theme (works offline)
            $themeConfig = $embeddedTheme
        }

        # Try to initialize Oh My Posh with selected theme
        $initSuccess = $false
        try {
            $initScript = & $ohmyposhPath init pwsh --config $themeConfig 2>&1
            if ($initScript -and $LASTEXITCODE -eq 0) {
                Invoke-Expression $initScript
                $initSuccess = $true
                Write-Host "✅ Oh My Posh loaded: $themeName" -ForegroundColor Green
            } else {
                throw "Init script failed or empty"
            }
        } catch {
            # Fallback to embedded Blue PSL 10K theme if custom theme failed
            if ($themeConfig -ne $embeddedTheme -and (Test-Path $embeddedTheme)) {
                Write-Host "⚠️  Theme '$themeName' failed, falling back to Blue PSL 10K..." -ForegroundColor Yellow
                try {
                    $initScript = & $ohmyposhPath init pwsh --config $embeddedTheme 2>&1
                    if ($initScript -and $LASTEXITCODE -eq 0) {
                        Invoke-Expression $initScript
                        $initSuccess = $true
                        $isFallback = $true
                        Write-Host "✅ Oh My Posh loaded: Blue PSL 10K (fallback)" -ForegroundColor Green
                    }
                } catch {
                    # Fallback failed too
                }
            }

            if (-not $initSuccess) {
                Write-Host "⚠️  Oh My Posh initialization failed: $($_.Exception.Message)" -ForegroundColor Yellow
                Write-Host "   Using basic PowerShell prompt" -ForegroundColor Gray
            }
        }
    } else {
        Write-Host "⚠️  Oh My Posh not found at $ohmyposhPath, using basic prompt" -ForegroundColor Yellow
    }
}

# Container-specific information function
function Show-ContainerInfo {
    Write-Host "`n🐳 PowerShell Container Information:" -ForegroundColor Cyan
    Write-Host "   PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor White
    Write-Host "   .NET Version: $([System.Runtime.InteropServices.RuntimeInformation]::FrameworkDescription)" -ForegroundColor White
    Write-Host "   OS: $([System.Runtime.InteropServices.RuntimeInformation]::OSDescription)" -ForegroundColor White
    Write-Host "   Architecture: $([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture)" -ForegroundColor White
    Write-Host "   Working Directory: $(Get-Location)" -ForegroundColor White

    # Show Git info if in a Git repository
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $gitBranch = git branch --show-current 2>$null
        if ($gitBranch) {
            Write-Host "   Git Branch: $gitBranch" -ForegroundColor White
        }
    }
    Write-Host ""
}

# Alias for container info
Set-Alias -Name info -Value Show-ContainerInfo

# Welcome message (only show once)
if (-not $Global:OhMyPoshWelcomeShown) {
    $Global:OhMyPoshWelcomeShown = $true
    Write-Host "`n🚀 Enhanced PowerShell Container Ready!" -ForegroundColor Green
    Write-Host "   Type 'info' to see container details" -ForegroundColor Gray
    Write-Host "   Environment variables: ENABLE_OHMYPOSH, OHMYPOSH_THEME" -ForegroundColor Gray
}

# Reset error preference
$ErrorActionPreference = 'Continue'
