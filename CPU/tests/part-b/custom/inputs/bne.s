addi t0, x0, 37
addi t1, x0, -1
bne t0, t1, bottom

jump_down:
addi t0, x0, -1
addi t1, x0, -2
bne t0, t1, end
addi t0, t0, 1
bne t0, t1, end

jump_up:
addi t0, t0, -4
add t1, x0, t0
bne t0, t1, jump_down

bottom:
addi t0, t0, -1
bne t0, t1, jump_down
bne t1, t0, jump_up

end:
addi t0, x0, 42