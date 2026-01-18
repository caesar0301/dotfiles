# Development Environment Installer Scripts

This directory contains standalone installer scripts for various development tools and environments. These scripts are designed to be used both independently and through the `shmisc.sh` library functions.

## Available Installers

### Python Development
- **`install-uv.sh`** - Installs uv Python package manager
- **`install-pyenv.sh`** - Installs pyenv Python version manager

### Java Development
- **`install-jenv.sh`** - Installs jenv Java version manager
- **`install-jdt-language-server.sh`** - Installs Eclipse JDT Language Server
- **`install-google-java-format.sh`** - Installs Google Java Format tool

### Go Development
- **`install-gvm.sh`** - Installs Go Version Manager (GVM)
- **`install-golang.sh`** - Installs Go programming language

### Node.js Development
- **`install-nvm.sh`** - Installs Node Version Manager (nvm)

### Rust Development
- **`install-cargo.sh`** - Installs Rust and Cargo

### Text Editors & Tools
- **`install-neovim.sh`** - Installs Neovim text editor
- **`install-fzf.sh`** - Installs fzf fuzzy finder
- **`install-shfmt.sh`** - Installs shfmt shell formatter

### Fonts & UI
- **`install-hack-nerd-font.sh`** - Installs Hack Nerd Font

### AI Development
- **`install-ai-code-agents.sh`** - Installs various AI code agents

## Usage

### Standalone Usage

Each script can be run independently:

```bash
# Install a specific tool
./install-neovim.sh

# Install with custom version
./install-golang.sh 1.25.0

# Install with custom shfmt version
./install-shfmt.sh v3.8.0
```

### Through shmisc.sh Library

The scripts are also accessible through the `shmisc.sh` library functions, maintaining backward compatibility:

```bash
# Source the library
source lib/shmisc.sh

# Use the installer functions
install_neovim
install_golang 1.25.0
```

## Features

- **Platform Detection**: Automatically detects macOS vs Linux and x86_64 vs ARM64
- **Version Management**: Supports custom version specifications
- **Shell Integration**: Automatically configures shell profiles when needed
- **Error Handling**: Comprehensive error handling and user feedback
- **Dependency Checking**: Verifies prerequisites before installation
- **Backup Support**: Creates backups of existing configurations
- **Verification**: Validates installations after completion

## Requirements

All scripts require the `shmisc.sh` library to be available in the same directory. The library provides:

- Logging and messaging functions
- Path and file utilities
- System information detection
- Package management helpers

## Architecture

Each installer script follows a consistent pattern:

1. **Header**: Script description and copyright information
2. **Library Import**: Sources the `shmisc.sh` library
3. **Main Function**: Contains the installation logic
4. **Direct Execution**: Runs main function if script is executed directly
5. **Error Handling**: Comprehensive error checking and user feedback

## Benefits

- **Modularity**: Each tool has its own dedicated installer
- **Maintainability**: Easier to update and maintain individual tools
- **Reusability**: Scripts can be used independently or as part of larger workflows
- **Compatibility**: Maintains backward compatibility with existing `shmisc.sh` functions
- **Testing**: Individual installers can be tested in isolation

## Contributing

When adding new installer scripts:

1. Follow the existing naming convention: `install-{tool-name}.sh`
2. Include comprehensive header documentation
3. Source the `shmisc.sh` library
4. Implement proper error handling
5. Add the corresponding function to `shmisc.sh` for compatibility
6. Make the script executable with `chmod +x`
7. Test both standalone and library function usage

## License

MIT License - see the main project LICENSE file for details.
