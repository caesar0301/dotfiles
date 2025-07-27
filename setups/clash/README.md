# Install Mihomo (original ClashMeta)

Download from https://github.com/MetaCubeX/mihomo/releases

sudo systemctl status mihomo

## Update config

`clash_config_fetcher.py`

Fetch clash config from remote server. Two vars are supported:
* V2SS_LINK: v2ss config registration link
* TROJAN_LINK: trojanflare.com registration link

## Running the script from anywhere

The `run_batch.sh` script has been optimized to work from any directory. You can now run it from anywhere:

```bash
# Set your TrojanFlare URL
export TROJANFLARE_CLASHX_URL="your_trojanflare_url_here"

# Run from any directory
/path/to/clash/run_batch.sh

# Or make it executable and run directly
chmod +x /path/to/clash/run_batch.sh
/path/to/clash/run_batch.sh
```

The script automatically:
1. Determines its own directory location
2. Changes to that directory before execution
3. Uses absolute paths for all resource files (rules/, ruleset/, etc.)
4. Generates both `config.latest` and `config.gfwlist` files
