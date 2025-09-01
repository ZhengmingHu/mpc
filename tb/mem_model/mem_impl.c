#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include "svdpi.h"

#define MEMORY_SIZE 262144

static svBitVecVal memory[MEMORY_SIZE];

void write_slice_0_memory(const int address, const svBitVecVal* data, 
                         const svBit write_en, const int cacheline_width) {
    if (!write_en) {
        return;
    }
    
    if (address < 0 || address >= MEMORY_SIZE) {
        printf("Error: Memory address %d out of range (0-%d)\n", address, MEMORY_SIZE-1);
        return;
    }

    int words_per_line = cacheline_width / 32;

    if (cacheline_width % 32 != 0) {
        printf("Error: cacheline_width (%d) must be a multiple of 32\n", cacheline_width);
        return;
    }
    
    if (address + words_per_line > MEMORY_SIZE) {
        printf("Error: Writing cacheline would exceed memory bounds (address %d, length %d)\n", 
               address, words_per_line);
        return;
    }
    
    if (write_en) {
        for (int i = 0; i < words_per_line; i++) {
            memory[address + i] = data[i];
        }
        // printf("Write to address %d (length %d) completed\n", address, words_per_line);
    }
}

void write_slice_1_memory(const int address, const svBitVecVal* data, 
                         const svBit write_en, const int cacheline_width) {
    if (!write_en) {
        return;
    }
    
    if (address < 0 || address >= MEMORY_SIZE) {
        printf("Error: Memory address %d out of range (0-%d)\n", address, MEMORY_SIZE-1);
        return;
    }

    int words_per_line = cacheline_width / 32;

    if (cacheline_width % 32 != 0) {
        printf("Error: cacheline_width (%d) must be a multiple of 32\n", cacheline_width);
        return;
    }
    
    if (address + words_per_line > MEMORY_SIZE) {
        printf("Error: Writing cacheline would exceed memory bounds (address %d, length %d)\n", 
               address, words_per_line);
        return;
    }
    
    if (write_en) {
        for (int i = 0; i < words_per_line; i++) {
            memory[address + i] = data[i];
        }
        // printf("Write to address %d (length %d) completed\n", address, words_per_line);
    }
}

void write_slice_2_memory(const int address, const svBitVecVal* data, 
                         const svBit write_en, const int cacheline_width) {
    if (!write_en) {
        return;
    }
    
    if (address < 0 || address >= MEMORY_SIZE) {
        printf("Error: Memory address %d out of range (0-%d)\n", address, MEMORY_SIZE-1);
        return;
    }

    int words_per_line = cacheline_width / 32;

    if (cacheline_width % 32 != 0) {
        printf("Error: cacheline_width (%d) must be a multiple of 32\n", cacheline_width);
        return;
    }
    
    if (address + words_per_line > MEMORY_SIZE) {
        printf("Error: Writing cacheline would exceed memory bounds (address %d, length %d)\n", 
               address, words_per_line);
        return;
    }
    
    if (write_en) {
        for (int i = 0; i < words_per_line; i++) {
            memory[address + i] = data[i];
        }
        // printf("Write to address %d (length %d) completed\n", address, words_per_line);
    }
}

void write_slice_3_memory(const int address, const svBitVecVal* data, 
                         const svBit write_en, const int cacheline_width) {
    if (!write_en) {
        return;
    }
    
    if (address < 0 || address >= MEMORY_SIZE) {
        printf("Error: Memory address %d out of range (0-%d)\n", address, MEMORY_SIZE-1);
        return;
    }

    int words_per_line = cacheline_width / 32;

    if (cacheline_width % 32 != 0) {
        printf("Error: cacheline_width (%d) must be a multiple of 32\n", cacheline_width);
        return;
    }
    
    if (address + words_per_line > MEMORY_SIZE) {
        printf("Error: Writing cacheline would exceed memory bounds (address %d, length %d)\n", 
               address, words_per_line);
        return;
    }
    
    if (write_en) {
        for (int i = 0; i < words_per_line; i++) {
            memory[address + i] = data[i];
        }
        // printf("Write to address %d (length %d) completed\n", address, words_per_line);
    }
}

