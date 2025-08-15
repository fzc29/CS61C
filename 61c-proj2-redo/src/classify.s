.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:

    # error checks 
    # 5 arguments to the program
    li t0 5 
    bne a0 t0 error_incorrect_arg
    
    # Prologue
    addi sp sp -52
    sw ra 0(sp)
    sw s0 4(sp) # argc   
    sw s1 8(sp) # argv and pointer to all the file paths 
    sw s2 12(sp) # silent mode 
    
    sw s3 16(sp) # pointer to m0 file path 
    sw s4 20(sp) # pointer to m1 file path 
    sw s5 24(sp) # pointer to input file path
    
    # combine pointer together 
    sw s6 28(sp) # m0 row + m0 col 
    sw s7 32(sp) # m1 row + m1 col
    sw s8 36(sp) # input row + input col
    
    # create space to save newly allocated matrixes 
    sw s9 40(sp) # pointer to h
    sw s10 44(sp) # pointer to o
    sw s11 48(sp) # final answer 
    
    # saving parameters 
    mv s0 a0 # argc
    mv s1 a1 # where all the file paths are
    mv s2 a2 # if print or not 
   
read_m0: # Read pretrained m0
    
    # allocate memory for row and col (use malloc)
    # m0 row + col (s6) 
    li a0 8
    jal malloc 
    
    # check error
    li t0 0
    beq a0 t0 error_malloc
    
    mv s6 a0 
    
    # a0 = pointer to filename string 
    # get from s1 
    lw a0 4(s1)
    # a1 = pointer to int for m0 row
    mv a1 s6
    # a2 = pointer to int for m0 col 
    addi a2 s6 4 
    
    jal read_matrix
    
    # save actual matrix of m0 
    mv s3 a0
    # should auto save row and col into s6 
    # 0(s6) = row; 4(s7) = col 

read_m1: # Read pretrained m1
    
    # allocate memory for row and col (use malloc) 
    # m1 row+col (s7)
    li a0 8
    jal ra malloc 
    
    # check error
    li t0 0
    beq a0 t0 error_malloc
    
    mv s7 a0

    # a0 = pointer to filename string 
    # get from s1 
    lw a0 8(s1)
    # a1 = pointer to int for row
    mv a1 s7
    # a2 = pointer to int for col
    addi a2 s7 4    
    
    jal read_matrix
    
    # save actual matrix of m1 
    mv s4 a0


read_input: # Read input matrix
    
    # allocate memory for row and col 
    # input row+col (s8) 
    li a0 8
    jal malloc 
    # check error
    li t0 0
    beq a0 t0 error_malloc
    mv s8 a0
    
    # a0 = pointer to filename string 
    # get from s1 
    lw a0 12(s1)
    # a1 = pointer to int for row
    mv a1 s8 
    # a2 = pointer to int for col
    addi a2 s8 4
    
    jal read_matrix
    
    # save actual matrix of input 
    mv s5 a0

compute_h: # Compute h = matmul(m0, input)

    # first malloc space for h 
    # a0 = size of memory needed (compute here)
    # (m0 row X m0 col) x (input row X input col) = (m0 row X input col)
    lw t1 0(s6)
    lw t2 4(s8)
    # t0 = total elements in h 
    mul t0 t1 t2
    # t0 = total bytes (multiply by 4)
    slli t0 t0 2
    mv a0 t0
    jal malloc
    # check error
    li t0 0
    beq a0 t0 error_malloc
        
    mv s9 a0   
    # a0 currently pointer to space for h 
    
    # transfer to a6
    mv a6 s9
    # a0 = pointer to start of first matrix (m0)
    mv a0 s3
    # a1 = row of m0
    lw a1 0(s6)
    # a2 = col of m0
    lw a2 4(s6)
    # a3 = pointer to start of second matrix (input)
    mv a3 s5
    # a4 = row of input
    lw a4 0(s8)
    # a5 = col input 
    lw a5 4(s8)
    
    jal matmul
    

