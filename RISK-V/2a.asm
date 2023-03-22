#-------------------------------------------------------------------------------
#author       : Tymon Żarski
#date         : 2023.22.03
#description  : RISC-V - Swap the position of characters in consecutive pairs
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
   
# Swap the position of characters in consecutive pairs
	li t4, '\n'
# current_character_pointer = input -> t0
	la t0, input
# next_character_pointer = current_character + 1 -> t1
	la t1, input
	addi t1, t1, 1 

while_start:
# while(*current_character != '\0'){ -> t2

	
	lbu t2, (t0)
	beqz t2, while_end
#	 	save next value -> t3
	lbu t3, (t1)
	beqz t3, while_end
	
# end if any of the pointers are \n (optional)

	beq t4, t3, while_end
	beq t4, t2, while_end
	
#		save bite next as current
	sb t3, (t0)
#		save current bit as next
 	sb t2, (t1)
#		update pointers by 2 
	addi t0, t0, 2
	addi t1, t1, 2
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