void read_slice_0_memory(const int address, svBitVecVal* data, 
                        const svBit read_en, const int cacheline_width) {
    if (!read_en) {
        return;
    }

    if (address < 0 || address >= MEMORY_SIZE) {
        printf("Error: Memory address %d out of range (0-%d)\n", address, MEMORY_SIZE-1);
        memset(data, 0, cacheline_width / 8);  // 清零整个cacheline（byte长度）
        return;
    }

    int words_per_line = cacheline_width / 32;
    
    if (cacheline_width % 32 != 0) {
        printf("Error: cacheline_width (%d) must be a multiple of 32\n", cacheline_width);
        memset(data, 0, cacheline_width / 8);
        return;
    }
    
    if (address + words_per_line > MEMORY_SIZE) {
        printf("Error: Reading cacheline would exceed memory bounds (address %d, length %d)\n", 
               address, words_per_line);
        memset(data, 0, cacheline_width / 8);
        return;
    }
    
    if (read_en) {
        for (int i = 0; i < words_per_line; i++) {
            data[i] = memory[address + i];
        }

    }
}

void read_slice_1_memory(const int address, svBitVecVal* data, 
                        const svBit read_en, const int cacheline_width) {
    if (!read_en) {
        return;
    }

    // 检查address是否对齐且有效
    if (address < 0 || address >= MEMORY_SIZE) {
        printf("Error: Memory address %d out of range (0-%d)\n", address, MEMORY_SIZE-1);
        memset(data, 0, cacheline_width / 8);  // 清零整个cacheline（byte长度）
        return;
    }
    
    // 计算cacheline包含多少个32bit字
    int words_per_line = cacheline_width / 32;
    
    // 检查cacheline_width是否是32的倍数
    if (cacheline_width % 32 != 0) {
        printf("Error: cacheline_width (%d) must be a multiple of 32\n", cacheline_width);
        memset(data, 0, cacheline_width / 8);
        return;
    }
    
    // 检查读取不会越界
    if (address + words_per_line > MEMORY_SIZE) {
        printf("Error: Reading cacheline would exceed memory bounds (address %d, length %d)\n", 
               address, words_per_line);
        memset(data, 0, cacheline_width / 8);
        return;
    }
    
    // 执行读取操作
    if (read_en) {
        for (int i = 0; i < words_per_line; i++) {
            data[i] = memory[address + i];
        }
        // printf("Read from address %d (length %d) completed\n", address, words_per_line);
    }
}

void read_slice_2_memory(const int address, svBitVecVal* data, 
                        const svBit read_en, const int cacheline_width) {
    if (!read_en) {
        return;
    }

    // 检查address是否对齐且有效
    if (address < 0 || address >= MEMORY_SIZE) {
        printf("Error: Memory address %d out of range (0-%d)\n", address, MEMORY_SIZE-1);
        memset(data, 0, cacheline_width / 8);  // 清零整个cacheline（byte长度）
        return;
    }
    
    // 计算cacheline包含多少个32bit字
    int words_per_line = cacheline_width / 32;
    
    // 检查cacheline_width是否是32的倍数
    if (cacheline_width % 32 != 0) {
        printf("Error: cacheline_width (%d) must be a multiple of 32\n", cacheline_width);
        memset(data, 0, cacheline_width / 8);
        return;
    }
    
    // 检查读取不会越界
    if (address + words_per_line > MEMORY_SIZE) {
        printf("Error: Reading cacheline would exceed memory bounds (address %d, length %d)\n", 
               address, words_per_line);
        memset(data, 0, cacheline_width / 8);
        return;
    }
    
    // 执行读取操作
    if (read_en) {
        for (int i = 0; i < words_per_line; i++) {
            data[i] = memory[address + i];
        }
        // printf("Read from address %d (length %d) completed\n", address, words_per_line);
    }
}

void read_slice_3_memory(const int address, svBitVecVal* data, 
                        const svBit read_en, const int cacheline_width) {
    if (!read_en) {
        return;
    }

    // 检查address是否对齐且有效
    if (address < 0 || address >= MEMORY_SIZE) {
        printf("Error: Memory address %d out of range (0-%d)\n", address, MEMORY_SIZE-1);
        memset(data, 0, cacheline_width / 8);  // 清零整个cacheline（byte长度）
        return;
    }
    
    // 计算cacheline包含多少个32bit字
    int words_per_line = cacheline_width / 32;
    
    // 检查cacheline_width是否是32的倍数
    if (cacheline_width % 32 != 0) {
        printf("Error: cacheline_width (%d) must be a multiple of 32\n", cacheline_width);
        memset(data, 0, cacheline_width / 8);
        return;
    }
    
    // 检查读取不会越界
    if (address + words_per_line > MEMORY_SIZE) {
        printf("Error: Reading cacheline would exceed memory bounds (address %d, length %d)\n", 
               address, words_per_line);
        memset(data, 0, cacheline_width / 8);
        return;
    }
    
    // 执行读取操作
    if (read_en) {
        for (int i = 0; i < words_per_line; i++) {
            data[i] = memory[address + i];
        }
        // printf("Read from address %d (length %d) completed\n", address, words_per_line);
    }
}