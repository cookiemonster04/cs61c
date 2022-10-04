.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 34
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 34
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 34
# =======================================================
# Variables:
# s0-5: store function input a0-5
# s6: stores ra
# s7: m0 row
# s8: m1 column
# s9: write pointer (pointing to position inside result matrix)
# =======================================================
matmul:

    # Error checks
    # Check m0 dimensions
	ble a1, zero, dimension_error
	ble a2, zero, dimension_error
    # Check m1 dimensions
    ble a4, zero, dimension_error
    ble a5, zero, dimension_error
    # Check m0 columns = m1 rows 
    bne a2, a4, dimension_error
    # Prologue
    # Store saved registers' stuff in stack
    addi sp, sp, -40
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw s8, 32(sp)
    sw s9, 36(sp)
    # Copying function inputs
    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3
    mv s4, a4
    mv s5, a5
    mv s6, ra
    # initialize m0 current row to 0
	li s7, 0
    # s8 (m1 current column) will be initialized later
    mv s9, a6

outer_loop_start:
	bge s7, s1, outer_loop_end
    # Set inner loop current index (m1 current column) to 0
    li s8, 0
    # don't need to store ra because stored in prologue
	jal ra, inner_loop_start
    # Increase current index by 1
    addi s7, s7, 1
	j outer_loop_start

inner_loop_start:
	bge s8, s5, inner_loop_end
    # Prepare for function call
    # Finds first element in row to be multiplied in m0 and puts it in a0
    mul t0, s7, s2
    # Multiply by 4 for int size
    slli t0, t0, 2
    add a0, s0, t0
    # Finds column to be multiplied in m1, multiply by 4 for int size
    slli t0, s8, 2
    add a1, s3, t0
    mv a2, s2
    # m0 stride = 1
    li a3, 1
    # m1 stride = # of columns
    mv a4, s5
    # Save current ra
	addi sp, sp, -4
    sw ra, 0(sp)
    # Function call
    jal ra, dot
    # Restore ra
    lw ra, 0(sp)
    addi sp, sp, 4
    # Store result
    sw a0, 0(s9)
    # increment write pointer
    addi s9, s9, 4
    # Increase current index by 1
    addi s8, s8, 1
	j inner_loop_start

inner_loop_end:
	ret

outer_loop_end:
    # Epilogue
    # Load in return address
    mv ra, s6
    # Load stuff back in
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw s8, 32(sp)
    lw s9, 36(sp)
    addi sp, sp, 40
    ret

dimension_error:
	li a1, 34
    j exit2