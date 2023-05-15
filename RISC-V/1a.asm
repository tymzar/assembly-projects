#-------------------------------------------------------------------------------
#author       : Tymon Żarski
#date         : 2023.22.03
#description  : RISC-V - Convert all lower case letters to *. 
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
	
# Convert all lower case letters to *

# current_character = input -> t1
	la t1, input

while_start:
# while(*current_character != '\0'){
	lbu t2, (t1)
	beqz t2, while_end
# 	if(*current_character <  && *current_character > ){ # ascii range 97 - 122
	li t3, 'a'
	blt t2, t3, skip
	li t3 'z'
	bgt t2, t3, skip
#		current_character[pointer] = *
	li t2, '*' # 42 in ascii is *

skip:	
	sb t2, (t1)
#		current_character++
	addi t1, t1, 1
	j while_start
#	}
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
    