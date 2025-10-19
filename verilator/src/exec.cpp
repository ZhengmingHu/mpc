#include <common.h>
#include <opcode.h>
#include <sim.h>

const char *trace_file = "/home/zcy/workspace/mpc/smoke_test/dhrystone.trace";

void sim_exec() {
    sim_delay(2);
    execute_trace(trace_file);

}

