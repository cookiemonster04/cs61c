lui t0, 0xDEADC
addi t0, t0, -273
addi sp, x0, 0x3E8
addi sp, sp, 4
sw t0, 0(sp)
lw s0, 0(sp)
lui t1, 0xABCDE
addi t1, t1, -838
sw t0, 0(sp)
lw t0, 0(sp)

lui t0, 0xDEADC
addi t0, t0, -273
addi sp, x0, 0x3E8
addi sp, sp, -4
sw t0, -4(sp)
lw s0, -4(sp)
lui t1, 0xABCDE
addi t1, t1, -838
sw t0, -4(sp)
lw t0, -4(sp)