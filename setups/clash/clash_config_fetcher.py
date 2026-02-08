#!/usr/bin/env python3
"""
Clash Configuration Fetcher

A utility script to fetch and process Clash proxy configurations.
Supports remote config fetching, proxy group management, and rule processing.
"""

import argparse
import base64
import copy
import os
import urllib.request
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Any
from urllib.error import URLError

import yaml
from yaml import Loader, safe_load


# -----------------------------------------------------------------------------
# Constants (hard-coded; change here for easy tuning)
# -----------------------------------------------------------------------------
GFWRULES_PATH = "rules/gfwrules.txt"
RULESET_FILES = ["ai-agents.yaml", "news.yaml", "oracle.yaml"]
RULESET_DIR = "ruleset"
USER_AGENT = (
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36 Edg/116.0.1938.69"
)
COUNTRY_GROUP_NAMES = {
    "美国": "AutoUS",
    "日本": "AutoJP",
    "台湾": "AutoTW",
    "香港": "AutoHK",
}
DEFAULT_OUTPUT_PATTERN = "config.%Y%m%d"
TROJAN_SECRET = "canyoukissme"
URL_TEST_URL = "http://www.gstatic.com/generate_204"
URL_TEST_INTERVAL = 300

# Global configuration flags (set from CLI; defaults applied in main())
DEFAULT_MATCH_DIRECT = False
ADD_COUNTRY_GROUPS = False
ADD_GFWLIST = False


def get_script_dir() -> Path:
    """
    Get the directory where this script is located.

    Returns:
        Path object pointing to the script directory
    """
    return Path(__file__).parent.absolute()


def get_resource_path(relative_path: str) -> Path:
    """
    Get absolute path for a resource file relative to the script directory.

    Args:
        relative_path: Path relative to the script directory

    Returns:
        Absolute path to the resource file
    """
    return get_script_dir() / relative_path


def read_remote_config(link: str) -> Optional[Dict[str, Any]]:
    """
    Fetch and parse remote Clash configuration from a URL.

    Args:
        link: URL to the remote configuration file

    Returns:
        Parsed YAML configuration or None if failed
    """
    if not link:
        return None

    try:
        req = urllib.request.Request(link)
        req.add_header("User-Agent", USER_AGENT)

        with urllib.request.urlopen(req) as response:
            return yaml.load(response, Loader=Loader)

    except (URLError, yaml.YAMLError) as e:
        print(f"Error reading remote config: {e}")
        return None


def create_proxy_group(
    name: str,
    proxy_configs: List[Dict[str, Any]],
    extra_names: Optional[List[str]] = None,
    group_type: str = "select",
    url: str = URL_TEST_URL,
    interval: int = URL_TEST_INTERVAL,
) -> Dict[str, Any]:
    """
    Create a proxy group configuration.

    Args:
        name: Group name
        proxy_configs: List of proxy configurations
        extra_names: Additional proxy names to include
        group_type: Group type (select, url-test, etc.)
        url: Test URL for url-test type groups
        interval: Test interval for url-test type groups

    Returns:
        Proxy group configuration dictionary
    """
    if extra_names is None:
        extra_names = []

    new_group = {"name": name, "type": group_type, "proxies": []}

    if group_type == "url-test":
        new_group["interval"] = interval
        new_group["url"] = url

    proxy_names = [proxy["name"] for proxy in proxy_configs]
    new_group["proxies"] = extra_names + proxy_names
    return new_group


def rule_key(rule: str) -> Tuple[str, str]:
    """
    Extract key components from a rule string.

    Args:
        rule: Rule string to parse

    Returns:
        Tuple of (rule_type, rule_value)
    """
    parts = rule.split(",")
    if len(parts) < 3:
        return (parts[0], "")
    return (parts[0], parts[2])


def get_gfw_rules() -> List[str]:
    """
    Read GFW rules from remote GitHub URL first, fallback to local file.

    Returns:
        List of GFW rules
    """
    rules = []
    try:
        local_file = get_resource_path(GFWRULES_PATH)
        with open(local_file, encoding="utf-8") as rule_file:
            for line in rule_file:
                line = line.strip("\r\n ")
                if line and not line.startswith("#"):
                    rules.append(line)
        print(f"Successfully loaded {len(rules)} GFW rules from local file")
    except FileNotFoundError:
        print(f"Warning: {GFWRULES_PATH} not found")
    except Exception as e:
        print(f"Error reading GFW rules: {e}")
    return rules


def read_ruleset_as_rules(result: Dict[str, Any]) -> Dict[str, Any]:
    """
    Read rules from specific ruleset files and add them to the result.

    Args:
        result: Configuration dictionary to modify

    Returns:
        Modified configuration dictionary
    """
    for filename in RULESET_FILES:
        filepath = get_resource_path(f"{RULESET_DIR}/{filename}")
        try:
            with open(filepath, encoding="utf-8") as rule_file:
                extra_rules = safe_load(rule_file)
        except FileNotFoundError:
            print(f"Warning: {filepath} not found")
            continue
        except yaml.YAMLError as e:
            print(f"Error parsing {filepath}: {e}")
            continue

        if "payload" not in extra_rules:
            continue

        for rule in extra_rules["payload"]:
            if "IP-CIDR" not in rule:
                result["rules"].append(f"{rule},Proxy")

    return result


