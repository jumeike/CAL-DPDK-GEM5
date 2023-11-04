#!/bin/bash


# Take checkpoint
# ./l2fwd-ckp.sh --take-checkpoint --num-nics 1 --script dpdk-l2fwd.sh &

# ./l2fwd-ckp.sh --take-checkpoint --num-nics 1 --script dpdk-l2fwd-touchfwd.sh &

# ./l2fwd-ckp.sh --take-checkpoint --num-nics 1 --script dpdk-l2fwd-touchdrop.sh &

# ./l2fwd-ckp.sh --take-checkpoint --num-nics 1 --script dpdk-testpmd-512.sh --freq 3GHz &

# ./l2fwd-ckp.sh --take-checkpoint --num-nics 1 --script dpdk-testpmd-256.sh --freq 3GHz &

# ./l2fwd-ckp.sh --take-checkpoint --num-nics 1 --script dpdk-testpmd-3.sh --freq 3GHz &

./l2fwd-ckp.sh --take-checkpoint --num-nics 1 --script dpdk-testpmd.sh --freq 3GHz &

./l2fwd-ckp.sh --take-checkpoint --num-nics 1 --script dpdk-testpmd-touchfwd.sh --freq 3GHz &

./l2fwd-ckp.sh --take-checkpoint --num-nics 1 --script dpdk-testpmd-touchdrop.sh --freq 3GHz &

./memcached-dpdk.sh --take-checkpoint --num-nics 1 --script memcached_dpdk.sh --l2-size 1MB --freq 3GHz &

./memcached-kernel.sh --take-checkpoint --num-nics 1 --script memcached_kernel.sh --l2-size 1MB --freq 3GHz &

