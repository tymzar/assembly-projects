#-------------------------------------------------------------------------------
#author: Tymon Żarski
#data : 2021.07.02
#description : RISC-V RM4SCC barcode generator
#test: https://demo.dynamsoft.com/barcode-reader/
#-------------------------------------------------------------------------------
#https://github.com/TheThirdOne/rars/wiki
#only 24-bits 600x50 pixels BMP files are supported

.eqv BMP_FILE_SIZE 90122
.eqv BYTES_PER_ROW 1800
.eqv SYMBOL_OFFSET 7
.eqv ZERO_ASCII 48
.eqv START_TOP 26
.eqv START_BOTTOM 25

	.data

#space for the 600x50px 24-bits bmp image

input:	.space 80
output:	.space 80

top_checksum: .space 1
bottom_checksum: .space 1

current_offset: .space 2
prompt:	.asciz "\nString to encode       > "
prompt_number:	.asciz "\nBar width       > "

codes: 
	.byte 0x3, 0x5, 0x6, 0x9, 0xA, 0xC
	
bar_height:
	.byte 0x3, 0xA
special_height:
	.byte 0x0, 0xA

.align 4

res:	.space 2

image:	.space BMP_FILE_SIZE

fname:	.asciz "source.bmp"
outfname: .asciz "output.bmp"

# alternatywne podejście korzystanie z wartości ascii '0' - 48 
# razem z deklaracją offset'u pomiędzy cyframi a dużymi lterami.

# rozkodowywanie znaków na kod, znając offset dzieląc z resztą wynik można interpretować
# reszta z dzielenia - watością bottom oraz index = (reszta - 1) kodu w codes
# wartiść dzelenia - wartość top = wynik dzelenia + 1 oraz index kody w codes

# generowanie:
# 1. zliczenie znaków aby wyliczyć offset z lewej strony aby całość była wyśrodkowana
# 2. określona wartość - śrosdkowy pixel (vertical height)
# 3. w zależności od code z codes (bottom or top) rysujemy odpowednio w dół lub górę

# Rysowanie słupka:
# current offset
# kierunek 
# czy krótka
# return - current offset + szerokośc słupka + default margines

	.text

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
# Display the input prompt
    li a7, 4		# System call for print_string
    la a0, prompt_number	# Address of string 
    ecall
# Read the input number
    li a7, 5		# System call for read_string
    ecall
    mv s8, a0 # save the bar pixes width

    
	li s10, 0 # top checksum
	li s11, 0 # bottom checksum
	li s9, 50 # current x point 

	
	jal	read_bmp
	
	li a0, 1
    mv a1, s9
    li a2, 1
    li a3, 0
    jal print_top
    
	li a0, 0
    mv a1, s9
    li a2, 0
    li a3, 0
    jal print_top    
	
	# Processing the letters to the RM4CC code
	la s0, input
	
	loop:
	    lbu  t2, 0(s0)         # load a byte from the string
	    beqz t2 loop_end       # if the byte is zero, we're done
	    li   t3, '\n'
	    beq  t2, t3, loop_end
	
		#if number
		li t3, ZERO_ASCII
		#if character then add SYMBOL_OFFSET to the t3
		mv a0, t2
		jal is_uppercase_character
		
		beqz a0, char_encoding
		
		li t4, SYMBOL_OFFSET # redeam for the gap between the 
		add t3, t3, t4
		
	char_encoding:
		sub t3, t2, t3 # t3 - character index
		
		li t4, 6
		divu s1, t3, t4 # s1 - result of division by 6, y axies index
		
		li t5, 6
		remu s2, t3, t5 # s2 - reminder of division by 6, x axies index


   		add s10, s10, s1
    	addi s10,s10, 1	# we need to add 1 because value is index + 1
    	rem s10, s10, t5 # s10 top code
    	
    	add s11, s11, s2
    	addi s11,s11, 1 # we need to add 1 because value is index + 1
    	rem s11, s11, t5 # s11 bottom code

		la t4, codes     # Load address of 'codes' into a0
		add t4, t4, s1
    	lb s1, 0(t4)
    	
		la t4, codes     # Load address of 'codes' into a0
		add t4, t4, s2
    	lb s2, 0(t4)    	
    	
    	li t5, 6
    	
 
    	
    	
    	mv a0, s10
    	li a7, 1
    	ecall
    	
    	li a0, 9
    	li a7, 1
    	ecall
    	
    	mv a0, s11
    	li a7, 1
    	ecall
    	
    	li a0, 9
    	li a7, 1
    	ecall
    	#print top
    	#mv a0, s1
    	#li a7, 1
    	#ecall
    	
    	#mv a0, s2
    	#li a7, 1
    	#ecall
    	
    	mv a0, s1
    	mv a1, s9
    	li a2, 1
    	li a3, 1
    	jal print_top

    	mv a0, s2
    	mv a1, s9
    	li a2, 0
    	li a3, 1
    	jal print_top
    	
    	
    	#print bottom
	
	    addi s0, s0, 1         # increment the string pointer

	    j    loop              # jump back to the start of the loop
	loop_end:

	addi s10, s10, -1
	la t4, codes     # Load address of 'codes' into a0
	add t4, t4, s10
    lb s10, 0(t4)

	addi s11, s11, -1
	la t4, codes     # Load address of 'codes' into a0
	add t4, t4, s11
    lb s11, 0(t4)
	
	
	mv a0, s10
    mv a1, s9
    li a2, 1
    li a3, 1
    jal print_top
    
    mv a0, s11
    mv a1, s9
    li a2, 0
    li a3, 1
    jal print_top
				
	
	li a0, 8
    mv a1, s9
    li a2, 1
    li a3, 0
    jal print_top
    
    li a0, 8
    mv a1, s9
    li a2, 0
    li a3, 0
    jal print_top
	
	jal	save_bmp

