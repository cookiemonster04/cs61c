addi t0, x0, 1
addi t1, x0, 2
slt s0, t0, t1
slt s0, t1, t0
addi t1, x0, 1
slt s0, t0, t1
slt s0, t1, t0
addi t0, x0, -1
addi t1, x0, 3
slt s0, t0, t1
slt s0, t1, t0
addi t1, x0, -1
slt s0, t0, t1
slt s0, t1, t0