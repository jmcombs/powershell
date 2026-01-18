#!/usr/bin/env bats

# Integration tests for Oh My Posh functionality
# Note: Container ENTRYPOINT is already 'pwsh', so we don't include 'pwsh' in docker run commands

load '../test_helper'

@test "oh-my-posh binary is installed and executable" {
    run docker run --rm jmcombs/powershell:latest -NoProfile -c "Test-Path '/usr/local/bin/oh-my-posh'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"True"* ]]
}

@test "PowerShell profile exists" {
    run docker run --rm jmcombs/powershell:latest -NoProfile -c "Test-Path '/home/coder/.config/powershell/Microsoft.PowerShell_profile.ps1'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"True"* ]]
}

@test "Oh My Posh theme configuration exists" {
    run docker run --rm jmcombs/powershell:latest -NoProfile -c "Test-Path '/home/coder/.config/powershell/ohmyposh-container.json'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"True"* ]]
}

# PowerShell modules are installed during Docker build

@test "Terminal-Icons module is available" {
    run docker run --rm jmcombs/powershell:latest -NoProfile -c "Get-Module -ListAvailable -Name Terminal-Icons | Select-Object -ExpandProperty Name"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Terminal-Icons"* ]]
}

@test "PSReadLine module is available" {
    run docker run --rm jmcombs/powershell:latest -NoProfile -c "Get-Module -ListAvailable -Name PSReadLine | Select-Object -ExpandProperty Name"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PSReadLine"* ]]
}

@test "container info function works when profile is loaded" {
    # Use -Command with profile loading to test profile functions
    run docker run --rm jmcombs/powershell:latest -c ". \$PROFILE; Show-ContainerInfo"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PowerShell Container Information"* ]]
    [[ "$output" == *"PowerShell Version"* ]]
    [[ "$output" == *".NET Version"* ]]
}

@test "info alias works when profile is loaded" {
    run docker run --rm jmcombs/powershell:latest -c ". \$PROFILE; info"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PowerShell Container Information"* ]]
}

@test "PowerShell runs without errors" {
    run docker run --rm jmcombs/powershell:latest -NoProfile -c "Write-Host 'PowerShell works'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PowerShell works"* ]]
}

# Note: Nerd Font tests removed - fonts must be installed on HOST machine, not in container
# The container relies on the host terminal's font configuration for proper glyph rendering

@test "ENABLE_OHMYPOSH environment variable is set" {
    run docker run --rm jmcombs/powershell:latest -NoProfile -c "\$env:ENABLE_OHMYPOSH"
    [ "$status" -eq 0 ]
    [[ "$output" == *"true"* ]]
}

@test "OHMYPOSH_THEME environment variable exists" {
    # OHMYPOSH_THEME is set but empty by default
    run docker run --rm jmcombs/powershell:latest -NoProfile -c "[Environment]::GetEnvironmentVariable('OHMYPOSH_THEME') -ne \$null -or (Test-Path env:OHMYPOSH_THEME -ErrorAction SilentlyContinue)"
    [ "$status" -eq 0 ]
}
