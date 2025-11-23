#include <common.h>
#include <opcode.h>
#include <sim.h>

const char *trace_file = "/home/zcy/workspace/mpc/smoke_test/conv_stride.trace";

void sim_exec() {
    sim_delay(2);
#ifdef CONFIG_CPU_NPU
    execute_trace_npu(trace_file);
#else
    execute_trace(trace_file);
#endif

}

