#!/usr/bin/env python3
"""
Merge nerd font symbols from starship-nerd-font-symbols.toml into starship.toml.
For each [header] section in the symbols file:
- If the section doesn't exist in starship.toml, add it
- If it exists, replace/update the key-value pairs from the symbols file
"""

import sys

try:
    # Python 3.11+ has tomllib built-in
    import tomllib
except ImportError:
    import tomli as tomllib

try:
    import tomli_w
except ImportError:
    print("Error: tomli_w is required for writing TOML files")
    print("Install it with: pip install tomli-w")
    sys.exit(1)


def merge_toml_sections(base_config, symbols_config):
    """
    Merge symbols from symbols_config into base_config.
    For each section in symbols_config, update or add to base_config.
    """
    for section, values in symbols_config.items():
        if section == "$schema":
            # Skip schema key
            continue

        if section not in base_config:
            # Section doesn't exist, add it entirely
            base_config[section] = values
            print(f"Added new section: [{section}]")
        else:
            # Section exists, update its values
            if isinstance(values, dict) and isinstance(base_config[section], dict):
                for key, value in values.items():
                    if (
                        key not in base_config[section]
                        or base_config[section][key] != value
                    ):
                        base_config[section][key] = value
                        print(f"Updated [{section}].{key} = {repr(value)}")
            else:
                # Replace entire value
                base_config[section] = values
                print(f"Replaced [{section}] = {repr(values)}")

    return base_config


def main():
    symbols_file = "~/.dotfiles/.config/starship-nerd-font-symbols.toml"
    starship_file = "~/.dotfiles/.config/starship.toml"

    # Read the symbols file
    print(f"Reading symbols from {symbols_file}...")
    with open(symbols_file, "rb") as f:
        symbols_config = tomllib.load(f)

    # Read the main starship config
    print(f"Reading main config from {starship_file}...")
    with open(starship_file, "rb") as f:
        starship_config = tomllib.load(f)

    # Merge the configs
    print("\nMerging configurations...")
    merged_config = merge_toml_sections(starship_config, symbols_config)

    # Write back to starship.toml
    print(f"\nWriting merged config to {starship_file}...")
    with open(starship_file + ".merged", "wb") as f:
        tomli_w.dump(merged_config, f)

    print("\n✓ Successfully merged nerd font symbols into starship.toml")


if __name__ == "__main__":
    main()
