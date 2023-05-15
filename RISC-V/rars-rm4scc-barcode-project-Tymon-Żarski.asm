#-------------------------------------------------------------------------------
#author: Tymon Żarski
#data : 2021.07.02
#description : example RISC V program for reading, modifying and writing a BMP file 
#-------------------------------------------------------------------------------

#https://github.com/TheThirdOne/rars/wiki

#only 24-bits 600x50 pixels BMP files are supported

.eqv BMP_FILE_SIZE 90122
.eqv BYTES_PER_ROW 1800

	.data



#space for the 600x50px 24-bits bmp image

.align 4

codes: .byte 0b0011, 0b0101, 0b0110, 0b1001, 0b1010, 0b1100
characters: .byte '0', '1', '2', '3', '4', '5', '6','7','8','9','0' # 'A', 'B' etc.
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

res:	.space 2
image:	.space BMP_FILE_SIZE

error_message: .asciz "Error: failed to open file.\n"

fname:	.asciz "source.bmp"
	.text

main:

	jal	read_bmp

	#put red pixel in bottom left corner	
	li	a0, 0		#x
	li	a1, 0		#y
	li 	a2, 0x00FF0000	#color - 00RRGGBB
	jal	put_pixel

	#get pixel color - $a0=x, $a1=y, result $v0=0x00RRGGBB
	li	a0, 0		#x
	li	a1, 0		#y
	jal     get_pixel

	#put green pixel one pixel above	
	li	a0, 0		#x
	li	a1, 1		#y
	li 	a2, 0x0000FF00	#color - 00RRGGBB
	jal	put_pixel

	#get pixel color - $a0=x, $a1=y, result $v0=0x00RRGGBB
	li	a0, 0		#x
	li	a1, 1		#y
	jal     get_pixel

	#put blue pixel one pixel above
	li	a0, 0		#x
	li	a1, 2		#y
	li 	a2, 0x000000FF	#color - 00RRGGBB
	jal	put_pixel

	#get pixel color - $a0=x, $a1=y, result $v0=0x00RRGGBB
	li	a0, 0		#x
	li	a1, 2		#y
	jal get_pixel


	jal	save_bmp

exit:	li 	a7,10		#Terminate the program

	ecall



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

#check for errors - if the file was opened

	# Here, we are checking if file descriptor is less than 0. If it's less than 0, an error occurred.
	blt s1, zero, error_handler

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

error_handler:
	# print error message
	la a0, error_message
	li a7, 4
	ecall
	# exit program
	li a7, 10
	ecall

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
    la a0, fname		#file name 
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
