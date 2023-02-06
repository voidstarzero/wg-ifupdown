# wg-ifupdown
Wireguard integrations for ifup(8)/ifdown(8)

This repo provides a set of plugin scripts that allow automatic configuration
of wireguard networks from `interfaces(5)` files as used on Debian and other
systems.

## Features
- `interfaces(5)` options for all wireguard interface config directives
- Integrates well with other networks specified in `/etc/network/interfaces`
- Loads private key from a separate file natively
- Checks relevant files for permission issues before loading

## Requirements
- bash
- coreutils (for `stat`)
- iproute2
- wireguard (obviously)

## Installing
**TL;DR:**
```
$ sudo -i
# git clone https://github.com/voidstarzero/wg-ifupdown
# cd wg-ifupdown
# ./install.sh
```

To function, the scripts in `ifupdown` have to end up in the corresponding
plugin directories contained within `/etc/network`. For example, the script
named `if-pre-up.sh` needs to end up in the directory
`/etc/network/if-pre-up.d`.

The default `install.sh` does this by copying the files straight from the
repositories to their usual destination. You may want to customize this to fit
your installation, or to symlink them from the repository instead.

If you opt for a manual install, I recommend naming the copies something else
that reflects their origin. A file named `if-pre-up.sh` in `if-pre-up.d` tells
you nothing about what it does. The default installer takes care of this.

## Usage
wg-ifupdown adds a set of additional configuration options that can be used by
a wireguard network block in e.g. `/etc/network/interfaces` to properly create,
bring up and destroy the interface.

The following example includes every new option, alongside a short description
of their use:
```
auto wg-example
iface wg-example inet static
    # Specify a custom file from which to load the interface private key.
    # If not specified, wg-ifupdown looks in the following locations, in order
    # until a file is found:
    #     * /etc/wireguard/wg-example.key
    #     * /etc/wireguard/wg-example/private.key
    #     * /etc/wireguard/private.key
    # The script also ensures appropriate permissions for the key file. This
    # separates the key from the config, unlike in the default wireguard setup.
    wg-private-key /etc/wireguard/example.key

    # The port on the host to use for sending/receiving encrypted wireguard
    # packets. Corresponds to `ListenPort` in a standard wireguard config.
    wg-listen-port 55555

    # Sets the fwmark for encrypted wireguard packets. Equivalent to `FwMark`
    # in standard wireguard configs.
    wg-fwmark 42
    
    # This host's VPN address and default network to use on the VPN. Uses the
    # standard ifup option.
    address 192.0.2.1/24

    # Specify a wireguard-style config file to load additional commands from.
    # This is most obviously useful to specify the peer configs (not yet
    # included in wg-ifupdown), but can also add any options allowed.
    # If any of the following files exist, they are also loaded:
    #     * /etc/wireguard/wg-example/config
    #     * /etc/wireguard/wg-example.conf 
    wg-config-file /etc/wireguard/example-peers.conf

    # If present and set to a value of 'yes', learn additional routes from the
    # allowed-ips of each wireguard peer. If in doubt, leave this option unset.
    wg-autoroute no

    # Specify additional routes to be sent down the wireguard interface. These
    # routes are added after loading with `ip route`. This option may be
    # present any number of times. Note: Any traffic sent to the interface
    # without a corresponding allowed-ips range on a peer will not get routed
    # by the wireguard subsystem.
    wg-addroute 198.51.100.0/24
    wg-addroute 203.0.113.0/24
```

## TODO
- Do route summarization when loading `wg-autoroute` and `wg-addroute` options
- Allow peer specification inline in the single configuration
- Add some dynamic features (maybe)
- Improve this documentation?
