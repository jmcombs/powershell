# PowerShell Profile for Enhanced Container Experience
# Inspired by Scott Hanselman's Ultimate PowerShell Prompt
# https://www.hanselman.com/blog/my-ultimate-powershell-prompt-with-oh-my-posh-and-the-windows-terminal

# Performance: Only load modules if they're available
$ErrorActionPreference = 'SilentlyContinue'

# Check if modules need to be installed
$moduleInstallScript = '/home/coder/install-modules.sh'
if ((Test-Path $moduleInstallScript) -and -not (Get-Module -ListAvailable -Name Terminal-Icons)) {
    Write-Host "🔄 Installing PowerShell modules for enhanced experience..." -ForegroundColor Yellow
    & bash $moduleInstallScript
    Remove-Item $moduleInstallScript -Force -ErrorAction SilentlyContinue
}

# Import Terminal-Icons for colorized directory listings
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module -Name Terminal-Icons
    Write-Host "✅ Terminal-Icons loaded" -ForegroundColor Green
} else {
    Write-Host "⚠️  Terminal-Icons not available - install with: Install-Module Terminal-Icons" -ForegroundColor Yellow
}

# Enhanced PSReadLine configuration
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine
    
    # Set PSReadLine options for better experience
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineOption -BellStyle None
    
    # Key bindings for common operations
    Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteChar
    Set-PSReadLineKeyHandler -Key Ctrl+w -Function BackwardDeleteWord
    Set-PSReadLineKeyHandler -Key Alt+d -Function DeleteWord
    Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow -Function BackwardWord
    Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord
    
    # Custom key binding for dotnet build (Ctrl+Shift+B)
    Set-PSReadLineKeyHandler -Key Ctrl+Shift+b -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert('dotnet build')
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
    
    Write-Host "✅ PSReadLine configured with enhanced features" -ForegroundColor Green
} else {
    Write-Host "⚠️  PSReadLine not available - install with: Install-Module PSReadLine -AllowPrerelease" -ForegroundColor Yellow
}

# Oh My Posh initialization
$ohmyposhPath = '/usr/local/bin/oh-my-posh'
if (Test-Path $ohmyposhPath) {
    # Use a container-optimized theme
    $configPath = '/home/coder/.config/powershell/ohmyposh-container.json'
    
    if (Test-Path $configPath) {
        # Use custom container theme
        & $ohmyposhPath init pwsh --config $configPath | Invoke-Expression
        Write-Host "✅ Oh My Posh loaded with container theme" -ForegroundColor Green
    } else {
        # Fallback to a built-in theme that works well in containers
        & $ohmyposhPath init pwsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/atomic.omp.json' | Invoke-Expression
        Write-Host "✅ Oh My Posh loaded with atomic theme" -ForegroundColor Green
    }
} else {
    Write-Host "⚠️  Oh My Posh not found, using default prompt" -ForegroundColor Yellow
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

# Welcome message
Write-Host "`n🚀 Enhanced PowerShell Container Ready!" -ForegroundColor Green
Write-Host "   Type 'info' to see container details" -ForegroundColor Gray
Write-Host "   Enhanced features: Oh My Posh, Terminal-Icons, PSReadLine" -ForegroundColor Gray

# Reset error preference
$ErrorActionPreference = 'Continue'
