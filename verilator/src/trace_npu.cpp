#include <common.h>
#include <opcode.h>
#include <sim.h>
#include <debug.h>

// parse trace per line
int parse_trace_line_npu(const char* line, int* req_type, int* op_type, int* size_type, 
                    uint64_t* addr, uint64_t* data_low, uint64_t* data_high) {
    char op_str[16], size_str[16];
    char addr_str[32], data_str[64];
    
    // parse line
    int parsed = sscanf(line, "%15s %15s %31s %63s", op_str, size_str, addr_str, data_str);
    if (parsed < 3) {
        return 0; // parse failed
    }
    
    // parse op type
    if (strcmp(op_str, "read") == 0) {
        *op_type = LOAD;
    } else if (strcmp(op_str, "store") == 0) {
        *op_type = STORE;
    } else if (strcmp(op_str, "read_simd") == 0) {
        *op_type = LOAD;
    } else if (strcmp(op_str, "store_simd") == 0) {
        *op_type = STORE;
    } else {
        return 0; // unknown type
    }
    
    // parse op size
    if (strcmp(size_str, "byte") == 0) {
        *size_type = BYTE;
    } else if (strcmp(size_str, "halfword") == 0) {
        *size_type = HALF;
    } else if (strcmp(size_str, "word") == 0) {
        *size_type = WORD;
    } else if (strstr(line, "doubleword")) {
        *size_type = DOUBLE;
    } else if (strstr(line, "quadword")) {
        *size_type = QUAD;
    } else {
        return 0; // unknown size
    }
    
    // parse addr
    char* addr_clean = addr_str;
    if (strncmp(addr_str, "0x", 2) == 0) {
        addr_clean = addr_str + 2;
    }
    *addr = strtoull(addr_clean, NULL, 16);
    
    // parse data（for store）
    *data_low = 0;
    *data_high = 0;

    char* data_clean = data_str;
    if (strncmp(data_str, "0x", 2) == 0) {
        data_clean = data_str + 2;
    }
    
    if (*size_type == QUAD) {
        char high64_str[17] = "0";
        char low64_str[17] = "0";

        strncpy(high64_str, data_clean, 16);
        high64_str[16] = '\0';

        strncpy(low64_str, data_clean + 16, 16);
        low64_str[16] = '\0';

        *data_high = strtoull(high64_str, NULL, 16);
        *data_low = strtoull(low64_str, NULL, 16);
        
    }
    else {
        *data_low = strtoull(data_clean, NULL, 16);
    }
    // do some correction
    // check instruction type
    const char* is_ins = strchr(line, '#');
    if (is_ins != NULL) {
        
        *req_type = INS;

        // 1. check if it is a compress instruction
        if ((*data_low & 0x1) == 0) {
            *size_type = HALF;
        }

        // 2. check cross cacheline boundary
        if (*size_type == WORD) {
            uint8_t addr_bits = *addr & 0xf;
            if (addr_bits == 0xe) { 
#ifdef CONFIG_DEBUG
                printf("DEBUG: Cross cacheline detected, forcing size to halfword\n");
#endif
                *size_type = HALF;
                // only keep low 16 bit
                *data_low  = *data_low & 0xFFFF;
            }
        }
    } else {
        *req_type = DATA;
    }
    
    
    
    return 1; // successfully parsed
}

template<size_t N>
VlWide<N> create_vlwide(std::initializer_list<uint32_t> values) {

    uint32_t a[N];
    std::copy(values.begin(), values.end(), a);
    
    VlWide<N> data;
    std::copy(std::rbegin(a), std::rend(a), std::begin(data.m_storage));
    return data;
}

