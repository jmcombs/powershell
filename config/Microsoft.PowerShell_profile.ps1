# PowerShell Profile for Enhanced Container Experience
# Inspired by Scott Hanselman's Ultimate PowerShell Prompt

# Prevent recursive loading
if ($Global:OhMyPoshProfileLoaded) { return }
$Global:OhMyPoshProfileLoaded = $true

# Performance: Suppress errors during module loading
$ErrorActionPreference = 'SilentlyContinue'

# Import pre-installed modules (installed during Docker build)
# Terminal-Icons: Provides file/folder icons in terminal listings
# PSReadLine: Enhanced command-line editing experience with predictive IntelliSense
Import-Module Terminal-Icons -ErrorAction SilentlyContinue
Import-Module PSReadLine -ErrorAction SilentlyContinue

# Configure PSReadLine for enhanced experience (if available)
if (Get-Module PSReadLine) {
    Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
    Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction SilentlyContinue
}

# Oh My Posh initialization with environment variable support
# Environment Variables:
#   ENABLE_OHMYPOSH - Set to 'false' or '0' to disable Oh My Posh
#   OHMYPOSH_THEME  - Theme name (e.g., 'atomic') or URL to custom theme
#                     If empty, uses embedded Blue PSL 10K theme

# Initialize Oh My Posh (unless disabled)
if ($env:ENABLE_OHMYPOSH -ne 'false' -and $env:ENABLE_OHMYPOSH -ne '0') {
    $ohmyposhPath = '/usr/local/bin/oh-my-posh'
    $embeddedTheme = '/home/coder/.config/powershell/blue-psl-10k.omp.json'

    if (Test-Path $ohmyposhPath) {
        $themeConfig = $embeddedTheme

        # Determine theme configuration based on OHMYPOSH_THEME environment variable
        if ($env:OHMYPOSH_THEME) {
            if ($env:OHMYPOSH_THEME -match '^https?://') {
                # Full URL provided - use as-is
                $themeConfig = $env:OHMYPOSH_THEME
            } else {
                # Theme name provided - construct URL to Oh My Posh built-in themes
                $themeConfig = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/$($env:OHMYPOSH_THEME).omp.json"
            }
        }

        # Try to initialize Oh My Posh with selected theme
        try {
            $initScript = & $ohmyposhPath init pwsh --config $themeConfig 2>&1
            if ($initScript -and $LASTEXITCODE -eq 0) {
                Invoke-Expression $initScript
            } elseif ($themeConfig -ne $embeddedTheme -and (Test-Path $embeddedTheme)) {
                # Fallback to embedded theme if custom theme failed
                $initScript = & $ohmyposhPath init pwsh --config $embeddedTheme 2>&1
                if ($initScript -and $LASTEXITCODE -eq 0) {
                    Invoke-Expression $initScript
                }
            }
        } catch {
            # Silent failure - Oh My Posh initialization failed, continue with basic prompt
        }
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

# Automatically show container info for interactive sessions (can be disabled via SHOW_CONTAINER_INFO env var)
if ($Host.Name -eq 'ConsoleHost' -and $env:SHOW_CONTAINER_INFO -ne 'false' -and $env:SHOW_CONTAINER_INFO -ne '0') {
    Show-ContainerInfo
}

# Reset error preference
$ErrorActionPreference = 'Continue'
