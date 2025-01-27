.data
	input_msg_1:	.asciiz "Please enter option (1: add, 2: sub, 3: mul): "
    input_msg_2:	.asciiz "Please enter the first number: "
    input_msg_3:	.asciiz "Please enter the second number: "
	output_msg:	    .asciiz "The calculation result is: "
	newline: 	    .asciiz "\n"

.text
.globl main
#------------------------- main -----------------------------
main:
# print input_msg on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, input_msg_1	# load address of string into $a0
	syscall                 	# run the syscall
 
# read the input integer in $v0
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $a2, $v0      		# store input in $a0

# print input_msg on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, input_msg_2	# load address of string into $a0
	syscall                 	# run the syscall
 
# read the input integer in $v0
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $t6, $v0      		# store input in $a0

# print input_msg on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, input_msg_3	# load address of string into $a0
	syscall                 	# run the syscall
 
# read the input integer in $v0
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $t7, $v0      		# store input in $a0

    addi    $t0, $a2, -1
    beq     $t0, $zero, ADDL
    addi    $t0, $t0, -1
    beq     $t0, $zero, SUBL
    addi    $t0, $t0, -1
    beq     $t0, $zero, MULL

ADDL:
    add     $t3, $t6, $t7
    j       Endmain
SUBL:
    sub     $t3, $t6, $t7
    j       Endmain
MULL:
    mul     $t3, $t6, $t7
    j       Endmain

Endmain:
# print output_msg on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, output_msg		# load address of string into $a0
	syscall                 	# run the syscall

# print the result of procedure factorial on the console interface
	li 		$v0, 1				# call system call: print int
	move 	$a0, $t3			# move value of integer into $a0
	syscall 					# run the syscall

# print a newline at the end
	li		$v0, 4				# call system call: print string
	la		$a0, newline		# load address of string into $a0
	syscall						# run the syscall

# exit the program
	li 		$v0, 10				# call system call: exit
	syscall						# run the syscall

