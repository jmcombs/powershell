#!/usr/bin/env bash

# Test helper functions for bats tests

# Setup function to be called at the beginning of each test
setup() {
    # Create temporary directory for test files
    export TEST_TEMP_DIR="$(mktemp -d)"
    export ORIGINAL_PWD="$PWD"
    
    # Clean up any existing environment variables file
    rm -f /tmp/env_vars
    
    # Set up mock data directory
    export MOCK_DATA_DIR="$BATS_TEST_DIRNAME/mocks"
}

# Teardown function to be called at the end of each test
teardown() {
    # Clean up temporary directory
    if [[ -n "$TEST_TEMP_DIR" && -d "$TEST_TEMP_DIR" ]]; then
        rm -rf "$TEST_TEMP_DIR"
    fi
    
    # Clean up environment variables file
    rm -f /tmp/env_vars
    
    # Return to original directory
    cd "$ORIGINAL_PWD"
}

# Mock curl command for testing
mock_curl() {
    local url="$1"
    local mock_file=""
    
    case "$url" in
        *"releases-index.json")
            mock_file="$MOCK_DATA_DIR/dotnet_releases_index.json"
            ;;
        *"releases.json")
            mock_file="$MOCK_DATA_DIR/dotnet_releases.json"
            ;;
        *"api.github.com"*)
            mock_file="$MOCK_DATA_DIR/powershell_release.json"
            ;;
        *"aka.ms/powershell-release"*)
            echo "https://github.com/PowerShell/PowerShell/releases/tag/v7.4.7"
            return 0
            ;;
    esac
    
    if [[ -f "$mock_file" ]]; then
        cat "$mock_file"
    else
        echo "Mock data not found for URL: $url" >&2
        return 1
    fi
}

# Check if required tools are available
check_required_tools() {
    local missing_tools=()
    
    if ! command -v curl >/dev/null 2>&1; then
        missing_tools+=("curl")
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        missing_tools+=("jq")
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        echo "Missing required tools: ${missing_tools[*]}" >&2
        return 1
    fi
    
    return 0
}

# Validate environment variables file
validate_env_vars_file() {
    local env_file="${1:-/tmp/env_vars}"
    
    if [[ ! -f "$env_file" ]]; then
        echo "Environment variables file not found: $env_file" >&2
        return 1
    fi
    
    local required_vars=(
        "NET_RUNTIME_LTS_VERSION"
        "PWSH_LTS_VERSION"
        "PWSH_LTS_MAJOR_VERSION"
        "NET_RUNTIME_URL_x64"
        "NET_RUNTIME_URL_arm64"
        "NET_RUNTIME_URL_arm"
        "PWSH_LTS_URL_x64"
        "PWSH_LTS_URL_arm64"
        "PWSH_LTS_URL_arm32"
    )
    
    local missing_vars=()
    for var in "${required_vars[@]}"; do
        if ! grep -q "^$var=" "$env_file"; then
            missing_vars+=("$var")
        fi
    done
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        echo "Missing required environment variables: ${missing_vars[*]}" >&2
        return 1
    fi
    
    return 0
}

# Extract version from environment variables file
get_version_from_env_file() {
    local var_name="$1"
    local env_file="${2:-/tmp/env_vars}"
    
    if [[ ! -f "$env_file" ]]; then
        echo "Environment variables file not found: $env_file" >&2
        return 1
    fi
    
    grep "^$var_name=" "$env_file" | cut -d '=' -f 2
}

# Validate version format
validate_version_format() {
    local version="$1"
    local version_type="$2"
    
    case "$version_type" in
        "dotnet")
            # .NET versions follow semantic versioning (e.g., 8.0.14)
            if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                echo "Invalid .NET version format: $version" >&2
                return 1
            fi
            ;;
        "powershell")
            # PowerShell versions follow semantic versioning (e.g., 7.4.7)
            if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                echo "Invalid PowerShell version format: $version" >&2
                return 1
            fi
            ;;
        *)
            echo "Unknown version type: $version_type" >&2
            return 1
            ;;
    esac
    
    return 0
}
