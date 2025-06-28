#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include "svdpi.h"

#define MEMORY_SIZE 131072
#define DATA_WIDTH 8  // 255 bits needs 8 x 32-bit words (256 bits total)

typedef struct {
    svBitVecVal words[DATA_WIDTH];
} memory_data_t;

static memory_data_t memory[MEMORY_SIZE];

void write_slice_0_memory(const int address, const svBitVecVal* data, const svBit write_en) {
    if (!write_en) {
        // printf("Write operation disabled for address %d\n", address);
        return;
    }
    if (address < 0 || address >= MEMORY_SIZE) {
        printf("Error: Memory address %d out of range (0-%d)\n", address, MEMORY_SIZE-1);
        return;
    }
    
    // Only perform write if enable is high
    if (write_en) {
        for (int i = 0; i < DATA_WIDTH; i++) {
            memory[address].words[i] = data[i];
        }
        // printf("Write to address %d completed\n", address);
    }
}

void write_slice_1_memory(const int address, const svBitVecVal* data, const svBit write_en) {
    if (!write_en) {
        // printf("Write operation disabled for address %d\n", address);
        return;
    }
    if (address < 0 || address >= MEMORY_SIZE) {
        printf("Error: Memory address %d out of range (0-%d)\n", address, MEMORY_SIZE-1);
        return;
    }
    
    // Only perform write if enable is high
    if (write_en) {
        for (int i = 0; i < DATA_WIDTH; i++) {
            memory[address].words[i] = data[i];
        }
        // printf("Write to address %d completed\n", address);
    }
}

void write_slice_2_memory(const int address, const svBitVecVal* data, const svBit write_en) {
    if (!write_en) {
        // printf("Write operation disabled for address %d\n", address);
        return;
    }
    if (address < 0 || address >= MEMORY_SIZE) {
        printf("Error: Memory address %d out of range (0-%d)\n", address, MEMORY_SIZE-1);
        return;
    }
    
    // Only perform write if enable is high
    if (write_en) {
        for (int i = 0; i < DATA_WIDTH; i++) {
            memory[address].words[i] = data[i];
        }
        // printf("Write to address %d completed\n", address);
    }
}

void write_slice_3_memory(const int address, const svBitVecVal* data, const svBit write_en) {
    if (!write_en) {
        // printf("Write operation disabled for address %d\n", address);
        return;
    }
    if (address < 0 || address >= MEMORY_SIZE) {
        printf("Error: Memory address %d out of range (0-%d)\n", address, MEMORY_SIZE-1);
        return;
    }
    
    // Only perform write if enable is high
    if (write_en) {
        for (int i = 0; i < DATA_WIDTH; i++) {
            memory[address].words[i] = data[i];
        }
        // printf("Write to address %d completed\n", address);
    }
}

void read_slice_0_memory(const int address, svBitVecVal* data, const svBit read_en) {
    if (!read_en) {
        // printf("Read operation disabled for address %d\n", address);
        return;
    }

    if (address < 0 || address >= MEMORY_SIZE) {
        printf("Error: Memory address %d out of range (0-%d)\n", address, MEMORY_SIZE-1);
        memset(data, 0, DATA_WIDTH * sizeof(svBitVecVal));
        return;
    }
    
    // Only perform read if enable is high
    if (read_en) {
        for (int i = 0; i < DATA_WIDTH; i++) {
            data[i] = memory[address].words[i];
        }
        // printf("Read from address %d completed\n", address);
    }
}

void read_slice_1_memory(const int address, svBitVecVal* data, const svBit read_en) {
    if (!read_en) {
        // printf("Read operation disabled for address %d\n", address);
        return;
    }

    if (address < 0 || address >= MEMORY_SIZE) {
        printf("Error: Memory address %d out of range (0-%d)\n", address, MEMORY_SIZE-1);
        memset(data, 0, DATA_WIDTH * sizeof(svBitVecVal));
        return;
    }
    
    // Only perform read if enable is high
    if (read_en) {
        for (int i = 0; i < DATA_WIDTH; i++) {
            data[i] = memory[address].words[i];
        }
        // printf("Read from address %d completed\n", address);
    }
}

void read_slice_2_memory(const int address, svBitVecVal* data, const svBit read_en) {
    if (!read_en) {
        // printf("Read operation disabled for address %d\n", address);
        return;
    }

    if (address < 0 || address >= MEMORY_SIZE) {
        printf("Error: Memory address %d out of range (0-%d)\n", address, MEMORY_SIZE-1);
        memset(data, 0, DATA_WIDTH * sizeof(svBitVecVal));
        return;
    }
    
    // Only perform read if enable is high
    if (read_en) {
        for (int i = 0; i < DATA_WIDTH; i++) {
            data[i] = memory[address].words[i];
        }
        // printf("Read from address %d completed\n", address);
    }
}

void read_slice_3_memory(const int address, svBitVecVal* data, const svBit read_en) {
    if (!read_en) {
        // printf("Read operation disabled for address %d\n", address);
        return;
    }

    if (address < 0 || address >= MEMORY_SIZE) {
        printf("Error: Memory address %d out of range (0-%d)\n", address, MEMORY_SIZE-1);
        memset(data, 0, DATA_WIDTH * sizeof(svBitVecVal));
        return;
    }
    
    // Only perform read if enable is high
    if (read_en) {
        for (int i = 0; i < DATA_WIDTH; i++) {
            data[i] = memory[address].words[i];
        }
        // printf("Read from address %d completed\n", address);
    }
}