#!/bin/bash

set -euo pipefail

VERBOSE=""

GEN_PSK=""
WG_COMMAND="$(command -v wg)"
WG_HOME='/etc/wireguard'
KEYS_DIR="$WG_HOME/keys"

usage() {
    echo "Usage: $0 [MODE] [OPTION]..."
    echo "Help set up a WireGuard server and/or client"
    echo
    echo "Mode; only one of the following may be chosen:"
    echo
    echo "-i, --init-server  Run on server to set up for the first time."
    echo "-n, --new-client   Run on server to enable a new client to connect."
    echo
    echo "-p, --psk          Also generates a PSK when setting up a new client."
    echo "                   Only affects --new-client".
    echo
    echo "-d, --debug        runs with set -x"
    echo "-h, --help         prints this help text."
    echo "-v, --verbose      provides verbose output."
    exit 0
}

vecho() {
    if [ -n "$VERBOSE" ]; then
        echo "$@"
    fi
}

next_address() {
    curr_address=$(grep Address "$WG_HOME/wg0.cconf" | sort | tail -1)
    next_host=$((1+$(echo "$curr_address" | awk -F. '{print $4}')))
    network=$(echo "$curr_address" | awk -F. '{print $1.$2.$3}')
    echo "${network}.${next_host}"
}

init_server() {
    vecho "Using default port of 51420"
    SERVER_PORT='51420'

    vecho "Enabling IPv4 forwarding"
    sysctl -w net.ipv4.ip_forward=1
    echo 'sysctl -w net.ipv4.ip_forward=1' >> /etc/sysctl.d/99-sysctl.conf

    echo "If you have a firewall, you'll need to open $SERVER_PORT in to here."

    mkdir -p "$WG_HOME"

    INTERFACE=$(ip route show | grep default | grep -v tun | awk '{print $5}')
    vecho "I think your default network interface is $INTERFACE"

    vecho "Generating server keys..."
    "$WG_COMMAND" genkey > "$KEYS_DIR/server"
    "$WG_COMMAND" pubkey < "$KEYS_DIR/server" > "$KEYS_DIR/server.pub"

    cat <<-HEREDOC >>"$WG_HOME/wg0.conf"
    [Interface]
    Address = 10.200.200.1/24
    ListenPort = $SERVER_PORT
    PrivateKey = $(cat "$KEYS_DIR/server")
    
    PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o $INTERFACE -j MASQUERADE
    PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o $INTERFACE -j MASQUERADE
 
HEREDOC
}

new_client() {
    if [ -d "$WG_HOME" ] && [ -f "$WG_HOME/wg0.conf" ]; then
        vecho "Adding $CLIENT_NAME to this server."

        SERVER_INTERNAL_IP=$(grep -E '^Address =' "$WG_HOME/wg0.conf" | awk -F= '{print $2}' | awk -F'/' '{print $1}')
        SERVER_PORT=$(grep -E '^ListenPort =' "$WG_HOME/wg0.conf" | awk -F= '{print $2}')

        "$WG_COMMAND" genkey > "$KEYS_DIR/$CLIENT_NAME"
        "$WG_COMMAND" pubkey < "$KEYS_DIR/$CLIENT_NAME" > "$KEYS_DIR/$CLIENT_NAME.pub"

        cat <<-HEREDOC >>"$WG_HOME/wg0.conf"

        [Peer]
        # $CLIENT_NAME
        PublicKey = $(cat "$KEYS_DIR/$CLIENT_NAME")
        AllowedIPs = 0.0.0.0/0, ::/0
HEREDOC

        if [ -n "$GEN_PSK" ]; then
            "$WG_COMMAND" genpsk > "$KEYS_DIR/$CLIENT_NAME.psk"
            cat <<-HEREDOC >>"$WG_HOME/wg0.conf"
            PresharedKey = $(cat "$KEYS_DIR/$CLIENT_NAME.psk")
HEREDOC
        fi

        CLIENT_CONFIG=$(mktemp)

        cat <<-HEREDOC >>"$CLIENT_CONFIG"
        [Interface]
        Address = $(next_address)
        PrivateKey = $(cat "$KEYS_DIR/$CLIENT_NAME.pub")
        DNS = $SERVER_INTERNAL_IP

        [Peer]
        PublicKey = $(cat $KEYS_DIR/server.pub)
        PresharedKey = $(cat "$KEYS_DIR/$CLIENT_NAME.psk")
        AllowedIPs = 0.0.0.0/0, ::/0
        Endpoint = $SERVER_ADDRESS:$SERVER_PORT
HEREDOC

        if [ -z "$GEN_PSK" ]; then
            sed -i 'g/^PresharedKey =/d' "$CLIENT_CONFIG"
        fi
        echo "Generated client config file is located at $CLIENT_CONFIG"


    else
        echo "This must be run on a Wireguard server."
        echo "If you'd like to set this computer up as a server,"
        echo "please run $0 --init-server"
        exit 1
    fi
}

OPTIONS=$(getopt -o n:iphvd --long new-client:init-server:psk,help,verbose,debug -n "$0" -- "$@")
eval set -- "$OPTIONS"

while true; do
    case "$1" in
        -n|--new-client)
            CLIENT_NAME="$2"
            ACTION='new_client'
            shift 2
            ;;
        -i|--init-server)
            ACTION='init_server'
            shift 1
            ;;
        -p|--psk)
            GEN_PSK='1'
            shift 1
            ;;
        -h|--help)
            usage
            shift 1
            ;;
        -v|--verbose)
            VERBOSE="1"
            shift 1
            ;;
        -d|--debug)
            set -x
            shift 1
            ;;
        --)
            shift 1
            break
            ;;
        *)
            usage
            shift 1
            ;;
    esac
done

exec "$ACTION"
