#! /usr/bin/bash

# cd /nas/ei/home/go69hil/asic_wise2425_schaefrich/pulpino_clean

TESTBENCH=${1:-tb}       # top


. setup_cadence.sh

module use /nas/ei/share/sec/tools/modulefiles
module load risqv-ht/toolchain/aquorypt-2021

cd COMPILE/compile
make clean && make keccak_bench

cd ../../XCELIUM/work
# ../scripts/run.sh
../scripts/run-$TESTBENCH.sh
