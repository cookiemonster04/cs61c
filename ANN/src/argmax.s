.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 32
# =================================================================
# Variables:
# t0: Current index, used in loop condition and in updating t3
# t1: (in prologue) Stores 1. Used to check array length
# t1: (in loop) Stores the current element.
# t2: Stores the current max value
# t3: Stores pointer to max element
# =================================================================
argmax:
    # Prologue
    # initialize current index to 0
    li t0, 0
    # Load 1 into t1 for comparison to check if array length is less than 1
    li t1, 1
    bge a1, t1, init
    # Exit with exit code 32 if array length is less than 1
    li a1, 32
    j exit2

init:
	# initializes maximum value to 0th element and maximum index to 0
    lw t2, 0(a0)
    li t3, 0
    # Increase t0 by 1 and move a1 by one element since 0th element already accounted for
    addi t0, t0, 1
    addi a0, a0, 4

loop_start:
	# If current index = # of elements in the vector, exit loop
	beq t0, a1, loop_end
    # t1 = current element
    lw t1, 0(a0)
    # If t2 >= t1, do nothing
    bge t2, t1, loop_continue
    # Set the current max element to t1
    mv t2, t1
    # Set the current max index to t0 
	mv t3, t0

loop_continue:
	# increase index by 1
	addi t0, t0, 1
    # Move pointer to next element
    addi a0, a0, 4
	j loop_start

loop_end:
    # Epilogue
    # Load return value
    mv a0, t3
	ret
