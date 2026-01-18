#!/usr/bin/env bats

# Integration tests for get-net-pwsh-versions.sh script

load '../test_helper'

@test "script runs successfully with real network calls" {
    # Check if required tools are available
    run check_required_tools
    if [ "$status" -ne 0 ]; then
        skip "Required tools (curl, jq) not available"
    fi
    
    # Run the actual script
    run timeout 60 bash scripts/get-net-pwsh-versions.sh
    [ "$status" -eq 0 ]
    
    # Check that environment variables file was created
    [ -f "/tmp/env_vars" ]
    
    # Validate the environment variables file
    run validate_env_vars_file
    [ "$status" -eq 0 ]
}

@test "generated versions have correct format" {
    # Check if required tools are available
    run check_required_tools
    if [ "$status" -ne 0 ]; then
        skip "Required tools (curl, jq) not available"
    fi
    
    # Run the script first
    run timeout 60 bash scripts/get-net-pwsh-versions.sh
    [ "$status" -eq 0 ]
    
    # Check .NET version format
    net_version=$(get_version_from_env_file "NET_RUNTIME_LTS_VERSION")
    run validate_version_format "$net_version" "dotnet"
    [ "$status" -eq 0 ]
    
    # Check PowerShell version format
    pwsh_version=$(get_version_from_env_file "PWSH_LTS_VERSION")
    run validate_version_format "$pwsh_version" "powershell"
    [ "$status" -eq 0 ]
}

@test "all required URLs are generated" {
    # Check if required tools are available
    run check_required_tools
    if [ "$status" -ne 0 ]; then
        skip "Required tools (curl, jq) not available"
    fi
    
    # Run the script first
    run timeout 60 bash scripts/get-net-pwsh-versions.sh
    [ "$status" -eq 0 ]
    
    # Check that all architecture URLs are present
    local architectures=("x64" "arm64" "arm")
    for arch in "${architectures[@]}"; do
        net_url=$(get_version_from_env_file "NET_RUNTIME_URL_$arch")
        [ -n "$net_url" ]
        [[ "$net_url" =~ ^https:// ]]
    done
    
    # Check PowerShell URLs (note: arm32 for PowerShell)
    local pwsh_architectures=("x64" "arm64" "arm32")
    for arch in "${pwsh_architectures[@]}"; do
        pwsh_url=$(get_version_from_env_file "PWSH_LTS_URL_$arch")
        [ -n "$pwsh_url" ]
        [[ "$pwsh_url" =~ ^https:// ]]
    done
}

@test "script handles network timeouts gracefully" {
    # This test simulates network issues by using a very short timeout
    run timeout 1 bash scripts/get-net-pwsh-versions.sh
    
    # The script should either succeed quickly or timeout
    # We don't expect it to crash or produce invalid output
    if [ "$status" -eq 0 ]; then
        # If it succeeded, validate the output
        if [ -f "/tmp/env_vars" ]; then
            run validate_env_vars_file
            [ "$status" -eq 0 ]
        fi
    else
        # If it timed out, that's also acceptable for this test
        [ "$status" -eq 124 ] # timeout exit code
    fi
}

@test "script can be sourced without executing main logic" {
    # Test that we can source the script to access its functions
    # without executing the main logic (now that we've added protection)

    # Source the script directly
    source scripts/get-net-pwsh-versions.sh

    # Test that functions are available
    run declare -f write_env_file
    [ "$status" -eq 0 ]

    run declare -f net_lts_version
    [ "$status" -eq 0 ]

    run declare -f pwsh_lts_version
    [ "$status" -eq 0 ]

    run declare -f main
    [ "$status" -eq 0 ]
}

@test "script produces consistent output across multiple runs" {
    # Check if required tools are available
    run check_required_tools
    if [ "$status" -ne 0 ]; then
        skip "Required tools (curl, jq) not available"
    fi
    
    # Run the script twice and compare outputs
    run timeout 60 bash scripts/get-net-pwsh-versions.sh
    [ "$status" -eq 0 ]
    
    # Save first run results
    cp /tmp/env_vars "$TEST_TEMP_DIR/env_vars_run1"
    
    # Clean up and run again
    rm -f /tmp/env_vars
    
    run timeout 60 bash scripts/get-net-pwsh-versions.sh
    [ "$status" -eq 0 ]
    
    # Compare results (they should be identical for LTS versions)
    run diff "$TEST_TEMP_DIR/env_vars_run1" /tmp/env_vars
    [ "$status" -eq 0 ]
}

@test "environment variables can be used in Docker build context" {
    # Check if required tools are available
    run check_required_tools
    if [ "$status" -ne 0 ]; then
        skip "Required tools (curl, jq) not available"
    fi
    
    # Run the script
    run timeout 60 bash scripts/get-net-pwsh-versions.sh
    [ "$status" -eq 0 ]
    
    # Test that the environment variables can be formatted for Docker build args
    cat > "$TEST_TEMP_DIR/test_docker_args.sh" << 'EOF'
#!/bin/bash

# Source environment variables
if [ -f /tmp/env_vars ]; then
    # Convert to Docker build args format
    echo "BUILD_ARGS<<EOF"
    cat /tmp/env_vars
    echo "EOF"
fi
EOF

    chmod +x "$TEST_TEMP_DIR/test_docker_args.sh"
    
    run bash "$TEST_TEMP_DIR/test_docker_args.sh"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "BUILD_ARGS<<EOF" ]]
    [[ "$output" =~ "NET_RUNTIME_LTS_VERSION=" ]]
    [[ "$output" =~ "PWSH_LTS_VERSION=" ]]
    [[ "$output" =~ "EOF" ]]
}
