#!/usr/bin/env bash

function runcmd {
    [[ $VERBOSITY == 1 ]] && echo "$@" >&2
    "$@"
}

function loadconf {
    local config_path="$1"

    # Refuse to load the config if it is writable by others.
    config_mode=$(stat --format %A "$config_path")
    if [[ $config_mode != ?????-??-? ]]; then
        printf "Error: Config file '%s' is writable by others.\n" \
            "$config_path" >&2
        exit 1
    fi

    # Refuse to load the config if it overrides the private key. For security
    # reasons, private keys should be separate and have mode 600.
    if fgrep -isq 'PrivateKey' "$config_path"; then
        echo "Error: Specifying private key in config file is unsupported." >&2
        exit 1
    fi

    runcmd wg addconf "$IFACE" "$config_path"
}

# Given an IP range in CIDR notation, adds it as a route
function addroutes {
    # TODO: Some form of route summarization
    while read ip_route; do
        # TODO: Don't add routes already covered
        runcmd ip route add $ip_route dev "$IFACE"
    done
}

if [[ "$IFACE" == wg* ]]; then
    # Apply any matching wireguard configs found, in order:
    #     * Interface-specific config in interface-specific folder
    #     * Interface-specific config in default wireguard folder
    #     * Custom interface option 'wg-config-file'
    if [[ -f /etc/wireguard/"$IFACE"/config ]]; then
        loadconf /etc/wireguard/"$IFACE"/config
    fi
    if [[ -f /etc/wireguard/"$IFACE".conf ]]; then
        loadconf /etc/wireguard/"$IFACE".conf
    fi
    if [[ -f "$IF_WG_CONFIG_FILE" ]]; then
        loadconf "$IF_WG_CONFIG_FILE"
    fi

    # If 'wg-autoroute yes' is set, generate extra routing table entries for
    # every AllowedIP range. Don't default to this, as adding the interface
    # address automatically creates a route to that subnet. Careful selection
    # of the prefix length in the 'address' field on each host should render
    # this unnecessay, unless (e.g.) you are routing extra blocks to hosts.
    if [[ "$IF_WG_AUTOROUTE" == yes ]]; then
        # Wireguard itself is best-positioned to know what IPs are allowed to
        # traverse each peer. It can dump a list of "public-key\tallowed-ip"
        # pairs with the following command.
        runcmd wg show "$IFACE" allowed-ips | cut -f 2 | addroutes
    fi

    # Allow adding manual routes using the 'wg-addroute' directive as well.
    # This is useful e.g. if you have an AllowedIPs = 0.0.0.0/0 tunnel and
    # want to pick what actually gets sent down it.
    if [[ "$IF_WG_ADDROUTE" ]]; then
        addroutes <<< "$IF_WG_ADDROUTE"
    fi
fi
