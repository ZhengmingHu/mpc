#include <common.h>
#include <monitor.h>
#include <sim.h>



int main(int argc, char** argv, char** env) {

    Verilated::commandArgs(argc, argv);

    init_monitor(argc, argv);

    sim_reset();

    sim_exec();

    sim_exit();

}