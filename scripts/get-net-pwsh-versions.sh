#!/bin/bash

# Determines latest long-term support (LTS) version of .NET Core and PowerShell and sets them as environment variables.

# Function to check and install dependencies
check_dependencies() {
    for dep in "$@"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            echo "error: $dep is not installed, attempting to install..."
            if command -v apt-get >/dev/null 2>&1; then
                apt-get update && apt-get install --no-install-recommends -y "$dep"
            else
                echo "error: cannot install $dep, please install it manually" >&2
                exit 1
            fi
        fi
    done
}

# Fetch the latest LTS version in 'active' support of .NET
net_lts_version() {
    local response
    local latest_runtime
    local releases_json

    response=$(curl -s https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/releases-index.json)
    latest_runtime=$(echo "$response" | jq -r '.["releases-index"][] | select(.["support-phase"] == "active" and .["release-type"] == "lts") | .["latest-runtime"]')
    releases_json=$(echo "$response" | jq -r '.["releases-index"][] | select(.["support-phase"] == "active" and .["release-type"] == "lts") | .["releases.json"]')

    # Fetch the runtime section from the releases.json URL where runtime.version matches latest_runtime
    runtime_files=$(curl -s "$releases_json" | jq -r --arg latest_runtime "$latest_runtime" '.releases[] | select(.["release-version"] == $latest_runtime) | .runtime.["files"]')

    for arch in "$@"; do
        url=$(echo "$runtime_files" | jq -r --arg arch "dotnet-runtime-linux-$arch.tar.gz" '.[] | select(.name == $arch) | .url')
        eval "export NET_RUNTIME_URL_$arch=\"$url\""
        eval "echo \".NET_RUNTIME_URL_$arch: \$NET_RUNTIME_URL_$arch\""
    done

    eval "export NET_RUNTIME_LTS_VERSION=\"$latest_runtime\""
    eval "echo \".NET Runtime LTS Version: \$latest_runtime\""
    eval "echo \".NET Releases JSON: \$releases_json\""  
}

# Fetch the latest LTS version of PowerShell
pwsh_lts_version() {
    local lts_url
    local gh_api_lts_url
    local gh_api_lts_response
    local lts_version
    local lts_major_version

    lts_url=$(curl -Ls -o /dev/null -w '%{url_effective}\n' https://aka.ms/powershell-release\?tag\=lts)
    gh_api_lts_url=$(echo $lts_url | sed 's|https://github.com|https://api.github.com/repos|g; s|tag/|tags/|')
    gh_api_lts_response=$(curl -s "$gh_api_lts_url")
    lts_version=$(echo "$gh_api_lts_response" | jq -r '.tag_name' | sed 's|^v||')
    lts_major_version=$(echo "$lts_version" | cut -d 'v' -f 2 | cut -d '.' -f 1)

    for arch in "$@"; do
        url=$(echo "$gh_api_lts_response" | jq -r --arg arch "powershell-$lts_version-linux-$arch.tar.gz" '.assets[] | select(.name | contains($arch)) | .browser_download_url')
        package_name=$(basename "$url")
        eval "export PWSH_LTS_URL_$arch=\"$url\""
        eval "export PWSH_LTS_PACKAGE_NAME_$arch=\"$package_name\""
        eval "echo \"PowerShell LTS URL for $arch: \$PWSH_LTS_URL_$arch\""
        eval "echo \"PowerShell LTS Package Name for $arch: \$PWSH_LTS_PACKAGE_NAME_$arch\""
    done

    eval "export PWSH_LTS_VERSION=\"$lts_version\""
    eval "export PWSH_LTS_MAJOR_VERSION=\"$lts_major_version\""
    eval "echo \"PowerShell LTS Version: \$lts_version\""
    eval "echo \"PowerShell LTS Major Version: \$lts_major_version\""
}

check_dependencies curl ca-certificates jq
net_lts_version arm arm64 x64
pwsh_lts_version arm32 arm64 x64