ip link set dev eth0 up
ifconfig eth0 192.17.100.7 netmask 255.255.252.0
{ sleep 3; m5 checkpoint; } &

echo "Starting memcached server in Kernel mode"
memcached -p 0 -U 11211 -u root
# memcached -p 0 -U 11211 -u root -vvv
# tcpdump -i eth0 -X