exit:	li 	a7,10		#Terminate the program
	ecall
# ============================================================================
print_top:
#description: 
#	takes in a0 the 8 byte configuration top codes
#	takes in a1 current y offset
# 	takes in a2 if the bar us up or down
#   takes in a3 if the character is a end or start sign
#arguments:
#	character
#return value: none
    addi sp, sp, -40		# make space on the stack for 3 registers
    sw s1, 0(sp)			# save register s1
    sw s2, 4(sp)			# save register s2
    sw s3, 8(sp)			# save register s3
    sw s4, 12(sp)			# save register s4
    sw s5, 16(sp)			# save register s5
    sw s6, 20(sp)			# save register s5
   	sw s7, 24(sp)
   	sw s10, 28(sp)
   	sw s11, 32(sp)
   	sw ra, 36(sp)
    	    	   	
    add s1, zero, a0      # t0 is the register you want to loop over, and 0x3 is the value
    add s4, zero, s9 # local x point
    add s10, zero, a2
    add s11, zero, a3



    li s6, 4        # t1 will be the loop counter (4 bits in this case)
loop_bit:
	
    andi s2, s1, 0x8        # t2 will hold the most significant bit of t0

    mv t1, s2
    srli t1, t1, 3
    andi t1, t1, 0x1
    
    
    
    la t2, bar_height     
	bnez s11, load_height
	
	la t2, special_height
	
	load_height:
	add t2, t2, t1		  # Add the index to the addres to get the bar height
    lb s3, 0(t2) 
    
    # s9 - current x point 
	# s8 -  save the bar pixes width

    li s7, 0
    x_loop:
       

    	#mv a0,s4
    	#li a7, 1
    	#ecall
    	
    	li s5, 0
    	y_loop:

    	#mv a0,s5
    	#li a7, 1
    	#ecall

		mv a0,s4 #x
		
		
		li a1, START_TOP
		add a1, a1, s5
		bnez s10, put_in_file
		
		li a1, START_BOTTOM
		sub a1, a1, s5
		mv s9, s4
		
		put_in_file:
		
		beqz s3, end_y_loop
		
		#mv a1, s5
		li 	a2, 0x00000000	#color - 00RRGGBB
		
		
	
		#mv a1, s5
		#addi a1, a1, START_TOP
		#li 	a2, 0x000000FF	#color - 00RRGGBB
		
		
		jal	put_pixel

    	addi s5, s5, 1

    	bne s5, s3, y_loop 
    end_y_loop:	
    	
    
    
    addi s7, s7, 1
    addi s4, s4, 1
    bne s7, s8, x_loop     
    
    add s4, s4, s8


    slli s1, s1, 1          # Shift t0 right by 1 bit
    addi s6, s6, -1         # Decrement the loop counter
    bnez s6, loop_bit           # If the counter is not zero, continue looping

bnez s10, print_top_done
add s9, s9, s8 
add s9, s9, s8     
    
print_top_done:

 	lw s1, 0(sp)			# restore register s1
    lw s2, 4(sp)			# restore register s2
    lw s3, 8(sp)			# restore register s3
    lw s4, 12(sp)			# restore register s3
    lw s5, 16(sp)			# save register s3
    lw s6, 20(sp)
    lw s7, 24(sp)
    lw s10, 28(sp)
    lw s11, 32(sp)
    lw ra, 36(sp)
    addi sp, sp, 40		# restore the stack pointer
    jr ra                # return from the function with the number of modified characters in t0