// send single trace request
void send_trace_request_npu(int req_type, int op_type, int size_type, uint64_t addr, uint64_t data_low, uint64_t data_high) {
    
    // channel 0 for ifu, channel 1 for lsu, channel 2 for npu
    if (req_type == INS) {
        top->u_channel_0_req_bus_valid = 1;
        top->u_channel_0_req_bus_op = op_type;
        top->u_channel_0_req_bus_size = size_type;
        top->u_channel_0_req_bus_addr = addr;
        top->u_channel_0_req_bus_wdata = create_vlwide<4>({0, 0, 0, 0});

        top->u_channel_2_req_bus_valid = 0;
        top->u_channel_2_req_bus_op = 0;
        top->u_channel_2_req_bus_size = 0;
        top->u_channel_2_req_bus_addr = 0;
        top->u_channel_2_req_bus_wdata = create_vlwide<4>({0, 0, 0, 0});

        top->u_channel_1_req_bus_valid = 0;
        top->u_channel_1_req_bus_op = 0;
        top->u_channel_1_req_bus_size = 0;
        top->u_channel_1_req_bus_addr = 0;
        top->u_channel_1_req_bus_wdata = create_vlwide<4>({0, 0, 0, 0});
    }
    else if (size_type == QUAD) {
         // set basical request info
        top->u_channel_0_req_bus_valid = 0;
        top->u_channel_0_req_bus_op = 0;
        top->u_channel_0_req_bus_size = 0;
        top->u_channel_0_req_bus_addr = 0;
        top->u_channel_0_req_bus_wdata = create_vlwide<4>({0, 0, 0, 0});

        top->u_channel_1_req_bus_valid = 0;
        top->u_channel_1_req_bus_op = 0;
        top->u_channel_1_req_bus_size = 0;
        top->u_channel_1_req_bus_addr = 0;
        top->u_channel_1_req_bus_wdata = create_vlwide<4>({0, 0, 0, 0});

        top->u_channel_2_req_bus_valid = 1;
        top->u_channel_2_req_bus_op = op_type;
        top->u_channel_2_req_bus_size = size_type;
        top->u_channel_2_req_bus_addr = addr;
    
        // set wdata（for store）, default 128 bit
        if (op_type == STORE) {
            uint32_t data_low_high = (uint32_t)(data_low >> 32);
            uint32_t data_low_low = (uint32_t)(data_low & 0xFFFFFFFF);
            uint32_t data_high_high = (uint32_t)(data_high >> 32);
            uint32_t data_high_low = (uint32_t)(data_high & 0xFFFFFFFF);
            top->u_channel_2_req_bus_wdata = create_vlwide<4>({data_high_high, data_high_low, data_low_high, data_low_low});
        } else {
            // for load op，write data is 0
            top->u_channel_2_req_bus_wdata = create_vlwide<4>({0, 0, 0, 0});
        }
    }
    else {
        // set basical request info
        top->u_channel_0_req_bus_valid = 0;
        top->u_channel_0_req_bus_op = 0;
        top->u_channel_0_req_bus_size = 0;
        top->u_channel_0_req_bus_addr = 0;
        top->u_channel_0_req_bus_wdata = create_vlwide<4>({0, 0, 0, 0});

        top->u_channel_2_req_bus_valid = 0;
        top->u_channel_2_req_bus_op = 0;
        top->u_channel_2_req_bus_size = 0;
        top->u_channel_2_req_bus_addr = 0;
        top->u_channel_2_req_bus_wdata = create_vlwide<4>({0, 0, 0, 0});

        top->u_channel_1_req_bus_valid = 1;
        top->u_channel_1_req_bus_op = op_type;
        top->u_channel_1_req_bus_size = size_type;
        top->u_channel_1_req_bus_addr = addr;
    
        // set wdata（for store）, default 128 bit
        if (op_type == STORE) {
            if (size_type == DOUBLE) {
                uint32_t high = (uint32_t)(data_low >> 32);
                uint32_t low = (uint32_t)(data_low & 0xFFFFFFFF);
                top->u_channel_1_req_bus_wdata = create_vlwide<4>({0, 0, high, low});
            } else {
                top->u_channel_1_req_bus_wdata = create_vlwide<4>({0, 0, 0, (uint32_t)data_low});
            }   
        } else {
            // for load op，write data is 0
            top->u_channel_1_req_bus_wdata = create_vlwide<4>({0, 0, 0, 0});
        }
    }

    top->u_channel_0_rsp_bus_ready = 1;
    top->u_channel_1_rsp_bus_ready = 1;
    top->u_channel_2_rsp_bus_ready = 1;
    event->instr++;
}

// reset request
void reset_request_signals_npu() {
    top->u_channel_0_req_bus_valid = 0;
    top->u_channel_0_req_bus_op = 0;
    top->u_channel_0_req_bus_size = 0;
    top->u_channel_0_req_bus_addr = 0;

    top->u_channel_1_req_bus_valid = 0;
    top->u_channel_1_req_bus_op = 0;
    top->u_channel_1_req_bus_size = 0;
    top->u_channel_1_req_bus_addr = 0;

    top->u_channel_2_req_bus_valid = 0;
    top->u_channel_2_req_bus_op = 0;
    top->u_channel_2_req_bus_size = 0;
    top->u_channel_2_req_bus_addr = 0;
}

void update_mshr_stat_npu(uint64_t slice0, uint64_t slice1, uint64_t slice2, uint64_t slice3) {
    
    int busy_slice0 = count_bits_builtin(slice0);
    int busy_slice1 = count_bits_builtin(slice1);
    int busy_slice2 = count_bits_builtin(slice1);
    int busy_slice3 = count_bits_builtin(slice3);

    int max_busy_count = max(busy_slice0, busy_slice1, busy_slice2, busy_slice3);
    event->lsq_max_busy_count[max_busy_count]++;
}

