if [ "$EUID" -ne 0 ]; then
    echo "please run this script with sudo"
    exit 1
fi

ip tuntap add dev tap0 mode tap multi_queue user ${SUDO_USER:-$USER}
ip addr add 10.0.2.2/24 dev tap0
ip link set dev tap0 up

sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -o enp5s0 -j MASQUERADE
iptables -A FORWARD -i tap0 -o enp5s0 -j ACCEPT
iptables -A FORWARD -i enp5s0 -o tap0 -m state --state RELATED,ESTABLISHED -j ACCEPT

read -p "press enter to stop and revert changes"

iptables -t nat -D POSTROUTING -o enp5s0 -j MASQUERADE
iptables -D FORWARD -i tap0 -o enp5s0 -j ACCEPT
iptables -D FORWARD -i enp5s0 -o tap0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sysctl -w net.ipv4.ip_forward=0

ip link set dev tap0 down
ip link delete tap0
