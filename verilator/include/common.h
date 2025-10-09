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

#define PG_ALIGN __attribute((aligned(4096)))
#define ARRLEN(arr) (int)(sizeof(arr) / sizeof(arr[0]))

#endif