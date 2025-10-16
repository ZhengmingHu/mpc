FSDB ?= 0
DEFINE ?= +define+DW_SUPPRESS_WARN
ROOT ?= /home/zcy/workspace/mpc

RTL_DIR := $(ROOT)/rtl
INC_DIR := $(ROOT)/rtl/include
TB_DIR := $(ROOT)/tb

ifeq ($(FSDB),1)
	DEFINE += +define+FSDB
endif

##*****************************************************##
##													   ##
##				   SIMGLE_TEST   		               ##
##													   ##
##*****************************************************##

# TEST_CASE ?= arbiter
# TEST_CASE ?= xbar_core
# TEST_CASE ?= prio_enc
# TEST_CASE ?= htu
# TEST_CASE ?= xbar_wrapper
# TEST_CASE ?= rob_id_gen
# TEST_CASE ?= inflight_array
# TEST_CASE ?= mux1h
# TEST_CASE ?= srb
# TEST_CASE ?= rtn_xbar_core
# TEST_CASE ?= kob
# TEST_CASE ?= isu
# TEST_CASE ?= rc_wrapper
# TEST_CASE ?= write_buffer
# TEST_CASE ?= mc_wrapper
# TEST_CASE ?= extmem
# TEST_CASE ?= mpc_wrapper
# TEST_CASE ?= mem_intf_arbiter
TEST_CASE ?= top


##*****************************************************##
##													   ##
##						IVERILOG		               ##
##													   ##
##*****************************************************##

