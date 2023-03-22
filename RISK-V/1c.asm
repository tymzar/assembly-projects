#-------------------------------------------------------------------------------
#author       : Tymon Żarski
#date         : 2023.22.03
#description  : RISC-V - Convert all upper case letters to *
#-------------------------------------------------------------------------------

		.data
input:	.space 80
prompt:	.asciz "\nInput string       > "
msg1:	.asciz "\nConversion results > "

		.text
# ============================================================================
main:
# Display the input prompt
    li a7, 4		# System call for print_string
    la a0, prompt	# Address of string 
    ecall

# Read the input string
    li a7, 8		# System call for read_string
    la a0, input	# Address of buffer    
    li a1, 79	    # Max length
    ecall
   
# Convert all upper case letters to *

# curret_character = input
	la t0, input

while_start:
# while(*current_character != '\0'){
	lbu t1, 0(t0)
	beqz t1, while_end
# 	if(*current_character > '0' && *current_character < '9'){
	li t2, '0'
	blt t1, t2, skip
	li t2, '9'
	bgt t1, t2, skip
#		current_character = '*';
	li t1, '*'
#	}
skip:
#	input = current_character;
	sb t1, (t0)
#	current_character++
	addi t0, t0, 1
	j while_start
# } 

while_end:

# Display the output prompt and the string
    li a7, 4		# System call for print_string
    la a0, msg1		# Address of string 
    ecall
    li a7, 4		# System call for print_string
    la a0, input	# Address of string 
    ecall

exit:	
    li 	a7,10	# Terminate the program