
section .bss
    top_checksum resq  1
    bottom_checksum resq  1
    current_point resq  1
    current_height resq  1
    character_index resq  1
    y_index resq  1
    x_index resq  1
    x_loop_limit resq  1
    y_loop_limit resq  1
    dest_bitmap_address resq  1

section .data
; Declared arrays for the barcodes
    codes db 0x3, 0x5, 0x6, 0x9, 0xA, 0xC
    bar_height db 0x3, 0xA
    special_height db 0x0, 0xA

    bytesPerPixel       equ 3 ; The number of bytes per pixel for a 24-bit bitmap
    bmpWidth            equ 600 ; The width of the bitmap image. Replace 800 with your image's width
    WIDTH               equ 600
    HEIGHT              equ 50
    BYTES_PER_PIXEL     equ 3
    HEADER_SIZE         equ 54
    SYMBOL_OFFSET       equ 7
    ZERO_ASCII          equ 48
    START_TOP           equ 26
    START_BOTTOM        equ 25

section .text
    global encodeRM4SCC

; Function to print the address, bar_width, and text passed as the first, second, and third arguments respectively, then return 0.
; Arguments:
;   dest_bitmap: a pointer to the bitmap data
;   bar_width: the width of the bar
;   text: a pointer to the text
encodeRM4SCC:
    ; Save base pointer and set up a new base pointer
    push rbp
    mov rbp, rsp

    push rbx                ; Preserve rbx register

    xor rcx, rcx            ; Return code = 0
    xor rbx, rbx            ; Return code = 0



    ;clear destination bitmap address
    mov qword [dest_bitmap_address], 0
    ;save first argument to destination bitmap address
    mov rax , qword rdi  ; First argument is in rdi, not on the stack
    mov qword [dest_bitmap_address], rax

    mov qword  [top_checksum], 0
    mov qword  [bottom_checksum], 0
    mov qword  [current_point], 50

    

    ;set x_loop_limit to the value of third argument
    mov rax, qword rsi ; Second argument is in rsi, not on the stack
    mov [x_loop_limit], rax


        push rdx
        push rdi
        push rsi
        mov RDI, 1
        mov RSI, 1
        mov RDX, 0
        call print_top
        pop rsi
        pop rdi        
        pop rdx



        push rdx
        push rdi
        push rsi
        mov RDI, 0
        mov RSI, 0
        mov RDX, 0
        call print_top
        pop rsi
        pop rdi        
        pop rdx


    mov rcx, qword rdx ; Third argument is in rdx, not on the stack

    loop:

        ;char from current pointer 
        mov bl, byte [rcx]

        ;check if char is null terminator or newline
        cmp bl, 0
        je loop_end
        cmp bx, "\n"
        je loop_end

        mov rdx, ZERO_ASCII

        mov al, bl
        call is_valid_character
        cmp rax, 0
        je invalid_character

        mov al, bl
        call is_uppercase_character

        cmp rax, 0
        je char_encoding

        add rdx, SYMBOL_OFFSET

        char_encoding:

        sub rbx, rdx

        ; Move the value in RAX to RDX for the division operation
        mov rax, rbx
        mov rbx, 6
        xor rdx, rdx            ; Clear the high 64 bits of rdx (quotient)
        div rbx                 ; Divide rax by rbx, quotient in rax, remainder in rdx


        ; The quotient is stored in RAX
        ; The remainder is stored in RDX

        result:

        ; Now RAX contains the quotient 
        ; Now RDX contains the remainder 

        ; Add RAX to the top checksum
        add qword  [top_checksum], rax
        add qword  [top_checksum], 1
        ; Add RDX to the bottom checksum
        add qword  [bottom_checksum], rdx
        add qword  [bottom_checksum], 1

        ; ; and perform % 6 on the top checksum but preserve the remainder and quotient

        push rdx
        push rax

        mov rax, qword  [top_checksum]
        mov rbx, 6
        xor rdx, rdx            ; Clear the high 64 bits of rdx (quotient)
        div rbx                 ; Divide rax by rbx, quotient in rax, remainder in rdx
        mov qword  [top_checksum], rdx

        pop rax
        pop rdx


        
        push rdx
        push rax

        mov rax, qword  [bottom_checksum]
        mov rbx, 6
        xor rdx, rdx            ; Clear the high 64 bits of rdx (quotient)
        div rbx                 ; Divide rax by rbx, quotient in rax, remainder in rdx
        mov qword  [bottom_checksum], rdx

        pop rax
        pop rdx


        mov bl, byte [codes + rax] ; top bar
        movzx r9, bl
        rr91:

        ;replace with print top
        push rdx

        mov RDI, r9
        mov RSI, 1
        mov RDX, 1
        call print_top

        pop rdx

        mov bl, byte [codes + rdx] ; top bar
        movzx r9, bl

        rr92:

        push rdx
        mov RDI, r9
        mov RSI, 0
        mov RDX, 1
        call print_top
        pop rdx


        ; increment current pointer rbx
        inc rcx
        jmp loop

    loop_end:

    ;from the top checksum substract 1
    mov rcx, qword [top_checksum]

    ; if rcx is 0 then set it to 6
    cmp rcx, 0
    jne proces_top_checksum
    mov rcx, 6
    
    proces_top_checksum:
    sub rcx, 1
    ;load valie from codes of index top checksum
    mov bl, byte [codes + rcx]
    movzx rcx, bl

    ;print top checkmark
    push rdx
    push rdi
    push rsi
    mov RDI, rcx
    mov RSI, 1
    mov RDX, 1
    call print_top
    pop rsi
    pop rdi        
    pop rdx


    ;from the bottom checksum substract 1
    mov rcx, qword [bottom_checksum]

    ; if rcx is 0 then set it to 6
    cmp rcx, 0
    jne proces_bottom_checksum

    mov rcx, 6

    proces_bottom_checksum:

    sub rcx, 1
    ;load valie from codes of index bottom checksum
    mov bl, byte [codes + rcx]
    movzx rcx, bl

    ;print top checkmark
    push rdx
    push rdi
    push rsi
    mov RDI, rcx
    mov RSI, 0
    mov RDX, 1
    call print_top
    pop rsi
    pop rdi        
    pop rdx


        push rdx
        push rdi
        push rsi
        mov RDI, 8
        mov RSI, 1
        mov RDX, 0
        call print_top
        pop rsi
        pop rdi        
        pop rdx



        push rdx
        push rdi
        push rsi
        mov RDI, 8
        mov RSI, 0
        mov RDX, 0
        call print_top
        pop rsi
        pop rdi        
        pop rdx    

    mov rax, 0            ;return replace_count
    pop rbx                 ; Restore rbx register
    pop rbp
    ret       ; returns to the calling function

