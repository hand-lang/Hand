.data

LD1:
.asciz "%d"
LD2:
.asciz "%s"
LD3:
.asciz "apa"
.text
_print:
push {fp, lr}
add fp, sp, #4
add sp, sp, #-12
ldr r0, =LD1
ldr r3, [fp, #4]
str r3, [fp, #-8]
ldr r1, [fp, #-8]
bl printf
add sp, fp, #-4
pop  {fp, lr}
bx lr

_pring:
push {fp, lr}
add fp, sp, #4
add sp, sp, #-12
ldr r0, =LD2
ldr r3, [fp, #4]
str r3, [fp, #-8]
ldr r1, [fp, #-8]
bl printf
add sp, fp, #-4
pop  {fp, lr}
bx lr

_ess:
push {fp, lr}
add fp, sp, #4
add sp, sp, #-20
ldr r3, [fp, #4]

str r3, [fp, #-8]
ldr r3, [fp, #4]
str r3, [fp, #-12]
mov r3, #3
ldr r4, [fp, #-12]
mul r3, r4, r3

str r3, [fp, #-12]
mov r3, #1

str r3, [fp, #-12]
add sp, fp, #-4
pop  {fp, lr}
bx lr

__initial:
push {fp, lr}
add fp, sp, #4
add sp, sp, #-36
ldr r3, =LD3

str r3, [fp, #-8]
str sp, [fp, #-12]
ldr r3, [fp, #-12]

str r3, [fp, #-16]
add sp, fp, #-16
bl _pring
ldr sp, [fp, #-12]
str r0, [fp, #-12]
mov r3, #2

str r3, [fp, #-12]
mov r3, #1
str r3, [fp, #-20]
mov r3, #1
ldr r4, [fp, #-20]
add r3, r4, r3

str r3, [fp, #-16]
ldr r3, LD4

str r3, [fp, #-20]
ldr r3, [fp, #-16]
str r3, [fp, #-28]
ldr r3, [fp, #-24]
str r3, [fp, #-32]
mov r3, #45
mov r4, r3
ldr r3, [fp, #-24]
udiv r3, r4, r3
ldr r4, [fp, #-32]
mul r3, r4, r3
ldr r4, [fp, #-28]
add r3, r4, r3
str r3, [fp, #-28]
mov r3, #22
str r3, [fp, #-32]
mov r3, #8
ldr r4, [fp, #-32]
mul r3, r4, r3
ldr r4, [fp, #-28]
add r3, r4, r3
str r3, [fp, #-28]
mov r3, #10
ldr r4, [fp, #-28]
mul r3, r4, r3

str r3, [fp, #-24]
str sp, [fp, #-32]
ldr r3, [fp, #-28]

str r3, [fp, #-36]
add sp, fp, #-36
bl _print
ldr sp, [fp, #-32]
str r0, [fp, #-32]
add sp, fp, #-4
pop  {fp, lr}
bx lr
LD4:
.word 200000
.global main
main:
push {fp, lr}
add fp, sp, #4
add sp, sp, #-12
str sp, [fp, #-8]

add sp, fp, #-8
bl __initial
ldr sp, [fp, #-8]
str r0, [fp, #-8]
add sp, fp, #-4
pop  {fp, lr}
bx lr
