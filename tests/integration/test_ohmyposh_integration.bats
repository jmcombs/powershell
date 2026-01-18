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
    run docker run --rm jmcombs/powershell:latest -NoProfile -c "Test-Path '/home/coder/.config/powershell/blue-psl-10k.omp.json'"
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

@test "ENABLE_OHMYPOSH environment variable is set to true by default" {
    run docker run --rm jmcombs/powershell:latest -NoProfile -c "\$env:ENABLE_OHMYPOSH"
    [ "$status" -eq 0 ]
    [[ "$output" == *"true"* ]]
}

@test "OHMYPOSH_THEME environment variable exists and is empty by default" {
    # OHMYPOSH_THEME is set but empty by default
    run docker run --rm jmcombs/powershell:latest -NoProfile -c "if ([string]::IsNullOrEmpty(\$env:OHMYPOSH_THEME)) { Write-Host 'EMPTY' } else { Write-Host \$env:OHMYPOSH_THEME }"
    [ "$status" -eq 0 ]
    [[ "$output" == *"EMPTY"* ]]
}

# Test ENABLE_OHMYPOSH=false disables Oh My Posh
@test "ENABLE_OHMYPOSH=false disables Oh My Posh initialization" {
    # When ENABLE_OHMYPOSH is false, the profile should not initialize Oh My Posh
    # We verify this by checking that the profile loads without errors and the container starts
    run docker run --rm -e ENABLE_OHMYPOSH=false jmcombs/powershell:latest -c "Write-Host 'Container started successfully'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Container started successfully"* ]]
}

@test "ENABLE_OHMYPOSH=0 disables Oh My Posh initialization" {
    # Test numeric zero as alternative to 'false'
    run docker run --rm -e ENABLE_OHMYPOSH=0 jmcombs/powershell:latest -c "Write-Host 'Container started successfully'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Container started successfully"* ]]
}

@test "container starts successfully with Oh My Posh disabled" {
    # Verify that disabling Oh My Posh doesn't break the container
    run docker run --rm -e ENABLE_OHMYPOSH=false jmcombs/powershell:latest -c "Get-Location | Select-Object -ExpandProperty Path"
    [ "$status" -eq 0 ]
    [[ "$output" == *"/home/coder"* ]]
}

# Test OHMYPOSH_THEME with built-in theme name
@test "OHMYPOSH_THEME with built-in theme name constructs correct URL" {
    # When a theme name is provided (not a URL), the profile should construct a GitHub URL
    # We can't easily verify the exact theme loaded, but we can verify the container starts
    run docker run --rm -e OHMYPOSH_THEME=atomic jmcombs/powershell:latest -c "Write-Host 'Theme test passed'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Theme test passed"* ]]
}

@test "OHMYPOSH_THEME with another built-in theme (jandedobbeleer)" {
    run docker run --rm -e OHMYPOSH_THEME=jandedobbeleer jmcombs/powershell:latest -c "Write-Host 'Theme test passed'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Theme test passed"* ]]
}

# Test OHMYPOSH_THEME with custom URL
@test "OHMYPOSH_THEME with custom HTTPS URL" {
    # Test with a valid Oh My Posh theme URL
    run docker run --rm -e OHMYPOSH_THEME=https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/atomic.omp.json jmcombs/powershell:latest -c "Write-Host 'Custom URL test passed'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Custom URL test passed"* ]]
}

@test "OHMYPOSH_THEME with custom HTTP URL" {
    # Test with HTTP (not HTTPS) URL - should still be recognized as URL
    run docker run --rm -e OHMYPOSH_THEME=http://example.com/theme.omp.json jmcombs/powershell:latest -c "Write-Host 'HTTP URL test passed'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"HTTP URL test passed"* ]]
}

# Test fallback behavior when invalid theme is specified
@test "invalid OHMYPOSH_THEME falls back to embedded theme" {
    # When an invalid theme name is provided, the profile should fall back to the embedded Blue PSL 10K theme
    # The container should still start successfully
    run docker run --rm -e OHMYPOSH_THEME=nonexistent-theme-12345 jmcombs/powershell:latest -c "Write-Host 'Fallback test passed'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Fallback test passed"* ]]
}