void print_perf_stats_npu(const perf_event_t* event, int line_num) {

    printf("%s[perf] Total Cycle: %ld%s\n", COLOR_CYAN, event->cycles, COLOR_RESET);
    printf("%s[perf] Total Instr: %ld%s\n", COLOR_CYAN, event->instr, COLOR_RESET);
    printf("%s[perf] Total CPI: %f%s\n", COLOR_CYAN, (double)((double)event->cycles/(double)event->instr), COLOR_RESET);
    printf("%sProcessed lines: %s%d%s\n", COLOR_YELLOW, COLOR_CYAN, line_num, COLOR_RESET);
    
    printf("\n%s=== LSQ Max Busy Table Entry Statistics ===%s\n", COLOR_CYAN, COLOR_RESET);
    printf("%sNote: Statistics show the maximum busy entries among 4 slices%s\n", COLOR_YELLOW, COLOR_RESET);
    printf("%sMax Busy Count | Cycles | Percentage%s\n", COLOR_CYAN, COLOR_RESET);
    printf("%s-------------------------------------%s\n", COLOR_CYAN, COLOR_RESET);
    
    for (int i = 0; i < MSHR_SIZE; i++) {
        double percentage = (double)event->lsq_max_busy_count[i] / event->cycles * 100.0;
        printf("%s%2d entries    | %6lu | %6.2f%%%s\n", COLOR_CYAN, i, event->lsq_max_busy_count[i], percentage, COLOR_RESET);
    }
    
    uint64_t total_weighted_cycles = 0;
    for (int i = 0; i < MSHR_SIZE; i++) {
        total_weighted_cycles += i * event->lsq_max_busy_count[i];
    }
    
    double avg_max_busy = (double)total_weighted_cycles / event->cycles;
    printf("%s\nAverage max busy entries per cycle: %.2f%s\n", COLOR_CYAN, avg_max_busy, COLOR_RESET);
    
    uint64_t peak_usage_cycles = 0;
    for (int i = (3*(MSHR_SIZE))/4; i < MSHR_SIZE; i++) { 
        peak_usage_cycles += event->lsq_max_busy_count[i];
    }
    double peak_usage_percentage = (double)peak_usage_cycles / event->cycles * 100.0;
    printf("%sPeak usage (>=%d entries): %.2f%% of cycles%s\n", COLOR_CYAN, (3*(MSHR_SIZE))/4, peak_usage_percentage, COLOR_RESET);
}

