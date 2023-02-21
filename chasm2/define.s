#define A[B] mov r0, B
#define psh[X] str X, [sp, -4]!
mov r0, 10
A[10]
str r0, [sp, 04]!
psh[r0]
