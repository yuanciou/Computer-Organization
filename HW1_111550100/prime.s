.data
    input_msg:   .asciiz "Please input a number: "
    output_msg_p: .asciiz "It's a prime\n"
    output_msg_np: .asciiz "It's not a prime\n"

.text
.globl main
#------------------------- main -----------------------------
main:
    # print input_msg on the console interface
    li      $v0, 4             # call system call: print string
    la      $a0, input_msg     # load address of string into $a0
    syscall                    # run the syscall

    # read the input integer in $v0
    li      $v0, 5             # call system call: read integer
    syscall                    # run the syscall
    move    $a0, $v0           # store input in $a0 (set argument of procedure prime)

    # jump to procedure prime
    jal     prime
    move    $t0, $v0           # save return value in t0 (because v0 will be used by system call)

    bne     $t0, $zero, Isprime
    beq     $t0, $zero, Notprime
Isprime:
    # print output_msg on the console interface
    li      $v0, 4             # call system call: print string
    la      $a0, output_msg_p  # load address of string into $a0
    syscall                    # run the syscall
    j       Endmain
Notprime:
    li      $v0, 4             # call system call: print string
    la      $a0, output_msg_np # load address of string into $a0
    syscall                    # run the syscall
    j       Endmain
Endmain:
    li      $v0, 10            # call system call: exit
    syscall                    # run the syscall

#------------------------- procedure prime -----------------------------
# load argument n in $a0, return value in $v0. 
.text
prime:  
    addi    $sp, $sp, -4        # adjust stack for 1 item
    sw      $ra, 0($sp)         # save return address
    
    addi    $t0, $a0, -1        
    beq     $t0, $zero, NotPrime
    
    addi    $t1, $zero, 2       # i = 2
Loop:
    mul     $t2, $t1, $t1       # t2 = i * i
    bgt     $t2, $a0, Exit      # if (i*i > n) exit loop
    
    div     $a0, $t1            
    mfhi    $t3                 
    beq     $t3, $zero, NotPrime
    addi    $t1, $t1, 1         
    j       Loop                
NotPrime:
    li      $v0, 0              
    lw      $ra, 0($sp)         
    addi    $sp, $sp, 4         
    jr      $ra                 
Exit:
    li      $v0, 1              
    lw      $ra, 0($sp)         
    addi    $sp, $sp, 4         
    jr      $ra                 
