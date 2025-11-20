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

#ifdef CONFIG_CPU_MULTIPORT

// cache line to a file
void cache_line(FILE* ch0, FILE* ch1, FILE* ch2, const char* line, int op_type, uint64_t addr) {

    // Compute width for each addr region
    const int OFFSET_BITS = __builtin_ctz(LINE_SIZE);  // log2(LINE_SIZE)
    const int SET_BITS = __builtin_ctz(SET_NUM);       // log2(SET_NUM)
    const int SLICE_BITS = 2;                          // 4个slice -> 2bit
    
    const int SLICE_SHIFT = OFFSET_BITS + SET_BITS + 1;
    
    // extract slice
    uint64_t slice = (addr >> SLICE_SHIFT) & 0x3;
    if (ch0 && line && (strchr(line, '#') != NULL)) {
        fputs(line, ch0);
        fflush(ch0);  // ensure writing immediately
    }
    else if (ch1 && line && (slice == 0 || slice == 2) && (op_type==LOAD)) {
        fputs(line, ch1);
        fflush(ch1);  // ensure writing immediately

    }
    else if (ch2 && line && (slice == 1 || slice == 3) && (op_type==LOAD)) {
        fputs(line, ch2);
        fflush(ch2);  // ensure writing immediately
    }
}

// global variable tracking read pointer pos
static long ch0_read_position = 0;
static long ch1_read_position = 0;
static long ch2_read_position = 0;

// read next cache line
void test_read_cache_line(FILE* cache_file) {
    if (!cache_file) {
        return;
    }
    
    // save current file pos
    long current_pos = ftell(cache_file);
    
    // rewind to the head (first call) or continue reading
    if (ch0_read_position == 0) {
        rewind(cache_file);
    } else {
        fseek(cache_file, ch0_read_position, SEEK_SET);
    }
    
    char cached_line[256];
    if (fgets(cached_line, sizeof(cached_line), cache_file)) {
        printf("CACHED INSTRUCTION: %s", cached_line);
        // update read position
        ch0_read_position = ftell(cache_file);
    } else {
        ch0_read_position = 0;  // reset
    }
    
    // recover to current_pos, not affecting write
    fseek(cache_file, current_pos, SEEK_SET);
}

