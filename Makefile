# User configurable
TOP  ?= FIFO
MODE ?=

# Directory structure
WORK_DIR   := $(shell pwd)
BUILD_DIR  := $(WORK_DIR)/build
OUTPUT_DIR := $(BUILD_DIR)/$(TOP)
SIMV       := $(OUTPUT_DIR)/simv

LOG_FILE   := $(OUTPUT_DIR)/sim_$(TOP).log

# Compile-time defines
DEFINES := SIM
ifneq ($(strip $(MODE)),)
DEFINES += $(MODE)
endif

# Time scale
TIME_SCALE := 1ns/1ns

# VCS flags (grouped by purpose)
VCS_BASE_FLAGS  := -full64 -sverilog -timescale=$(TIME_SCALE)
VCS_DEBUG_FLAGS := -debug_acc+dmptf -debug_access+all -kdb -lca
VCS_BUILD_FLAGS := -Mdir=$(OUTPUT_DIR)/csrc -o $(SIMV)
VCS_WAVE_FLAGS  := +memcbk
VCS_LINT_FLAGS  := +lint=TFIPC-L +error+999
VCS_LINK_FLAGS  := -LDFLAGS -Wl,--no-as-needed

VCS_FLAGS := $(VCS_BASE_FLAGS)  \
             $(VCS_DEBUG_FLAGS) \
			 $(VCS_BUILD_FLAGS) \
             $(VCS_WAVE_FLAGS)  \
             $(VCS_LINT_FLAGS)  \
             $(VCS_LINK_FLAGS)

VCS_FLAGS += -top $(TOP)_TB -l $(LOG_FILE)   \
			 $(addprefix +define+,$(DEFINES))

# Verdi flags
FSDB_FILE   := $(OUTPUT_DIR)/$(TOP).fsdb
DAIDIR_FILE := $(OUTPUT_DIR)/simv.daidir
SIGNAL_FILE := $(OUTPUT_DIR)/signal.rc
VERDI_FLAGS := -simflow -nologo -dbdir $(DAIDIR_FILE) \
			   -ssf $(FSDB_FILE) -sswr $(SIGNAL_FILE)

# Source files
include filelist/common_filelist.mk
include filelist/$(TOP)_filelist.mk
VSRC += testbench/$(TOP)_TB.sv

.PHONY: all sim compile run verdi clean clean-all
all: sim

# Create output directory if not exists
$(shell mkdir -p $(OUTPUT_DIR))

$(SIMV): $(VSRC)
	vcs $^ $(VCS_FLAGS)
compile: $(SIMV)

# Run simulation (after compile)
# cd $(OUTPUT_DIR) to generate ucli.key
run: $(SIMV)
	cd $(OUTPUT_DIR) && $^

sim: run

# Launch Verdi
$(DAIDIR_FILE): $(SIMV)
	$^
verdi: $(DAIDIR_FILE)
	cd $(OUTPUT_DIR) &&	verdi $(VERDI_FLAGS)

clean:
	rm -rf $(OUTPUT_DIR)

clean-all:
	rm -rf $(BUILD_DIR)