TESTBENCH_MODULE = tb_$(TEST_CASE)
TESTBENCH_FILE = $(ROOT)/tb/$(TESTBENCH_MODULE).sv
RTL_FILE = $(ROOT)/rtl/lib/*.sv $(ROOT)/rtl/Xbar/*.sv
GTKW_FILE = $(TESTBENCH_MODULE).gtkw

iverilog_compile:
	iverilog -g2012 -o $(TESTBENCH_MODULE).vvp $(RTL_FILE) $(TESTBENCH_FILE)

iverilog_run:iverilog_compile
	vvp -n $(TESTBENCH_MODULE).vvp -lxt2

iverilog_wave:
    ifneq "$(wildcard $(GTKW_FILE))" ""
	    gtkwave $(GTKW_FILE)
    else
	    gtkwave $(TESTBENCH_MODULE).vcd
    endif

iverilog: iverilog_compile iverilog_run


##*****************************************************##
##													   ##
##						  VCS   		               ##
##													   ##
##*****************************************************##

BUILD_DIR := ./build
VCS_DEBUG := -fsdb --debug_access

INIT_RESULT := $(BUILD_DIR)/result/init_test
VERDI_FILE := $(BUILD_DIR)/result/init_test/$(TEST_CASE)

FILELIST_DIR := $(ROOT)/filelist
FILELIST := $(FILELIST_DIR)/$(TEST_CASE).f

RCFILE_DIR := $(ROOT)/verdi_common
RCFILE ?= $(TEST_CASE).rc

MEM_DIR := $(TB_DIR)/mem_model

vcs_compile:
	@if [ ! -d $(BUILD_DIR) ]; then\
		mkdir $(BUILD_DIR); \
	fi
	vcs -full64 -sverilog -timescale=1ns/1ns \
		+nospecify +notimingcheck \
		+vcs+loopresport+10000 \
		$(VCS_DEBUG) \
		$(DEFINE) \
		-debug_access+all -kdb -lca \
		-deraceclockdata \
		-LDFLAGS "-Wl,-rpath,." \
		-CFLAGS "--std=c99 -fno-extended-identifiers -I${VCS_HOME}/include" \
		+lint=TFIPC-L \
		+lint=PCWM \
		+incdir+$(INC_DIR) \
		-daidir=$(BUILD_DIR)/simv.daidir -Mdir=$(BUILD_DIR)/csrc \
		-l $(BUILD_DIR)/compile.log -f $(FILELIST)	

vcs_run:vcs_compile
	-mkdir -p $(INIT_RESULT)
	./simv -sv_lib $(MEM_DIR)/mem_impl \
	$(DEFINE) \
	+FSDB_FILE=$(INIT_RESULT)/$(TEST_CASE).fsdb
 
verdi:
	verdi -sverilog -nologo \
	-sswr $(RCFILE_DIR)/$(RCFILE) \
	$(DEFINE) \
	-ssf $(VERDI_FILE).fsdb -f $(FILELIST) &

##*****************************************************##
##													   ##
##						VERILATOR 		               ##
##													   ##
##*****************************************************##

# path and top module
MODULE=mpc_wrapper
VPATH=$(MPC_HOME)/rtl
CPATH=$(MPC_HOME)/verilator
TOPPATH=$(CPATH)/src
VERI_BUILD_DIR=./veri_build

MPC_INCPATH=$(VPATH)/include
CINCPATH=$(CPATH)/include

OBJ_DIR=$(VERI_BUILD_DIR)/obj_dir
BIN=$(VERI_BUILD_DIR)/V$(MODULE)
VCD_FILE=$(VERI_BUILD_DIR)/$(TEST_CASE).vcd

# project source
CSRCS=$(shell find $(abspath ../verilator) \( -name "*.cpp" -o -name "*.cc" \) -not -path ".build/obj_dir/*" )
INCSRC=$(shell find $(abspath ../rtl/include) -name "*.sv")
RTLSRC=$(shell find $(abspath ../rtl) \( -name "*.sv" \) -not -path "$(abspath ../rtl/include)/*")
SVSRC=$(INCSRC) $(RTLSRC)

# rules for verilator
VERILATOR = verilator
VERILATOR_CFLAGS += -O3 -MMD --build --trace\
					--assert --autoflush --cc\
					--x-assign unique --x-initial unique \
					--timescale "1ns/1ns" --no-timing \
					-I$(MPC_INCPATH)
CFLAGS += $(shell llvm-config --cxxflags | sed 's/-D__STDC_FORMAT_MACROS//g') -fPIE -I$(CINCPATH)
LDFLAGS += -lreadline $(shell llvm-config --libs) -ldl -pie -lSDL2

$(shell mkdir -p $(VERI_BUILD_DIR))

veri_run:$(VCD_FILE)
	@echo "### GENERATING WAVEFORM ###"
	@if [ -f waveform.vcd ]; then \
		vcd2fsdb waveform.vcd; \
	else \
		echo "Warning: waveform.vcd does not exist, skipping VCD to FSDB conversion"; \
	fi


veri_build:$(BIN)

$(VCD_FILE):$(BIN)
	@echo
	@echo "### SIMULATING ###"
	@$^

$(BIN): $(CSRCS) $(SVSRC)
	@rm -rf $(OBJ_DIR)
	@echo
	@echo "### VERILATING ###"
	@for file in $(SVSRC); do \
		echo + VL $$file; \
	done
	@for file in $(VSRC); do \
		echo + VL $$file; \
	done
	@for file in $(CSRCS); do \
		echo + CC $$file; \
	done
	@$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(MODULE) $^ \
		$(addprefix -CFLAGS , $(CFLAGS)) \
		$(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) \
		--exe -o $(abspath $(BIN))
	@touch .stamp.verilate
	
vcd2fsdb:
	@if [ -f waveform.vcd ]; then \
		vcd2fsdb waveform.vcd; \
	else \
		echo "Warning: waveform.vcd does not exist, skipping VCD to FSDB conversion"; \
	fi

veri_verdi:
	verdi -sverilog -nologo \
	-sswr $(RCFILE_DIR)/$(RCFILE) \
	$(DEFINE) \
	-ssf waveform.vcd.fsdb -f $(FILELIST) &


.PHONY:lint
lint:  $(VPATH)$(MODULE).sv
	verilator --lint-only $(VPATH)$(MODULE).sv

# clear middle files
clean:
	rm -rf .stamp.* ./build *.vvp *vcd *.gtkw novas* simv ucli.key *.log ./verdiLog

