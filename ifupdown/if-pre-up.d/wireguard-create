#!/usr/bin/env bash

function runcmd {
    [[ $VERBOSITY == 1 ]] && echo "$@" >&2
    "$@"
}

# Applies a given key to the interface.
function applykey {
    # Reject the key if it's accessible to anyone other than root.
    local keymode=$(stat --format %a "$1")
    if [[ $keymode != ?00 ]]; then
        printf "Error: private key '%s' mode %s, should be 600\n" \
            "$1" $keymode >&2
        exit 1
    fi

    runcmd wg set "$IFACE" private-key "$1"
}

# There's no convenient way to find out if an interface is supposed to be
# wireguard, other than how it's named.
if [[ "$IFACE" == wg* ]]; then
    # The ifup(8) program doesn't know how to to create wireguard links using
    # ip(8), so we need to create it before anything is tried.
    runcmd ip link add "$IFACE" type wireguard

    # If we know what host port we're listening on already, bind to it now.
    if [[ "$IF_WG_LISTEN_PORT" ]]; then
        runcmd wg set "$IFACE" listen-port "$IF_WG_LISTEN_PORT"
    fi

    # Apply a firmware mark if required.
    if [[ "$IF_WG_FWMARK" ]]; then
        runcmd wg set "$IFACE" fwmark "$IF_WG_FWMARK"
    fi

    # If the interface block specifies a specific key, use that. Otherwise,
    # search standard interface-specific paths, then a system wireguard
    # default path.
    if [[ "$IF_WG_PRIVATE_KEY" ]]; then
        applykey "$IF_WG_PRIVATE_KEY"
    elif [[ -f /etc/wireguard/"$IFACE".key ]]; then
        applykey /etc/wireguard/"$IFACE".key
    elif [[ -f /etc/wireguard/"$IFACE"/private.key ]]; then
        applykey /etc/wireguard/"$IFACE"/private.key
    elif [[ -f /etc/wireguard/private.key ]]; then
        applykey /etc/wireguard/private.key
    else
        echo "Error: No private key specified." >&2
        exit 1
    fi
fi
