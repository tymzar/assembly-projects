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
	
# 	if(*current_character > 'A' && *current_character < 'Z' && *current_character > 'a' && *current_character < 'z'){
	li t2, 'Z'
	blt t1, t2, uppercase_check
	
	li t2, 'a'
	bgt t1, t2, lowercase_check
	
	

	uppercase_check:
		li t2, 'A'
		blt t1, t2, change_character
		
		j skip
	
	lowercase_check:
		li t2, 'z'
		bgt t1, t2, change_character
		
		j skip
	
	change_character:
		li t1, '*'
	
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