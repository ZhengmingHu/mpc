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
TEST_CASE ?= mpc_wrapper


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


# clear middle files
clean:
	rm -rf ./build *.vvp *vcd *.gtkw novas* simv ucli.key *.log ./verdiLog

