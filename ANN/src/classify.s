.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # Exceptions:
    # - If there are an incorrect number of command line args,
    #   this function terminates the program with exit code 35
    # - If malloc fails, this function terminates the program with exit code 48
    #
    # Usage:
    #   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
    
	# =======================================================
    # VARIABLES:
    # s0: m0 path (replaced with memory address after)
    # s1: m0 rows and classification (at the end)
    # s2: m0 columns
    # s3: m1 path (^)
    # s4: m1 rows
    # s5: m1 columns
    # s6: input path (^)
    # s7: input rows
    # s8: input columns
    # s9: output path
    # s10: result matrix 1
    # s11: final result matrix
	# =======================================================
	# Check correct argument count
	li t0, 5 # there's 4 arguments but apparently argc is 5? idk
    bne a0, t0, cnt_error

	# Load in m0, m1, input, output, print or no print
	addi sp, sp, -56
    sw ra, 0(sp)
    sw a2, 4(sp)
    sw s0, 8(sp)
    sw s1, 12(sp)
    sw s2, 16(sp)
    sw s3, 20(sp)
    sw s4, 24(sp)
    sw s5, 28(sp)
    sw s6, 32(sp)
    sw s7, 36(sp)
    sw s8, 40(sp)
    sw s9, 44(sp)
    sw s10, 48(sp)
    sw s11, 52(sp)
    
	lw s0, 4(a1) # index 1
    lw s3, 8(a1) # index 2
    lw s6, 12(a1)# index 3
    lw s9, 16(a1)# index 4
    
    
	# =====================================
    # LOAD MATRICES
    # =====================================
    
    # Load pretrained m0
	# Load arguments
	mv a0, s0
	addi sp, sp, -4
    mv a1, sp
	addi sp, sp, -4
	mv a2, sp
    jal ra, read_matrix
    mv s0, a0 # Replace m0 file path with m0 memory address
    lw s2, 0(sp) # load columns
    addi sp, sp, 4
    lw s1, 0(sp) # load rows
    addi sp, sp, 4
    
    # Load pretrained m1
	# Load arguments
	mv a0, s3
	addi sp, sp, -4
    mv a1, sp
	addi sp, sp, -4
	mv a2, sp
    jal ra, read_matrix
    mv s3, a0 # Replace m0 file path with m0 memory address
    lw s5, 0(sp) # load columns
    addi sp, sp, 4
    lw s4, 0(sp) # load rows
    addi sp, sp, 4
    
    # Load input matrix
	# Load arguments
	mv a0, s6
	addi sp, sp, -4
    mv a1, sp
	addi sp, sp, -4
	mv a2, sp
    jal ra, read_matrix
    mv s6, a0 # Replace m0 file path with m0 memory address
    lw s8, 0(sp) # load columns
    addi sp, sp, 4
    lw s7, 0(sp) # load rows
    addi sp, sp, 4

    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)
	
    # Layer 1 ============================
    # malloc result matrix
    mul a0, s1, s8 # allocate m0 rows * input columns * 4 bytes
    slli a0, a0, 2
    jal ra, malloc
    beq a0, zero, malloc_error # Check for error
    mv s10, a0
    
	mv a0, s0
    mv a1, s1
    mv a2, s2
    mv a3, s6
	mv a4, s7
    mv a5, s8
    mv a6, s10
    jal ra, matmul
    
	# Layer 2 ============================
	mv a0, s10
	mul a1, s1, s8
	jal ra, relu

	# Layer 3 ============================
	mul a0, s4, s8 # allocate m1 rows * input columns * 4 bytes
    slli a0, a0, 2
    jal ra, malloc
    beq a0, zero, malloc_error # Check for error
    mv s11, a0
    
	mv a0, s3
    mv a1, s4
    mv a2, s5
    mv a3, s10
	mv a4, s1
    mv a5, s8
    mv a6, s11
    jal ra, matmul

    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix
	mv a0, s9
	mv a1, s11
	mv a2, s4
	mv a3, s8
	jal ra, write_matrix
    
    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax
	mv a0, s11
    mul a1, s4, s8
	jal ra, argmax
    mv s1, a0 # store ret in s1 because s1 doesn't matter anymore anyway
    
    # Free stuff =====================================
    mv a0, s0
    jal ra, free
    mv a0, s3
    jal ra, free
    mv a0, s6
    jal ra, free
    mv a0, s10
    jal ra, free
    mv a0, s11
    jal ra, free
    # ================================================
    
    # if don't print, go to finish
    lw a2, 4(sp)
	bne a2, zero, finish
    # Print classification
    ebreak
	mv a1, s1
    jal ra, print_int
    # Print newline afterwards for clarity
	li a1, '\n'
    jal ra, print_char

finish:
	mv a0, s0
    lw ra, 0(sp)
    lw s0, 8(sp)
    lw s1, 12(sp)
    lw s2, 16(sp)
    lw s3, 20(sp)
    lw s4, 24(sp)
    lw s5, 28(sp)
    lw s6, 32(sp)
    lw s7, 36(sp)
    lw s8, 40(sp)
    lw s9, 44(sp)
    lw s10, 48(sp)
    lw s11, 52(sp)
    addi sp, sp, 56
    ret

cnt_error:
	li a1, 35
    j exit2

malloc_error:
	li a1, 48
    j exit2