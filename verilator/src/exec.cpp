#include <common.h>
#include <opcode.h>
#include <sim.h>

const char *trace_file = "/home/zcy/riscv-tools/riscv-tests/benchmarks/log/dhrystone.trace";

void sim_exec() {
    sim_delay(2);
    execute_trace(trace_file);

}

