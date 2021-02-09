#!/usr/bin/env bash

# install.sh - Install ifupdown components for wireguard
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

# Adjust for your system if necessary.
netdir=/etc/network

cd ifupdown
workdir=$(pwd)

ln -sf $workdir/if-pre-up.sh $netdir/if-pre-up.d/wireguard
ln -sf $workdir/if-up.sh $netdir/if-up.d/wireguard
ln -sf $workdir/if-post-down.sh $netdir/if-post-down.d/wireguard
