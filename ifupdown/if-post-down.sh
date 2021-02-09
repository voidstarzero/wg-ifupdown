#!/usr/bin/env bash

# if-post-down.sh - Cleanup steps for ifdown for wireguard interfaces
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

# Destroy the interface after all deconfiguration.
if [[ "$IFACE" == wg* ]]; then
    runcmd ip link del "$IFACE"
fi
