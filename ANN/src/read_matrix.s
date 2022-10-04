.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
# - If malloc returns an error,
#   this function terminates the program with error code 48
# - If you receive an fopen error or eof, 
#   this function terminates the program with error code 64
# - If you receive an fread error or eof,
#   this function terminates the program with error code 66
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 65
# ==============================================================================
# Variables:
# s1-2: address to store # of rows, columns
# s0: file descriptor for a0's file
# s10: pointer to malloc'd memory (to be used to return the matrix read)
# ==============================================================================
read_matrix:
    # Prologue
    # Store arguments in s registers
	addi sp, sp, -20
	sw s0, 0(sp)
	sw s1, 4(sp)
    sw s2, 8(sp)
    sw s10, 12(sp)
    sw ra, 16(sp)
    mv s1, a1
    mv s2, a2
    
    # Prepare arguments for open file
	mv a1, a0 # Provide string
    li a2, 0 # Read only
    # Open file
    jal ra, fopen
    # load -1 and compare with a0 to check for error
    li t0, -1
    beq a0, t0, fopen_error
    # Store file descriptor
	mv s0, a0
    
	# Load # rows
	mv a1, s0
    mv a2, s1
    li a3, 4
    jal ra, fread
    # Check for error
    li t0, 4
    bne a0, t0, fread_error 
    
    # Load # columns
    mv a1, s0
    mv a2, s2
    li a3, 4
    jal ra, fread
    # Check for error
    li t0, 4
    bne a0, t0, fread_error
    
    # Loaded in the two numbers, don't need the addresses anymore. Just store the numbers.
    lw s1, 0(s1)
    lw s2, 0(s2)
    
    # Prepare arguments for malloc: calculate amount of memory required
	mul a0, s1, s2
    slli a0, a0, 2
    # Call malloc
    jal ra, malloc
    # Check for malloc failure
    beq a0, zero, malloc_error
    # Store pointer to malloc'd memory
    mv s10, a0
    
    # Read 4*r*c bytes into the return address
    # Prepare arguments for read
    mv a1, s0 # File descriptor
    mv a2, s10 # write pointer
    mul a3, s1, s2 # Number of elements to read
    slli a3, a3, 2 # Convert to bytes
    jal ra, fread
    # Set up t0 to compare with a0 to see if all bytes are read
    mul t0, s1, s2
    slli t0, t0, 2
    # Check for error
    bne a0, t0, fread_error
    
    # Close file
    mv a1, s0
    jal ra, fclose
    # Check for error
    bne a0, zero, fclose_error
    
    # Epilogue
    mv a0, s10 # Stores address of matrix for return
	lw s0, 0(sp)
	lw s1, 4(sp)
    lw s2, 8(sp)
    lw s10, 12(sp)
    lw ra, 16(sp)
	addi sp, sp, 20
    ret

malloc_error:
	li a1, 48
    j exit2

fopen_error:
	li a1, 64
    j exit2
    
fread_error:
	li a1, 66
    j exit2
    
fclose_error:
	li a1, 65
    j exit2