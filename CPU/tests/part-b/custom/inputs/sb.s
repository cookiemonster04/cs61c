addi t0, x0, 0xDE
addi sp, x0, 0x3E8
addi sp, sp, 4
sb t0, 0(sp)
addi t0, x0, 0xAD
sb t0, 1(sp)
addi t0, x0, 0xBE
sb t0, 2(sp)
addi t0, x0, 0xEF
sb t0, 3(sp)
lw s0, 0(sp)
addi t1, x0, 0xAB
sb t1, 0(sp)
addi t1, x0, 0xCD
sb t1, 1(sp)
addi t1, x0, 0xDC
sb t1, 2(sp)
addi t1, x0, 0xBA
sb t1, 3(sp)
lw t0, 0(sp)

addi t0, x0, 0xDE
addi sp, x0, 0x3E8
addi sp, sp, -4
sb t0, -4(sp)
addi t0, x0, 0xAD
sb t0, -3(sp)
addi t0, x0, 0xBE
sb t0, -2(sp)
addi t0, x0, 0xEF
sb t0, -1(sp)
lw s0, -4(sp)
addi t1, x0, 0xAB
sb t1, -4(sp)
addi t1, x0, 0xCD
sb t1, -3(sp)
addi t1, x0, 0xDC
sb t1, -2(sp)
addi t1, x0, 0xBA
sb t1, -1(sp)
lw t0, -4(sp)