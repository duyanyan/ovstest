#!/usr/bin/env bash

default_device=${DEFAULT_DEVICE}
secondary_device=${SECONDARY_DEVICE}
profile_name=${PROFILE_NAME}
secondary_profile_name=${SECONDARY_PROFILE_NAME}
set -ex

if [[ -z $default_device || -z $secondary_device ]]; then
	echo -e "Default and secondary device names were not defined.\nPlease provide DEFAULT_DEVICE and SECONDARY_DEVICE environment variables" >&2
	exit 1
fi

if [[ -z $profile_name ]]; then
	profile_name="$default_device"
fi

if [[ -z $secondary_profile_name ]]; then
	secondary_profile_name="$secondary_device"
fi

mac=$(nmcli -g GENERAL.HWADDR dev show $default_device | sed -e 's/\\//g')

# make bridge
if [[ ! -z ${CLONE_MAC_ON_BRIDGE} ]]; then
	nmcli conn add type ovs-bridge conn.interface brcnv 802-3-ethernet.cloned-mac-address $mac
else
	nmcli conn add type ovs-bridge conn.interface brcnv
fi

nmcli conn add type ovs-port conn.interface brcnv-port master brcnv
nmcli conn add type ovs-interface conn.id brcnv-iface conn.interface brcnv master brcnv-port ipv4.method auto ipv4.dhcp-client-id "01:$mac" connection.autoconnect no


# make bond
nmcli conn down "$profile_name"
nmcli conn mod "$profile_name" connection.autoconnect no
nmcli conn down "$secondary_profile_name"
nmcli conn mod "$secondary_profile_name" connection.autoconnect no
nmcli conn add type ovs-port conn.interface bond0 master brcnv ovs-port.bond-mode balance-slb
nmcli conn add type ethernet conn.interface $default_device master bond0
nmcli conn add type ethernet conn.interface $secondary_device master bond0
nmcli conn up brcnv-iface
nmcli conn mod brcnv-iface connection.autoconnect yes
