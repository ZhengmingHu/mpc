#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <math.h>
#include <time.h>


#define MAX_LINE_LENGTH 256

typedef enum {
    LRU,
    PLRU_TREE,
    FIFO,
    RANDOM,
    RRIP,
    MRU
} ReplacementPolicy;

typedef struct {
    uint32_t tag;
    int valid;
    int dirty;
    unsigned long long timestamp;  
    int plru_bits;                
    int rrip_value;                
} CacheLine;

typedef struct {
    CacheLine *lines;
    unsigned long long access_counter; 
    int *fifo_counters;                
} CacheSet;

typedef struct {
    CacheSet *sets;
    int num_sets;
    int num_ways;
    int cacheline_size;
    ReplacementPolicy policy;
    unsigned long long global_counter;
    
    unsigned long long accesses;
    unsigned long long hits;
    unsigned long long misses;
} Cache;

Cache* create_cache(int num_sets, int num_ways, int cacheline_size, ReplacementPolicy policy);
void destroy_cache(Cache *cache);
void access_cache(Cache *cache, uint32_t addr);
int find_victim(Cache *cache, int set_index);
void update_replacement_bits(Cache *cache, int set_index, int way);
uint32_t get_tag(Cache *cache, uint32_t addr);
uint32_t get_set_index(Cache *cache, uint32_t addr);
uint32_t cacheline_align(Cache *cache, uint32_t addr);
void print_stats(Cache *cache);

Cache* create_cache(int num_sets, int num_ways, int cacheline_size, ReplacementPolicy policy) {
    Cache *cache = (Cache*)malloc(sizeof(Cache));
    cache->num_sets = num_sets;
    cache->num_ways = num_ways;
    cache->cacheline_size = cacheline_size;
    cache->policy = policy;
    cache->global_counter = 0;
    cache->accesses = 0;
    cache->hits = 0;
    cache->misses = 0;
    
    cache->sets = (CacheSet*)malloc(num_sets * sizeof(CacheSet));
    for (int i = 0; i < num_sets; i++) {
        cache->sets[i].lines = (CacheLine*)malloc(num_ways * sizeof(CacheLine));
        cache->sets[i].access_counter = 0;
        cache->sets[i].fifo_counters = (int*)malloc(num_ways * sizeof(int));
        
        for (int j = 0; j < num_ways; j++) {
            cache->sets[i].lines[j].valid = 0;
            cache->sets[i].lines[j].dirty = 0;
            cache->sets[i].lines[j].tag = 0;
            cache->sets[i].lines[j].timestamp = 0;
            cache->sets[i].lines[j].plru_bits = 0;
            cache->sets[i].lines[j].rrip_value = 0;
            cache->sets[i].fifo_counters[j] = 0;
        }
    }
    
    return cache;
}

void destroy_cache(Cache *cache) {
    for (int i = 0; i < cache->num_sets; i++) {
        free(cache->sets[i].lines);
        free(cache->sets[i].fifo_counters);
    }
    free(cache->sets);
    free(cache);
}

uint32_t get_tag(Cache *cache, uint32_t addr) {
    int offset_bits = __builtin_ctz(cache->cacheline_size);
    int index_bits = __builtin_ctz(cache->num_sets);
    return addr >> (offset_bits + index_bits);
}

uint32_t get_set_index(Cache *cache, uint32_t addr) {
    int offset_bits = __builtin_ctz(cache->cacheline_size);
    int index_bits = __builtin_ctz(cache->num_sets);
    uint32_t mask = (1 << index_bits) - 1;
    return (addr >> offset_bits) & mask;
}

uint32_t cacheline_align(Cache *cache, uint32_t addr) {
    return addr & ~(cache->cacheline_size - 1);
}

int lru_find_victim(Cache *cache, int set_index) {
    CacheSet *set = &cache->sets[set_index];
    int victim_way = 0;
    unsigned long long min_timestamp = set->lines[0].timestamp;
    
    for (int i = 1; i < cache->num_ways; i++) {
        if (!set->lines[i].valid) {
            return i; 
        }
        if (set->lines[i].timestamp < min_timestamp) {
            min_timestamp = set->lines[i].timestamp;
            victim_way = i;
        }
    }
    return victim_way;
}

