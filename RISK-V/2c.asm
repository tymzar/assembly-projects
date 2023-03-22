#-------------------------------------------------------------------------------
#author       : Tymon Żarski
#date         : 2023.22.03
#description  : RISC-V - At the beginning of the output string put the characters from the odd positions, next the even
#-------------------------------------------------------------------------------

		.data
input:	.space 80
output:	.space 80
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
   
# At the beginning of the output string put the characters from the odd positions, next the even

# current_character = input -> t0
	la t0, input
# current_output = output -> t1
	la t1, output
	la t4, input
	
# store '\n' to later remove
	li t6, '\n'

while_odd_start:
# while(*current_character != '\0'){
	lbu t2, (t0)
	beqz t2, while_odd_end
	beq t6, t2, while_odd_end
# 	if(current_characte - input_start % 2 == 1 ){
	# current_index
	sub t5, t0, t4 
	
	li t3, 1 # since the limit is 80 chars then 1 is in binary 0000001
	and t3, t3, t5
	
	bnez t3, skip_odd
#		output = current_character
	sb t2, (t1)
	addi t1, t1, 1
#		output++
#	}
skip_odd:
#	current_character++
	addi t0, t0, 1
	j while_odd_start
# }
while_odd_end:
#

	la t0, input
	
while_even_start:
# while(*current_character != '\0'){
	lbu t2, (t0)
	beqz t2, while_even_end
	beq t6, t2, while_even_end
# 	if(current_characte - input_start % 2 == 0 ){
#		output = current_character 
	sub t5, t0, t4
	
	li t3, 1 # since the limit is 80 chars then 1 is in binary 0000001
	and t3, t3, t5
	
	beqz t3, skip_even
	
	sb t2, (t1)
	addi t1, t1, 1
#		output++
#	}

skip_even:
	addi t0, t0, 1
	j while_even_start


#	current_character++
# }
while_even_end:


# Display the output prompt and the string
    li a7, 4		# System call for print_string
    la a0, msg1		# Address of string 
    ecall
    li a7, 4		# System call for print_string
    la a0, output	# Address of string 
    ecall

exit:	
    li 	a7,10	# Terminate the program