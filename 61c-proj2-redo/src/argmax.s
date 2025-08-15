.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    # Prologue
    li t0 1
    blt a1 t0 error

    # t0 = current index 
    li t0 0
    # t1 = target index (max so far) 
    li t1 0
    # t2 = current max value 
    lw t2 0(a0)
    
loop_start:
    beq a1 x0 loop_end
    # current value 
    lw t3 0(a0)
    # if current_max >= current_value (no need to make changes)
    bge t2 t3 loop_continue 

    # else need to update current max
    mv t2 t3
    # update current max index
    mv t1 t0
    
loop_continue:
    addi t0 t0 1
    addi a0 a0 4
    addi a1 a1 -1
    j loop_start

loop_end:
    # Epilogue
    mv a0 t1
    
    jr ra

error:
    li a0 36
    j exit 
    
