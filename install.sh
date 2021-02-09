#!/usr/bin/env bash

# Remove old ifupdown wireguard scripts.
pushd /etc/network
sudo find -path './if-*' -name 'wireguard-*' -exec rm {} +
popd

# Install ifupdown scripts to their proper locations.
pushd ifupdown
sudo cp -R * /etc/network/
popd
