#!/usr/bin/env python3
"""
Clash Configuration Fetcher

A utility script to fetch and process Clash proxy configurations.
Supports remote config fetching, proxy group management, and rule processing.
"""

import argparse
import copy
import urllib.request
from typing import Dict, List, Optional, Tuple, Any
from urllib.error import URLError

import yaml
from yaml import Loader, safe_load


# Global configuration flags
DEFAULT_MATCH_DIRECT = False
ADD_COUNTRY_GROUPS = False
ADD_GFWLIST = False


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
        req.add_header(
            "User-Agent",
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 "
            "(KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36 Edg/116.0.1938.69",
        )

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
    url: str = "http://www.gstatic.com/generate_204",
    interval: int = 300,
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
    Read GFW rules from the rules file.

    Returns:
        List of GFW rules
    """
    rules = []
    try:
        with open("rules/gfwrules.txt", encoding="utf-8") as rule_file:
            for line in rule_file:
                line = line.strip("\r\n ")
                if line and not line.startswith("#"):
                    rules.append(line)
    except FileNotFoundError:
        print("Warning: rules/gfwrules.txt not found")
    except Exception as e:
        print(f"Error reading GFW rules: {e}")

    return rules


def read_ruleset_as_providers(result: Dict[str, Any]) -> Dict[str, Any]:
    """
    Read rule providers from rule_providers.yaml and add them to the result.

    Args:
        result: Configuration dictionary to modify

    Returns:
        Modified configuration dictionary
    """
    filename = "rule_providers.yaml"
    ruleset = {}

    try:
        with open(filename, encoding="utf-8") as rule_file:
            ruleset = safe_load(rule_file)
    except FileNotFoundError:
        print(f"Warning: {filename} not found")
        return result
    except yaml.YAMLError as e:
        print(f"Error parsing {filename}: {e}")
        return result

    providers = ruleset.get("rule-providers", [])
    result["rule-providers"] = providers
    print(f"Loaded {len(providers)} rule providers")

    for provider in providers:
        result["rules"].append(f"RULE-SET,{provider},Proxy")

    return result


def read_ruleset_as_rules(result: Dict[str, Any]) -> Dict[str, Any]:
    """
    Read rules from specific ruleset files and add them to the result.

    Args:
        result: Configuration dictionary to modify

    Returns:
        Modified configuration dictionary
    """
    target_files = ["ChatGPT.yaml", "cdn.yaml", "news.yaml", "oracle.yaml"]

    for filename in target_files:
        filepath = f"ruleset/{filename}"
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

    config["rules"] = res


def finalize_groups(result: Dict[str, Any]) -> Dict[str, Any]:
    """
    Finalize proxy groups by filtering proxies and creating group hierarchy.

    Args:
        result: Configuration dictionary to modify

    Returns:
        Modified configuration dictionary
    """
    # Filter selected proxies by country
    selected_countries = ["美国", "日本", "香港"]
    selected_proxies = []

    for country in selected_countries:
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
        country_groups = {"美国": "AutoUS", "日本": "AutoJP", "香港": "AutoHK"}
        for country, group_name in country_groups.items():
            country_proxies = [
                proxy for proxy in result["proxies"] if country in proxy["name"]
            ]
            country_group = create_proxy_group(
                name=group_name, proxy_configs=country_proxies, group_type="url-test"
            )
            add_group(result, country_group)
        group_names.extend(country_groups.values())

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
        "-r",
        "--rulesets",
        action="store_true",
        help="Add predefined ruleset (default false)",
    )
    parser.add_argument(
        "-p",
        "--providers",
        action="store_true",
        help="Add predefined ruleset as providers (default false)",
    )
    parser.add_argument(
        "-d",
        "--default-direct",
        action="store_true",
        help="Add default MATCH as DIRECT (default false)",
    )
    parser.add_argument(
        "-g",
        "--groups",
        action="store_true",
        help="Add country wise groups (default false)",
    )
    parser.add_argument(
        "-w", "--gfwlist", action="store_true", help="Add gfwlist rules (default false)"
    )
    parser.add_argument(
        "-o", "--output", type=str, default="config.latest", help="Output filename (default: config.latest)"
    )

    args = parser.parse_args()

    # Set global flags
    global ADD_COUNTRY_GROUPS, DEFAULT_MATCH_DIRECT, ADD_GFWLIST
    ADD_COUNTRY_GROUPS = args.groups
    DEFAULT_MATCH_DIRECT = args.default_direct
    ADD_GFWLIST = args.gfwlist

    # Load remote configuration
    trojan = read_remote_config(args.trojan)
    if trojan is None:
        raise RuntimeError("Failed to load remote trojan configuration")

    # Initialize configuration
    trojan["secret"] = "canyoukissme"
    trojan["proxy-groups"] = []

    # Process rulesets
    if args.providers:
        read_ruleset_as_providers(trojan)
    if args.rulesets:
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
