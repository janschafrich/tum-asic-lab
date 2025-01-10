#!/bin/bash

shopt -s expand_aliases

export RTL=../../RTL
export IPS=${RTL}/ips
STIM=../

# option -gui
xrun $1 -64bit -f ../scripts/sim.args -access +rwc -define PULP_FPGA_EMUL -define STIM_PATH=\"${STIM}\" -disable_sem2009 -v93 -timescale 1ps/1ps -simvisargs '-input ../scripts/sim_wave.tcl' -top tb
