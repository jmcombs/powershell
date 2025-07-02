# Contributing to PowerShell Container Project

Thank you for your interest in contributing to this project! This document provides guidelines and information for contributors.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Testing](#testing)
- [Code Style](#code-style)
- [Submitting Changes](#submitting-changes)
- [Issue Reporting](#issue-reporting)

## Getting Started

This project maintains LTS versions of PowerShell Core and .NET Core in Linux containers. The main components include:

- **Docker container**: Multi-architecture Linux container with PowerShell and .NET Core
- **Version detection script**: Bash script that fetches latest LTS versions
- **CI/CD pipeline**: Automated builds and deployments
- **Testing framework**: Comprehensive test suite using bats-core

## Development Setup

### Prerequisites

- Docker and Docker Buildx
- Bash 4.0 or later
- curl and jq for API calls
- Git for version control

### Local Development

1. **Clone the repository**:
   ```bash
   git clone https://github.com/jmcombs/powershell.git
   cd powershell
   ```

2. **Install testing dependencies**:
   ```bash
   # Install bats-core for testing
   git clone https://github.com/bats-core/bats-core.git
   cd bats-core && sudo ./install.sh /usr/local
   cd .. && rm -rf bats-core
   
   # Install shellcheck for script validation
   sudo apt-get install shellcheck  # Ubuntu/Debian
   brew install shellcheck          # macOS
   ```

3. **Make scripts executable**:
   ```bash
   chmod +x scripts/*.sh
   ```

## Testing

This project uses a comprehensive testing strategy with multiple test types:

### Test Structure

```
tests/
├── test_helper.bash          # Common test utilities and setup
├── mocks/                    # Mock data for testing
│   ├── dotnet_releases_index.json
│   ├── dotnet_releases.json
│   └── powershell_release.json
├── unit/                     # Unit tests with mocked dependencies
│   └── test_get_net_pwsh_versions.bats
└── integration/              # Integration tests with real network calls
    └── test_script_integration.bats
```

### Running Tests

```bash
# Run all tests
bats tests/

# Run specific test categories
bats tests/unit/              # Unit tests only
bats tests/integration/       # Integration tests only

# Run specific test file
bats tests/unit/test_get_net_pwsh_versions.bats

# Run tests with verbose output
bats -t tests/
```

### Test Categories

1. **Unit Tests**: Test individual functions with mocked dependencies
   - Fast execution
   - No network dependencies
   - Test edge cases and error conditions

2. **Integration Tests**: Test complete workflows with real API calls
   - Slower execution
   - Require network access
   - Test real-world scenarios

3. **Script Validation**: Static analysis and syntax checking
   - Shellcheck for bash script quality
   - Syntax validation
   - Permission checks

### Writing Tests

When adding new functionality:

1. **Write unit tests first** for new functions
2. **Add integration tests** for end-to-end workflows
3. **Update mock data** if API responses change
4. **Test error conditions** and edge cases

Example test structure:
```bash
@test "descriptive test name" {
    # Arrange: Set up test conditions
    
    # Act: Execute the code being tested
    run your_function_or_command
    
    # Assert: Verify the results
    [ "$status" -eq 0 ]
    [[ "$output" =~ "expected pattern" ]]
}
```

## Code Style

### Bash Scripts

- Use `#!/bin/bash` shebang
- Follow [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- Use `set -e` for error handling where appropriate
- Quote variables: `"$variable"` not `$variable`
- Use meaningful function and variable names
- Add comments for complex logic

### Testing

- Use descriptive test names that explain what is being tested
- Group related tests in the same file
- Use the `load '../test_helper'` pattern for shared utilities
- Clean up test artifacts in teardown functions

## Submitting Changes

### Branch Naming

Use descriptive branch names with prefixes:
- `feature/description` - New features
- `fix/description` - Bug fixes
- `test/description` - Test improvements
- `docs/description` - Documentation updates

### Commit Messages

Follow conventional commit format:
```
type(scope): description

Longer explanation if needed

Fixes #issue-number
```

Types: `feat`, `fix`, `test`, `docs`, `ci`, `refactor`

### Pull Request Process

1. **Create a feature branch** from `main`
2. **Make your changes** with appropriate tests
3. **Run the test suite** locally: `bats tests/`
4. **Run shellcheck** on modified scripts
5. **Update documentation** if needed
6. **Submit a pull request** with:
   - Clear description of changes
   - Reference to related issues
   - Test results summary

### Pull Request Checklist

- [ ] Tests pass locally
- [ ] New functionality includes tests
- [ ] Documentation updated if needed
- [ ] Commit messages follow convention
- [ ] No merge conflicts with main branch
- [ ] Scripts pass shellcheck validation

## Issue Reporting

### Bug Reports

Use the bug report template and include:
- Clear description of the issue
- Steps to reproduce
- Expected vs actual behavior
- Environment details (OS, Docker version, etc.)
- Relevant logs or error messages

### Feature Requests

Use the feature request template and include:
- Clear description of the proposed feature
- Use case and motivation
- Possible implementation approach
- Any breaking changes considerations

## Getting Help

- **Issues**: Use GitHub issues for bugs and feature requests
- **Discussions**: Use GitHub discussions for questions and ideas
- **Documentation**: Check README.md and inline code comments

## License

By contributing to this project, you agree that your contributions will be licensed under the same license as the project (see LICENSE file).

Thank you for contributing! 🎉
