.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 32
# ==============================================================================
# Variables:
# t0: # of elements remaining, used in loop condition
# t1: (in prologue) Stores 1. Used to check array length
# t1: (in loop) Stores the current element.
# =================================================================
relu:
    # Prologue
    # Store arguments in stack
	addi sp, sp, -4
    sw a0, 0(sp)
    # Store a1 in t0 in preparation for loop
    add t0, a1, zero
    # Load 1 into t1 for comparison to check if array length is less than 1
    li t1, 1
    bge a1, t1, loop_start
    # Exit with exit code 32 if array length is less than 1
    li a1, 32
    j exit2

loop_start:
	# If remaining # of elements is 0, exit loop
	beq t0, zero, loop_end
    # t1 = current element
    lw t1, 0(a0)
    # If t1 >= 0, do nothing
    bge t1, zero, loop_continue
    # Set the current element to 0
	sw zero, 0(a0)

loop_continue:
	# decrease # of remaining elements by 1
	addi t0, t0, -1
    # Move pointer to next element
    addi a0, a0, 4
	j loop_start


loop_end:
    # Epilogue
    # Load argument back in
	lw a0, 0(sp)
    addi sp, sp, 4
	ret
