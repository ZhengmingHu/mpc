#ifndef __PADDR_H__
#define __PADDR_H__

#include <common.h>


uint8_t* guest_to_host(uint32_t paddr);

void free_memory();

void init_memory();

void memory_dump(uint64_t addr, uint64_t size); 

#endif