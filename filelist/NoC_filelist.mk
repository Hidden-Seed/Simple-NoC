# Router
include testbench/Router_filelist.mk

# Node
VSRC += $(wildcard vsrc/node/*.sv)

# NoC
VSRC += vsrc/NOC.sv
