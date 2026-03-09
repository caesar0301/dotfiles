# Configure openclaw

## Cloudflare

1. Create new tunnel with your domain name, with target service `http://openclaw:18789` (openclaw is docker service name in docker-compose.yml)

## Workspace

1. Copy ~/.dotfiles/setups/openclaw to ~/openclaw_workspace
2. Create tunnel and get token from Claudflare. Replace $CF_TUNNEL_TOKEN
3. Docker compose up to run openclaw in docker containers

## Configure

1. Configure gateway to listen on lan: Edit `config/openclaw.json` and add gateway subfield:
```
{
  "gateway": {
    "bind": "lan",
    "controlUi": {
      "allowedOrigins": [
        "https://your.domain.name"
      ]
    }
  }
}
```

2. Generate gateway token and approve device:
```
docker exec openclaw-agent sh -lc 'node openclaw.mjs dashboard --no-open'
docker exec openclaw-agent sh -lc 'node openclaw.mjs devices list'
docker exec openclaw-agent sh -lc 'node openclaw.mjs devices approve c97db7af-bced-4209-9136-afa18e6163ef'
```
