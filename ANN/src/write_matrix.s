.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
# - If you receive an fopen error or eof,
#   this function terminates the program with error code 64
# - If you receive an fwrite error or eof,
#   this function terminates the program with error code 67
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 65
# ==============================================================================
# Variables:
# s1-2: address to store # of rows, columns
# s0: file descriptor for a0's file
# s10: pointer to matrix in memory
# ==============================================================================
write_matrix:

    # Prologue
	addi sp, sp, -20
	sw s0, 0(sp)
	sw s1, 4(sp)
    sw s2, 8(sp)
    sw s10, 12(sp)
    sw ra, 16(sp)
    mv s1, a2
    mv s2, a3
	mv s10, a1

	# Prepare arguments for open file
	mv a1, a0 # Provide string
    li a2, 1 # Read only
    # Open file
    jal ra, fopen
    # load -1 and compare with a0 to check for error
    li t0, -1
    beq a0, t0, fopen_error
    # Store file descriptor
	mv s0, a0

	# Write # of rows
    addi sp, sp, -4 # Create new buffer
    sw s1, 0(sp) # Load # of rows into buffer
    
	# Prepare arguments for write
	mv a1, s0 # File descriptor
	mv a2, sp # Buffer address
    li a3, 1 # 1 element
    li a4, 4
    jal ra, fwrite
    # Check for error
    li t0, 1
    bne a0, t0, fwrite_error
    
    # Write # of columns
    sw s2, 0(sp) # Load # of columns into buffer
    
    # Prepare arguments for write
	mv a1, s0 # File descriptor
	mv a2, sp # Buffer address
    li a3, 1 # 1 element
    li a4, 4
    jal ra, fwrite
    # Check for error
    li t0, 1
    bne a0, t0, fwrite_error

	# Release buffer
    addi sp, sp, 4
    
	# Prepare arguments for write
	mv a1, s0 # File descriptor
	mv a2, s10 # Buffer address
    mul a3, s1, s2
    li a4, 4
    jal ra, fwrite
    # Check for error
    mul t0, s1, s2
    bne a0, t0, fwrite_error
    
    # Close file
    mv a1, s0
    jal ra, fclose
    # Check for error
    bne a0, zero, fclose_error
    
    # Epilogue
	lw s0, 0(sp)
	lw s1, 4(sp)
    lw s2, 8(sp)
    lw s10, 12(sp)
    lw ra, 16(sp)
	addi sp, sp, 20
    ret

fopen_error:
	li a1, 64
    j exit2
    
fwrite_error:
	li a1, 67
    j exit2
    
fclose_error:
	li a1, 65
    j exit2