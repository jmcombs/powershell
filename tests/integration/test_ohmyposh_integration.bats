#!/usr/bin/env bats

# Integration tests for Oh My Posh functionality

load '../test_helper'

@test "oh-my-posh binary is installed and executable" {
    run docker run --rm jmcombs/powershell:latest pwsh -c "Test-Path '/usr/local/bin/oh-my-posh'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"True"* ]]
}

@test "PowerShell profile exists and loads" {
    run docker run --rm jmcombs/powershell:latest pwsh -c "Test-Path '/home/coder/.config/powershell/Microsoft.PowerShell_profile.ps1'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"True"* ]]
}

@test "Oh My Posh theme configuration exists" {
    run docker run --rm jmcombs/powershell:latest pwsh -c "Test-Path '/home/coder/.config/powershell/ohmyposh-container.json'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"True"* ]]
}

@test "Terminal-Icons module is available" {
    run docker run --rm jmcombs/powershell:latest pwsh -c "Get-Module -ListAvailable -Name Terminal-Icons | Select-Object -ExpandProperty Name"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Terminal-Icons"* ]]
}

@test "PSReadLine module is available" {
    run docker run --rm jmcombs/powershell:latest pwsh -c "Get-Module -ListAvailable -Name PSReadLine | Select-Object -ExpandProperty Name"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PSReadLine"* ]]
}

@test "container info function works" {
    run docker run --rm jmcombs/powershell:latest pwsh -c "Show-ContainerInfo"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PowerShell Container Information"* ]]
    [[ "$output" == *"PowerShell Version"* ]]
    [[ "$output" == *".NET Version"* ]]
}

@test "info alias works" {
    run docker run --rm jmcombs/powershell:latest pwsh -c "info"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PowerShell Container Information"* ]]
}

@test "enhanced prompt loads without errors" {
    run docker run --rm jmcombs/powershell:latest pwsh -c "Write-Host 'Profile loaded successfully'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Profile loaded successfully"* ]]
}

# Note: Nerd Font tests removed - fonts must be installed on HOST machine, not in container
# The container relies on the host terminal's font configuration for proper glyph rendering

@test "ENABLE_OHMYPOSH environment variable is set" {
    run docker run --rm jmcombs/powershell:latest pwsh -c "\$env:ENABLE_OHMYPOSH"
    [ "$status" -eq 0 ]
    [[ "$output" == *"true"* ]]
}

@test "OHMYPOSH_THEME environment variable exists" {
    run docker run --rm jmcombs/powershell:latest pwsh -c "Test-Path env:OHMYPOSH_THEME"
    [ "$status" -eq 0 ]
}
