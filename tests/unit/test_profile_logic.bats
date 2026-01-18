#!/usr/bin/env bats

# Unit tests for PowerShell profile environment variable logic
# These tests validate the profile's behavior in isolation

load '../test_helper'

# Test environment variable parsing logic
@test "profile script exists" {
    [ -f "config/Microsoft.PowerShell_profile.ps1" ]
}

@test "profile contains ENABLE_OHMYPOSH check" {
    grep -q "ENABLE_OHMYPOSH" config/Microsoft.PowerShell_profile.ps1
}

@test "profile contains OHMYPOSH_THEME check" {
    grep -q "OHMYPOSH_THEME" config/Microsoft.PowerShell_profile.ps1
}

@test "profile contains SHOW_CONTAINER_INFO check" {
    grep -q "SHOW_CONTAINER_INFO" config/Microsoft.PowerShell_profile.ps1
}

# Test that profile checks for both 'false' and '0' for ENABLE_OHMYPOSH
@test "profile checks for ENABLE_OHMYPOSH=false" {
    grep -q "ENABLE_OHMYPOSH.*'false'" config/Microsoft.PowerShell_profile.ps1
}

@test "profile checks for ENABLE_OHMYPOSH=0" {
    grep -q "ENABLE_OHMYPOSH.*'0'" config/Microsoft.PowerShell_profile.ps1
}

# Test that profile checks for both 'false' and '0' for SHOW_CONTAINER_INFO
@test "profile checks for SHOW_CONTAINER_INFO=false" {
    grep -q "SHOW_CONTAINER_INFO.*'false'" config/Microsoft.PowerShell_profile.ps1
}

@test "profile checks for SHOW_CONTAINER_INFO=0" {
    grep -q "SHOW_CONTAINER_INFO.*'0'" config/Microsoft.PowerShell_profile.ps1
}

# Test URL detection logic for OHMYPOSH_THEME
@test "profile contains URL detection regex for OHMYPOSH_THEME" {
    grep -q "https\\?://" config/Microsoft.PowerShell_profile.ps1
}

# Test that profile references the embedded theme path
@test "profile references embedded Blue PSL 10K theme path" {
    grep -q "/home/coder/.config/powershell/blue-psl-10k.omp.json" config/Microsoft.PowerShell_profile.ps1
}

# Test that profile references oh-my-posh binary path
@test "profile references oh-my-posh binary path" {
    grep -q "/usr/local/bin/oh-my-posh" config/Microsoft.PowerShell_profile.ps1
}

# Test that profile constructs GitHub URL for built-in themes
@test "profile constructs GitHub URL for built-in themes" {
    grep -q "githubusercontent.com/JanDeDobbeleer/oh-my-posh" config/Microsoft.PowerShell_profile.ps1
}

# Test fallback logic
@test "profile contains fallback logic for failed theme loading" {
    # Profile should have try-catch or conditional logic for fallback
    grep -q "try\|catch\|elseif.*embeddedTheme" config/Microsoft.PowerShell_profile.ps1
}

# Test that profile defines Show-ContainerInfo function
@test "profile defines Show-ContainerInfo function" {
    grep -q "function Show-ContainerInfo" config/Microsoft.PowerShell_profile.ps1
}

# Test that profile creates info alias
@test "profile creates info alias for Show-ContainerInfo" {
    grep -q "Set-Alias.*info.*Show-ContainerInfo" config/Microsoft.PowerShell_profile.ps1
}

# Test that profile checks for interactive session (ConsoleHost)
@test "profile checks for ConsoleHost for auto-display" {
    grep -q "ConsoleHost" config/Microsoft.PowerShell_profile.ps1
}

# Test that profile imports Terminal-Icons module
@test "profile imports Terminal-Icons module" {
    grep -q "Import-Module Terminal-Icons" config/Microsoft.PowerShell_profile.ps1
}

# Test that profile imports PSReadLine module
@test "profile imports PSReadLine module" {
    grep -q "Import-Module PSReadLine" config/Microsoft.PowerShell_profile.ps1
}

# Test that profile configures PSReadLine
@test "profile configures PSReadLine prediction source" {
    grep -q "Set-PSReadLineOption.*PredictionSource" config/Microsoft.PowerShell_profile.ps1
}

@test "profile configures PSReadLine prediction view style" {
    grep -q "Set-PSReadLineOption.*PredictionViewStyle" config/Microsoft.PowerShell_profile.ps1
}

# Test that profile has recursive loading protection
@test "profile has recursive loading protection" {
    grep -q "OhMyPoshProfileLoaded" config/Microsoft.PowerShell_profile.ps1
}

# Test that profile sets ErrorActionPreference
@test "profile sets ErrorActionPreference to SilentlyContinue during module loading" {
    grep -q "ErrorActionPreference.*SilentlyContinue" config/Microsoft.PowerShell_profile.ps1
}

@test "profile resets ErrorActionPreference to Continue" {
    grep -q "ErrorActionPreference.*Continue" config/Microsoft.PowerShell_profile.ps1
}

# Test Show-ContainerInfo function content
@test "Show-ContainerInfo displays PowerShell version" {
    grep -q "PSVersionTable.PSVersion" config/Microsoft.PowerShell_profile.ps1
}

@test "Show-ContainerInfo displays .NET version" {
    grep -q "FrameworkDescription" config/Microsoft.PowerShell_profile.ps1
}

@test "Show-ContainerInfo displays OS information" {
    grep -q "OSDescription" config/Microsoft.PowerShell_profile.ps1
}

@test "Show-ContainerInfo displays architecture" {
    grep -q "OSArchitecture" config/Microsoft.PowerShell_profile.ps1
}

@test "Show-ContainerInfo checks for git" {
    grep -q "Get-Command git" config/Microsoft.PowerShell_profile.ps1
}

# Test that profile validates oh-my-posh binary exists before using it
@test "profile checks if oh-my-posh binary exists" {
    grep -q "Test-Path.*ohmyposhPath" config/Microsoft.PowerShell_profile.ps1
}

# Test that profile calls oh-my-posh init with pwsh
@test "profile calls oh-my-posh init with pwsh" {
    grep -q "init pwsh" config/Microsoft.PowerShell_profile.ps1
}

# Test that profile checks LASTEXITCODE after oh-my-posh init
@test "profile checks LASTEXITCODE after oh-my-posh init" {
    grep -q "LASTEXITCODE" config/Microsoft.PowerShell_profile.ps1
}

# Test that profile uses Invoke-Expression for oh-my-posh init script
@test "profile uses Invoke-Expression for oh-my-posh init script" {
    grep -q "Invoke-Expression" config/Microsoft.PowerShell_profile.ps1
}

