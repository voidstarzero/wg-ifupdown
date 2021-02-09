#!/usr/bin/env bash

# if-pre-up.sh - Creation steps for ifup for wireguard interfaces
# Copyright (C) 2021 James Arcus <jimbo@ucc.asn.au>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