// main exec func - execute trace file per line
void execute_trace_npu(const char* trace_file) {

    FILE* file = fopen(trace_file, "r");
    
#ifdef CONFIG_DIFFTEST
    FILE* ch0 = fopen("ch0.trace", "w+");
    FILE* ch1 = fopen("ch1.trace", "w+");
    FILE* ch2 = fopen("ch2.trace", "w+");
#endif

    if (!file) {
        printf("Error: Cannot open trace file %s\n", trace_file);
        return;
    }
    
    char line[256];
    int line_num = 0;
    int ref_num = 0;
    int rsp_retry_num = 0;
    int rsp = PASS;
    bool deadlock = false;
    
    printf("Starting trace execution: %s\n", trace_file);

    sim_delay(2);
    
    while (fgets(line, sizeof(line), file)) {
        
        line_num++;
    
        // skip empty line and comment line
        if (strlen(line) <= 1 || line[0] == '#') {
            continue;
        }
        
        int req_type, op_type, size_type;
        uint64_t addr, data_low, data_high;
        rsp = PASS;

        if (parse_trace_line_npu(line, &req_type, &op_type, &size_type, &addr, &data_low, &data_high)) {
#ifdef CONFIG_DEBUG
            print_line_npu(line_num, op_type, size_type, addr, data_low, data_high);
#endif
#ifdef CONFIG_DIFFTEST
            cache_line_npu(ch0, ch1, ch2, line, op_type, size_type, addr);
#endif
            int retry_count = 0;
            
            // send request
            send_trace_request_npu(req_type, op_type, size_type, addr, data_low, data_high);                        
            while (retry_count < MAX_RETRY && !(top->u_channel_0_req_bus_valid && top->u_channel_0_req_bus_ready ||
                   top->u_channel_1_req_bus_valid && top->u_channel_1_req_bus_ready ||
                   top->u_channel_2_req_bus_valid && top->u_channel_2_req_bus_ready)) {                
                
                // difftest
#ifdef CONFIG_DIFFTEST
                rsp = handle_multiport_rsp_data_npu(ch0, ch1, ch2, &ref_num, &rsp_retry_num, false);
                if (rsp==FAIL) {break;}
#endif
                // delay 1 cycle when not handshake
                sim_delay(2);
                event->cycles++;
                update_mshr_stat_npu(top->slice_0_pmu_lsq_busy, top->slice_1_pmu_lsq_busy, top->slice_2_pmu_lsq_busy, top->slice_3_pmu_lsq_busy);
                retry_count++;
            }
        
            // check if deadlock occurred
            if (retry_count >= MAX_RETRY) {
                printf("Error: Deadlock detected at line %d after %d retries\n", line_num, MAX_RETRY);
                deadlock = true;
                break;
            }
// difftest
#ifdef CONFIG_DIFFTEST
            if (rsp==FAIL) {break;}
            rsp = handle_multiport_rsp_data_npu(ch0, ch1, ch2, &ref_num, &rsp_retry_num, false);
            if (rsp==FAIL) {break;}
#endif
            // delay when handshake
            sim_delay(2);
            event->cycles++;
            update_mshr_stat_npu(top->slice_0_pmu_lsq_busy, top->slice_1_pmu_lsq_busy, top->slice_2_pmu_lsq_busy, top->slice_3_pmu_lsq_busy);
        } else {
            printf("Warning: Failed to parse line %d: %s", line_num, line);
        }
    }
    reset_request_signals_npu();
    if (deadlock) {
        printf("\n%s%s%s\n", COLOR_RED, SEPARATOR, COLOR_RESET);
        printf("%sDEADLOCK%s\n", COLOR_RED, COLOR_RESET);
        printf("%s%s%s\n", COLOR_RED, SEPARATOR, COLOR_RESET);
        printf("%sTrace execution failed due to deadlock!%s\n", COLOR_CYAN, COLOR_RESET);
        printf("%sProcessed lines: %s%d%s\n", COLOR_YELLOW, COLOR_CYAN, line_num, COLOR_RESET);
        printf("\n");
        return;
    }
#ifdef CONFIG_DIFFTEST
    if (rsp == FAIL) {
        printf("\n%s%s%s\n", COLOR_RED, SEPARATOR, COLOR_RESET);
        printf("%sFAIL%s\n", COLOR_RED, COLOR_RESET);
        printf("%s%s%s\n", COLOR_RED, SEPARATOR, COLOR_RESET);
        printf("%sTrace execution failed due to response error!%s\n", COLOR_CYAN, COLOR_RESET);
        printf("%sProcessed lines: %s%d%s\n", COLOR_YELLOW, COLOR_CYAN, line_num, COLOR_RESET);
        printf("\n");
        return;
    }
    int i=0;
    while(rsp == PASS){
        rsp = handle_multiport_rsp_data(ch0, ch1, ch2, &ref_num,  &rsp_retry_num, true);
        sim_delay(2);
        event->cycles++;
        update_mshr_stat_npu(top->slice_0_pmu_lsq_busy, top->slice_1_pmu_lsq_busy, top->slice_2_pmu_lsq_busy, top->slice_3_pmu_lsq_busy);
    };
#endif
    if (rsp == DONE) {
        printf("\n%s%s%s\n", COLOR_GREEN, SEPARATOR, COLOR_RESET);
        printf("%s✓ PASS%s\n", COLOR_GREEN, COLOR_RESET);
        printf("%s%s%s\n", COLOR_GREEN, SEPARATOR, COLOR_RESET);
        printf("%sTrace execution completed successfully!%s\n", COLOR_CYAN, COLOR_RESET);
        print_perf_stats_npu(event, line_num);
        printf("%sProcessed lines: %s%d%s\n", COLOR_YELLOW, COLOR_CYAN, line_num, COLOR_RESET);
        printf("\n");
    }
    if (rsp == DEADLOCK) {
        printf("\n%s%s%s\n", COLOR_RED, SEPARATOR, COLOR_RESET);
        printf("%sDEADLOCK%s\n", COLOR_RED, COLOR_RESET);
        printf("%s%s%s\n", COLOR_RED, SEPARATOR, COLOR_RESET);
        printf("%sTrace execution failed due to deadlock!%s\n", COLOR_CYAN, COLOR_RESET);
        printf("%sProcessed lines: %s%d%s\n", COLOR_YELLOW, COLOR_CYAN, line_num, COLOR_RESET);
        printf("\n");
        return;
    }
    else if (rsp == FAIL) {
        printf("\n%s%s%s\n", COLOR_RED, SEPARATOR, COLOR_RESET);
        printf("%s✓ FAIL%s\n", COLOR_RED, COLOR_RESET);
        printf("%s%s%s\n", COLOR_RED, SEPARATOR, COLOR_RESET);
        printf("%sTrace execution failed due to response errror!%s\n", COLOR_CYAN, COLOR_RESET);
        printf("%sProcessed lines: %s%d%s\n", COLOR_YELLOW, COLOR_CYAN, line_num, COLOR_RESET);
        printf("\n");
        return;
    }
    
    sim_delay(200);

    fclose(file);

#ifdef CONFIG_DIFFTEST
    fclose(ch0);
    fclose(ch1);
    fclose(ch2);
#endif

    printf(".................................................\n");
}