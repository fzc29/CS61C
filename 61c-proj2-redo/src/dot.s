.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the number of elements to use is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
    # check if num elements used is less than 1 
    li t0 1
    blt a2 t0 error_36
    # check if stride of either array is less than 1 
    blt a3 t0 error_37
    blt a4 t0 error_37
    
    # Prologue
    li t0 4
    # step size a0
    mul t2 a3 t0
    # step size a1
    mul t3 a4 t0
    # current sum
    li t0 0
    # current counter for num elems 
    li t1 0

loop_start:
    # a2 = counter
    beq a2 x0 loop_end
    # load right values 
    lw t4 0(a0)
    lw t5 0(a1) 
    mul t6 t4 t5
    # update sum 
    add t0 t0 t6
    
    # update counters
    addi a2 a2 -1
    add a0 a0 t2
    add a1 a1 t3
    j loop_start

loop_end:
    # Epilogue
    mv a0 t0
    jr ra

error_36: 
    li a0 36
    j exit 
    
error_37:
    li a0 37
    j exit