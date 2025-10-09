#include <common.h>
#include <config.h>
#include <paddr.h>
#include <debug.h>

VerilatedContext* contextp = NULL;
VerilatedVcdC* tfp = NULL;
Vmpc_wrapper* top;

const static char *img_file = "/home/zcy/riscv-tools/riscv-tests/benchmarks/dhrystone.riscv.bin";
const char *log_file = "/home/zcy/workspace/mpc/smoke_test/veri_build/mpc.log";

void init_log(const char *log_file);

void init_sim(){

  contextp = new VerilatedContext;
  tfp = new VerilatedVcdC;
  top = new Vmpc_wrapper;
#ifdef CONFIG_WAVETRACE  
  contextp->traceEverOn(true);
  top->trace(tfp, 0);
  tfp->open("waveform.vcd");
#endif

}

static long init_pmem() {
    init_memory(); 
    Log("\nStart loading image: %s", img_file);
    FILE *fp = fopen(img_file, "rb");
    assert(fp);
    fseek(fp, 0, SEEK_END);
    long size = ftell(fp);
    if (size > MEM_SIZE) {
        fprintf(stderr, "Error: File data exceeds memory bounds\n");
        fclose(fp);
        return -1;
    }
    Log("Finish loading image: %s, size = %ld", img_file, size);
    fseek(fp, 0, SEEK_SET);
    int ret = fread(guest_to_host(RESET_VECTOR), size, 1, fp);
    assert(ret == 1);
    fclose(fp);
    return size;
}

void init_monitor(int argc, char** argv) {

    init_sim();

    init_log(log_file);

    long img_size = init_pmem();

    memory_dump(0x80000000, 64);

}