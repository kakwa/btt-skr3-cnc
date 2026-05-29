#!/usr/bin/env bash
# Temporary DHCP + NAT bridge: LAN (ethernet) -> Pi, WAN (wifi) -> internet.
#
# Usage:
#   sudo ./misc/pi-dhcp-nat.sh
#   LAN_IF=eno1 WAN_IF=wlp0s20f3 sudo ./misc/pi-dhcp-nat.sh
#
# Override via env:
#   LAN_IF / LAN     wired interface to the Pi (default: auto-detect)
#   WAN_IF / WAN     uplink interface, usually WiFi (default: default-route iface)
#   LAN_IP           host address on the link (default: 192.168.100.1)
#   DHCP_RANGE       dnsmasq range (default: 192.168.100.50,192.168.100.150,24h)

set -euo pipefail

LAN_IF="${LAN_IF:-${LAN:-}}"
WAN_IF="${WAN_IF:-${WAN:-}}"
LAN_IP="${LAN_IP:-192.168.100.1}"
DHCP_RANGE="${DHCP_RANGE:-192.168.100.50,192.168.100.150,24h}"

CONF="$(mktemp /tmp/pi-dhcp-nat.XXXXXX.conf)"
DNSMASQ_PID=""

die() {
	echo "error: $*" >&2
	exit 1
}

require_root() {
	[[ "${EUID:-$(id -u)}" -eq 0 ]] || die "run as root (sudo $0)"
}

require_cmd() {
	command -v "$1" >/dev/null 2>&1 || die "'$1' not found (install ${2:-$1})"
}

list_ifaces() {
	ip -o link show | awk -F': ' '{print $2}' | cut -d@ -f1
}

is_wired() {
	local iface=$1
	[[ -e "/sys/class/net/$iface/device" && ! -e "/sys/class/net/$iface/wireless" ]]
}

is_virtual() {
	local iface=$1
	case "$iface" in
	lo | docker* | veth* | virbr* | br-* | tun* | tap*) return 0 ;;
	esac
	return 1
}

iface_up() {
	ip link show "$iface" 2>/dev/null | grep -q 'state UP'
}

guess_wan() {
	local iface

	iface=$(ip -4 route show default 2>/dev/null | awk '{print $5; exit}')
	if [[ -n "$iface" && "$iface" != "$LAN_IF" ]]; then
		echo "$iface"
		return
	fi

	for iface in $(list_ifaces); do
		is_virtual "$iface" && continue
		[[ "$iface" == "$LAN_IF" ]] && continue
		[[ "$iface" == wl* || -e "/sys/class/net/$iface/wireless" ]] || continue
		if iface_up "$iface"; then
			echo "$iface"
			return
		fi
	done

	die "could not guess WAN interface; set WAN_IF (e.g. WAN_IF=wlp0s20f3)"
}

guess_lan() {
	local iface

	for iface in $(list_ifaces); do
		is_virtual "$iface" && continue
		[[ "$iface" == "$WAN_IF" ]] && continue
		is_wired "$iface" || continue
		echo "$iface"
		return
	done

	die "could not guess LAN interface; set LAN_IF (e.g. LAN_IF=eno1)"
}

resolve_ifaces() {
	if [[ -z "$LAN_IF" ]]; then
		LAN_IF=$(guess_lan)
	fi
	if [[ -z "$WAN_IF" ]]; then
		WAN_IF=$(guess_wan)
	fi
	[[ "$LAN_IF" != "$WAN_IF" ]] || die "LAN and WAN must differ (LAN=$LAN_IF WAN=$WAN_IF)"
}

setup_lan_addr() {
	ip link set "$LAN_IF" up
	if ! ip addr show dev "$LAN_IF" | grep -q "inet ${LAN_IP}/"; then
		ip addr add "${LAN_IP}/24" dev "$LAN_IF"
	fi
}

setup_nat() {
	sysctl -w net.ipv4.ip_forward=1 >/dev/null
	iptables -t nat -C POSTROUTING -o "$WAN_IF" -j MASQUERADE 2>/dev/null \
		|| iptables -t nat -A POSTROUTING -o "$WAN_IF" -j MASQUERADE
	iptables -C FORWARD -i "$LAN_IF" -o "$WAN_IF" -j ACCEPT 2>/dev/null \
		|| iptables -A FORWARD -i "$LAN_IF" -o "$WAN_IF" -j ACCEPT
	iptables -C FORWARD -i "$WAN_IF" -o "$LAN_IF" -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null \
		|| iptables -A FORWARD -i "$WAN_IF" -o "$LAN_IF" -m state --state RELATED,ESTABLISHED -j ACCEPT
}

write_dnsmasq_conf() {
	cat >"$CONF" <<EOF
interface=${LAN_IF}
bind-interfaces
dhcp-range=${DHCP_RANGE}
dhcp-option=option:router,${LAN_IP}
dhcp-option=option:dns-server,${LAN_IP}
EOF
}

cleanup() {
	local rc=$?

	if [[ -n "$DNSMASQ_PID" ]] && kill -0 "$DNSMASQ_PID" 2>/dev/null; then
		kill "$DNSMASQ_PID" 2>/dev/null || true
		wait "$DNSMASQ_PID" 2>/dev/null || true
	fi

	if [[ -n "${LAN_IF:-}" && -n "${WAN_IF:-}" ]]; then
		iptables -t nat -D POSTROUTING -o "$WAN_IF" -j MASQUERADE 2>/dev/null || true
		iptables -D FORWARD -i "$LAN_IF" -o "$WAN_IF" -j ACCEPT 2>/dev/null || true
		iptables -D FORWARD -i "$WAN_IF" -o "$LAN_IF" -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || true
		ip addr del "${LAN_IP}/24" dev "$LAN_IF" 2>/dev/null || true
	fi

	rm -f "$CONF"
	exit "$rc"
}

main() {
	require_root
	require_cmd ip iproute2
	require_cmd iptables iptables
	require_cmd dnsmasq dnsmasq

	trap cleanup EXIT INT TERM

	resolve_ifaces

	echo "LAN (ethernet): $LAN_IF  ${LAN_IP}/24  DHCP ${DHCP_RANGE}"
	echo "WAN (uplink):   $WAN_IF"
	echo "Press Ctrl+C to stop and tear down."
	echo

	setup_lan_addr
	setup_nat
	write_dnsmasq_conf

	dnsmasq -d -C "$CONF" &
	DNSMASQ_PID=$!
	wait "$DNSMASQ_PID"
}

main "$@"
