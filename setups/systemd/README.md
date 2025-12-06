# Systemd Service Units

This directory contains systemd service unit files for managing various services.

## Available Services

| Service | Description | Type |
|---------|-------------|------|
| `mihomo.service` | Mihomo (Clash Meta) proxy daemon | System service |
| `colima.service` | Colima container runtime (Docker alternative) | User service |
| `minikube.service` | Minikube Kubernetes cluster | System service |

## Installation

### System-wide Services

Copy service files to `/etc/systemd/system/` for system-wide services:

```bash
# Mihomo proxy service
sudo cp mihomo.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable mihomo
sudo systemctl start mihomo

# Minikube service
sudo cp minikube.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable minikube
sudo systemctl start minikube
```

### User Services

For user-level services, copy to `~/.config/systemd/user/`:

```bash
# Colima container runtime
mkdir -p ~/.config/systemd/user
cp colima.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable colima
systemctl --user start colima
```

## Service Management

```bash
# Check service status
systemctl status mihomo
systemctl --user status colima

# View logs
journalctl -u mihomo -f
journalctl --user -u colima -f

# Restart service
sudo systemctl restart mihomo
systemctl --user restart colima

# Stop service
sudo systemctl stop mihomo
systemctl --user stop colima
```

## Service Details

### mihomo.service

Mihomo (formerly Clash Meta) is a rule-based tunnel proxy. This service:
- Starts after network is available
- Reads configuration from `/etc/mihomo/`
- Has elevated capabilities for network operations
- Automatically restarts on failure

**Prerequisites:**
- Binary installed at `/usr/local/bin/mihomo`
- Configuration at `/etc/mihomo/config.yaml`

### colima.service

Colima provides container runtimes on Linux/macOS with minimal setup. This service:
- Runs in foreground mode for proper systemd integration
- Automatically restarts on failure
- Uses Homebrew-installed binary

**Prerequisites:**
- Colima installed via Homebrew (`brew install colima`)

### minikube.service

Minikube runs a local Kubernetes cluster. This service:
- Starts after Docker service is available
- Runs as a oneshot service (starts cluster and exits)
- Persists state after exit (`RemainAfterExit=true`)

**Prerequisites:**
- Docker installed and running
- Minikube binary at `/usr/bin/minikube`

