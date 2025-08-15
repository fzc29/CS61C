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
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:

# Prologue
    addi sp sp -24
    sw ra 0(sp)
    sw s0 4(sp) # pointer to filename string
    sw s1 8(sp) # pointer to start of matrix in memory 
    sw s2 12(sp) # num rows of matrix
    sw s3 16(sp) # num cols of matrix 
    sw s4 20(sp) # file descriptor 
    
    mv s0 a0 # pointer to filename string
    mv s1 a1 # pointer to start of matrix in memory 
    mv s2 a2 # num rows of matrix
    mv s3 a3 # num cols of matrix 
    
    
file_open:
    # a0 = pointer to filename string
    mv a0 s0
    # a1 = permission bits (1 for write) 
    li a1 1
    jal ra fopen
    
    # check file open error
    li t0 -1
    beq a0 t0 error_fopen
    
    # save file descriptor 
    mv s4 a0 
    
file_write_row:
    # a0 = file descriptor to read from
    mv a0 s4
    # a1 = pointer to buffer for what we want written to file 
        # must use pointer > stack memory 
    addi sp sp -4
    # saving num rows to input (reverse of read_matrix) 
    sw s2 0(sp)
    mv a1 sp
    # a2 = number of elems to write 
    li a2 1
    # a3 = size of each elem
    li a3 4
    
    jal ra fwrite 
    
    # check file write error (should match a2)
    li t0 1 
    bne a0 t0 error_fwrite
    
    # clear space, no longer used
    lw t0 0(sp)
    addi sp sp 4
   

file_write_col:
    # a0 = file descriptor to read from
    mv a0 s4
    # a1 = pointer to buffer for what we want written to file 
    # same as earlier, make space on stack
    addi sp sp -4
    sw s3 0(sp)
    mv a1 sp
    # a2 = number of elems to write 
    li a2 1
    # a3 = size of each elem
    li a3 4
    
    jal ra fwrite 
    
    # check file write error (should match a2)
    li t0 1 
    bne a0 t0 error_fwrite
    
    # clear space, no longer used 
    lw t0 0(sp)
    addi sp sp 4

    
file_write_rest_matrix_data:
    # a0 = file descriptor to read from
    mv a0 s4
    # a1 = pointer to place we want to write to (alr given)
    mv a1 s1 
    # a2 = number of elem
    mul t0 s2 s3
    mv a2 t0
    # a3 = number of byte per elem
    li a3 4
    
    jal ra fwrite 
    
    # check file read error 
    mul t0 s2 s3
    bne a0 t0 error_fwrite

file_close:
    # a0 = file descriptor to close 
    mv a0 s4
    
    jal ra fclose 
    
    # check file close error (-1 on failure)
    li t0 -1
    beq a0 t0 error_fclose
    

return:
    # no return value
    
    # Epilogue
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    lw s4 20(sp) 
    
    addi sp sp 24

    jr ra


error_fopen:
    li a0 27
    j exit 
    
error_fclose:
    li a0 28
    j exit 
    
error_fwrite:
    li a0 30
    j exit 