int plru_find_victim(Cache *cache, int set_index) {
    CacheSet *set = &cache->sets[set_index];
    int way = 0;
    int node = 0;
    
    for (int level = 0; level < __builtin_ctz(cache->num_ways); level++) {
        if (set->lines[0].plru_bits & (1 << node)) {
            way |= (1 << level);
            node = node * 2 + 2;  
        } else {
            node = node * 2 + 1;  
        }
    }
    
    if (!set->lines[way].valid) {
        return way;
    }
    
    return way;
}


int rrip_find_victim(Cache *cache, int set_index) {
    CacheSet *set = &cache->sets[set_index];
    

    for (int i = 0; i < cache->num_ways; i++) {
        if (!set->lines[i].valid) {
            return i;
        }
    }
    
    while (1) {

        for (int i = 0; i < cache->num_ways; i++) {
            if (set->lines[i].rrip_value == 3) {

                for (int j = 0; j < cache->num_ways; j++) {
                    if (j != i && set->lines[j].rrip_value < 3) {
                        set->lines[j].rrip_value++;
                    }
                }
                return i;
            }
        }
        
        for (int i = 0; i < cache->num_ways; i++) {
            if (set->lines[i].rrip_value < 3) {
                set->lines[i].rrip_value++;
            }
        }
    }
    
    return 0; 
}

int fifo_find_victim(Cache *cache, int set_index) {
    CacheSet *set = &cache->sets[set_index];
    int victim_way = 0;
    int min_counter = set->fifo_counters[0];
    
    for (int i = 1; i < cache->num_ways; i++) {
        if (!set->lines[i].valid) {
            return i;
        }
        if (set->fifo_counters[i] < min_counter) {
            min_counter = set->fifo_counters[i];
            victim_way = i;
        }
    }
    return victim_way;
}

int random_find_victim(Cache *cache, int set_index) {
    CacheSet *set = &cache->sets[set_index];

    for (int i = 0; i < cache->num_ways; i++) {
        if (!set->lines[i].valid) {
            return i;
        }
    }

    return rand() % cache->num_ways;
}

int find_victim(Cache *cache, int set_index) {
    switch (cache->policy) {
        case LRU:
            return lru_find_victim(cache, set_index);
        case PLRU_TREE:
            return plru_find_victim(cache, set_index);
        case FIFO:
            return fifo_find_victim(cache, set_index);
        case RANDOM:
            return random_find_victim(cache, set_index);
        case RRIP:
            return rrip_find_victim(cache, set_index);
        case MRU:
            return rrip_find_victim(cache, set_index);
        default:
            return 0;
    }
}

void update_replacement_bits(Cache *cache, int set_index, int accessed_way) {
    CacheSet *set = &cache->sets[set_index];
    
    switch (cache->policy) {
        case LRU:
            set->lines[accessed_way].timestamp = cache->global_counter;
            break;
            
        case PLRU_TREE:

            {
                int way = accessed_way;
                int node = 0;
                int levels = __builtin_ctz(cache->num_ways);
                
                for (int level = 0; level < levels; level++) {
                    int direction = (way >> (levels - level - 1)) & 1;
                    if (direction == 0) {

                        set->lines[0].plru_bits |= (1 << node);
                        node = node * 2 + 1;
                    } else {
                        set->lines[0].plru_bits &= ~(1 << node);
                        node = node * 2 + 2;
                    }
                }
            }
            break;
        case RRIP:
                set->lines[accessed_way].rrip_value = 0;
            break;
        case MRU:
            {   
                if (set->lines[accessed_way].rrip_value > 0){
                    set->lines[accessed_way].rrip_value -= 1;
                }
            }
            break;
        case FIFO:

            break;

        case RANDOM:

            break;
    }
}

void access_cache(Cache *cache, uint32_t addr) {
    cache->accesses++;
    cache->global_counter++;
    
    uint32_t aligned_addr = cacheline_align(cache, addr);
    uint32_t tag = get_tag(cache, aligned_addr);
    uint32_t set_index = get_set_index(cache, aligned_addr);
    
    CacheSet *set = &cache->sets[set_index];
    
    int hit = 0;
    int hit_way = -1;
    
    for (int i = 0; i < cache->num_ways; i++) {
        if (set->lines[i].valid && set->lines[i].tag == tag) {
            hit = 1;
            hit_way = i;
            break;
        }
    }
    
    if (hit) {
        cache->hits++;

        if (cache->policy != FIFO) {
            update_replacement_bits(cache, set_index, hit_way);
        }
    } else {
        cache->misses++;

        int victim_way = find_victim(cache, set_index);
        
        set->lines[victim_way].valid = 1;
        set->lines[victim_way].tag = tag;
        
        if (cache->policy == LRU) {
            set->lines[victim_way].timestamp = cache->global_counter;
        } else if (cache->policy == FIFO) {
            set->fifo_counters[victim_way] = cache->global_counter;
        } else if (cache->policy == PLRU_TREE) {
            update_replacement_bits(cache, set_index, victim_way);
        } else if (cache->policy == RRIP) {
            set->lines[victim_way].rrip_value = 2;
        } else if (cache->policy == MRU) {
            set->lines[victim_way].rrip_value = 3;
        }
    }
}

