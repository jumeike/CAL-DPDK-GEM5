#!/bin/bash

CACHE_CONFIG="--caches --l2cache --l3cache --l3_size 4MB --l3_assoc 16 --l1i_size=64kB --l1i_assoc=4 \
--l1d_size=64kB --l1d_assoc=4 --l2_assoc=8 --cacheline_size=64" 
CPU_CONFIG="--param=system.cpu[0:2].l2cache.mshrs=46 --param=system.cpu[0:2].dcache.mshrs=20 \
  --param=system.cpu[0:2].icache.mshrs=20 --param=system.switch_cpus[0:2].decodeWidth=4 \
  --param=system.switch_cpus[0:2].numROBEntries=128 --param=system.switch_cpus[0:2].numIQEntries=64 \
  --param=system.switch_cpus[0:2].numPhysIntRegs=256 --param=system.switch_cpus[0:2].numPhysFloatRegs=256 \
  --param=system.switch_cpus[0:2].branchPred.BTBEntries=8192 --param=system.switch_cpus[0:2].issueWidth=8 \
  --param=system.switch_cpus[0:2].commitWidth=8 --param=system.switch_cpus[0:2].dispatchWidth=8 \
  --param=system.switch_cpus[0:2].fetchWidth=8 --param=system.switch_cpus[0:2].wbWidth=8 \
  --param=system.switch_cpus[0:2].squashWidth=8 --param=system.switch_cpus[0:2].renameWidth=8"

function usage {
  echo "Usage: $0 --num-nics <num_nics> [--script <script>] [--loadgen-find-bw] [--take-checkpoint] [-h|--help]"
  echo "  --num-nics <num_nics> : number of NICs to use"
  echo "  --script <script> : guest script to run"
  echo "  --loadgen-find-bw : run loadgen in find bandwidth mode"
  echo "  --take-checkpoint : take checkpoint after running"
  echo "  -h --help : print this message"
  exit 1
}

function setup_dirs {
  mkdir -p "$CKPT_DIR"
  mkdir -p "$RUNDIR"
}

function run_simulation {
  "$GEM5_DIR/build/ARM/gem5.$GEM5TYPE" $DEBUG_FLAGS --outdir="$RUNDIR" \
  "$GEM5_DIR"/configs/example/fs.py --cpu-type=$CPUTYPE \
  --kernel="$RESOURCES/vmlinux" --disk="$RESOURCES/rootfs.ext2" --bootloader="$RESOURCES/boot.arm64" --root=/dev/sda \
  --num-cpus=$(($num_nics+3)) --mem-type=DDR4_2400_16x4 --mem-channels=4 --mem-size=65536MB --script="$GUEST_SCRIPT_DIR/$GUEST_SCRIPT" \
  --num-nics="$num_nics" --num-loadgens="$num_nics" \
  --checkpoint-dir="$CKPT_DIR" $CONFIGARGS
}

if [[ -z "${GIT_ROOT}" ]]; then
  echo "Please export env var GIT_ROOT to point to the root of the CAL-DPDK-GEM5 repo"
  exit 1
fi

GEM5_DIR=${GIT_ROOT}/gem5
RESOURCES=${GIT_ROOT}/resources
GUEST_SCRIPT_DIR=${GIT_ROOT}/guest-scripts

# parse command line arguments
TEMP=$(getopt -o 'h' --long take-checkpoint,num-nics:,script:,packet-rate,loadgen-find-bw,help -n 'dpdk-loadgen' -- "$@")

# check for parsing errors
if [ $? != 0 ]; then
  echo "Error: unable to parse command line arguments" >&2
  exit 1
fi

eval set -- "$TEMP"

while true; do
  case "$1" in
  --num-nics)
    num_nics="$2"
    shift 2
    ;;
  --take-checkpoint)
    checkpoint=1
    shift 1
    ;;
  --script)
    GUEST_SCRIPT="$2"
    shift 2
    ;;
  --packet-rate)
    PACKET_RATE="$3"
    shift 2
    ;;
  --loadgen-find-bw)
    LOADGENREPLAYMODE="ReplayAndAdjustThroughput"
    shift 1
    ;;
  -h | --help)
    usage
    ;;
  --)
    shift
    break
    ;;
  *) break ;;
  esac
done

CKPT_DIR=${GIT_ROOT}/ckpts/ckpts/$num_nics"NIC"-$GUEST_SCRIPT

if [[ -z "$num_nics" ]]; then
  echo "Error: missing argument --num-nics" >&2
  usage
fi

if [[ -n "$checkpoint" ]]; then
  RUNDIR=${GIT_ROOT}/rundir/$num_nics"NIC-ckp-"$GUEST_SCRIPT
  setup_dirs
  echo "Taking Checkpoint for NICs=$num_nics" >&2
  GEM5TYPE="fast"
  DEBUG_FLAGS=""
  PORT=11211
  CPUTYPE="AtomicSimpleCPU"
  PACKET_RATE=1000
  LOADGENREPLAYMODE=ConstThroughput
  PCAP_FILENAME="../resources/warmup-dpdk.pcap"
  CONFIGARGS="--max-checkpoints 3 --checkpoint-at-end --loadgen-start=13015607472500 -m 20619488205000 --loadgen-type=Pcap --loadgen-stack=DPDKStack --loadgen_pcap_filename=$PCAP_FILENAME --packet-rate=$PACKET_RATE --loadgen-replymode=$LOADGENREPLAYMODE --loadgen-port-filter=$PORT"
  run_simulation
  exit 0
else
  if [[ -z "$PACKET_RATE" ]]; then
    echo "Error: missing argument --packet_rate" >&2
    usage
  fi
  PORT=11211
  PCAP_FILENAME="../resources/request-dpdk.pcap"
  ((INCR_INTERVAL = PACKET_RATE / 10)) 
  LOADGENREPLAYMODE=${LOADGENREPLAYMODE:-"ConstThroughput"}
  RUNDIR=${GIT_ROOT}/rundir/memcached-dpdk-test/$num_nics"NIC-"$PACKET_RATE"RATE-"$LOADGENREPLAYMODE"TimingCPU-3s"
  setup_dirs
  CPUTYPE="TimingSimpleCPU" # just because DerivO3CPU is too slow sometimes
  GEM5TYPE="opt"
  # LOADGENREPLAYMODE=${LOADGENREPLAYMODE:-"ConstThroughput"}
  DEBUG_FLAGS="--debug-flags=LoadgenDebug"
  CONFIGARGS="$CACHE_CONFIG -r 3 --loadgen-type=Pcap --loadgen-stack=DPDKStack --loadgen_pcap_filename=$PCAP_FILENAME --loadgen-start=20619588205000 --rel-max-tick=3000000000000 --packet-rate=$PACKET_RATE --loadgen-replymode=$LOADGENREPLAYMODE --loadgen-increment-interva=$INCR_INTERVAL --loadgen-port-filter=$PORT"
  run_simulation > ${RUNDIR}/simout
  exit
fi
