# Systemd Service Units

This directory contains systemd service unit files for managing various services.

## Available Services

| Service | Description | Type |
|---------|-------------|------|
| `mihomo.service` | Mihomo (Clash Meta) proxy daemon | System service |
| `colima.service` | Colima container runtime (Docker alternative) | User service |
| `minikube.service` | Minikube Kubernetes cluster | System service |
| `aliyunpan-sync.service` | Aliyun Drive file synchronization | User service |

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

# Aliyunpan sync service
mkdir -p ~/.config/systemd/user
cp aliyunpan-sync.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable aliyunpan-sync
systemctl --user start aliyunpan-sync
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

### aliyunpan-sync.service

Syncs files between local directory and Aliyun Drive. This service:
- Runs after network is online
- Configurable via environment variables
- Automatically restarts on failure
- Includes security hardening options

**Prerequisites:**
- aliyunpan binary installed (`pip install aliyunpan` or download from GitHub)
- Authenticated with Aliyun Drive (run `aliyunpan login` first)

**Configuration:**

The service can be configured via environment variables in the service file:

| Variable | Default | Description |
|----------|---------|-------------|
| `ALIYUNPAN_VERBOSE` | `0` | Enable verbose logging |
| `ALIYUNPAN_CONFIG_DIR` | `~/.config/aliyunpan` | Config directory |
| `LOCAL_DIR` | `~/Documents/Aliyunpan` | Local sync directory |
| `PAN_DIR` | `/Research` | Remote directory on Aliyun Drive |
| `SYNC_MODE` | `download` | Sync mode: `upload` or `download` |
| `DRIVE_TYPE` | `resource` | Drive type: `backup` or `resource` |

To customize, edit `~/.config/systemd/user/aliyunpan-sync.service` after copying.

