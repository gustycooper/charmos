#include <stdlib.h>
#define READ 1
#define WRITE 2
#define MAX_MEM (64*1024)


struct memorydump {
    unsigned int data[32];  
};

int system_bus(int address, int *value, int control);
int system_bus_b(int address, unsigned char *value, int control);
int dump_memory(int start_address, int num_bytes);
int dump_memory_word(int start_address, int num_bytes);
void load_memory(char *filename);
struct memorydump dump_raw();