def add_group(target: Dict[str, Any], new_group: Dict[str, Any]) -> None:
    """
    Add or update a proxy group in the target configuration.

    Args:
        target: Target configuration dictionary
        new_group: New group configuration to add/update
    """
    groups = target.get("proxy-groups", [])
    group_name = new_group["name"]

    # Update existing group or add new one
    for i, group in enumerate(groups):
        if group["name"] == group_name:
            groups[i] = new_group
            break
    else:
        groups.append(new_group)

    target["proxy-groups"] = groups


def finalize_rules(config: Dict[str, Any]) -> None:
    """
    Finalize the rules list by adding GFW rules and default match rule.

    Args:
        config: Configuration dictionary to modify
    """
    rules = copy.deepcopy(config["rules"])

    if ADD_GFWLIST:
        gfw_rules = get_gfw_rules()
        rules.extend(gfw_rules)

    # Remove duplicates and sort
    unique_rules = set(rules)
    res = sorted([rule for rule in unique_rules if not rule.startswith("MATCH,")])

    # Add default match rule
    if DEFAULT_MATCH_DIRECT:
        res.append("MATCH,DIRECT")
    else:
        res.append("MATCH,Proxy")

    config["rules"] = [rule for rule in res if all(rule.split(","))]


def finalize_groups(result: Dict[str, Any]) -> Dict[str, Any]:
    """
    Finalize proxy groups by filtering proxies and creating group hierarchy.

    Args:
        result: Configuration dictionary to modify

    Returns:
        Modified configuration dictionary
    """
    # Filter selected proxies by country
    selected_proxies = []
    for country in COUNTRY_GROUP_NAMES:
        country_proxies = [
            proxy for proxy in result["proxies"] if country in proxy["name"]
        ]
        selected_proxies.extend(country_proxies)

    result["proxies"] = selected_proxies

    # Create unified auto group
    auto_group = create_proxy_group(
        name="Auto", proxy_configs=result["proxies"], group_type="url-test"
    )
    add_group(result, auto_group)

    group_names = ["Auto"]

    # Create country-specific groups
    if ADD_COUNTRY_GROUPS:
        for country, group_name in COUNTRY_GROUP_NAMES.items():
            country_proxies = [
                proxy for proxy in result["proxies"] if country in proxy["name"]
            ]
            country_group = create_proxy_group(
                name=group_name, proxy_configs=country_proxies, group_type="url-test"
            )
            add_group(result, country_group)
        group_names.extend(COUNTRY_GROUP_NAMES.values())

    # Create main proxy group
    merged_group = create_proxy_group(
        name="Proxy",
        proxy_configs=result["proxies"],
        group_type="select",
        extra_names=group_names,
    )
    add_group(result, merged_group)

    return result


def main() -> None:
    """Main function to process command line arguments and generate configuration."""
    parser = argparse.ArgumentParser(
        prog="ClashConfigFetcher",
        description="Fetch and process Clash proxy configurations",
    )
    parser.add_argument(
        "-t", "--trojan", type=str, required=True, help="Trojan registration link"
    )
    parser.add_argument(
        "--no-rulesets",
        action="store_true",
        dest="no_rulesets",
        help="Disable predefined ruleset (default: rulesets enabled)",
    )
    parser.add_argument(
        "--no-default-direct",
        action="store_true",
        dest="no_default_direct",
        help="Disable default MATCH as DIRECT (default: MATCH is DIRECT)",
    )
    parser.add_argument(
        "--no-groups",
        action="store_true",
        dest="no_groups",
        help="Disable country-wise groups (default: groups enabled)",
    )
    parser.add_argument(
        "--no-gfwlist",
        action="store_true",
        dest="no_gfwlist",
        help="Disable gfwlist rules (default: gfwlist enabled)",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=str,
        default=datetime.now().strftime(DEFAULT_OUTPUT_PATTERN),
        help="Output filename (default: config.YYYYMMDD)",
    )

    args = parser.parse_args()

    # Set global flags (all features on by default; --no-* turns off)
    global ADD_COUNTRY_GROUPS, DEFAULT_MATCH_DIRECT, ADD_GFWLIST
    ADD_COUNTRY_GROUPS = not args.no_groups
    DEFAULT_MATCH_DIRECT = not args.no_default_direct
    ADD_GFWLIST = not args.no_gfwlist
    add_rulesets = not args.no_rulesets

    # Load remote configuration
    trojan = read_remote_config(args.trojan)
    if trojan is None:
        raise RuntimeError("Failed to load remote trojan configuration")

    # Initialize configuration
    trojan["secret"] = TROJAN_SECRET
    trojan["proxy-groups"] = []

    # Process rulesets
    if add_rulesets:
        read_ruleset_as_rules(trojan)

    # Finalize configuration
    finalize_rules(trojan)
    finalize_groups(trojan)

    # Write output file
    output_filename = args.output
    try:
        with open(output_filename, "w", encoding="utf-8") as output_file:
            yaml.dump(trojan, output_file, default_flow_style=False, allow_unicode=True)
        print(f"Configuration written to {output_filename}")
    except Exception as e:
        print(f"Error writing configuration file: {e}")
        raise


if __name__ == "__main__":
    main()
