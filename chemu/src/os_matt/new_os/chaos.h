#define PROC_SIZE 64
#define KSTACK_SIZE 256
#define USTACK_SIZE 256
#define TF_USP 0
#define TF_R0 4
#define TF_R1 8
#define TF_R2 12
#define TF_R3 16
#define TF_LR 60
#define TF_TYPE 64
#define TF_CPSR 68
#define TF_SPSR 72
#define TF_PC 76
#define TF_SIZE 80
#define CONTEXT_SIZE 64
#define PROC_PID 0
#define PROC_STATE 4
#define PROC_STARTADDR 8
#define PROC_SZ 12
#define PROC_USTACK 16
#define PROC_KSTACK 20
#define PROC_CONTEXT 24
#define PROC_NAME 48
#define PROC_TF 28
#define PROC_CHAN 36
#define CONTEXT_LR 56
#define CONTEXT_PC 60
#define RUNNING 3
#define READY 2
#define ASLEEP 4
#define LOAD_MALLOC 1

#define push[X] str X, [sp, -4]!
#define pop[X]  ldr X, [sp], 4
