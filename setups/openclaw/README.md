# Configure openclaw

Generate gateway token and approve device:

```
docker exec openclaw-agent sh -lc 'node openclaw.mjs dashboard --no-open'
docker exec openclaw-agent sh -lc 'node openclaw.mjs devices list'
docker exec openclaw-agent sh -lc 'node openclaw.mjs devices approve c97db7af-bced-4209-9136-afa18e6163ef'
```
