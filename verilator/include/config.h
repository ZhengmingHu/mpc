#define CONFIG_WAVETRACE

// Memory configuration

#define MEM_SIZE            0x4000000     // 64MB
#define MEM_BASE_ADDR       0x80000000    // Base Address
#define RESET_VECTOR        0x80000000

// Emulator configuration

//#define CONFIG_DEBUG

#define CONFIG_DIFFTEST

#define MAX_RETRY           20