void print_stats(Cache *cache) {
    printf("Cache Configuration:\n");
    printf("  Sets: %d\n", cache->num_sets);
    printf("  Ways: %d\n", cache->num_ways);
    printf("  Cacheline Size: %d bytes\n", cache->cacheline_size);
    printf("  Replacement Policy: ");
    switch (cache->policy) {
        case LRU: printf("LRU\n"); break;
        case PLRU_TREE: printf("PLRU-Tree\n"); break;
        case FIFO: printf("FIFO\n"); break;
        case RANDOM: printf("RANDOM\n"); break;
        case RRIP: printf("RRIP\n"); break;
        case MRU: printf("MRU\n"); break;
    }

    printf("\nStatistics:\n");
    printf("  Total Accesses: %llu\n", cache->accesses);
    printf("  Hits: %llu\n", cache->hits);
    printf("  Misses: %llu\n", cache->misses);
    printf("  Hit Rate: %.2f%%\n", (double)cache->hits / cache->accesses * 100);
    printf("  Miss Rate: %.2f%%\n", (double)cache->misses / cache->accesses * 100);

    printf("MPKI_DATA: %llu %llu\n", cache->accesses, cache->misses);
}

void simulate_trace(Cache *cache, const char *trace_file) {
    FILE *file = fopen(trace_file, "r");
    if (!file) {
        printf("Error: Cannot open trace file %s\n", trace_file);
        return;
    }
    
    char line[MAX_LINE_LENGTH];
    char token1[32], token2[32], token3[32], token4[32];
    uint32_t addr;
    
    while (fgets(line, sizeof(line), file)) {

        int tokens = sscanf(line, "%31s %31s %31s %31s", token1, token2, token3, token4);
        
        if (tokens >= 3) {

            if (sscanf(token3, "0x%x", &addr) == 1) {
                access_cache(cache, addr);
            }
        }
    }
    
    fclose(file);
}

int main(int argc, char *argv[]) {
    if (argc != 6) {
        printf("Usage: %s <ways> <sets> <cacheline_size> <policy> <trace_file>\n", argv[0]);
        printf("  policy: lru, plru, fifo, random, rrip, mru\n");
        printf("Example: %s 4 256 64 random trace.txt\n", argv[0]);
        return 1;
    }

    srand(time(NULL));
    
    int ways = atoi(argv[1]);
    int sets = atoi(argv[2]);
    int cacheline_size = atoi(argv[3]);
    char *policy_str = argv[4];
    char *trace_file = argv[5];
    
    if ((sets & (sets - 1)) != 0) {
        printf("Error: Number of sets must be a power of 2\n");
        return 1;
    }
    if ((cacheline_size & (cacheline_size - 1)) != 0) {
        printf("Error: Cacheline size must be a power of 2\n");
        return 1;
    }
    if ((ways & (ways - 1)) != 0 && strcmp(policy_str, "plru") == 0) {
        printf("Error: Number of ways must be a power of 2 for PLRU-tree\n");
        return 1;
    }
    
    ReplacementPolicy policy;
    if (strcmp(policy_str, "lru") == 0) {
        policy = LRU;
    } else if (strcmp(policy_str, "plru") == 0) {
        policy = PLRU_TREE;
    } else if (strcmp(policy_str, "fifo") == 0) {
        policy = FIFO;
    } else if (strcmp(policy_str, "random") == 0) {
        policy = RANDOM;
    } else if (strcmp(policy_str, "rrip") == 0) {
        policy = RRIP;
    } else if (strcmp(policy_str, "mru") == 0) {
        policy = MRU;
    } else {
        printf("Error: Unknown policy %s. Use lru, plru, fifo, random, rrip or mru\n", policy_str);
        return 1;
    }

    Cache *cache = create_cache(sets, ways, cacheline_size, policy);
    simulate_trace(cache, trace_file);
    print_stats(cache);
    destroy_cache(cache);
    
    return 0;
}