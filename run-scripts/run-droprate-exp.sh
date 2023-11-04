#!/bin/bash 

# for j in 1GHz 2GHz 3GHz;do
#   for i in {1..9..1};do
#     ./l2fwd-ckp.sh --num-nics 1  --script dpdk-testpmd.sh --packet-rate $((2150786*$i)) --packet-size 64 --freq $j &
#   done
# done

# wait

for j in 1GHz 2GHz 3GHz;do
  for i in {10..18..1};do
    ./l2fwd-ckp.sh --num-nics 1  --script dpdk-testpmd.sh --packet-rate $((2150786*$i)) --packet-size 64 --freq $j &
  done
done

wait

# for j in 1GHz 2GHz 3GHz;do
#   for i in {21..25..1};do
#     ./l2fwd-ckp.sh --num-nics 1  --script dpdk-testpmd.sh --packet-rate $((2150786*$i)) --packet-size 64 --freq $j &
#   done
# done

# wait

# for j in 1GHz 2GHz 3GHz;do
#   for i in {11..19..1};do
#     ./l2fwd-ckp.sh --num-nics 1  --script dpdk-testpmd.sh --packet-rate $((2150786*$i/2)) --packet-size 128 --freq $j &
#   done
# done

# wait

# for j in 1GHz 2GHz 3GHz;do
#   for i in {20..28..1};do
#     ./l2fwd-ckp.sh --num-nics 1  --script dpdk-testpmd.sh --packet-rate $((2150786*$i/2)) --packet-size 128 --freq $j &
#   done
# done

# wait

# for j in 1GHz 2GHz 3GHz;do
#   for i in {24..32..1};do
#     ./l2fwd-ckp.sh --num-nics 1  --script dpdk-testpmd.sh --packet-rate $((2150786*$i/4)) --packet-size 256 --freq $j &
#   done
# done

# wait 

# for j in 1GHz 2GHz 3GHz;do
#   for i in {33..41..1};do
#     ./l2fwd-ckp.sh --num-nics 1  --script dpdk-testpmd.sh --packet-rate $((2150786*$i/4)) --packet-size 256 --freq $j &
#   done
# done

# wait 

# for j in 1GHz 2GHz 3GHz;do
#   for i in {42..50..1};do
#     ./l2fwd-ckp.sh --num-nics 1  --script dpdk-testpmd.sh --packet-rate $((2150786*$i/4)) --packet-size 256 --freq $j &
#   done
# done

# wait

# for j in 1GHz 2GHz 3GHz;do
#   for i in {42..50..1};do
#     ./l2fwd-ckp.sh --num-nics 1  --script dpdk-testpmd.sh --packet-rate $((2150786*$i/8)) --packet-size 512 --freq $j &
#   done
# done

# wait

# for j in 1GHz 2GHz 3GHz;do
#   for i in {51..59..1};do
#     ./l2fwd-ckp.sh --num-nics 1  --script dpdk-testpmd.sh --packet-rate $((2150786*$i/8)) --packet-size 512 --freq $j &
#   done
# done

# wait

# for j in 1GHz 2GHz 3GHz;do
#   for i in {60..68.1};do
#     ./l2fwd-ckp.sh --num-nics 1  --script dpdk-testpmd.sh --packet-rate $((2150786*$i/8)) --packet-size 512 --freq $j &
#   done
# done

# wait

# for j in 1GHz 2GHz 3GHz;do
#   for i in {48..56..1};do
#     ./l2fwd-ckp.sh --num-nics 1  --script dpdk-testpmd.sh --packet-rate $((2150786*$i/16)) --packet-size 1024 --freq $j &
#   done
# done

# wait

# for j in 1GHz 2GHz 3GHz;do
#   for i in {57..65..1};do
#     ./l2fwd-ckp.sh --num-nics 1  --script dpdk-testpmd.sh --packet-rate $((2150786*$i/16)) --packet-size 1024 --freq $j &
#   done
# done

# wait

# # for j in 1GHz 2GHz 3GHz;do
# #   for i in {66..71..1};do
# #     ./l2fwd-ckp.sh --num-nics 1  --script dpdk-testpmd.sh --packet-rate $((2150786*$i/16)) --packet-size 1024 --freq $j &
# #   done
# # done

# # wait
# # for j in 1GHz;do
# #   for i in {5..15..1};do
# #     ./l2fwd-ckp.sh --num-nics 1  --script dpdk-testpmd.sh --packet-rate $((2150786*$i/4)) --packet-size 256 --freq $j &
# #   done
# # done

# # wait 


# # for j in 1GHz 2GHz;do
# #   for i in {16..23..1};do
# #     ./l2fwd-ckp.sh --num-nics 1  --script dpdk-testpmd.sh --packet-rate $((2150786*$i/4)) --packet-size 256 --freq $j &
# #   done
# # done

# # wait 

# # for j in 1GHz 2GHz;do
# #   for i in 25 27 28 30;do
# #     ./l2fwd-ckp.sh --num-nics 1  --script dpdk-testpmd.sh --packet-rate $((2150786*$i/4)) --packet-size 256 --freq $j &
# #   done
# # done

# # wait 

# # for j in 1GHz 2GHz;do
# #   for i in 31 32 34 40 41 42 45 53 54 55 56;do
# #     ./l2fwd-ckp.sh --num-nics 1  --script dpdk-testpmd.sh --packet-rate $((2150786*$i/4)) --packet-size 256 --freq $j &
# #   done
# # done

# # wait 

# for j in 1GHz 2GHz 3GHz;do
#   for i in {45..53..1};do
#     ./l2fwd-ckp.sh --num-nics 1  --script dpdk-testpmd.sh --packet-rate $((88418*$i)) --packet-size 1518 --freq $j &
#   done
# done

# wait

# for j in 1GHz 2GHz 3GHz;do
#   for i in {54..62..1};do
#     ./l2fwd-ckp.sh --num-nics 1  --script dpdk-testpmd.sh --packet-rate $((88418*$i)) --packet-size 1518 --freq $j &
#   done
# done

# wait

# for j in 1GHz 2GHz 3GHz;do
#   for i in {62..70..1};do
#     ./l2fwd-ckp.sh --num-nics 1  --script dpdk-testpmd.sh --packet-rate $((88418*$i)) --packet-size 1518 --freq $j &
#   done
# done

# wait
# for j in 1GHz 2GHz 3GHz;do
#   for i in {77..87..1};do
#     ./l2fwd-ckp.sh --num-nics 1  --script dpdk-testpmd.sh --packet-rate $((88418*$i)) --packet-size 1518 --freq $j &
#   done
# done

# wait

# for j in 1GHz 2GHz 3GHz;do
#   for i in {88..100..1};do
#     ./l2fwd-ckp.sh --num-nics 1  --script dpdk-testpmd.sh --packet-rate $((88418*$i)) --packet-size 1518 --freq $j &
#   done
# done

wait