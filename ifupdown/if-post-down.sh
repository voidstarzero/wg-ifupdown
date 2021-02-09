#!/usr/bin/env bash

function runcmd {
    [[ $VERBOSITY == 1 ]] && echo "$@" >&2
    "$@"
}

# Destroy the interface after all deconfiguration.
if [[ "$IFACE" == wg* ]]; then
    runcmd ip link del "$IFACE"
fi
