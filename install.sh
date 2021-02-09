#!/usr/bin/env bash

# Adjust for your system if necessary.
netdir=/etc/network

cd ifupdown
workdir=$(pwd)

ln -sf $workdir/if-pre-up.sh $netdir/if-pre-up.d/wireguard
ln -sf $workdir/if-up.sh $netdir/if-up.d/wireguard
ln -sf $workdir/if-post-down.sh $netdir/if-post-down.d/wireguard
