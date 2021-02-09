#!/usr/bin/env bash

# Remove old ifupdown wireguard scripts.
pushd /etc/network
find -path './if-*' -name 'wireguard-*' -exec rm {} +
popd

# Install ifupdown scripts to their proper locations.
pushd ifupdown
cp -R * /etc/network/
popd
