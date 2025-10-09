#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <common.h>
#include <config.h>

// Memory array - aligned for better performance
static uint8_t *memory = NULL;
static size_t memory_size = MEM_SIZE;


uint8_t* guest_to_host(uint32_t addr) { return memory + addr - MEM_BASE_ADDR; }


// Initialize memory
void init_memory() {
    if (memory == NULL) {
        memory = (uint8_t*)aligned_alloc(64, memory_size);
        if (memory == NULL) {
            fprintf(stderr, "Error: Failed to allocate memory\n");
            exit(1);
        }
    }
}

// Clean up memory
void free_memory() {
    if (memory != NULL) {
        free(memory);
        memory = NULL;
    }
}

// Debug function to dump memory region
void memory_dump(uint64_t addr, uint64_t size) {
    if (memory == NULL) {
        printf("Memory not initialized\n");
        return;
    }
    
    uint64_t offset = addr - MEM_BASE_ADDR;
    if (offset + size > memory_size) {
        printf("Error: Dump region out of bounds\n");
        return;
    }
    
    printf("Memory dump from 0x%lx (size: 0x%lx):\n", addr, size);
    for (uint64_t i = 0; i < size; i += 16) {
        printf("0x%08lx: ", addr + i);
        for (uint64_t j = 0; j < 16 && (i + j) < size; j++) {
            printf("%02x ", memory[offset + i + j]);
        }
        printf("\n");
    }
}

// DPI-C functions for Verilator
#ifdef __cplusplus
extern "C" {
#endif
// Read 256-bit data from memory
void read_memory(int address, svBitVecVal* data, svBit read_en, int cacheline_width) {
    
    if (!read_en) {
        return;
    }

    int DATA_WIDTH_WORDS = cacheline_width / 32;
    int DATA_WIDTH_BYTES = cacheline_width / 8;
    
    if (memory == NULL) {
        for (int i = 0; i < DATA_WIDTH_WORDS; i++) {
            data[i] = 0;
        }
        return;
    }
    
    int offset = address - MEM_BASE_ADDR;
    
    // Check address alignment and range
    if (offset % DATA_WIDTH_WORDS!= 0) {
        fprintf(stderr, "Warning: Unaligned read address 0x%x\n", address);
    }
    
    if (offset + DATA_WIDTH_BYTES > memory_size) {
        fprintf(stderr, "Error: Read address 0x%x out of range\n", address);
        for (int i = 0; i < DATA_WIDTH_WORDS; i++) {
            data[i] = 0;
        }
        return;
    }
    
    const uint32_t* src = reinterpret_cast<const uint32_t*>(memory + offset);
    for (int i = 0; i < DATA_WIDTH_WORDS; i++) {
        data[i] = src[i];
    }
}

// Write 256-bit data to memory
void write_memory(int address,  const svBitVecVal* data, svBit write_en, int cacheline_width) {
    if (!write_en) {
        return;
    }
    
    int DATA_WIDTH_WORDS = cacheline_width / 32;
    int DATA_WIDTH_BYTES = cacheline_width / 8;
    
    if (memory == NULL) return;
    
    int offset = address - MEM_BASE_ADDR;
    
    // Check address alignment and range
    if (offset % DATA_WIDTH_WORDS != 0) {
        fprintf(stderr, "Warning: Unaligned write address 0x%x\n", address);
    }
    
    if (offset + DATA_WIDTH_BYTES > memory_size) {
        fprintf(stderr, "Error: Write address 0x%x out of range\n", address);
        return;
    }
    
    uint32_t* dst = reinterpret_cast<uint32_t*>(memory + offset);
    for (int i = 0; i < DATA_WIDTH_WORDS; i++) {
        dst[i] = data[i];
    }
}

uint64_t memory_get_base_addr() {
    return MEM_BASE_ADDR;
}

// Get memory size
uint64_t memory_get_size() {
    return memory_size;
}

#ifdef __cplusplus
}
#endif