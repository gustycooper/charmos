#include chaos_api.h

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
mva r0, fmt
mva r1, gusty_str
mov r2, 222
blr printf         // printf practice
.label loop_gusty
ldr r2, [sp, 8]    // put i in r2, initialized to 1 above
cmp r2, 0
beq end_gusty
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
.label loop_lauren
ldr r2, [sp, 8]    // put i in r2, initialized to 1 above
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
mva r0, fmt
mva r1, matt_str
mov r2, 333
blr printf
.label loop_matt
ldr r2, [sp, 8]    // i to r2
cmp r2, 0
beq end_matt
add r2, r2, 1
str r2, [sp, 8]    // i++
bal loop_matt
.label end_matt
ldr lr, [sp, 4]
sub sp, sp, 32
mov r15, r14

.stack 0x0e00

