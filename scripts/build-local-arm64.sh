#!/bin/bash
set -e

# Build Docker image locally for ARM64 (Apple Silicon)
# This script builds the image natively without QEMU emulation issues

echo "🔧 Building PowerShell Docker image for ARM64 (Apple Silicon)..."

# Get version information
echo "📋 Getting .NET and PowerShell versions..."
chmod +x ./scripts/get-net-pwsh-versions.sh
./scripts/get-net-pwsh-versions.sh

# Source the environment variables
if [ -f /tmp/env_vars ]; then
    echo "✅ Loading build arguments from /tmp/env_vars"
    export $(cat /tmp/env_vars | xargs)
else
    echo "❌ Error: /tmp/env_vars not found"
    exit 1
fi

# Build the image for ARM64
echo "🐳 Building Docker image for linux/arm64..."
docker buildx build \
    --platform linux/arm64 \
    --build-arg NET_RUNTIME_LTS_VERSION="${NET_RUNTIME_LTS_VERSION}" \
    --build-arg NET_RUNTIME_URL_arm="${NET_RUNTIME_URL_arm}" \
    --build-arg NET_RUNTIME_PACKAGE_NAME_arm="${NET_RUNTIME_PACKAGE_NAME_arm}" \
    --build-arg NET_RUNTIME_URL_arm64="${NET_RUNTIME_URL_arm64}" \
    --build-arg NET_RUNTIME_PACKAGE_NAME_arm64="${NET_RUNTIME_PACKAGE_NAME_arm64}" \
    --build-arg NET_RUNTIME_URL_x64="${NET_RUNTIME_URL_x64}" \
    --build-arg NET_RUNTIME_PACKAGE_NAME_x64="${NET_RUNTIME_PACKAGE_NAME_x64}" \
    --build-arg PWSH_LTS_URL_arm32="${PWSH_LTS_URL_arm32}" \
    --build-arg PWSH_LTS_PACKAGE_NAME_arm32="${PWSH_LTS_PACKAGE_NAME_arm32}" \
    --build-arg PWSH_LTS_URL_arm64="${PWSH_LTS_URL_arm64}" \
    --build-arg PWSH_LTS_PACKAGE_NAME_arm64="${PWSH_LTS_PACKAGE_NAME_arm64}" \
    --build-arg PWSH_LTS_URL_x64="${PWSH_LTS_URL_x64}" \
    --build-arg PWSH_LTS_PACKAGE_NAME_x64="${PWSH_LTS_PACKAGE_NAME_x64}" \
    --build-arg PWSH_LTS_VERSION="${PWSH_LTS_VERSION}" \
    --build-arg PWSH_LTS_MAJOR_VERSION="${PWSH_LTS_MAJOR_VERSION}" \
    --load \
    --tag jmcombs/powershell:test \
    --tag jmcombs/powershell:latest \
    .

echo ""
echo "✅ Build complete!"
echo ""
echo "📦 Tagged images:"
echo "   - jmcombs/powershell:test"
echo "   - jmcombs/powershell:latest"
echo ""

# Tag the image as 'latest' for integration tests
echo "🏷️  Tagging image as latest for integration tests..."
docker tag jmcombs/powershell:test jmcombs/powershell:latest

# Run integration tests with act using the main CI workflow with skip_build input
echo "🧪 Running integration tests with act..."
echo ""

if command -v act &> /dev/null; then
    # Use the main ci.yml workflow with skip_build=true to bypass the build job
    # This runs the integration-tests-local job which assumes the image already exists
    act workflow_dispatch --pull=false --input skip_build=true -j integration-tests-local
    TEST_EXIT_CODE=$?

    echo ""
    if [ $TEST_EXIT_CODE -eq 0 ]; then
        echo "✅ All integration tests passed!"
    else
        echo "❌ Integration tests failed with exit code: $TEST_EXIT_CODE"
        exit $TEST_EXIT_CODE
    fi
else
    echo "⚠️  Warning: 'act' is not installed. Skipping integration tests."
    echo ""
    echo "   Install act with:"
    echo "   brew install act"
    echo ""
    echo "   To run tests manually:"
    echo "   act workflow_dispatch --pull=false --input skip_build=true -j integration-tests-local"
fi

echo ""
echo "🚀 To run the container:"
echo "   docker run -it jmcombs/powershell:latest"

