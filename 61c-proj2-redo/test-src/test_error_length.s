.import ../src/utils.s
.import ../src/../coverage-src/initialize_zero.s

.data
msg0: .asciiz "Expected a0 to be 36 not: "

.globl main_test
.text
# main_test function for testing
main_test:
    # Prologue
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)


    # load -4 into a0
    li a0 -4

    # call initialize_zero function
    jal ra initialize_zero

    # save all return values in the save registers
    mv s0 a0


    # check that a0 == 36
    li t0 36
    beq s0 t0 a0_eq_36
    # print error and exit
    la a0, msg0
    jal print_str
    mv a0 s0
    jal print_int
    # Print newline
    li a0 '\n'
    jal ra print_char
    # exit with code 8 to indicate failure
    li a0 8
    jal exit
    a0_eq_36:

    # we expect initialize_zero to exit early with code 36

    # exit normally
    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8

    li a0 0
    jal exit
