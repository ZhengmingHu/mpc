#ifndef __SIM_H__
#define __SIM_H__

#include <common.h>
#include <paddr.h>

extern VerilatedContext* contextp;
extern VerilatedVcdC* tfp;
extern Vmpc_wrapper* top;
extern int first_inst;

inline void step_and_dump_wave(){
  top->clk ^= 1;
#ifdef CONFIG_WAVETRACE
  contextp->timeInc(1);
#endif
  top->eval();
#ifdef CONFIG_WAVETRACE
  tfp->dump(contextp->time());
#endif
}

inline void sim_exit(){
    step_and_dump_wave();
#ifdef CONFIG_WAVETRACE
    tfp->close();
#endif
    free_memory();
}

inline void sim_delay(int cycles) {
  for (int i = 0; i < cycles; i++) {
    step_and_dump_wave();
  }
}

inline void sim_reset() {
    top->rst_n = 1; sim_delay(2);
    top->rst_n = 0; sim_delay(20);
    top->rst_n = 1; sim_delay(2);
}

void sim_exec();

void execute_trace(const char* trace_file); 

#endif