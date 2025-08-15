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
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:

    # Prologue
    addi sp sp -28
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp) # num rows
    sw s2 12(sp) # num cols
    sw s3 16(sp) # file descriptor 
    sw s4 20(sp) # newly allocated mem
    sw s5 24(sp) # total bytes to read
    
    mv s0 a0 # pointer to filename string
    mv s1 a1 # pointer to int containing number of rows (allocated mem)
    mv s2 a2 # pointer to int containing number of columns (allocated mem)
    
file_open:
    # a0 = pointer to filename string
    mv a0 s0
    # a1 = permission bits (0 for read) 
    li a1 0
    
    jal ra fopen
    
    # check file open error
    li t0 -1
    beq a0 t0 error_fopen
    
    # save file descriptor 
    mv s3 a0 
    
file_read_row:
    # a0 = file descriptor to read from
    mv a0 s3
    # a1 = pointer to buffer where read bytes are stored
    mv a1 s1
    # a2 = number of bytes to read 
    li a2 4
    
    jal ra fread 
    
    # check file read error 
    li t0 4 
    bne a0 t0 error_fread
   

file_read_col:
    # a0 = file descriptor to read from
    mv a0 s3
    # a1 = pointer to buffer where read bytes are stored
    mv a1 s2
    # a2 = number of bytes to read 
    li a2 4
    
    jal ra fread 
    
    # check file read error 
    li t0 4 
    bne a0 t0 error_fread


allocate:
    # determine how much space needed
    lw t1 0(s1)
    lw t2 0(s2)
    mul t3 t1 t2
    slli t3 t3 2
    # save total space (in bytes) 
    mv s5 t3
    
    # a0 = size of memory to allocate 
    mv a0 t3
    
    jal ra malloc 
    
    # check malloc error
    beq a0 x0 error_malloc
    
    # save newly allocated memory
    mv s4 a0 
    
file_read_matrix:
    # a0 = file descriptor to read from
    mv a0 s3
    # a1 = pointer to buffer where read bytes are stored
    mv a1 s4
    # a2 = number of bytes to read 
    mv a2 s5
    
    jal ra fread 
    
    # check file read error 
    bne a0 s5 error_fread

file_close:
    # a0 = file descriptor
    mv a0 s3
    
    jal ra fclose 
    
    # check file close error 
    li t0 -1
    beq a0 t0 error_fclose
    

return:
    # a0 = return value = pointer to matrix in memory 
    mv a0 s4
    
    # Epilogue
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    lw s4 20(sp) 
    lw s5 24(sp)
    
    addi sp sp 28

    jr ra
    

error_malloc:
    li a0 26
    j exit 
    
error_fopen:
    li a0 27
    j exit 
    
error_fclose:
    li a0 28
    j exit 
    
error_fread:
    li a0 29
    j exit 
