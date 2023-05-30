
section .bss
    top_checksum resd  1
    bottom_checksum resd  1
    current_point resd  1
    current_height resd  1
    character_index resd  1
    y_index resd  1
    x_index resd  1
    x_loop_limit resd  1
    y_loop_limit resd  1
    dest_bitmap_address resd  1

section .data
    bytesPerPixel       equ 3 ; The number of bytes per pixel for a 24-bit bitmap
    bmpWidth            equ 600 ; The width of the bitmap image. Replace 800 with your image's width

; Declared arrays for the barcodes
    codes db 0x3, 0x5, 0x6, 0x9, 0xA, 0xC
    bar_height db 0x3, 0xA
    special_height db 0x0, 0xA

    WIDTH equ 600
    HEIGHT equ 50
    BYTES_PER_PIXEL equ 3
    HEADER_SIZE equ 54
    SYMBOL_OFFSET equ 7
    ZERO_ASCII equ 48
    START_TOP equ 26
    START_BOTTOM equ 25

section .text
    global encodeRM4SCC

; Function to print the address, bar_width, and text passed as the first, second, and third arguments respectively, then return 0.
; Arguments:
;   dest_bitmap: a pointer to the bitmap data
;   bar_width: the width of the bar
;   text: a pointer to the text
encodeRM4SCC:
    ; Save base pointer and set up a new base pointer

    push ebp
    mov ebp, esp

    push ebx                ; Preserve ebx register

    xor ecx, ecx            ; Return code = 0
    xor ebx, ebx            ; Return code = 0





    ; mov eax, DWORD [ebp+8]  ;address of *a to eax

    ; mov edi, 20 ; x
    ; push    eax ; *dest_bitmap
    ; push    edi           ; y position
    ; push    edi  ; x position
    ; call    put_pixel
    ; add     esp, 12

    ;clear destination bitmap address
    mov dword [dest_bitmap_address], 0
    ;save first argument to destination bitmap address
    mov eax , dword [ebp+8]
    mov dword [dest_bitmap_address], eax

    mov dword  [top_checksum], 0
    mov dword  [bottom_checksum], 0
    mov dword  [current_point], 50

    ;set x_loop_limit to the value of third argument
    mov eax, dword [ebp+12]
    mov [x_loop_limit], eax


    push 0
    push 1
    push 1
    call print_top
    add esp, 12

    push 0
    push 0
    push 0
    call print_top
    add esp, 12



    mov ecx, DWORD [ebp+16] ; address of *text to ebx

    loop:

        ;char from current pointer 
        mov bl, byte [ecx]

        ;check if char is null terminator or newline
        cmp bl, 0
        je loop_end
        cmp bx, "\n"
        je loop_end

        mov edx, ZERO_ASCII



        mov al, bl
        call is_valid_character
        cmp eax, 0
        je invalid_character

        mov al, bl
        call is_uppercase_character

        cmp eax, 0
        je char_encoding

        add edx, SYMBOL_OFFSET

        
        char_encoding:

        sub ebx, edx
        mov dword  [character_index], ebx ; save character index



        ; Move the value in ECX to EAX for the division operation
        mov eax, dword  [character_index]

        ; Load the divisor (3) into EBX
        mov ebx, 6

        ; Sign-extend EAX into EDX:EAX
        cdq

        ; Perform signed division
        idiv ebx


        ; Now EAX contains the quotient 
        ; Now EDX contains the remainder 

        ; Add EAX to the top checksum
        add dword  [top_checksum], eax
        add dword  [top_checksum], 1
        ; Add EDX to the bottom checksum
        add dword  [bottom_checksum], edx
        add dword  [bottom_checksum], 1


        ; ; and prerform % 6 on the top checksum but preserve the remainder and quotient

        push edx
        push eax

        mov eax, dword  [top_checksum]
        mov ebx, 6
        cdq
        idiv ebx
        mov dword  [top_checksum], edx

        pop eax
        pop edx


        
        push edx
        push eax
        ; and prerform % 6 on the bottom checksum
        mov eax, dword  [bottom_checksum]
        mov ebx, 6
        cdq
        idiv ebx
        mov  dword  [bottom_checksum], edx

        pop eax
        pop edx


        push ecx
        ; get from the codes table the value at the index eax
        mov bl, byte [codes + eax] ; top bar
        movzx ecx, bl


        push 1
        push 1
        push ecx
        call print_top
        add esp, 12


        ; get from the codes table the value at the index edx
        mov dl, byte [codes + edx] ; bottom bar
        movzx ecx, dl

        push 1
        push 0
        push ecx
        call print_top
        add esp, 12

        pop ecx



        ; increment current pointer ebx
        inc ecx
        jmp loop

    loop_end:

    ;from the top checksum substract 1
    mov ecx, dword [top_checksum]
    ; if rcx is 0 then set it to 6
    cmp ecx, 0
    jne proces_top_checksum
    mov ecx, 6
    proces_top_checksum:
    sub ecx, 1
    ;load valie from codes of index top checksum
    mov bl, byte [codes + ecx]
    movzx ecx, bl

    ;print top checkmark
    push 1
    push 1
    push ecx
    call print_top
    add esp, 12

    ;from the bottom checksum substract 1
    mov ecx, dword [bottom_checksum]

    ; if rcx is 0 then set it to 6
    cmp ecx, 0
    jne proces_bottom_checksum
    mov ecx, 6
    proces_bottom_checksum:
 
    sub ecx, 1
    ;load valie from codes of index bottom checksum
    mov bl, byte [codes + ecx]
    movzx ecx, bl

    ;print bottom checkmark
    push 1
    push 0
    push ecx
    call print_top
    add esp, 12

    push 0
    push 1
    push 8
    call print_top
    add esp, 12

    push 0
    push 0
    push 8
    call print_top
    add esp, 12


    mov eax, 0            ;return replace_count
    pop ebx                 ; Restore ebx register
    pop ebp
    ret   