relu_h: # Compute h = relu(h)
    # in-place transformation
    # a0 = pointer to start of int array to transform
    mv a0 s9
    # a1 = length of array (num elems)
    # row of m0 X col of input
    lw t1 0(s6) 
    lw t2 4(s8)
    mul t0 t1 t2
    mv a1 t0
    
    jal relu


compute_o: # Compute o = matmul(m1, h)
    # first malloc space for o
    # a0 = size of memory needed (compute here)
    # (m1 row X m1 col) x (h row X h col)
    # (m1 row X m1 col) x (m0 row X input col)
    # (m1 row x input col) 
    
    # t0 = total elements in o
    lw t1 0(s7)
    lw t2 4(s8)
    mul t0 t1 t2
    # t0 = total bytes 
    slli t0 t0 2
    mv a0 t0
    jal malloc
    # check error
    li t0 0
    beq a0 t0 error_malloc
        
    # a0 currently pointer to space for o
    mv s10 a0
    
    # transfer to a6
    mv a6 s10
    # a0 = pointer to start of first matrix (m1)
    mv a0 s4
    # a1 = row of m1
    lw a1 0(s7)
    # a2 = col of m1
    lw a2 4(s7)
    # a3 = pointer to start of second matrix (h)
    mv a3 s9
    # a4 = row of h = row of m0
    lw a4 0(s6)
    # a5 = col of h = col of input 
    lw a5 4(s8)
    
    jal matmul
    

write_o: # Write output matrix o

    # a0 = pointer to filename string
    lw a0 16(s1)
    # a1 = pointer to matrix o 
    mv a1 s10
    # a2 = num rows of o (m1 row)
    lw a2 0(s7)
    # a3 = num cols of o (input col)
    lw a3 4(s8)
    
    jal write_matrix 
    # no return 
    
    lw t0 0(s10)
    lw t1 8(s10)
    
compute_argmax: # Compute and return argmax(o)
    
    # a0 = pointer to start of o
    mv a0 s10
    # a1 = number of elements (length)
    lw t1 0(s7)
    lw t2 4(s8)
    mul a1 t1 t2
    jal argmax 
    
    # a0 = return = index of largest element
    add s11 a0 x0
#     mv t0 a0
#     addi sp sp -4
#     sw t0 0(sp)
    lw t0 0(s10)
    lw t1 8(s10)
    
    # If enabled, print argmax(o) and newline
    # if a2 = s2 = 0 print classification 
    # if a2 = 1; dont print > skip to free 
    li t1 1
    beq s2 t1 free_labels
    
    # print int 
    # a0 = integer to print 
    # currently a0 = index; t0 = array o
    # slli t3 a0 2
    # add t4 s3 t3
    # store final argmax answer to where m1 was 
    # lw s4 0(t4)
    # lw a0 0(t4)
    mv a0 s11
    jal print_int
    
    # print char
    # a0 = print new line 
    li a0 '\n'
    jal print_char

    

free_labels:
    # free all matrix read allocations
    mv a0 s3
    jal free
    
    mv a0 s4
    jal free
    
    mv a0 s5
    jal free
    
    # free m0 row and col
    mv a0 s6
    jal free
    # free m1 row and col
    mv a0 s7
    jal free
    # free input row and col
    mv a0 s8
    jal free
    
    # free h 
    mv a0 s9
    jal free
    
    # free o
    mv a0 s10
    jal free
      
    mv a0 s11
    
    # epilogue
    lw ra 0(sp)
    lw s0 4(sp) 
    lw s1 8(sp)
    lw s2 12(sp) 
    lw s3 16(sp) 
    lw s4 20(sp) 
    lw s5 24(sp) 
    lw s6 28(sp) 
    lw s7 32(sp) 
    lw s8 36(sp) 
    lw s9 40(sp) 
    lw s10 44(sp) 
    lw s11 48(sp) 
    addi sp sp 52
    jr ra


error_incorrect_arg:
    li a0 31
    j exit
    
error_malloc:
    li a0 26
    j exit