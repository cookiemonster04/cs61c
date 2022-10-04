addi t0, x0, 37
addi t1, x0, 37
beq t0, t1, bottom

jump_down:
addi t0, t0, -3
beq t0, t0, end

jump_up:
addi t0, t0, -3
add t1, x0, t0
beq t0, t1, jump_down

bottom:
addi t0, t0, -1
beq t0, t1, jump_down
beq t0, t1, jump_up

end:
addi t0, x0, 42