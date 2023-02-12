
// Define CPSR bit positions
#define N 31
#define Z 30
#define C 29
#define V 28
#define U 27  // set is user mode
#define K 26  // set is kernel mode via ker
#define I 25  // set is interrupt mode via timer
#define OS 1  // set is OS loaded
// Define registers
#define SR 13
#define LR 14
#define PC 15
#define R0 0
#define R1 1
#define R2 2
#define R3 3
#define R4 4
#define R5 5
#define R6 6
#define R7 7
#define R8 8
#define R9 9
#define R10 10
#define R11 11
#define R12 12
#define R13 13
#define R14 14
#define R15 15
// Define kernel registers
#define CPSR 0
#define KPSR 1
#define KR13 2
#define KR14 3
#define IPSR 4
#define IR13 5
#define IR14 6

// Define steps when to stop potential infinite loop
#define LOOP_STOP 500

enum stepret {
    ILLEGALINST = -1,
    NORMAL = 0,
    BREAKPOINT = 1,
    BALTOSELF = 2,
    SCANF = 3,
    MEMERROR = 4,
    LOOPSTOP = 5
};

enum rupttype {KERNEL, EXTERNRUPT};

void set_reg(int reg, int value);
int get_reg(int reg);
void set_kreg(int reg, int value);
int get_kreg(int reg);
void set_cpsr(int bit);
int get_cpsr();
void set_rupt(int value);
int get_rupt();
void show_regs();
int step();
int step_n(int n);
void step_show_reg();
void step_show_reg_mem();
void reset_pipeline();
void pipeline();
void show_mem_changed();
void chemuscanf(char *str);
int interrupt(enum rupttype rt);
