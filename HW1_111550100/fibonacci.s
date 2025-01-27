.data
    input_msg:  .asciiz "Please input a number: "
    output_msg: .asciiz "The result of fibonacci(n) is "
    newline:    .asciiz "\n"

.text
.globl main

#------------------------- main -----------------------------
main:
    # Print input message
    li      $v0, 4                 # syscall: print string
    la      $a0, input_msg         # load address of input message
    syscall                        # make syscall

    # Read integer input
    li      $v0, 5                 # syscall: read integer
    syscall                        # make syscall
    move    $a0, $v0               # store input in $a0

    # Call fibonacci function
    jal     fibonacci
    move    $t0, $v0               # store result of fibonacci in $t0

    # Print output message
    li      $v0, 4                 # syscall: print string
    la      $a0, output_msg        # load address of output message
    syscall                        # make syscall

    # Print the result of fibonacci on the console interface
    li      $v0, 1                 # syscall: print int
    move    $a0, $t0               # move value of integer into $a0
    syscall                        # run the syscall

    # Print a newline at the end
    li      $v0, 4                 # syscall: print string
    la      $a0, newline           # load address of string into $a0
    syscall                        # run the syscall

    # Exit program
    li      $v0, 10                # syscall: exit
    syscall                        # make syscall

#----------fibonacci----------
fibonacci:
    addi    $sp, $sp, -12
    sw      $ra, 8($sp)
    sw      $s0, 4($sp)
    sw      $s1, 0($sp)

    add     $s0, $a0, $zero
    move    $t1, $a0
    addi    $t2, $zero, 1
    ble     $s0, $t2, Return01

    addi    $a0, $s0, -1       #f(n-1)
    jal     fibonacci
    move    $s1, $v0
    addi	$a0, $s0, -2		#f(n-2)	
    jal     fibonacci
    add     $v0, $v0, $s1

    lw      $ra, 8($sp)        #!!!!!return of all
    lw      $s0, 4($sp)
    lw      $s1, 0($sp)     
    addi    $sp, $sp, 12
    jr		$ra	
    
Return01:
    move    $v0, $t1
    lw      $ra, 8($sp)
    lw      $s0, 4($sp)
    lw      $s1, 0($sp)     
    addi    $sp, $sp, 12
    jr		$ra					# jump to $ra
    