.data
    input_option_msg: .asciiz "Please enter option (1: triangle, 2: inverted triangle): "
    input_size_msg:   .asciiz "Please input a triangle size: "
    newline:          .asciiz "\n"
    space:            .asciiz " "
    star:             .asciiz "*"

.text
.globl main
#------------------------- main -----------------------------
main:
    # print input_msg on the console interface
    li      $v0, 4             # call system call: print string
    la      $a0, input_option_msg     # load address of string into $a0
    syscall                            # run the syscall

    # read the input integer in $v0
    li      $v0, 5             # call system call: read integer
    syscall                    # run the syscall
    move    $t0, $v0           # store input in $a0 (set argument of procedure prime)

    # print input_msg on the console interface
    li      $v0, 4             # call system call: print string
    la      $a0, input_size_msg     # load address of string into $a0
    syscall                            # run the syscall

    # read the input integer in $v0
    li      $v0, 5             # call system call: read integer
    syscall                    # run the syscall
    move    $t1, $v0           # store input in $a0 (set argument of procedure prime)

    add     $t2, $zero, $zero  # i = 0
    addi    $t0, $t0, -1
    beq     $t0, $zero, MainLoopOP1
    j       MainLoopOP0

MainLoopOP1:
    slt     $t3, $t2, $t1
    beq     $t3, $zero, MainExit
    move    $a0, $t1
    move    $a1, $t2
    jal     PrintLayer
    addi    $t2, $t2, 1
    j       MainLoopOP1

MainLoopOP0:
    slt     $t3, $t2, $t1
    beq     $t3, $zero, MainExit
    move    $a0, $t1
    sub     $t4, $t1, $t2
    addi    $t4, $t4, -1
    move    $a1, $t4
    jal     PrintLayer
    addi    $t2, $t2, 1
    j       MainLoopOP0

MainExit:
    li      $v0, 10            # call system call: exit
    syscall                    # run the syscall

#------------------------- procedure printlayer -----------------------------
# load argument n in $a0, return value in $v0. 
.text
PrintLayer: 
    addi    $sp, $sp, -4        # adjust stack for 1 item
    sw      $ra, 0($sp)         # save return address

    move    $t5, $a0
    move    $t6, $a1

    li      $t7, 1              #j = 1
    sub     $t8, $t5, $t6
    j       L1
L1:
    slt     $t9, $t7, $t8
    beq     $t9, $zero, L2
    li      $v0, 4             # call system call: print string
    la      $a0, space         # load address of string into $a0
    syscall                    # run the syscall
    addi    $t7, $t7, 1
    j       L1
L2:
    sub     $t7, $t5, $t6              #j = n - l
    add     $t8, $t5, $t6
    j       L22
L22:
    slt     $t9, $t8, $t7
    bne     $t9, $zero, Exit
    li      $v0, 4             # call system call: print string
    la      $a0, star         # load address of string into $a0
    syscall                    # run the syscall
    addi    $t7, $t7, 1
    j       L22           
Exit:
    li		$v0, 4				# call system call: print string
	la		$a0, newline		# load address of string into $a0
	syscall						# run the syscall
    li      $v0, 1              
    lw      $ra, 0($sp)         
    addi    $sp, $sp, 4         
    jr      $ra                 
