.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 32
# - If the stride of either vector is less than 1,
#   this function terminates the program with error code 33
# =======================================================
# Variables:
# t0: Current index, used in loop condition and in updating t3
# t1: (in prologue) Stores 1. Used to check array length
# t1: (in loop) Stores the dot product.
# t2: vector 1 current element
# t3: vector 2 current element
# t4: current product
# =================================================================
dot:
    # Prologue
    # CHeck if length / stride <= 0
    ble a2, zero, length_too_short
    ble a3, zero, stride_too_short
    ble a4, zero, stride_too_short
    # initialize current index to 0
    li t0, 0
    # initialize sum to 0
    li t1, 0
    # change strides to make them easier to work with
    slli a3, a3, 2
    slli a4, a4, 2
    
loop_start:
	# if current index >= length, quit
	bge t0, a2, loop_end
    # load in current elements
	lw t2, 0(a0)
	lw t3, 0(a1)
    # find product and update sum
	mul t4, t2, t3
	add t1, t1, t4
    # move pointers
    add a0, a0, a3
    add a1, a1, a4
    # increment current index
    addi t0, t0, 1
	j loop_start

loop_end:
    # Epilogue
	mv a0, t1
    ret

# Exit with exit code 32 if array length is less than 1
length_too_short:
	li a1, 32
    j exit2

# Exit with exit code 33 if array stride is less than 1
stride_too_short:
	li a1, 33
    j exit2