# ============================================================================
is_uppercase_character:
#description: 
#	takes a character and return 1 of its true else returnes 0
#arguments:
#	character
#return value: none
    addi sp, sp, -4        # allocate space on the stack for the return value
    sw   zero, 0(sp)       # initialize return value to zero
    
    li t4, 'A'
	blt a0, t4, is_uppercase_character_done
	li t4, 'Z'
	bgt a0, t4, is_uppercase_character_done
	
	li t4, 1
	sw t4, 0(sp)
    
    
is_uppercase_character_done:
    lw   a0, 0(sp)         # load the final string length from the stack
    addi sp, sp, 4         # deallocate space on the stack
    ret                    # return from the function with the number of modified characters in t0

# ============================================================================
read_bmp:
#description: 
#	reads the contents of a bmp file into memory
#arguments:
#	none
#return value: none
	addi sp, sp, -4		#push $s1
	sw s1, 0(sp)
#open file
	li a7, 1024
        la a0, fname		#file name 
        li a1, 0		#flags: 0-read file
        ecall
	mv s1, a0      # save the file descriptor
#read file
	li a7, 63
	mv a0, s1
	la a1, image
	li a2, BMP_FILE_SIZE
	ecall

#close file
	li a7, 57
	mv a0, s1
        ecall
	lw s1, 0(sp)		#restore (pop) s1
	addi sp, sp, 4
	jr ra
# ============================================================================
save_bmp:
#description: 
#	saves bmp file stored in memory to a file
#arguments:
#	none
#return value: none
	addi sp, sp, -4		#push s1
	sw s1, (sp)
#open file
	li a7, 1024
        la a0, outfname		#file name 
        li a1, 1		#flags: 1-write file
        ecall
	mv s1, a0      # save the file descriptor
#save file
	li a7, 64
	mv a0, s1
	la a1, image
	li a2, BMP_FILE_SIZE
	ecall

	#close file
	li a7, 57
	mv a0, s1
        ecall
	lw s1, (sp)		#restore (pop) $s1
	addi sp, sp, 4
	jr ra

# ============================================================================
put_pixel:
	#description: 
	#	sets the color of specified pixel
	#arguments:
	#	a0 - x coordinate
	#	a1 - y coordinate - (0,0) - bottom left corner
	#	a2 - 0RGB - pixel color
	#return value: none

	la t1, image	#adress of file offset to pixel array
	addi t1,t1,10
	lw t2, (t1)		#file offset to pixel array in $t2
	la t1, image		#adress of bitmap
	add t2, t1, t2	#adress of pixel array in $t2
	
	#pixel address calculation
	li t4,BYTES_PER_ROW
	mul t1, a1, t4 #t1= y*BYTES_PER_ROW
	mv t3, a0		
	slli a0, a0, 1
	add t3, t3, a0	#$t3= 3*x
	add t1, t1, t3	#$t1 = 3x + y*BYTES_PER_ROW
	add t2, t2, t1	#pixel address 

	#set new color
	sb a2,(t2)		#store B
	srli a2,a2,8
	sb a2,1(t2)		#store G
	srli a2,a2,8
	sb a2,2(t2)		#store R

	jr ra
# ============================================================================

get_pixel:
	#description: 
	#	returns color of specified pixel
	#arguments:
	#	a0 - x coordinate
	#	a1 - y coordinate - (0,0) - bottom left corner
	#return value:
	#	a0 - 0RGB - pixel color
	la t1, image		#adress of file offset to pixel array
	addi t1,t1,10
	lw t2, (t1)		#file offset to pixel array in $t2
	la t1, image		#adress of bitmap
	add t2, t1, t2		#adress of pixel array in $t2

	#pixel address calculation
	li t4,BYTES_PER_ROW
	mul t1, a1, t4 		#t1= y*BYTES_PER_ROW
	mv t3, a0		
	slli a0, a0, 1
	add t3, t3, a0		#$t3= 3*x
	add t1, t1, t3		#$t1 = 3x + y*BYTES_PER_ROW
	add t2, t2, t1	#pixel address 

	#get color
	lbu a0,(t2)		#load B
	lbu t1,1(t2)		#load G
	slli t1,t1,8
	or a0, a0, t1
	lbu t1,2(t2)		#load R
        slli t1,t1,16
	or a0, a0, t1

	jr ra

# ============================================================================