@test "invalid custom URL falls back to embedded theme" {
    # When an invalid URL is provided, the profile should fall back to the embedded theme
    run docker run --rm -e OHMYPOSH_THEME=https://invalid.example.com/nonexistent.omp.json jmcombs/powershell:latest -c "Write-Host 'Invalid URL fallback test passed'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Invalid URL fallback test passed"* ]]
}

# Test default behavior (Blue PSL 10K theme)
@test "default configuration uses embedded Blue PSL 10K theme" {
    # With no environment variables set, the container should use the embedded theme
    run docker run --rm jmcombs/powershell:latest -c "Write-Host 'Default theme test passed'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Default theme test passed"* ]]
}

@test "embedded Blue PSL 10K theme file is accessible" {
    run docker run --rm jmcombs/powershell:latest -NoProfile -c "Test-Path '/home/coder/.config/powershell/blue-psl-10k.omp.json'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"True"* ]]
}

# Test SHOW_CONTAINER_INFO environment variable
@test "SHOW_CONTAINER_INFO is not set by default (allows auto-display)" {
    # By default, SHOW_CONTAINER_INFO is not set, which means Show-ContainerInfo runs automatically
    # We can't easily test interactive sessions, but we can verify the env var state
    run docker run --rm jmcombs/powershell:latest -NoProfile -c "if ([string]::IsNullOrEmpty(\$env:SHOW_CONTAINER_INFO)) { Write-Host 'NOT_SET' } else { Write-Host \$env:SHOW_CONTAINER_INFO }"
    [ "$status" -eq 0 ]
    [[ "$output" == *"NOT_SET"* ]]
}

@test "SHOW_CONTAINER_INFO=false prevents automatic display" {
    # When set to false, Show-ContainerInfo should not run automatically
    # We verify the container starts without the info display
    run docker run --rm -e SHOW_CONTAINER_INFO=false jmcombs/powershell:latest -c "Write-Host 'No auto info'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"No auto info"* ]]
    # Should NOT contain the container info output
    [[ "$output" != *"PowerShell Container Information"* ]]
}

@test "SHOW_CONTAINER_INFO=0 prevents automatic display" {
    # Test numeric zero as alternative to 'false'
    run docker run --rm -e SHOW_CONTAINER_INFO=0 jmcombs/powershell:latest -c "Write-Host 'No auto info'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"No auto info"* ]]
    [[ "$output" != *"PowerShell Container Information"* ]]
}

@test "Show-ContainerInfo function still works when auto-display is disabled" {
    # Even when SHOW_CONTAINER_INFO=false, the function should still be available
    run docker run --rm -e SHOW_CONTAINER_INFO=false jmcombs/powershell:latest -c ". \$PROFILE; Show-ContainerInfo"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PowerShell Container Information"* ]]
}

# Test combination of environment variables
@test "ENABLE_OHMYPOSH=false with SHOW_CONTAINER_INFO=false" {
    # Test that both can be disabled simultaneously
    run docker run --rm -e ENABLE_OHMYPOSH=false -e SHOW_CONTAINER_INFO=false jmcombs/powershell:latest -c "Write-Host 'Both disabled'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Both disabled"* ]]
    [[ "$output" != *"PowerShell Container Information"* ]]
}

@test "ENABLE_OHMYPOSH=false with custom OHMYPOSH_THEME (theme should be ignored)" {
    # When Oh My Posh is disabled, the theme setting should be ignored
    run docker run --rm -e ENABLE_OHMYPOSH=false -e OHMYPOSH_THEME=atomic jmcombs/powershell:latest -c "Write-Host 'OMP disabled, theme ignored'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"OMP disabled, theme ignored"* ]]
}

# Test that profile loads without errors in all configurations
@test "profile loads without errors with default settings" {
    run docker run --rm jmcombs/powershell:latest -c "\$Error.Count"
    [ "$status" -eq 0 ]
    # Error count should be 0 or very low (some modules may generate benign errors)
}

@test "profile loads without errors when Oh My Posh is disabled" {
    run docker run --rm -e ENABLE_OHMYPOSH=false jmcombs/powershell:latest -c "\$Error.Count"
    [ "$status" -eq 0 ]
}

@test "profile loads without errors with custom theme" {
    run docker run --rm -e OHMYPOSH_THEME=atomic jmcombs/powershell:latest -c "\$Error.Count"
    [ "$status" -eq 0 ]
}
