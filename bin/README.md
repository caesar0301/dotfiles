# Bin Directory - Custom Tools and Utilities

This directory contains custom tools and utilities, including the `dotme-xxx` series of personalized tools designed to enhance development workflows.

## Overview

The `dotme-xxx` series consists of wrapper scripts and enhanced versions of common development tools, customized for personal use cases and improved user experience.

## Tools Overview

### Google Java Format (`dotme-google-java-format`)

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
dotme-google-java-format MyFile.java

# Check setup and versions
dotme-google-java-format --check-version

# Dry run to see what would be formatted
dotme-google-java-format --dry-run *.java

# Format directory in-place
dotme-google-java-format -i src/main/java/

# Get help
dotme-google-java-format --help
```

**Environment Variables:**
- `JAVA_HOME_4GJF`: Preferred Java installation for GJF
- `JAVA_HOME`: Fallback Java installation
- `GJF_JAR_FILE`: Custom path to GJF JAR file

### GPG Helper (`dotme-gpg`)

Convenient GPG operations using key aliases for encryption and decryption.

**Usage:**
```bash
# Decrypt and display
dotme-gpg dec <alias> <encrypted_file>

# Encrypt file
dotme-gpg enc <alias> <file_to_encrypt>

# Decrypt, edit, and re-encrypt
dotme-gpg edit <alias> <encrypted_file>
```

### Decrypt Zshenv (`dotme-decrypt-zshenv`)

Decrypt and set up local zshenv environment file.

**Usage:**
```bash
# Decrypt with default alias
dotme-decrypt-zshenv

# Decrypt with specific alias
dotme-decrypt-zshenv my-alias

# Decrypt specific file
dotme-decrypt-zshenv my-alias /path/to/file.enc
```

### Run Container (`dotme-run-container`)

Docker container runner with convenient mount and proxy configurations.

**Usage:**
```bash
# Run container with volume mount
dotme-run-container my-image:latest /path/to/host:/path/in/container
```

### Install Python (`dotme-install-python`)

Python installation helper with version management support.

### Rsync Parallel (`dotme-rsync-parallel`)

Parallel rsync wrapper for faster file synchronization.

## Installation and Setup

### Prerequisites

1. **Google Java Format:**
   - Java 8 or higher
   - Google Java Format JAR file (automatically detected from common locations)

2. **GPG Helper:**
   - GPG installed and configured
   - Valid GPG keys for aliases

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

### GPG Issues

1. **"No GPG private key found" error:**
   - Import your GPG private key
   - Verify key aliases are configured correctly

## Contributing

When adding new tools to the `dotme-xxx` series:

1. Follow the naming convention: `dotme-tool-name`
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
- [GPG Documentation](https://gnupg.org/documentation/)
- [Java Installation Guide](https://adoptium.net/)

---

*Last updated: 2024*
