;=====================================================================
; ECOAR - example Intel x86 assembly program
;
; Author:      Zbigniew Szymanski
; Date:        2016-03-16
; Description: Function converts first character to an 'w'.
;              int func(char *a);
;
;=====================================================================

section .data               ; Initialized data
    ; There is no initialized data to add at this time

global func
section .text

func:
    push ebp

    mov ebp, esp
    push ebx                ; Preserve ebx register
    mov eax, DWORD [ebp+8]  ;address of *a to eax
    mov esi, DWORD [ebp+8]  ; keep a copy of the address


    
    xor ecx, ecx            ;replace_count=0

loop:
    mov bl,[eax]            ;while(*a!='\0')
    cmp bl,0
    je convert

    inc eax ;increment string pointer

    inc ecx ;increment string length 

    jmp loop


convert:
    ; ecx contains the dividend (lengths)
    ; We want to divide by 3
    ; Preserve EAX value by pushing it onto the stack
    push eax

    ; Move the value in ECX to EAX for the division operation
    mov eax, ecx

    ; Load the divisor (3) into EBX
    mov ebx, 3

    ; Sign-extend EAX into EDX:EAX
    cdq

    ; Perform signed division
    idiv ebx
    ; Now EDX contains the remainder (ECX % 3)

    ; Restore the original value of EAX by popping it from the stack
    pop eax

    cmp edx, 0

    je start_lowercase
    jne start_asterix


start_asterix:

    inc edx ;increment the division reminder
	
    sub eax, edx ; sub the reminder from the current pointer because we are going backwords
    mov BYTE [eax],'*'

convert_loop:

   	sub eax, 3 ; go back 3
	cmp eax, esi
    jbe done

    mov BYTE [eax],'*'

    jmp convert_loop


start_lowercase:

    inc edx ;increment the division reminder
	
    sub eax, edx ; sub the reminder from the current pointer because we are going backwords
  
    cmp BYTE [eax],41h                 ; Test input char against lowercase 'a'
    jb  convert_lowercase_loop          ; If below 'a' in ASCII chart, not lowercase letter
    cmp BYTE [eax],5AH                 ; Test input char against lowercase 'z'
    ja  convert_lowercase_loop          ; If above 'z' in ASCII chart, not a lowercase letter 

    sub BYTE [eax],-20h                ; add 20h from the value in Buff to give an lowercase letter's ASCII code

convert_lowercase_loop:

   	sub eax, 3 ; go back 3
	cmp eax, esi
    jbe done

    cmp BYTE [eax],41h                 ; Test input char against lowercase 'a'
    jb  convert_lowercase_loop          ; If below 'a' in ASCII chart, not lowercase letter
    cmp BYTE [eax],5AH                 ; Test input char against lowercase 'z'
    ja  convert_lowercase_loop          ; If above 'z' in ASCII chart, not a lowercase letter 

    sub BYTE [eax],-20h                ; add 20h from the value in Buff to give an lowercase letter's ASCII code

    jmp convert_lowercase_loop

done:
    mov eax, ecx            ;return replace_count
    pop ebx                 ; Restore ebx register
    pop ebp
    ret                     ;return and clean the stack           
