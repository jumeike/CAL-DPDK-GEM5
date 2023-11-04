#!/bin/bash
#wbWidth=4 causes error when you run
CACHE_CONFIG="--caches --l2cache --l3cache --l3_size 16MB --l3_assoc 16 --ddio-enabled --l1i_size=64kB --l1i_assoc=4 \
--l1d_size=64kB --l1d_assoc=4 --l2_size=1MB --l2_assoc=8 --cacheline_size=64" 
CPU_CONFIG="--param=system.cpu[0:4].l2cache.mshrs=46 --param=system.cpu[0:4].dcache.mshrs=20 \
  --param=system.cpu[0:4].icache.mshrs=20 --param=system.switch_cpus[0:4].decodeWidth=4 \
  --param=system.switch_cpus[0:4].numROBEntries=128 --param=system.switch_cpus[0:4].numIQEntries=64 \
  --param=system.switch_cpus[0:4].LQEntries=68 --param=system.switch_cpus[0:4].SQEntries=72 \
  --param=system.switch_cpus[0:4].numPhysIntRegs=256 --param=system.switch_cpus[0:4].numPhysFloatRegs=256 \
  --param=system.switch_cpus[0:4].branchPred.BTBEntries=8192 --param=system.switch_cpus[0:4].issueWidth=8 \
  --param=system.switch_cpus[0:4].commitWidth=8 --param=system.switch_cpus[0:4].dispatchWidth=8 \
  --param=system.switch_cpus[0:4].fetchWidth=8 --param=system.switch_cpus[0:4].wbWidth=8 \
  --param=system.switch_cpus[0:4].squashWidth=8 --param=system.switch_cpus[0:4].renameWidth=8"

function usage {
  echo "Usage: $0 --num-nics <num_nics> [--script <script>] [--packet-rate <packet_rate>] [--packet-size <packet_size>] [--loadgen-find-bw] [--take-checkpoint] [-h|--help]"
  echo "  --num-nics <num_nics> : number of NICs to use"
  echo "  --script <script> : guest script to run"
  echo "  --packet-rate <packet_rate> : packet rate in PPS"
  echo "  --packet-size <packet_size> : packet size in bytes"
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
  --num-cpus=$(($num_nics+3)) --mem-type=DDR4_2400_16x4 --mem-channels=4 --mem-size=65536MB --cpu-clock=3GHz --script="$GUEST_SCRIPT_DIR/$GUEST_SCRIPT" \
  --num-nics="$num_nics" --num-loadgens="$num_nics" \
  --checkpoint-dir="$CKPT_DIR" $CONFIGARGS
}

if [[ -z "${GIT_ROOT}" ]]; then
  echo "Please export env var GIT_ROOT to point to the root of the CAL-DPDK-GEM5 repo"
  exit 1
fi

GEM5_DIR=${GIT_ROOT}/gem5
# RESOURCES=${GIT_ROOT}/resources
RESOURCES=${GIT_ROOT}/resources-dpdk
GUEST_SCRIPT_DIR=${GIT_ROOT}/guest-scripts

# parse command line arguments
TEMP=$(getopt -o 'h' --long take-checkpoint,num-nics:,script:,packet-rate:,packet-size:,loadgen-find-bw,help -n 'dpdk-loadgen' -- "$@")

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
  --packet-size)
    PACKET_SIZE="$2"
    shift 2
    ;;
  --packet-rate)
    PACKET_RATE="$2"
    shift 2
    ;;
  --loadgen-find-bw)
    LOADGENMODE="Increment"
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

# CKPT_DIR=${GIT_ROOT}/ckpts/$num_nics"NIC"-$GUEST_SCRIPT
CKPT_DIR=${GIT_ROOT}/ckpts/ckpts-with-new-vmlinux/$num_nics"NIC"-$GUEST_SCRIPT
if [[ -z "$num_nics" ]]; then
  echo "Error: missing argument --num-nics" >&2
  usage
fi

if [[ -n "$checkpoint" ]]; then
  # RUNDIR=${GIT_ROOT}/rundir/$num_nics"NIC-ckp"-$GUEST_SCRIPT
  RUNDIR=${GIT_ROOT}/rundir/ckpts-with-new-vmlinux/$num_nics"NIC-ckp"-$GUEST_SCRIPT
  setup_dirs
  echo "Taking Checkpoint for NICs=$num_nics" >&2
  GEM5TYPE="fast"
  # packet-size = 0 leads to segfault
  PACKET_SIZE=128
  CPUTYPE="AtomicSimpleCPU"
  # CONFIGARGS="--max-checkpoints 2"
  CONFIGARGS="--max-checkpoints 1 -r 1"
  run_simulation
  exit 0
else
  if [[ -z "$PACKET_SIZE" ]]; then
    echo "Error: missing argument --packet_size" >&2
    usage
  fi

  if [[ -z "$PACKET_RATE" ]]; then
    echo "Error: missing argument --packet_rate" >&2
    usage
  fi
  ((RATE = PACKET_RATE * PACKET_SIZE * 8 / 1024 / 1024 / 1024))
  RUNDIR=${GIT_ROOT}/rundir/ckpts-with-new-vmlinux/fixed/$num_nics"NIC-"$PACKET_SIZE"SIZE-"$PACKET_RATE"RATE-"$RATE"Gbps-ddio-enabled"-$GUEST_SCRIPT
  setup_dirs

  echo "Running NICs=$num_nics at $RATE GBPS" >&2
  CPUTYPE="DerivO3CPU"
  GEM5TYPE="opt"
  LOADGENMODE=${LOADGENMODE:-"Static"}
  DEBUG_FLAGS="--debug-flags=LoadgenDebug" #--debug-start=3395283404348" #EthernetAll,EthernetDesc,LoadgenDebug
  CONFIGARGS="$CACHE_CONFIG $CPU_CONFIG -r 2 --loadgen-start=8715127583908 --rel-max-tick=1000000000000 --packet-rate=$PACKET_RATE --packet-size=$PACKET_SIZE --loadgen-mode=$LOADGENMODE" \
  # --warmup-dpdk 200000000000"
  run_simulation > ${RUNDIR}/simout
  exit
fi
#26292414940003 - testpmd
#26292402742869 - testpmd-touchfwd
#26296403413194 - testpmd-touchdrop
#8715117583908  - l2fwd
#25098506526510 - l2fwd-touchdrop
#4747072597245  - l2fwd-touchfwd