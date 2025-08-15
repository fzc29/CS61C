.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:

    # Error checks
    li t0 1
    
    blt a1 t0 error_38
    blt a2 t0 error_38
    blt a4 t0 error_38
    blt a5 t0 error_38
    
    bne a2 a4 error_38

    # Prologue
    
    addi sp sp -40
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    sw s3 16(sp)
    sw s4 20(sp) 
    sw s5 24(sp)
    sw s6 28(sp)
    sw s7 32(sp)
    sw s8 36(sp)
    
    mv s0 a0 # pointer to start of m0
    mv s1 a1 # row of m0 (height)
    mv s2 a2 # col of m0 (width)
    mv s3 a3 # pointer to start of m1
    mv s4 a4 # row of m1 (height)
    mv s5 a5 # col of m1 (width)
    mv s6 a6 # pointer to result matrix 
    
    # resulting matrix should be row of m0 by col of m1: s1 X s5
    
    # counter for outer loop (reach row of m0)  
    li s7 0 
    # t1 temp register for array 1
    mv t1 s0
    
outer_loop_start:
    # loop through rows of m0 
    beq s7 s1 outer_loop_end
    
    # t2 temp register for array 2 (reset each outerloop iteration)
    mv t2 s3
    
    # counter for inner loop (reach col of m1)
    li s8 0
inner_loop_start:
    # loop through col of m1
    beq s8 s5 inner_loop_end
    
    # save relevant registers 
    addi sp sp -8
    sw t1 0(sp)
    sw t2 4(sp)
    
    # dot product here 
    # a0 = pointer to start of first array
    mv a0 t1
    # a1 = pointer to start of second array
    mv a1 t2
    # a2 = number of elements 
    mv a2 s2
    # a3 = stride of first array
    li a3 1
    # a4 = stride of second array 
    mv a4 s5
    jal ra dot 
   
    # restore registers
    lw t1 0(sp)
    lw t2 4(sp)
    addi sp sp 8
    
    # add result to resulting matrix 
    # a0 = result 
    mul t3 s7 s5
    add t3 t3 s8
    slli t3 t3 2
    add t4 s6 t3
    sw a0 0(t4)
    
    # loop back inner
    addi s8 s8 1
    slli t3 s8 2
    add t2 s3 t3
    j inner_loop_start


inner_loop_end:
    addi s7 s7 1
    
    # how much to increment t1 by 
    mul t3 s7 s2
    slli t3 t3 2
    add t1 s0 t3

    # call outer loop 
    j outer_loop_start


outer_loop_end:

    mv a6 s6 
    
    # Epilogue
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
    
    addi sp sp 40
    
    jr ra


error_38:
    li a0 38
    j exit

