.import ../src/utils.s
.import ../src/../coverage-src/zero_one_loss.s

.data
.align 4
m0: .word 1 2 3 4 5 6 7 8 9
.align 4
m1: .word 1 0 0 0 0 0 0 8 0
.align 4
m2: .word -1 -1 -1 -1 -1 -1 -1 -1 -1
msg0: .asciiz "Expected a0 to be 36 not: "

.globl main_test
.text
# main_test function for testing
main_test:
    # Prologue
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)


    # load address to array m0 into a0
    la a0 m0

    # load address to array m1 into a1
    la a1 m1

    # load -1 into a2
    li a2 -1

    # load address to array m2 into a3
    la a3 m2

    # call zero_one_loss function
    jal ra zero_one_loss

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

    # we expect zero_one_loss to exit early with code 36

    # exit normally
    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8

    li a0 0
    jal exit
