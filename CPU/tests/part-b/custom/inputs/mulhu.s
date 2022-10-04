addi t0, x0, -1
addi t1, x0, -1
mulhu t2, t0, t1
addi t1, x0, -1
mulhu t2, t0, t1
lui t0, 0x80000
addi t0, t0, -1
mulhu t2, t0, t1
lui t1, 0x80000
addi t1, t1, -1
mulhu t2, t0, t1
addi t0, x0, 42
addi t1, x0, 37
mulhu t2, t0, t1
addi t1, x0, 0
mulhu t2, t0, t1