addi t1, x0, -1
addi t2, x0, 1
sub t0, x0, t1
sub t0, t1, t2
lui t1, 0xCFCFD # 0xCFCFCFCF
addi t1, t1, -49
lui t2, 0x7ABCB # 0x7ABCABCD
addi t2, t2, -1075
sub t0, t1, t2
