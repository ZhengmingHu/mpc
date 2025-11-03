#include <common.h>
#include <opcode.h>
#include <sim.h>
#include <debug.h>

// parse trace per line
int parse_trace_line(const char* line, int* op_type, int* size_type, 
                    uint64_t* addr, uint64_t* data) {
    char op_str[16], size_str[16];
    char addr_str[32], data_str[32];
    
    // parse line
    int parsed = sscanf(line, "%15s %15s %31s %31s", op_str, size_str, addr_str, data_str);
    if (parsed < 3) {
        return 0; // parse failed
    }
    
    // parse op type
    if (strcmp(op_str, "read") == 0) {
        *op_type = LOAD;
    } else if (strcmp(op_str, "store") == 0) {
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
    char* data_clean = data_str;
    if (strncmp(data_str, "0x", 2) == 0) {
        data_clean = data_str + 2;
    }
    *data = strtoull(data_clean, NULL, 16);

    // do some correction
    // check instruction type
    const char* is_ins = strchr(line, '#');
    if (is_ins != NULL) {
        
        // 1. check if it is a compress instruction
        if ((*data & 0x1) == 0) {
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
                *data = *data & 0xFFFF;
            }
        }
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
void send_trace_request(int op_type, int size_type, uint64_t addr, uint64_t data) {
    // set basical request info
    top->u_channel_0_req_bus_valid = 1;
    top->u_channel_0_req_bus_op = op_type;
    top->u_channel_0_req_bus_size = size_type;
    top->u_channel_0_req_bus_addr = addr;
    
    // set wdata（for store）, default 128 bit
    if (op_type == STORE) {
        if (size_type == DOUBLE) {
            uint32_t high = (uint32_t)(data >> 32);
            uint32_t low = (uint32_t)(data & 0xFFFFFFFF);
            top->u_channel_0_req_bus_wdata = create_vlwide<4>({0, 0, high, low});
        } else {
            top->u_channel_0_req_bus_wdata = create_vlwide<4>({0, 0, 0, (uint32_t)data});
        }
    } else {
        // for load op，write data is 0
        top->u_channel_0_req_bus_wdata = create_vlwide<4>({0, 0, 0, 0});
    }
    
    top->u_channel_0_rsp_bus_ready = 1;
}

// reset request
void reset_request_signals() {
    top->u_channel_0_req_bus_valid = 0;
    top->u_channel_0_req_bus_op = 0;
    top->u_channel_0_req_bus_size = 0;
    top->u_channel_0_req_bus_addr = 0;
}

// main exec func - execute trace file per line
void execute_trace(const char* trace_file) {

    FILE* file = fopen(trace_file, "r");
#ifdef CONFIG_DIFFTEST
    FILE* ref = fopen(trace_file, "r");
#endif
    if (!file) {
        printf("Error: Cannot open trace file %s\n", trace_file);
        return;
    }
    
    char line[256];
    int line_num = 0;
    int ref_num = 0;
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
        
        int op_type, size_type;
        uint64_t addr, data;
        rsp = PASS;

        if (parse_trace_line(line, &op_type, &size_type, &addr, &data)) {
#ifdef CONFIG_DEBUG
            print_line(line_num, op_type, size_type, addr, data);
#endif
            
            int request_sent = 0;
            int retry_count = 0;

            // send request
            send_trace_request(op_type, size_type, addr, data);
                        
            while (retry_count < MAX_RETRY && !(top->u_channel_0_req_bus_valid && top->u_channel_0_req_bus_ready)) {                
                
                // difftest
#ifdef CONFIG_DIFFTEST
                rsp = handle_rsp_data(ref, &ref_num);
                if (rsp==FAIL) {break;}
#endif
                // delay 1 cycle and check handshake
                sim_delay(2);
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
            rsp = handle_rsp_data(ref, &ref_num);
            if (rsp==FAIL) {break;}
#endif

            // delay after handshake
            sim_delay(2);
            
        } else {
            printf("Warning: Failed to parse line %d: %s", line_num, line);
        }
    }
    reset_request_signals();
    if (deadlock) {return;}
#ifdef CONFIG_DIFFTEST
    if (rsp == FAIL) {return;}
    while(handle_rsp_data(ref, &ref_num)==PASS);
#endif
    sim_delay(200);

    fclose(file);
#ifdef CONFIG_DIFFTEST
    fclose(ref);
#endif

    printf(".................................................\n");
    printf("Trace execution completed. Processed %d lines.\n", line_num);
}