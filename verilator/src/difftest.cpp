#include <common.h>
#include <opcode.h>
#include <sim.h>
#include <debug.h>

void print_line(int line_num, int op_type, int size_type, uint64_t addr, uint64_t data) {
    printf("Line %d: %s %s 0x%016lx", line_num,
                   op_type == LOAD ? "read" : "store",
                   size_type == BYTE ? "byte" : 
                   size_type == HALF ? "halfword" :
                   size_type == WORD ? "word" : "double word",
                   addr);
            
    if (op_type == STORE) {
        printf(" 0x%016lx", data);
    }
    printf("\n");
}


int handle_rsp_data(FILE* ref_file, int* ref_line_num) {
    if (top->u_channel_0_rsp_bus_valid && top->u_channel_0_rsp_bus_ready) {

        uint64_t dut_data_high = 0, dut_data_low = 0;
        
        // get 128 bit response from DUT
        dut_data_low = ((uint64_t)top->u_channel_0_rsp_bus_rdata.m_storage[1] << 32) | 
                    top->u_channel_0_rsp_bus_rdata.m_storage[0];
        dut_data_high = ((uint64_t)top->u_channel_0_rsp_bus_rdata.m_storage[3] << 32) | 
                    top->u_channel_0_rsp_bus_rdata.m_storage[2];
        
        // find next load instruction from ref
        char line[256];

        bool found_ins = false;

        int op_type, size_type;
        uint64_t ref_addr, ref_data;
    
        while (fgets(line, sizeof(line), ref_file)) {

            (*ref_line_num)++;
            found_ins = true;

            // skip empty line and comment line
            if (strlen(line) <= 1 || line[0] == '#') {
                continue;
            }            
            
            if (parse_trace_line(line, &op_type, &size_type, &ref_addr, &ref_data)) {

                // only care about load
                if (op_type == LOAD) {
                    break;
                }
                // if it is store instr, keep loading next line
            }
        }

        if (!found_ins) {
            return DONE;
        }
        
         // compare dut_data with ref
        int data_match = 0;
            
        if (size_type == BYTE) {
            data_match = ((dut_data_low & 0xFF) == (ref_data & 0xFF));
        } else if (size_type == HALF) {
            data_match = ((dut_data_low & 0xFFFF) == (ref_data & 0xFFFF));
        } else if (size_type == WORD) {
            data_match = ((dut_data_low & 0xFFFFFFFF) == (ref_data & 0xFFFFFFFF));
        } else if (size_type = DOUBLE) {
            data_match = (dut_data_high == 0 && dut_data_low == ref_data);
        }
            
        if (data_match) {
            printf("DIFFTEST: PASS - Addr=0x%016lx, Data=0x%016lx\n", ref_addr, ref_data);
            return PASS;
        } else {
            printf("DIFFTEST: FAIL - Addr=0x%016lx\n", ref_addr);
            printf("  Expected: 0x%016lx\n", ref_data);
            printf("  Got:      0x%016lx%016lx\n", dut_data_high, dut_data_low);
            printf("  Trace line: %d\n", *ref_line_num);
            return FAIL;
        }
    }
    else {
        if (feof(ref_file)) {
            return DONE;
        } else {
            return PASS;
        }
    }
}