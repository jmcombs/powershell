# powershell

LTS versions of PowerShell Core and .NET Core in Linux. Published for 64-bit `x86` and `ARM` architectures.

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/jmcombs/powershell/ci.yml?logo=github)
[![Docker Pulls](https://img.shields.io/docker/pulls/jmcombs/powershell)](https://hub.docker.com/r/jmcombs/powershell "Click to view the image on Docker Hub")
[![Docker Stars](https://img.shields.io/docker/stars/jmcombs/powershell)](https://hub.docker.com/r/jmcombs/powershell "Click to view the image on Docker Hub")
[![Github Issues](https://img.shields.io/github/issues/jmcombs/powershell)](https://github.com/jmcombs/powershell/issues "Click to view or open issues")
[![GitHub Sponsors](https://img.shields.io/github/sponsors/jmcombs)](https://github.com/sponsors/jmcombs "Sponsor this project")
![Oh My Posh Theme](https://img.shields.io/badge/Oh_My_Posh-Blue_PSL_10K-3465a4?logo=windowsterminal&logoColor=white)

## About

This container is based on the the latest Long Term Support (LTS) [Ubuntu (Docker Official Image)](https://hub.docker.com/_/ubuntu) image along with the latest LTS releases of .NET Core Runtime and PowerShell Core.

### ✨ Enhanced Prompt Features

This container includes an enhanced PowerShell experience with:

- **Oh My Posh** with **Blue PSL 10K theme** - Beautiful two-line prompt with Git integration, execution time, and multi-language support
- **Terminal-Icons** - Colorized directory listings with file type icons (pre-installed)
- **PSReadLine** - Enhanced command-line editing with predictive IntelliSense (pre-installed)
- **Nerd Font support** - Icons and glyphs for improved visual experience (requires host font configuration)
- **Offline-ready** - Embedded theme works without internet connectivity

See [Enhanced Prompt Documentation](docs/ENHANCED_PROMPT.md) for detailed information.

## Versions

This repository does automated weekly builds with the latest published LTS versions of .NET Core and PowerShell Core. Below are the current versions included in the latest build.

| Component         | Version |
| ----------------- | ------- |
| .NET Core Runtime | 10.0.1  |
| PowerShell Core   | 7.4.12   |

## How to Use

### **Requirements**

- Container's non-root and default user is `coder`
- Container's default shell is `pwsh`
- Container's default working directory is `/home/coder`

### **⚠️ Important: Host Font Configuration**

The Oh My Posh prompt uses **Nerd Font glyphs** for icons and special characters. **Fonts must be installed on your HOST machine** (not inside the container) because terminal rendering happens on your local system.

#### Installing a Nerd Font

**Recommended Font**: MesloLGM Nerd Font (officially recommended by Oh My Posh)

```shell
# Using Oh My Posh font installer (if oh-my-posh is installed locally)
oh-my-posh font install meslo

# Or download manually from:
# https://github.com/ryanoasis/nerd-fonts/releases
```

#### Configuring Your Terminal Emulator

After installing the font, configure your terminal to use it:

| Terminal | Setting Location |
|----------|-----------------|
| **Windows Terminal** | Settings → Profiles → Defaults → Appearance → Font face: `MesloLGM Nerd Font` |
| **VS Code** | Settings → Terminal › Integrated: Font Family: `MesloLGM Nerd Font` |
| **iTerm2** | Preferences → Profiles → Text → Font: `MesloLGM Nerd Font` |
| **Ghostty** | Config file: `font-family = MesloLGM Nerd Font` |
| **macOS Terminal** | Preferences → Profiles → Font → Change: `MesloLGM Nerd Font` |

> **Note**: If you see broken/missing characters in the prompt, your terminal is not using a Nerd Font.

### **Running Container**

```shell
# Default - Blue PSL 10K theme (works offline, no internet required)
docker run -it jmcombs/powershell
```

### **Environment Variables**

Customize the Oh My Posh prompt behavior at runtime using environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `ENABLE_OHMYPOSH` | `true` | Set to `false` or `0` to disable Oh My Posh entirely |
| `OHMYPOSH_THEME` | _(empty)_ | Theme name or URL; if empty, uses embedded Blue PSL 10K theme |

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

This repository uses [bats-core](https://github.com/bats-core/bats-core) for testing bash scripts. To run tests locally:

```shell
# Install bats-core (if not already installed)
git clone https://github.com/bats-core/bats-core.git
cd bats-core && sudo ./install.sh /usr/local

# Run all tests
bats tests/

# Run specific test files
bats tests/unit/test_get_net_pwsh_versions.bats
bats tests/integration/test_script_integration.bats
```

### **Contributing**

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on contributing to this project.
