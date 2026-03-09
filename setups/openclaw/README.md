# Configure openclaw

## Workspace

1. Copy ~/.dotfiles/setups/openclaw to ~/openclaw_workspace
2. Create tunnel and get token from Claudflare. Replace $CF_TUNNEL_TOKEN
3. Docker compose up to run openclaw in docker containers

## Configure

1. Generate gateway token and approve device:
```
docker exec openclaw-agent sh -lc 'node openclaw.mjs dashboard --no-open'
docker exec openclaw-agent sh -lc 'node openclaw.mjs devices list'
docker exec openclaw-agent sh -lc 'node openclaw.mjs devices approve c97db7af-bced-4209-9136-afa18e6163ef'
```
