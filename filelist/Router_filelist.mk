# Buffer
include filelist/Buffer_Unit_filelist.mk
VSRC += vsrc/router/buffer/Buffer.sv

# Switch & Allocator
VSRC += $(wildcard vsrc/router/switch/*.sv)    \
		$(wildcard vsrc/router/allocator/*.sv)

# Routing_Unit
include filelist/Routing_Unit_filelist.mk

# Router
VSRC += vsrc/router/Router.sv

# TB utils
VSRC += testbench/utils/ReqAckVif.sv    \
		testbench/utils/Routing_Func.sv
