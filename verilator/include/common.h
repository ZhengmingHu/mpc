#ifndef __COMMON_H__
#define __COMMON_H__

#include <stdlib.h>
#include <iostream>
#include <string.h>
#include <cstdlib>
#include <vector>
#include <math.h>
#include <config.h>
#include "Vmpc_wrapper__Dpi.h"
#include "svdpi.h"
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vmpc_wrapper___024root.h"
#include "Vmpc_wrapper.h"
#include <stdio.h>
#include <stdint.h>

#define PG_ALIGN __attribute((aligned(4096)))
#define ARRLEN(arr) (int)(sizeof(arr) / sizeof(arr[0]))

inline int count_bits_builtin(uint64_t value) {
    return __builtin_popcountll(value);
}

inline int max(int a, int b, int c, int d) {
    int max_val = a;
    if (b > max_val) max_val = b;
    if (c > max_val) max_val = c;
    if (d > max_val) max_val = d;
    return max_val;
}

#endif