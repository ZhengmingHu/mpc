#ifndef __DEBUG_H__
#define __DEBUG_H__

#include <common.h>
#include <stdio.h>
#include <utils/utils.h>

#define Log(format, ...) \
    _Log(ANSI_FMT("[%s:%d %s] " format, ANSI_FG_BLUE) "\n", \
        __FILE__, __LINE__, __func__, ## __VA_ARGS__)

#define Assert(cond, format, ...) \
  do { \
    if (!(cond)) { \
      fflush(stdout), fprintf(stderr, ANSI_FMT(format, ANSI_FG_RED) "\n", ##  __VA_ARGS__); \
      assert(cond); \
    } \
  } while (0)

#define panic(format, ...) Assert(0, format, ## __VA_ARGS__)

#define TODO() panic("please implement me")

#define PASS    0

#define FAIL    1

#define DONE    2

int parse_trace_line(const char* line, int* req_type, int* op_type, int* size_type, uint64_t* addr, uint64_t* data);

void print_line(int line_num, int op_type, int size_type, uint64_t addr, uint64_t data);

int handle_rsp_data(FILE* ref_file, int* ref_line_num);
int handle_multiport_rsp_data(FILE* ch0, FILE* ch1, FILE *ch2, int* ref_num, bool req_end);

#ifdef CONFIG_CPU_MULTIPORT

void cache_line(FILE* ch0, FILE* ch1, FILE* ch2, const char* line, int op_type, uint64_t addr);

void test_read_cache_line(FILE* cache_file);

#endif


#endif
