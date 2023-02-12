// processes gusty, lauren, and matt do the following
// char name_str[] = "gusty";
// int main() {
//   char name[8];
//   strcpy(name, name_str);
//   int i = 1;
//   while (i) {
//       i++;
//   }
// }
// stack
// 00 gust
// 04 y000
// 08 i's value
// 0c lr's value

// proc gusty uses OS API to printf, malloc, yield, sleep
// proc lauren uses OS API to printf, wake (gusty)
// proc matt uses OS API to printf
// proc forkproc uses PC relative branches, which allows it to be forked
// - fork is still to be implemented

// Define OS API adresses
.text 0xa000
.label printf
.text 0xa004
.label scanf
.text 0xa008
.label yield
.text 0xa00c
.label strcpy
.text 0xa010
.label sleep
.text 0xa014
.label wake
.text 0xa018
.label fork
.text 0xa01c
.label exec
.text 0xa020
.label malloc
.text 0xa024
.label free

.data 0x0200
.label gusty_str
.string //gusty
.label fmt
.string //%s: %d
.label scanfmt
.string //%d
.label xvar
0
// put hex for loadme.o because Linux puts space after .o
.label loadme
0x6c6f6164
0x6d652e6f
0x00000000
//.string //loadme.o
.label par
.string //par
.label chd
.string //chd
.text 0x0300
.label gusty
sub sp, sp, 32
str lr, [sp, 12]
mov r2, 1
str r2, [sp, 8]    // i = 1
mva r1, gusty_str
mov r0, sp
blr strcpy         // cpy "gusty" onto stack
ldr r2, [sp, 8]    // i to r2
mva r1, fmt
mva r2, gusty_str
mov r3, 777
ker 0x11           // printf via ker 0x11
mva r0, fmt
mva r1, gusty_str
mov r2, 222
blr printf         // printf practice
mva r1, fmt
mva r2, gusty_str
mov r3, 888
ker 0x11           // another printf via ker 0x11
//mva r0, scanfmt  // uncomment to read int into xvar
//mva r1, xvar
//blr scanf
                   // loadme.o puts numbers at address 0x100
mva r0, loadme
blr exec           // exec loads a .o - does not start a proc
.label after_exec
mov r0, 4
blr malloc         // call malloc to get 4 bytes from heap
mov r2, r0         // put addr returned from malloc in r2
mva r0, fmt
mva r1, gusty_str
blr printf         // printf gusty: addr_ret_from_malloc
mov r0, 0x55       // sleep on channel 0x55
blr sleep
.label before_yield
blr yield          // yield the cpu - no tmr rupt needed
ldr r2, [sp, 8]    // put i in r2, initialized to 1 above
.label loop_gusty
cmp r2, 0
beq end_gusty
//blr yield
add r2, r2, 1
str r2, [sp, 8]    // i++
bal loop_gusty
.label end_gusty
ldr lr, [sp, 4]
sub sp, sp, 32
mov r15, r14

.data 0x0400
.label lauren_str
.string //lauren
.text 0x0500
.label lauren
sub sp, sp, 32
str lr, [sp, 12]
mov r2, 1
str r2, [sp, 8]    // i = 1
mva r1, lauren_str
mov r0, sp
blr strcpy         // cpy "lauren" onto stack
ldr r2, [sp, 8]    // i to r2
mva r0, fmt
mva r1, lauren_str
mov r2, 333
blr printf
mov r0, 0x55
blr wake           // wakeup the sleeping gusty
ldr r2, [sp, 8]    // put i in r2, initialized to 1 above
.label loop_lauren
cmp r2, 0
beq end_lauren
add r2, r2, 1
str r2, [sp, 8]    // i++
bal loop_lauren
.label end_lauren
ldr lr, [sp, 4]
sub sp, sp, 32
mov r15, r14

.data 0x0600
.label matt_str
.string //matt
.text 0x0700
.label matt
sub sp, sp, 32
str lr, [sp, 12]
mov r2, 1
str r2, [sp, 8]    // i = 1
mva r1, matt_str
mov r0, sp
blr strcpy         // cpy "matt" onto stack
ldr r2, [sp, 8]    // i to r2
.label loop_matt
cmp r2, 0
beq end_matt
add r2, r2, 1
str r2, [sp, 8]    // i++
bal loop_matt
.label end_matt
ldr lr, [sp, 4]
sub sp, sp, 32
mov r15, r14

// The next proc uses pc relative jumps
// This proc can be forked and still run
.text 0x900
.label forkproc
sub sp, sp, 32
str lr, [sp, 12]

mov r0, 0x6672     // "fr" to r0
shf r0, 16
orr r0, r0, 0x6b70 // "frkp" to r0
str r0, [sp, 0]
mov r0, 0x726f     // "ro" to r0
shf r0, 16
orr r0, r0, 0x6300 // "roc\0" to r0
str r0, [sp, 4]    // "frkproc\0" at address top of stack
mov r0, 0x7061     // pa to r0
shf r0, 16
orr r0, r0, 0x7200 // par to r0
str r0, [sp, 8]    // par to sp+8
mov r0, 0x6368     // ch to r0
shf r0, 16
orr r0, r0, 0x6400 // chd to r0
str r0, [sp, 12]   // chd to sp+12
mov r2, 1
str r2, [sp, 16]    // i = 1
mov r0, sp
blr printf
blr fork
.label afterfork
cmp r0, 0
bne parent
mov r0, sp
add r0, r0, 12
blr printf
bal childdone
.label parent
mov r0, sp
add r0, r0, 8
blr printf
.label childdone
ldr r2, [sp, 16]    // i to r2
.label loop_forkproc
cmp r2, 0
beq !end_forkproc
add r2, r2, 1
str r2, [sp, 16]    // i++
bal !loop_forkproc
.label end_forkproc
ldr lr, [sp, 4]
sub sp, sp, 32
mov r15, r14

.stack 0x0e00

