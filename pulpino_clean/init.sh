#! /usr/bin/bash


. setup_cadence.sh

module use /nas/ei/share/sec/tools/modulefiles
module load risqv-ht/toolchain/aquorypt-2021

cd COMPILE/compile
make clean && make keccak_bench

cd ../../XCELIUM/work
../scripts/run.sh
