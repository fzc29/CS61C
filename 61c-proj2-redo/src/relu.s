.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    # Prologue
    li t0 1
    blt a1 t0 error
    
    addi sp sp -8
    sw ra 0(sp)
    sw s0 4(sp)
    
    # save a0 into s0
    mv s0 a0 
    
loop_start:
    # once a0 (number of elem) reaches 0, end loop
    beq x0 a1 loop_end
    # load current number 
    lw t0 0(a0) 
    # check if current number >= 0 (is so leave alone and jump to continue)
    bge t0 x0 loop_continue
    # if not: load 0 into current location
    sw x0 0(a0)

loop_continue:
    # decrement here 
    addi a1 a1 -1
    # increment a0 for access of right element 
    addi a0 a0 4
    # go back to loop start
    j loop_start


loop_end:
    # Epilogue
    mv a0 s0 
    
    lw ra 0(sp)
    lw s0 4(sp) 
    addi sp sp 8
    
    jr ra

error:
    li a0 36
    j exit 