#!/usr/bin/env bats

# Unit tests for get-net-pwsh-versions.sh script

load '../test_helper'

@test "script exists and is executable" {
    [ -f "scripts/get-net-pwsh-versions.sh" ]
    [ -x "scripts/get-net-pwsh-versions.sh" ]
}

@test "script has proper shebang" {
    run head -n 1 scripts/get-net-pwsh-versions.sh
    [ "$status" -eq 0 ]
    [[ "$output" == "#!/bin/bash" ]]
}

@test "write_env_file function works correctly" {
    # Source the script to access its functions
    source scripts/get-net-pwsh-versions.sh
    
    # Test the write_env_file function
    write_env_file "TEST_KEY" "test_value"
    
    [ -f "/tmp/env_vars" ]
    run grep "TEST_KEY=test_value" /tmp/env_vars
    [ "$status" -eq 0 ]
}

@test "script requires curl and jq" {
    # Test that script fails gracefully when required tools are missing
    skip "This test requires mocking PATH to simulate missing tools"
}

@test "net_lts_version function with mocked data" {
    # Source the script to access its functions (now safe since main logic is protected)
    source scripts/get-net-pwsh-versions.sh

    # Create a mock curl function that handles different argument patterns
    curl() {
        local args=("$@")
        local url=""

        # Parse curl arguments to find the URL
        for arg in "${args[@]}"; do
            if [[ "$arg" =~ ^https?:// ]]; then
                url="$arg"
                break
            fi
        done

        case "$url" in
            *"releases-index.json")
                cat "$MOCK_DATA_DIR/dotnet_releases_index.json"
                ;;
            *"releases.json")
                cat "$MOCK_DATA_DIR/dotnet_releases.json"
                ;;
            *)
                echo "Unknown URL: $url" >&2
                return 1
                ;;
        esac
    }

    # Test the net_lts_version function with mocked curl
    net_lts_version x64 arm64 arm

    # Check that environment variables file was created
    [ -f "/tmp/env_vars" ]

    # Check specific values
    run get_version_from_env_file "NET_RUNTIME_LTS_VERSION"
    [ "$status" -eq 0 ]
    [ "$output" = "8.0.14" ]
}

@test "pwsh_lts_version function with mocked data" {
    # Source the script to access its functions
    source scripts/get-net-pwsh-versions.sh

    # Create a mock curl function that handles different argument patterns
    curl() {
        local args=("$@")
        local url=""
        local has_redirect_flags=false

        # Check for redirect-specific flags (-Ls -o /dev/null -w)
        for arg in "${args[@]}"; do
            if [[ "$arg" == "-Ls" || "$arg" == "-o" || "$arg" == "-w" ]]; then
                has_redirect_flags=true
                break
            fi
        done

        # Parse curl arguments to find the URL
        for arg in "${args[@]}"; do
            if [[ "$arg" =~ ^https?:// ]]; then
                url="$arg"
                break
            fi
        done

        case "$url" in
            *"aka.ms/powershell-release"*)
                if [[ "$has_redirect_flags" == "true" ]]; then
                    # Mock the redirect response for -Ls -o /dev/null -w '%{url_effective}\n'
                    echo "https://github.com/PowerShell/PowerShell/releases/tag/v7.4.7"
                else
                    # Regular curl call
                    echo "https://github.com/PowerShell/PowerShell/releases/tag/v7.4.7"
                fi
                ;;
            *"api.github.com"*)
                cat "$MOCK_DATA_DIR/powershell_release.json"
                ;;
            *)
                echo "Unknown URL: $url" >&2
                return 1
                ;;
        esac
    }

    # Test the pwsh_lts_version function with mocked curl
    pwsh_lts_version x64 arm64 arm32

    # Check PowerShell version
    run get_version_from_env_file "PWSH_LTS_VERSION"
    [ "$status" -eq 0 ]
    [ "$output" = "7.4.7" ]

    # Check PowerShell major version
    run get_version_from_env_file "PWSH_LTS_MAJOR_VERSION"
    [ "$status" -eq 0 ]
    [ "$output" = "7" ]
}

@test "version format validation" {
    run validate_version_format "8.0.14" "dotnet"
    [ "$status" -eq 0 ]
    
    run validate_version_format "7.4.7" "powershell"
    [ "$status" -eq 0 ]
    
    run validate_version_format "invalid.version" "dotnet"
    [ "$status" -eq 1 ]
    
    run validate_version_format "1.2" "powershell"
    [ "$status" -eq 1 ]
}

@test "environment variables file validation" {
    # Create a valid environment variables file
    cat > "$TEST_TEMP_DIR/valid_env_vars" << 'EOF'
NET_RUNTIME_LTS_VERSION=8.0.14
PWSH_LTS_VERSION=7.4.7
PWSH_LTS_MAJOR_VERSION=7
NET_RUNTIME_URL_x64=https://example.com/dotnet-runtime-8.0.14-linux-x64.tar.gz
NET_RUNTIME_URL_arm64=https://example.com/dotnet-runtime-8.0.14-linux-arm64.tar.gz
NET_RUNTIME_URL_arm=https://example.com/dotnet-runtime-8.0.14-linux-arm.tar.gz
PWSH_LTS_URL_x64=https://example.com/powershell-7.4.7-linux-x64.tar.gz
PWSH_LTS_URL_arm64=https://example.com/powershell-7.4.7-linux-arm64.tar.gz
PWSH_LTS_URL_arm32=https://example.com/powershell-7.4.7-linux-arm32.tar.gz
EOF

    run validate_env_vars_file "$TEST_TEMP_DIR/valid_env_vars"
    [ "$status" -eq 0 ]
    
    # Test with missing file
    run validate_env_vars_file "$TEST_TEMP_DIR/nonexistent_file"
    [ "$status" -eq 1 ]
    
    # Test with incomplete file
    echo "NET_RUNTIME_LTS_VERSION=8.0.14" > "$TEST_TEMP_DIR/incomplete_env_vars"
    run validate_env_vars_file "$TEST_TEMP_DIR/incomplete_env_vars"
    [ "$status" -eq 1 ]
}

@test "get_version_from_env_file function" {
    # Create test environment variables file
    cat > "$TEST_TEMP_DIR/test_env_vars" << 'EOF'
NET_RUNTIME_LTS_VERSION=8.0.14
PWSH_LTS_VERSION=7.4.7
PWSH_LTS_MAJOR_VERSION=7
EOF

    run get_version_from_env_file "NET_RUNTIME_LTS_VERSION" "$TEST_TEMP_DIR/test_env_vars"
    [ "$status" -eq 0 ]
    [ "$output" = "8.0.14" ]
    
    run get_version_from_env_file "PWSH_LTS_VERSION" "$TEST_TEMP_DIR/test_env_vars"
    [ "$status" -eq 0 ]
    [ "$output" = "7.4.7" ]
    
    run get_version_from_env_file "NONEXISTENT_VAR" "$TEST_TEMP_DIR/test_env_vars"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}
