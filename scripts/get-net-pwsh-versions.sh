#!/bin/bash

# Determines latest long-term support (LTS) version of .NET Core and PowerShell and sets them as environment variables.

# Write environment variables to a file
write_env_file() {
    local key=$1
    local value=$2
    local env_file="/tmp/env_vars"
    echo "$key=$value" >> "$env_file"
}

# Fetch the latest LTS version in 'active' support of .NET
net_lts_version() {
    local response
    local latest_runtime
    local releases_json

    # Fetch the release metadata for .NET
    response=$(curl -s https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/releases-index.json)
        # The releases index can contain multiple LTS channels (e.g., 8.0 and 10.0)
        # We first filter to entries with support-phase == "active" and release-type == "lts",
        # then pick the newest channel using jq's max_by on the numeric parts of channel-version.
        # Example: "10.0" > "8.0" because [10,0] > [8,0] after split(".") | map(tonumber).
    latest_runtime=$(echo "$response" | jq -r '.["releases-index"]
        | map(select(.["support-phase"] == "active" and .["release-type"] == "lts"))
        | max_by(.["channel-version"] | split(".") | map(tonumber))
        | .["latest-runtime"]')
    # Extract the corresponding releases.json URL for that channel
    releases_json=$(echo "$response" | jq -r '.["releases-index"]
        | map(select(.["support-phase"] == "active" and .["release-type"] == "lts"))
        | max_by(.["channel-version"] | split(".") | map(tonumber))
        | .["releases.json"]')

    # Fetch the runtime files for the latest runtime version
    runtime_files=$(curl -s "$releases_json" | jq -r --arg latest_runtime "$latest_runtime" '.releases[] | select(.["release-version"] == $latest_runtime) | .runtime.files')

    # Loop through each architecture and fetch the corresponding runtime URL and package name
    for arch in "$@"; do
        url=$(echo "$runtime_files" | jq -r --arg arch "dotnet-runtime-linux-$arch.tar.gz" '.[] | select(.name == $arch) | .url')
        package_name=$(basename "$url")
        write_env_file "NET_RUNTIME_URL_$arch" "$url"
        write_env_file "NET_RUNTIME_PACKAGE_NAME_$arch" "$package_name"
    done

    # Write the latest runtime version to the environment file
    write_env_file "NET_RUNTIME_LTS_VERSION" "$latest_runtime"
}

# Fetch the latest LTS version of PowerShell
pwsh_lts_version() {
    local lts_url
    local gh_api_lts_url
    local gh_api_lts_response
    local lts_version
    local lts_major_version

    # Fetch the LTS release URL for PowerShell
    lts_url=$(curl -Ls -o /dev/null -w '%{url_effective}\n' https://aka.ms/powershell-release\?tag\=lts)
    # Convert the GitHub URL to the GitHub API URL
    gh_api_lts_url=$(echo $lts_url | sed 's|https://github.com|https://api.github.com/repos|g; s|tag/|tags/|')
    # Fetch the release metadata from the GitHub API
    gh_api_lts_response=$(curl -s "$gh_api_lts_url")
    lts_version=$(echo "$gh_api_lts_response" | jq -r '.tag_name' | sed 's|^v||')
    # Extract the major version number
    lts_major_version=$(echo "$lts_version" | cut -d '.' -f 1)

    # Loop through each architecture and fetch the corresponding PowerShell URL and package name
    for arch in "$@"; do
        url=$(echo "$gh_api_lts_response" | jq -r --arg fname "powershell-$lts_version-linux-$arch.tar.gz" '.assets[] | select(.name == $fname) | .browser_download_url')
        package_name=$(basename "$url")
        write_env_file "PWSH_LTS_URL_$arch" "$url"
        write_env_file "PWSH_LTS_PACKAGE_NAME_$arch" "$package_name"
    done

    # Write the LTS version and major version to the environment file
    write_env_file "PWSH_LTS_VERSION" "$lts_version"
    write_env_file "PWSH_LTS_MAJOR_VERSION" "$lts_major_version"
}

# Main function to fetch the latest LTS versions for .NET and PowerShell
main() {
    net_lts_version arm arm64 x64
    pwsh_lts_version arm32 arm64 x64
}

# Only run main function if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