invalid_character:
    mov rax, 1            ;return replace_count

done:
    pop rbx                 ; Restore rbx register
    pop rbp
    ret       ; returns to the calling function
; ============================================================================
; description: 
; 	takes in a0 the 8 byte configuration top codes
;  	takes in a2 if the bar us up or down
;   takes in a3 if the character is a end or start sign
; arguments:
; 	character
; return value: none
print_top:
push r11
push r10
push rcx
push r12
push rbx
push r13

xor r12, r12
xor rbx, rbx
; Get arguments from the stack
mov r11, RDI ; first argument, s1
mov r10, qword [current_point] ; store x position , s4

mov r9, RDX

brr19:

; loop counter to 4
mov rcx, 4 ; s6 is rcx

loop_bit:

    ; make and of r11 and 0x8 and save it to another register
    mov r13, r11 ; r13 is s2
    and r13, 0x8

    ; move last 8 bits from r13 to r12
    mov r12, r13 ; t1 is r12
    ;shift r12 to the right 3 times and add 0x1
    shr r12, 3
    and r12, 0x1

    ;load value to r14 address of bar_height address with offset
    xor rbx, rbx
    movzx rbx, byte [bar_height + r12]

    breakpt:

    ;if the third argument is not 0 then jum to load_height
    cmp r9, 0
    jne load_height

    ;load to r14 address of special_height
    xor rbx, rbx
    movzx rbx, byte [special_height + r12]



   	load_height:

    rrbx:

    ; set r12 to current_height
    mov qword [current_height], rbx
    
    ; initialize loop counter to 0 in dl


    xor dl, dl ; s7 is dl

    x_loop:

        ;initialize loop counter to 0 in r14
        xor r14, r14 ; s5 is r14

        y_loop:
        ; set bl as START_TOP + r14

        ; load value of START_TOP
        mov r13, qword START_TOP
        add r13, r14

        ; if second argument is not 0 jump to put_in_file
        cmp RSI, 0
        jne put_in_file

        ; set bl as START_BOTTOM + r14
        mov r13, qword START_BOTTOM
        sub r13, r14

        rr13:

        ; save the value of r10 to the current_point
        mov qword [current_point], r10

        put_in_file:

        ; if r14 0 jump to end_y_loop
        cmp qword [current_height], 0
        je end_y_loop


        ;replace with print top
        push RDX
        push RSI
        push RDI
        mov RDI, r10
        mov RSI, r13
        mov RDX, qword [dest_bitmap_address]
        call put_pixel
        pop RDI
        pop RSI
        pop RDX

        ;increment s5
        inc r14

        ; if current height is equal to s5 jump to y_loop
        cmp qword [current_height], r14
        jne y_loop





        end_y_loop:

    ;increment s7
    inc dl
    inc r10
    
    ; if x_loop_limit is not equal to s7 jump to x_loop
    mov r15, qword [x_loop_limit]

    cmp byte [x_loop_limit], dl

    rr15:

    jne x_loop

    ; add to r10 the bar width
    add r10, qword [x_loop_limit]

    ;shift left r11 1 time
    shl r11, 1
    ;decrement rcx
    dec rcx
    ; if rcx is not equal to 0 jump to loop_bit
    cmp rcx, 0
    jne loop_bit

