# Mihomo via Docker (macOS focused)

This setup runs Mihomo (Clash Meta core) in Docker and exposes local proxy ports.
It is designed to replace GUI clients with a lightweight containerized workflow.

## Files

- `docker-compose.yaml`: Container definition.
- `start.sh`: Startup helper with support for custom config directory.
- `config/config.yaml`: Minimal starter config.

## Quick start

```bash
cd setups/mihomo
./start.sh
```

By default this uses `setups/mihomo/config/config.yaml`.

## Use your own config

Prepare a directory that contains `config.yaml`, then:

```bash
./start.sh -c ~/.config/mihomo
```

The directory is mounted into container path `/root/.config/mihomo`.

## Exposed ports

- `7890`: Mixed HTTP/SOCKS proxy.
- `7891`: Extra optional port.
- `9090`: External controller API.

## macOS system proxy setup

1. Open **System Settings** -> **Network**.
2. Select your active network (e.g. Wi-Fi) -> **Details**.
3. Open **Proxies**.
4. Enable HTTP and HTTPS proxy with:
   - Host: `127.0.0.1`
   - Port: `7890`
5. (Optional) Enable SOCKS proxy with `127.0.0.1:7890`.

## Web console

Mihomo exposes controller API on `127.0.0.1:9090`.
Use Web dashboard:

- https://metacubex.github.io/metacubexd/#/

In the dashboard settings, connect to `http://127.0.0.1:9090`.

## Notes

- TUN mode is intentionally not supported in this setup.
- This mode relies on system proxy settings instead of kernel-level VPN interception.
