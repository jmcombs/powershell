#!/bin/bash

# Test script for Oh My Posh integration build
# This script builds the container and runs basic tests

set -e

echo "🚀 Testing Oh My Posh Integration Build"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Get the latest versions for build args
print_status $YELLOW "📋 Getting latest .NET and PowerShell versions..."
if [ -f "./scripts/get-net-pwsh-versions.sh" ]; then
    chmod +x ./scripts/get-net-pwsh-versions.sh
    ./scripts/get-net-pwsh-versions.sh
    
    if [ -f "/tmp/env_vars" ]; then
        print_status $GREEN "✅ Version information retrieved"
        echo "Build arguments:"
        cat /tmp/env_vars | head -10
    else
        print_status $RED "❌ Failed to get version information"
        exit 1
    fi
else
    print_status $RED "❌ Version script not found"
    exit 1
fi

# Build the container with Oh My Posh features
print_status $YELLOW "🔨 Building container with Oh My Posh integration..."

# Convert env_vars to build args
BUILD_ARGS=""
while IFS='=' read -r key value; do
    if [ -n "$key" ] && [ -n "$value" ]; then
        BUILD_ARGS="$BUILD_ARGS --build-arg $key=$value"
    fi
done < /tmp/env_vars

# Add architecture-specific build arg (detect current architecture)
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ] || [ "$ARCH" = "aarch64" ]; then
    BUILD_ARGS="$BUILD_ARGS --build-arg TARGETARCH=arm64"
elif [ "$ARCH" = "x86_64" ]; then
    BUILD_ARGS="$BUILD_ARGS --build-arg TARGETARCH=amd64"
else
    BUILD_ARGS="$BUILD_ARGS --build-arg TARGETARCH=amd64"
fi

print_status $YELLOW "Building for architecture: $ARCH (TARGETARCH: $(echo $BUILD_ARGS | grep -o 'TARGETARCH=[^ ]*' | cut -d= -f2))"

# Build the container
docker build $BUILD_ARGS -t jmcombs/powershell:ohmyposh-test . || {
    print_status $RED "❌ Container build failed"
    exit 1
}

print_status $GREEN "✅ Container built successfully"

# Test basic functionality
print_status $YELLOW "🧪 Running basic functionality tests..."

# Test 1: Container starts successfully
print_status $YELLOW "Test 1: Container startup"
if docker run --rm jmcombs/powershell:ohmyposh-test pwsh -c "Write-Host 'Container started successfully'" > /dev/null 2>&1; then
    print_status $GREEN "✅ Container starts successfully"
else
    print_status $RED "❌ Container startup failed"
    exit 1
fi

# Test 2: Oh My Posh is installed
print_status $YELLOW "Test 2: Oh My Posh installation"
if docker run --rm jmcombs/powershell:ohmyposh-test pwsh -c "Test-Path '/usr/local/bin/oh-my-posh'" | grep -q "True"; then
    print_status $GREEN "✅ Oh My Posh is installed"
else
    print_status $RED "❌ Oh My Posh installation failed"
    exit 1
fi

# Test 3: PowerShell profile exists
print_status $YELLOW "Test 3: PowerShell profile"
if docker run --rm jmcombs/powershell:ohmyposh-test pwsh -c "Test-Path '/home/coder/.config/powershell/Microsoft.PowerShell_profile.ps1'" | grep -q "True"; then
    print_status $GREEN "✅ PowerShell profile exists"
else
    print_status $RED "❌ PowerShell profile missing"
    exit 1
fi

# Test 4: Terminal-Icons module
print_status $YELLOW "Test 4: Terminal-Icons module"
if docker run --rm jmcombs/powershell:ohmyposh-test pwsh -c "Get-Module -ListAvailable -Name Terminal-Icons" | grep -q "Terminal-Icons"; then
    print_status $GREEN "✅ Terminal-Icons module available"
else
    print_status $RED "❌ Terminal-Icons module missing"
    exit 1
fi

# Test 5: Container info function
print_status $YELLOW "Test 5: Container info function"
if docker run --rm jmcombs/powershell:ohmyposh-test pwsh -c "Show-ContainerInfo" | grep -q "PowerShell Container Information"; then
    print_status $GREEN "✅ Container info function works"
else
    print_status $RED "❌ Container info function failed"
    exit 1
fi

# Test 6: Interactive session (brief test)
print_status $YELLOW "Test 6: Interactive session test"
if echo "Get-Location; exit" | docker run -i jmcombs/powershell:ohmyposh-test > /dev/null 2>&1; then
    print_status $GREEN "✅ Interactive session works"
else
    print_status $RED "❌ Interactive session failed"
    exit 1
fi

print_status $GREEN "🎉 All tests passed!"
print_status $YELLOW "📊 Container Information:"
docker images jmcombs/powershell:ohmyposh-test --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"

print_status $YELLOW "🔍 To test interactively, run:"
print_status $NC "docker run -it jmcombs/powershell:ohmyposh-test"

print_status $GREEN "✅ Oh My Posh integration build test completed successfully!"