#endif

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

        int req_type, op_type, size_type;
        uint64_t ref_addr, ref_data;
    
        while (fgets(line, sizeof(line), ref_file)) {

            (*ref_line_num)++;

            // skip empty line and comment line
            if (strlen(line) <= 1 || line[0] == '#') {
                continue;
            }            
            
            if (parse_trace_line(line, &req_type, &op_type, &size_type, &ref_addr, &ref_data)) {

                // only care about load
                if (op_type == LOAD) {
                    break;
                }
                // if it is store instr, keep loading next line
            }
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

int handle_multiport_rsp_data (FILE* ch0, FILE* ch1, FILE* ch2, int* ref_line_num, int* rsp_retry_num, bool req_end) {
    // save current file pos
    long ch0_current_pos = ftell(ch0);
    long ch1_current_pos = ftell(ch1);
    long ch2_current_pos = ftell(ch2);

    int ch0_state = PASS;
    int ch1_state = PASS;
    int ch2_state = PASS;

    // rewind to the head (first call) or continue reading
    if (ch0_read_position == 0) {
        rewind(ch0);
    } else {
        fseek(ch0, ch0_read_position, SEEK_SET);
    }

    if (ch1_read_position == 0) {
        rewind(ch1);
    } else {
        fseek(ch1, ch1_read_position, SEEK_SET);
    }

    if (ch2_read_position == 0) {
        rewind(ch2);
    } else {
        fseek(ch2, ch2_read_position, SEEK_SET);
    }

    // if (!top->u_channel_0_rsp_bus_valid & !top->u_channel_1_rsp_bus_valid & !top->u_channel_2_rsp_bus_valid & req_end){
    //     printf("here we go, retry_num:%d\n", (*rsp_retry_num));
    //     (*rsp_retry_num)++;
    //     if ((*rsp_retry_num) == MAX_RETRY){
    //         return DEADLOCK;
    //     } 
    // }
    // else {
    //     (*rsp_retry_num)=0;
    // }

    if (top->u_channel_0_rsp_bus_valid && top->u_channel_0_rsp_bus_ready) {

        uint64_t dut_data_high = 0, dut_data_low = 0;
        
        // get 128 bit response from DUT
        dut_data_low = ((uint64_t)top->u_channel_0_rsp_bus_rdata.m_storage[1] << 32) | 
                    top->u_channel_0_rsp_bus_rdata.m_storage[0];
        dut_data_high = ((uint64_t)top->u_channel_0_rsp_bus_rdata.m_storage[3] << 32) | 
                    top->u_channel_0_rsp_bus_rdata.m_storage[2];
        
        // find next load instruction from ref
        char line[256];

        int req_type, op_type, size_type;
        uint64_t ref_addr, ref_data;
    
        if(fgets(line, sizeof(line), ch0)){
            *ref_line_num++;      
            parse_trace_line(line, &req_type, &op_type, &size_type, &ref_addr, &ref_data);
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
            printf("DIFFTEST: CH0 PASS - Addr=0x%016lx, Data=0x%016lx\n", ref_addr, ref_data);
            ch0_state = PASS;
        } else {
            printf("DIFFTEST: CH0 FAIL - Addr=0x%016lx\n", ref_addr);
            printf("  Expected: 0x%016lx\n", ref_data);
            printf("  Got:      0x%016lx%016lx\n", dut_data_high, dut_data_low);
            printf("  Trace line: %d\n", *ref_line_num);
            ch0_state = FAIL;
        }
    }

    if (top->u_channel_1_rsp_bus_valid && top->u_channel_1_rsp_bus_ready) {
        uint64_t dut_data_high = 0, dut_data_low = 0;
        
        // get 128 bit response from DUT
        dut_data_low = ((uint64_t)top->u_channel_1_rsp_bus_rdata.m_storage[1] << 32) | 
                    top->u_channel_1_rsp_bus_rdata.m_storage[0];
        dut_data_high = ((uint64_t)top->u_channel_1_rsp_bus_rdata.m_storage[3] << 32) | 
                    top->u_channel_1_rsp_bus_rdata.m_storage[2];
        
        // find next load instruction from ref
        char line[256];

        int req_type, op_type, size_type;
        uint64_t ref_addr, ref_data;
    
        if(fgets(line, sizeof(line), ch1)){
            *ref_line_num++;   
            parse_trace_line(line, &req_type, &op_type, &size_type, &ref_addr, &ref_data);
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
            printf("DIFFTEST: CH1 PASS - Addr=0x%016lx, Data=0x%016lx\n", ref_addr, ref_data);
            ch1_state = PASS;
        } else {
            printf("DIFFTEST: CH1 FAIL - Addr=0x%016lx\n", ref_addr);
            printf("  Expected: 0x%016lx\n", ref_data);
            printf("  Got:      0x%016lx%016lx\n", dut_data_high, dut_data_low);
            printf("  Trace line: %d\n", *ref_line_num);
            ch1_state = FAIL;
        }
    }

    if (top->u_channel_2_rsp_bus_valid && top->u_channel_2_rsp_bus_ready) {
        uint64_t dut_data_high = 0, dut_data_low = 0;
        
        // get 128 bit response from DUT
        dut_data_low = ((uint64_t)top->u_channel_2_rsp_bus_rdata.m_storage[1] << 32) | 
                    top->u_channel_2_rsp_bus_rdata.m_storage[0];
        dut_data_high = ((uint64_t)top->u_channel_2_rsp_bus_rdata.m_storage[3] << 32) | 
                    top->u_channel_2_rsp_bus_rdata.m_storage[2];
        
        // find next load instruction from ref
        char line[256];

        int req_type, op_type, size_type;
        uint64_t ref_addr, ref_data;
    
        if(fgets(line, sizeof(line), ch2)) {
            *ref_line_num++;    
            parse_trace_line(line, &req_type, &op_type, &size_type, &ref_addr, &ref_data);
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
            printf("DIFFTEST: CH2 PASS - Addr=0x%016lx, Data=0x%016lx\n", ref_addr, ref_data);
            ch2_state = PASS;
        } else {
            printf("DIFFTEST: CH2 FAIL - Addr=0x%016lx\n", ref_addr);
            printf("  Expected: 0x%016lx\n", ref_data);
            printf("  Got:      0x%016lx%016lx\n", dut_data_high, dut_data_low);
            printf("  Trace line: %d\n", *ref_line_num);
            ch2_state = FAIL;
        }
    }

    // update read position
    ch0_read_position = ftell(ch0);
    ch1_read_position = ftell(ch1);
    ch2_read_position = ftell(ch2);

    if (ch0_read_position == ch0_current_pos && 
        ch1_read_position == ch1_current_pos &&
        ch2_read_position == ch2_current_pos && req_end) {
        return DONE;
    } else if (ch0_state == PASS && ch1_state == PASS && ch2_state == PASS) {
        // recover to current_pos, not affecting write
        fseek(ch0, ch0_current_pos, SEEK_SET);
        // recover to current_pos, not affecting write
        fseek(ch1, ch1_current_pos, SEEK_SET);
        // recover to current_pos, not affecting write
        fseek(ch2, ch2_current_pos, SEEK_SET);
        return PASS;
    } else {
        return FAIL;
    }
}