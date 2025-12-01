// Cache configuration

#define SET_NUM             64
#define LINE_SIZE           32
#define MSHR_SIZE           32


// Memory configuration

#define MEM_SIZE            0x4000000     // 64MB
#define MEM_BASE_ADDR       0x80000000    // Base Address
#define RESET_VECTOR        0x80000000

// Emulator configuration

// #define CONFIG_WAVETRACE
// #define CONFIG_WAVETRACE_PTL
#define DUMP_WAVE_POINT     14400000
// #define CONFIG_DEBUG
// #define CONFIG_CPU_NPU
#define CONFIG_DIFFTEST
#define CONFIG_CPU_MULTIPORT
#define MAX_RETRY           10000