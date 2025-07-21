# Bin Directory - Custom Tools and Utilities

This directory contains custom tools and utilities, including the `xxx-dotme` series of personalized tools designed to enhance development workflows.

## Overview

The `xxx-dotme` series consists of wrapper scripts and enhanced versions of common development tools, customized for personal use cases and improved user experience.

## Tools Overview

### Google Java Format (`google-java-format-dotme`)

An enhanced wrapper for Google Java Format with improved Java detection, error handling, and user experience.

**Features:**
- Automatic Java installation detection (macOS, Linux)
- Multiple JAR file location support
- Java version compatibility checking
- Colored output and informative messages
- Dry-run mode for safe testing
- Comprehensive help and version information

**Usage:**
```bash
# Format a single file
google-java-format-dotme MyFile.java

# Check setup and versions
google-java-format-dotme --check-version

# Dry run to see what would be formatted
google-java-format-dotme --dry-run *.java

# Format directory in-place
google-java-format-dotme -i src/main/java/

# Get help
google-java-format-dotme --help
```

**Environment Variables:**
- `JAVA_HOME_4GJF`: Preferred Java installation for GJF
- `JAVA_HOME`: Fallback Java installation
- `GJF_JAR_FILE`: Custom path to GJF JAR file

### Homebrew Wrapper (`brew-dotme`)

Enhanced Homebrew wrapper with cross-platform support and pyenv conflict resolution.

**Features:**
- Automatic Homebrew path detection (macOS Intel/Apple Silicon, Linux)
- pyenv conflict resolution
- Performance optimizations
- Better error handling

**Usage:**
```bash
# Use like regular brew
brew-dotme install package-name
brew-dotme update
brew-dotme upgrade
```

## Installation and Setup

### Prerequisites

1. **Google Java Format:**
   - Java 8 or higher
   - Google Java Format JAR file (automatically detected from common locations)

2. **Homebrew Wrapper:**
   - Homebrew installed (automatically detected)
   - Optional: pyenv (conflicts are automatically resolved)

### Setup

1. Make scripts executable:
   ```bash
   chmod +x bin/*
   ```

2. Add to PATH (add to your shell profile):
   ```bash
   export PATH="$HOME/.dotfiles/bin:$PATH"
   ```

3. Configure environment variables (optional):
   ```bash
   # For Google Java Format
   export JAVA_HOME_4GJF="/path/to/preferred/java"
   export GJF_JAR_FILE="/path/to/gjf.jar"
   ```

## Common Locations

### Google Java Format JAR Locations
The script automatically checks these locations:
- `$HOME/.local/share/google-java-format/google-java-format-all-deps.jar`
- `$HOME/.cache/google-java-format/google-java-format-all-deps.jar`
- `/usr/local/share/google-java-format/google-java-format-all-deps.jar`
- `/opt/google-java-format/google-java-format-all-deps.jar`

### Java Installation Locations
The script checks these common Java locations:
- `/usr/lib/jvm/default-java` (Linux)
- `/usr/lib/jvm/java-11-openjdk` (Linux)
- `/usr/lib/jvm/java-8-openjdk` (Linux)
- `/Library/Java/JavaVirtualMachines/adoptopenjdk-11.jdk/Contents/Home` (macOS)
- `/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home` (macOS)
- `/System/Library/Java/JavaVirtualMachines/1.8.jdk/Contents/Home` (macOS)

### Homebrew Locations
The script checks these Homebrew locations:
- `/usr/local/bin/brew` (Intel Mac, Linux)
- `/opt/homebrew/bin/brew` (Apple Silicon Mac)
- `/home/linuxbrew/.linuxbrew/bin/brew` (Linux)
- `$HOME/.linuxbrew/bin/brew` (User-installed Linux)

## Troubleshooting

### Google Java Format Issues

1. **"Java not found" error:**
   - Install Java 8 or higher
   - Set `JAVA_HOME` environment variable
   - Or set `JAVA_HOME_4GJF` for specific Java version

2. **"Google Java Format JAR not found" error:**
   - Download Google Java Format JAR
   - Set `GJF_JAR_FILE` environment variable
   - Or place JAR in one of the default locations

3. **Java version compatibility:**
   - Use `--check-version` to verify setup
   - Ensure Java 8+ is installed

### Homebrew Wrapper Issues

1. **"Homebrew not found" error:**
   - Install Homebrew from https://brew.sh
   - Ensure it's in one of the expected locations

2. **pyenv conflicts:**
   - The script automatically resolves pyenv conflicts
   - No manual intervention required

## Contributing

When adding new tools to the `xxx-dotme` series:

1. Follow the naming convention: `tool-name-dotme`
2. Include comprehensive error handling
3. Add colored output for better UX
4. Provide help/usage information
5. Support common environment variables
6. Add cross-platform compatibility
7. Update this README with documentation

## Best Practices

1. **Always use the wrapper scripts** instead of calling tools directly
2. **Set up environment variables** for consistent behavior
3. **Use dry-run modes** when available for safe testing
4. **Check tool versions** before running on important files
5. **Keep tools updated** for latest features and bug fixes

## Related Documentation

- [Google Java Format Documentation](https://github.com/google/google-java-format)
- [Homebrew Documentation](https://docs.brew.sh/)
- [Java Installation Guide](https://adoptium.net/)

---

*Last updated: $(date)*