invalid_character:
    mov eax, 1            ;return replace_count

done:
    pop ebx                 ; Restore ebx register
    pop ebp
    ret                     ;return and clean the stack
    
; ============================================================================
; description: 
; 	takes in a0 the 8 byte configuration top codes
;  	takes in a2 if the bar us up or down
;   takes in a3 if the character is a end or start sign
; arguments:
; 	character
; return value: none
print_top:
push ebp
mov ebp, esp

push eax
push esi
push ecx
push edx
push ebx
push edi

xor edx, edx
xor ebx, ebx
; Get arguments from the stack
mov eax, [ebp + 8] ; first argument, s1
mov esi, dword [current_point] ; store x position , s4

; loop counter to 4
mov ecx, 4 ; s6 is ecx

loop_bit:

    ; make and of eax and 0x8 and save it to another register
    mov edi, eax ; edi is s2
    and edi, 0x8

    ; move last 8 bits from edi to edx
    mov edx, edi ; t1 is edx
    ;shift edx to the right 3 times and add 0x1
    shr edx, 3
    and edx, 0x1

    ;load value to dh address of bar_height address with offset
    xor ebx, ebx
    movzx ebx, byte [bar_height + edx]

    breakpt:

    ;if the third argument is not 0 then jum to load_height
    cmp byte [ebp + 16], 0
    jne load_height

    ;load to dh address of special_height
    xor ebx, ebx
    movzx ebx, byte [special_height + edx]


   	load_height:

    ; set edx to current_height
    mov dword [current_height], ebx
    
    ; initialize loop counter to 0 in dl


    xor dl, dl ; s7 is dl

    x_loop:

        ;initialize loop counter to 0 in dh
        xor dh, dh ; s5 is dh

        y_loop:
        ; set bl as START_TOP + dh

        push ebx

        movzx ebx, dh
        ; load value of START_TOP
        mov edi, dword START_TOP
        add edi, ebx

        ; if second argument is not 0 jump to put_in_file
        cmp byte [ebp + 12], 0
        jne put_in_file

        ; set bl as START_BOTTOM + dh
        mov edi, dword START_BOTTOM
        sub edi, ebx

        ; save the value of esi to the current_point
        mov dword [current_point], esi

        put_in_file:

        pop ebx

        ; if dh 0 jump to end_y_loop
        cmp byte [current_height], 0
        je end_y_loop

        ;push desrinaion bitmap address
        push dword [dest_bitmap_address]
        push edi
        push esi
        ; push 20
        ; push 20
        call put_pixel
        add esp, 12
        ; mov edi, 20 ; x
        ; push    eax ; *dest_bitmap
        ; push    edi           ; y position
        ; push    edi  ; x position
        ; call    put_pixel
        ; add     esp, 12

        ;increment s5
        inc dh

        ; if current height is equal to s5 jump to y_loop
        cmp byte [current_height], dh
        jne y_loop





        end_y_loop:

    ;increment s7
    inc dl
    ;increment value current_point
    inc esi
    
    ; if x_loop_limit is not equal to s7 jump to x_loop
    cmp byte [x_loop_limit], dl
    jne x_loop

    ; add to esi the bar width
    add esi, dword [x_loop_limit]

    ;shift left eax 1 time
    shl eax, 1
    ;decrement ecx
    dec ecx
    ; if ecx is not equal to 0 jump to loop_bit
    cmp ecx, 0
    jne loop_bit

;if secind argument is not 0 jump to print_top_end
cmp byte [ebp + 12], 0
jne print_top_end

; else add to current_point x_loop_limit times 2
mov ecx, [x_loop_limit]
add dword [current_point], ecx
add dword [current_point], ecx

print_top_end:
pop edi
pop ebx
pop edx
pop ecx
pop esi
pop eax
mov esp, ebp
pop ebp
ret

;=========================================================================
; function is_uppercase_character
; checks if the passed character (in al register) is uppercase
; returns 1 in eax if uppercase, else 0
is_uppercase_character:
    ; Check if the character is less than 'A'
    cmp al, 'A'
    jl .not_uppercase

    ; Check if the character is greater than 'Z'
    cmp al, 'Z'
    jg .not_uppercase

    ; If we're here, then it's an uppercase character
    mov eax, 1
    ret

.not_uppercase:
    mov eax, 0
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
    mov eax, 0
    ret

.valid:
    mov eax, 1
    ret 
    
;=========================================================================
put_pixel:
    push    ebp
    mov     ebp, esp

    push    ecx
    push    edx

    mov     ecx, [ebp+12] ; y position
    imul    ecx, WIDTH
    add     ecx, [ebp+8] ; x position    
    imul    ecx, BYTES_PER_PIXEL
    add     ecx, [ebp+16] ; dest_bitmap
    add     ecx, HEADER_SIZE

    mov     edx, 0x00000000 ; 0x00RRGGBB
    mov     [ecx], dx
    shr     edx, 16         ; 0x000000RR
    mov     [ecx + 2], dl

set_pixel_fin:
    pop     edx
    pop     ecx

    pop     ebp

    ret





