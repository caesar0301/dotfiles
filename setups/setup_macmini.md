# Mac Mini Setup

## Tailscale

```
brew install tailscale
sudo brew services start tailscale
tailscale up
```

## pm2

To enable `ccr` and `opencode`

```
pm2 start ccr --name ccr -- start
pm2 save
pm2 status ccr
pm2 logs ccr
pm2 restart ccr
```

```
pm2 start "opencode web --hostname 0.0.0.0 --port 14096" --name "opencode-web"
pm2 status
pm2 delete opencode-web
```