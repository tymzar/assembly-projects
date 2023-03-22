#-------------------------------------------------------------------------------
#author       : Tymon Żarski
#date         : 2023.22.03
#description  : RISC-V - Reverse the order of characters in the string
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
   
# Reverse the order of characters in the string

# output_start = output -> t0
	la t0, output
# current_character = input -> t1
	la t1, input
	
back_while_start:
# while(*current_character != '\0'){ -> t2
	lbu t2, (t1)
	beqz t2, back_while_end
#	current_character++;
	addi t1, t1, 1
	j back_while_start
#}
back_while_end:

# remove the '\n' and the '\0'
addi t1,t1,-2

while_start:
# while(true){
#	if(current_character == input){ break; }
	la t3, input
	# 	output = current char
	lbu t2, (t1)
	sb t2, (t0)
	beq t3, t1, while_end
#	output++
	addi t0,t0,1
#	current_character--
	addi t1,t1,-1
	
	j while_start
# }
while_end:

# Display the output prompt and the string
    li a7, 4		# System call for print_string
    la a0, msg1		# Address of string 
    ecall
    li a7, 4		# System call for print_string
    la a0, output	# Address of string 
    ecall

exit:	
    li 	a7,10	# Terminate the program