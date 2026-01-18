# powershell

LTS versions of PowerShell Core and .NET Core in Linux. Published for 64-bit `x86` and `ARM` architectures.

<div align="center">

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/jmcombs/powershell/ci.yml?logo=github)
[![Docker Pulls](https://img.shields.io/docker/pulls/jmcombs/powershell)](https://hub.docker.com/r/jmcombs/powershell "Click to view the image on Docker Hub")
[![Docker Stars](https://img.shields.io/docker/stars/jmcombs/powershell)](https://hub.docker.com/r/jmcombs/powershell "Click to view the image on Docker Hub")
[![Github Issues](https://img.shields.io/github/issues/jmcombs/powershell)](https://github.com/jmcombs/powershell/issues "Click to view or open issues")
[![GitHub Sponsors](https://img.shields.io/github/sponsors/jmcombs)](https://github.com/sponsors/jmcombs "Sponsor this project")
[![Oh My Posh](https://img.shields.io/badge/Prompt-Oh%20My%20Posh-1abc9c?logo=powershell)](https://ohmyposh.dev/ "Oh My Posh documentation")
[![Blue PSL 10K Theme](https://img.shields.io/badge/Theme-Blue%20PSL%2010K-3465a4?logo=powershell)](https://github.com/JanDeDobbeleer/oh-my-posh/blob/main/themes/blue-psl-10k.omp.json "Blue PSL 10K theme")

</div>

## About

This container is based on the the latest Long Term Support (LTS) [Ubuntu (Docker Official Image)](https://hub.docker.com/_/ubuntu) image along with the latest LTS releases of .NET Core Runtime and PowerShell Core.

### **Sponsorship**

If this image is part of your daily workflow—whether as an individual developer or in your team's CI/CD pipelines—consider [sponsoring on GitHub](https://github.com/sponsors/jmcombs). Sponsorship helps fund ongoing maintenance, timely .NET and PowerShell LTS updates, and improvements to the prompt and testing infrastructure relied on in automated environments.

### Enhanced Prompt Features

This container includes an enhanced PowerShell experience with:

- <a href="https://ohmyposh.dev/" target="_blank" rel="noreferrer noopener"><strong>Oh My Posh</strong></a> with <a href="https://github.com/JanDeDobbeleer/oh-my-posh/blob/main/themes/blue-psl-10k.omp.json" target="_blank" rel="noreferrer noopener"><strong>Blue PSL 10K theme</strong></a> - Beautiful two-line prompt with Git integration, execution time, and multi-language support
- <a href="https://github.com/devblackops/Terminal-Icons" target="_blank" rel="noreferrer noopener"><strong>Terminal-Icons</strong></a> - Colorized directory listings with file type icons (pre-installed)
- <a href="https://learn.microsoft.com/powershell/module/psreadline/" target="_blank" rel="noreferrer noopener"><strong>PSReadLine</strong></a> - Enhanced command-line editing with predictive IntelliSense (pre-installed)
- **Nerd Font support** - Icons and glyphs for improved visual experience (requires host font configuration)

## Versions

This repository does automated weekly builds with the latest published LTS versions of .NET Core and PowerShell Core. Below are the current versions included in the latest build.

| Component         | Version |
| ----------------- | ------- |
| .NET Core Runtime | 10.0.1  |
| PowerShell Core   | 7.4.12  |

## How to Use

### **Requirements**

- Container's non-root and default user is `coder`
- Container's default shell is `pwsh`
- Container's default working directory is `/home/coder`
- Host terminal must use a Nerd Font (for example, MesloLGM Nerd Font) for prompt icons; fonts are installed on the host, not inside the container.
- Oh My Posh with Blue PSL 10K theme is enabled by default; see [Environment Variables](#environment-variables) for customization options.

### **Running Container**

```shell
# Default - Blue PSL 10K theme (works offline, no internet required)
docker run -it jmcombs/powershell
```

### **Environment Variables**

Customize the Oh My Posh prompt behavior at runtime using environment variables:

| Variable          | Default   | Description                                                   |
| ----------------- | --------- | ------------------------------------------------------------- |
| `ENABLE_OHMYPOSH` | `true`    | Set to `false` or `0` to disable Oh My Posh entirely          |
| `OHMYPOSH_THEME`  | _(empty)_ | Theme name or URL; if empty, uses embedded Blue PSL 10K theme |

#### Examples

```shell
# Disable Oh My Posh (use basic PowerShell prompt)
docker run -it -e ENABLE_OHMYPOSH=false jmcombs/powershell

# Use a built-in Oh My Posh theme (downloads from GitHub)
docker run -it -e OHMYPOSH_THEME=atomic jmcombs/powershell
docker run -it -e OHMYPOSH_THEME=jandedobbeleer jmcombs/powershell
docker run -it -e OHMYPOSH_THEME=paradox jmcombs/powershell

# Use a custom theme from URL
docker run -it -e OHMYPOSH_THEME=https://example.com/my-theme.omp.json jmcombs/powershell
```

### **Theme Fallback Behavior**

The container implements a robust fallback hierarchy:

1. **Primary**: Uses theme specified in `OHMYPOSH_THEME` (if set)
2. **Fallback**: If the specified theme fails to load, automatically falls back to embedded Blue PSL 10K theme
3. **Basic**: If all else fails, uses the basic PowerShell prompt

This ensures the container always starts with a working prompt, even without internet connectivity.

## Development

### **Testing**

This repository uses [bats-core](https://github.com/bats-core/bats-core) for both unit and integration tests.

- **Unit tests (`tests/unit/`)** validate local behavior such as script structure, helper functions, environment file validation, and PowerShell profile logic. They do not require network access.
- **Integration tests (`tests/integration/`)** run the version discovery script against the live Microsoft and GitHub endpoints and exercise the built Docker image with various environment variable configurations. These tests require network access and Docker.

**Test Coverage:**

- .NET and PowerShell LTS version discovery
- Docker image build and runtime behavior
- Oh My Posh environment variables (`ENABLE_OHMYPOSH`, `OHMYPOSH_THEME`)
- Container info display control (`SHOW_CONTAINER_INFO`)
- Theme loading (default, built-in, custom URL, fallback scenarios)
- PowerShell profile initialization and module loading

To run tests locally:

```shell
# Install bats-core (if not already installed)
git clone https://github.com/bats-core/bats-core.git
cd bats-core && sudo ./install.sh /usr/local

# Run offline unit tests
bats tests/unit/

# Run live integration tests (requires network and Docker)
bats tests/integration/
```

### **Contributing**

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on contributing to this project.
