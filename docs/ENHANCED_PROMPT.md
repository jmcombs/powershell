# Enhanced PowerShell Prompt Features

This document describes the enhanced PowerShell prompt features available in the container, inspired by Scott Hanselman's "Ultimate PowerShell Prompt" setup.

## Features Overview

### 🎨 Oh My Posh Integration
- **Modern prompt themes** with Git integration
- **Custom container-optimized theme** with essential information
- **Powerline-style segments** showing path, Git status, execution time
- **Cross-platform compatibility** across all supported architectures

### 🔤 Enhanced Typography
- **Nerd Fonts (CaskaydiaCove)** with special glyphs and icons
- **Unicode support** for enhanced visual elements
- **Fallback handling** for terminals without font support

### 📁 Terminal-Icons Module
- **Colorized directory listings** with file type icons
- **Enhanced `ls`/`dir` commands** with visual file type indicators
- **Improved file system navigation** experience

### ⌨️ PSReadLine Enhancements
- **Predictive IntelliSense** based on command history
- **Custom key bindings** for common operations
- **Enhanced command-line editing** with improved navigation

## Prompt Segments

The container-optimized theme displays the following information:

1. **User@Host** - Current user and hostname (container ID)
2. **Current Path** - Working directory with folder icons
3. **Git Status** - Branch, changes, stash count (when in Git repo)
4. **.NET Version** - Current .NET runtime version
5. **Execution Time** - Command execution time (for long-running commands)
6. **Exit Status** - Success/failure indicator
7. **Shell & Time** - Current shell and timestamp (right-aligned)

## Custom Functions

### `Show-ContainerInfo` / `info`
Displays comprehensive container information including:
- PowerShell version
- .NET runtime version
- Operating system details
- Architecture information
- Current working directory
- Git branch (if in a Git repository)

```powershell
# Usage
info
# or
Show-ContainerInfo
```

## Key Bindings

The following custom key bindings are available:

- **Ctrl+Shift+B** - Insert `dotnet build` command
- **Ctrl+D** - Delete character
- **Ctrl+W** - Delete word backward
- **Alt+D** - Delete word forward
- **Ctrl+Left/Right** - Move by word

## Configuration Files

### PowerShell Profile
- **Location**: `/home/coder/.config/powershell/Microsoft.PowerShell_profile.ps1`
- **Purpose**: Initializes Oh My Posh, loads modules, sets up key bindings

### Oh My Posh Theme
- **Location**: `/home/coder/.config/powershell/ohmyposh-container.json`
- **Purpose**: Container-optimized theme configuration

## Customization

### Using a Different Theme
To use a different Oh My Posh theme, you can:

1. **Use a built-in theme**:
   ```powershell
   oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/THEME_NAME.omp.json' | Invoke-Expression
   ```

2. **Mount a custom theme**:
   ```bash
   docker run -it -v /path/to/your/theme.json:/home/coder/.config/powershell/custom-theme.json jmcombs/powershell
   ```

### Environment Variables
You can customize behavior using environment variables:

- `OHMYPOSH_THEME` - Path to custom theme file
- `DISABLE_OHMYPOSH` - Set to "true" to disable Oh My Posh
- `DISABLE_TERMINAL_ICONS` - Set to "true" to disable Terminal-Icons

## Troubleshooting

### Fonts Not Displaying Correctly
If you see squares or missing glyphs:
1. Ensure your terminal supports Nerd Fonts
2. Install CaskaydiaCove NF font on your host system
3. Configure your terminal to use the Nerd Font

### Performance Issues
If the prompt feels slow:
1. Check if you're in a large Git repository
2. Consider disabling Git status fetching in the theme
3. Use a simpler theme for better performance

### Module Loading Errors
If PowerShell modules fail to load:
1. Check internet connectivity during container build
2. Verify PowerShell Gallery access
3. Check container logs for specific error messages

## Compatibility

### Terminal Emulators
Tested and compatible with:
- Windows Terminal
- VS Code Integrated Terminal
- iTerm2 (macOS)
- GNOME Terminal (Linux)
- Default Docker terminal

### Host Operating Systems
- ✅ Windows 10/11
- ✅ macOS (Intel & Apple Silicon)
- ✅ Linux (Ubuntu, Debian, CentOS, etc.)

### Container Architectures
- ✅ linux/amd64
- ✅ linux/arm64
- ✅ linux/arm/v7

## Performance Metrics

Typical performance characteristics:
- **Container startup**: +1-2 seconds additional time
- **Prompt rendering**: <100ms
- **Memory overhead**: ~30-40MB additional
- **Container size increase**: ~150-200MB

## References

- [Oh My Posh Documentation](https://ohmyposh.dev/)
- [Terminal-Icons GitHub](https://github.com/devblackops/Terminal-Icons)
- [PSReadLine Documentation](https://docs.microsoft.com/en-us/powershell/module/psreadline/)
- [Scott Hanselman's Blog Post](https://www.hanselman.com/blog/my-ultimate-powershell-prompt-with-oh-my-posh-and-the-windows-terminal)