;if secind argument is not 0 jump to print_top_end
cmp RSI, 0
jne print_top_end

; else add to current_point x_loop_limit times 2
mov rcx, [x_loop_limit]
add qword [current_point], rcx
add qword [current_point], rcx

print_top_end:
pop r13
pop rbx
pop r12
pop rcx
pop r10
pop r11
ret
;=========================================================================
; function is_uppercase_character
; checks if the passed character (in al register) is uppercase
; returns 1 in r11 if uppercase, else 0
is_uppercase_character:
    ; Check if the character is less than 'A'
    cmp al, 'A'
    jl .not_uppercase

    ; Check if the character is greater than 'Z'
    cmp al, 'Z'
    jg .not_uppercase

    ; If we're here, then it's an uppercase character
    mov rax, 1
    ret

.not_uppercase:
    mov rax, 0
    ret
; ========================================================================
; function is_valid_character chech is the character is ther 0-9 or A-Z if it is return 1 else 0
is_valid_character:
    ; check is the character is 0-9
    cmp al, '0'
    jl .not_valid
    cmp al, 'Z'
    jg .not_valid

    cmp al, '9'
    jle .valid

    ; check is the character is A-Z
    cmp al, 'A'
    jge .valid
    
.not_valid:
    mov rax, 0
    ret

.valid:
    mov rax, 1
    ret 

;=========================================================================
put_pixel:
    push    rbp
    push    rcx
    push    rdx

    mov     rcx, RSI ; y position
    imul    rcx, WIDTH
    add     rcx, RDI ; x position    
    imul    rcx, BYTES_PER_PIXEL
    add     rcx, RDX ; dest_bitmap
    add     rcx, HEADER_SIZE

    mov     byte [rcx+0], 0x00          ;BLUE
    mov     byte [rcx+1], 0x00          ;GREEN
    mov     byte [rcx+2], 0x00          ;RED

set_pixel_fin:
    pop     rdx
    pop     rcx
    pop     rbp

    ret








