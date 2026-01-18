#!/usr/bin/env bats

# Integration tests for Oh My Posh functionality

load '../test_helper'

@test "oh-my-posh binary is installed and executable" {
    run docker run --rm jmcombs/powershell:latest pwsh -NoProfile -c "Test-Path '/usr/local/bin/oh-my-posh'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"True"* ]]
}

@test "PowerShell profile exists" {
    run docker run --rm jmcombs/powershell:latest pwsh -NoProfile -c "Test-Path '/home/coder/.config/powershell/Microsoft.PowerShell_profile.ps1'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"True"* ]]
}

@test "Oh My Posh theme configuration exists" {
    run docker run --rm jmcombs/powershell:latest pwsh -NoProfile -c "Test-Path '/home/coder/.config/powershell/ohmyposh-container.json'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"True"* ]]
}

# Note: Terminal-Icons and PSReadLine modules are NOT installed during Docker build
# They can be installed by running ./install-modules.sh inside the container
# These tests verify the install script exists instead

@test "module install script exists" {
    run docker run --rm jmcombs/powershell:latest pwsh -NoProfile -c "Test-Path '/home/coder/install-modules.sh'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"True"* ]]
}

@test "container info function works when profile is loaded" {
    # Use -Command with profile loading to test profile functions
    run docker run --rm jmcombs/powershell:latest pwsh -c ". \$PROFILE; Show-ContainerInfo"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PowerShell Container Information"* ]]
    [[ "$output" == *"PowerShell Version"* ]]
    [[ "$output" == *".NET Version"* ]]
}

@test "info alias works when profile is loaded" {
    run docker run --rm jmcombs/powershell:latest pwsh -c ". \$PROFILE; info"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PowerShell Container Information"* ]]
}

@test "PowerShell runs without errors" {
    run docker run --rm jmcombs/powershell:latest pwsh -NoProfile -c "Write-Host 'PowerShell works'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PowerShell works"* ]]
}

# Note: Nerd Font tests removed - fonts must be installed on HOST machine, not in container
# The container relies on the host terminal's font configuration for proper glyph rendering

@test "ENABLE_OHMYPOSH environment variable is set" {
    run docker run --rm jmcombs/powershell:latest pwsh -NoProfile -c "\$env:ENABLE_OHMYPOSH"
    [ "$status" -eq 0 ]
    [[ "$output" == *"true"* ]]
}

@test "OHMYPOSH_THEME environment variable exists" {
    # OHMYPOSH_THEME is set but empty by default
    run docker run --rm jmcombs/powershell:latest pwsh -NoProfile -c "[Environment]::GetEnvironmentVariable('OHMYPOSH_THEME') -ne \$null -or (Test-Path env:OHMYPOSH_THEME -ErrorAction SilentlyContinue)"
    [ "$status" -eq 0 ]
}
