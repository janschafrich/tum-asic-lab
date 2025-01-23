#! /usr/bin/bash

# cd /nas/ei/home/go69hil/asic_wise2425_schaefrich/pulpino_clean

TASK=${1:-netlist}          # sim, netlist, phy
TESTBENCH=${2:-top}       # top tb keccak

echo "TASK=$TASK"


. setup_cadence.sh

module use /nas/ei/share/sec/tools/modulefiles
module load risqv-ht/toolchain/aquorypt-2021

if [[ "$TASK" == "sim" ]]
then
    cd COMPILE/compile
    make clean && make keccak_bench

    cd ../../XCELIUM/work
    # ../scripts/run.sh
    ../scripts/run-$TESTBENCH.sh
fi

if [[ "$TASK" == "netlist" ]]
then
    cd GENUS/work
    genus
    source ../scripts/synthesis.tcl
fi

if [[ "$TASK" == "physical" ]]
then
    cd INNOVUS/work
    innovus
   # source ../scripts/phys_syn.tcl
fi

