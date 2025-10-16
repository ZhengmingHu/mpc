#include <common.h>
#include <opcode.h>
#include <sim.h>

// 解析单行trace
int parse_trace_line(const char* line, int* op_type, int* size_type, 
                    uint64_t* addr, uint64_t* data) {
    char op_str[16], size_str[16];
    char addr_str[32], data_str[32];
    
    // 解析每行
    int parsed = sscanf(line, "%15s %15s %31s %31s", op_str, size_str, addr_str, data_str);
    if (parsed < 3) {
        return 0; // 解析失败
    }
    
    // 解析操作类型
    if (strcmp(op_str, "read") == 0) {
        *op_type = LOAD;
    } else if (strcmp(op_str, "store") == 0) {
        *op_type = STORE;
    } else {
        return 0; // 未知操作
    }
    
    // 解析大小类型
    if (strcmp(size_str, "byte") == 0) {
        *size_type = BYTE;
    } else if (strcmp(size_str, "halfword") == 0) {
        *size_type = HALF;
    } else if (strcmp(size_str, "word") == 0) {
        *size_type = WORD;
    } else if (strstr(line, "double word")) {
        *size_type = DOUBLE;
    } else {
        return 0; // 未知大小
    }
    
    // 解析地址
    char* addr_clean = addr_str;
    if (strncmp(addr_str, "0x", 2) == 0) {
        addr_clean = addr_str + 2;
    }
    *addr = strtoull(addr_clean, NULL, 16);
    
    // 解析数据（对于store操作）
    if (*op_type == STORE && parsed >= 4) {
        char* data_clean = data_str;
        if (strncmp(data_str, "0x", 2) == 0) {
            data_clean = data_str + 2;
        }
        *data = strtoull(data_clean, NULL, 16);
    } else {
        *data = 0;
    }
    
    return 1; // 解析成功
}

template<size_t N>
VlWide<N> create_vlwide(std::initializer_list<uint32_t> values) {

    uint32_t a[N];
    std::copy(values.begin(), values.end(), a);
    
    VlWide<N> data;
    std::copy(std::rbegin(a), std::rend(a), std::begin(data.m_storage));
    return data;
}

// 发送单个trace请求
void send_trace_request(int op_type, int size_type, uint64_t addr, uint64_t data) {
    // 设置请求基本信息
    top->u_channel_0_req_bus_valid = 1;
    top->u_channel_0_req_bus_op = op_type;
    top->u_channel_0_req_bus_size = size_type;
    top->u_channel_0_req_bus_addr = addr;
    
    // 设置写数据（对于store操作）
    if (op_type == STORE) {
        if (size_type == DOUBLE) {
            uint32_t high = (uint32_t)(data >> 32);
            uint32_t low = (uint32_t)(data & 0xFFFFFFFF);
            top->u_channel_0_req_bus_wdata = create_vlwide<4>({high, low, 0, 0});
        } else {
            top->u_channel_0_req_bus_wdata = create_vlwide<4>({(uint32_t)data, 0, 0, 0});
        }
    } else {
        // 对于load操作，写数据为0
        top->u_channel_0_req_bus_wdata = create_vlwide<4>({0, 0, 0, 0});
    }
    
    top->u_channel_0_rsp_bus_ready = 1;
}

// 复位请求信号
void reset_request_signals() {
    top->u_channel_0_req_bus_valid = 0;
    top->u_channel_0_req_bus_op = 0;
    top->u_channel_0_req_bus_size = 0;
    top->u_channel_0_req_bus_addr = 0;
}

// 主执行函数 - 逐行处理trace文件
void execute_trace(const char* trace_file) {

    FILE* file = fopen(trace_file, "r");
    if (!file) {
        printf("Error: Cannot open trace file %s\n", trace_file);
        return;
    }
    
    char line[256];
    int line_num = 0;
    
    printf("Starting trace execution: %s\n", trace_file);

    sim_delay(2);
    
    while (line_num < 10) {
        line_num++;
    
        fgets(line, sizeof(line), file);
    
        // 跳过空行和注释行
        if (strlen(line) <= 1 || line[0] == '#') {
            continue;
        }
        
        int op_type, size_type;
        uint64_t addr, data;
        
        if (parse_trace_line(line, &op_type, &size_type, &addr, &data)) {
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
            
            int request_sent = 0;
            while (!request_sent) {
                // 发送请求
                send_trace_request(op_type, size_type, addr, data);
                
                // 等待握手
                while (1) {
                    if (top->u_channel_0_req_bus_valid && top->u_channel_0_req_bus_ready) {
                        // 握手成功，延迟1拍
                        request_sent = 1;
                        sim_delay(2);
                        break;
                    } else {
                        // 未握手，延迟1拍后继续尝试
                        sim_delay(2);
                    }
                }
            }
            
            // 复位请求信号
            // 
            
        } else {
            printf("Warning: Failed to parse line %d: %s", line_num, line);
        }
    }
    reset_request_signals();
    sim_delay(200);

    fclose(file);
    printf("Trace execution completed. Processed %d lines.\n", line_num);
}