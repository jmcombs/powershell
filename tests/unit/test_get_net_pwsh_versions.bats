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
