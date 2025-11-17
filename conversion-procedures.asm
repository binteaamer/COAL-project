; -----------------------------
; Decimal to Binary
; -----------------------------
DecToBin PROC
    ; Prompt for decimal number
    mov edx, OFFSET choice     ;Change this to print a line that shows what operation the user selected instead of just the option number
                                ;Now a print "Enter the number: "
    call WriteString
    call ReadDec       ; EAX = decimal number

    ; Convert decimal to binary
    mov ecx, 32        ; 32 bits
    mov ebx, eax       ; Save original number
    lea edi, outputBuffer
    add edi, 32        ; Point to end of buffer
    mov BYTE PTR [edi], 0
    dec edi

decToBinLoop:
    mov eax, ebx
    and eax, 1
    add al, '0'
    mov [edi], al
    shr ebx, 1
    dec edi
    loop decToBinLoop

    ; Print result
    mov edx, OFFSET outputBuffer
    call WriteString
    call CrLf
    ret
DecToBin ENDP

; -----------------------------
; Decimal to Octal
; -----------------------------
DecToOct PROC
    mov edx, OFFSET choice
    call WriteString
    call ReadInt       ; EAX = decimal number

    mov ebx, eax
    lea edi, outputBuffer
    add edi, 32
    mov BYTE PTR [edi], 0
    dec edi

decToOctLoop:
    mov eax, ebx
    mov edx, 0
    mov ecx, 8
    div ecx            ; EAX / 8, remainder in EDX
    add dl, '0'
    mov [edi], dl
    mov ebx, eax
    cmp ebx, 0
    je decToOctDone
    dec edi
    jmp decToOctLoop

decToOctDone:
    mov edx, edi
    call WriteString
    call CrLf
    ret
DecToOct ENDP

; -----------------------------
; Decimal to Hexadecimal
; -----------------------------
DecToHex PROC
    mov edx, OFFSET choice
    call WriteString
    call ReadInt       ; EAX = decimal number

    mov ebx, eax
    lea edi, outputBuffer
    add edi, 32
    mov BYTE PTR [edi], 0
    dec edi

decToHexLoop:
    mov eax, ebx
    mov edx, 0
    mov ecx, 16
    div ecx
    cmp dl, 9
    jbe decToHexDigit
    add dl, 7           ; Convert 10-15 to 'A'-'F'
decToHexDigit:
    add dl, '0'
    mov [edi], dl
    mov ebx, eax
    cmp ebx, 0
    je decToHexDone
    dec edi
    jmp decToHexLoop

decToHexDone:
    mov edx, edi
    call WriteString
    call CrLf
    ret
DecToHex ENDP

; -----------------------------
; Binary to Decimal
; -----------------------------
BinToDec PROC
    mov edx, OFFSET choice
    call WriteString
    lea edx, inputBuffer
    call ReadString

    mov esi, OFFSET inputBuffer
    xor eax, eax
    xor ebx, ebx        ; EBX = result
binToDecLoop:
    mov bl, [esi]
    cmp bl, 0
    je binToDecDone
    shl ebx, 1
    cmp bl, '1'
    jne binNext
    or ebx, 1
binNext:
    inc esi
    jmp binToDecLoop
binToDecDone:
    mov eax, ebx
    call WriteInt
    call CrLf
    ret
BinToDec ENDP

; -----------------------------
; Octal to Decimal
; -----------------------------
OctToDec PROC
    mov edx, OFFSET choice
    call WriteString
    lea edx, inputBuffer
    call ReadString

    mov esi, OFFSET inputBuffer
    xor eax, eax
    xor ebx, ebx        ; EBX = result
octToDecLoop:
    mov bl, [esi]
    cmp bl, 0
    je octToDecDone
    sub bl, '0'
    imul eax, eax, 8
    add eax, ebx
    inc esi
    jmp octToDecLoop
octToDecDone:
    call WriteInt
    call CrLf
    ret
OctToDec ENDP

; -----------------------------
; Hexadecimal to Decimal
; -----------------------------
HexToDec PROC
    mov edx, OFFSET choice
    call WriteString
    lea edx, inputBuffer
    call ReadString

    mov esi, OFFSET inputBuffer
    xor eax, eax
hexToDecLoop:
    mov bl, [esi]
    cmp bl, 0
    je hexToDecDone
    shl eax, 4
    cmp bl, '0'
    jb hexNext
    cmp bl, '9'
    jbe hexAddDigit
    cmp bl, 'A'
    jb hexNext
    cmp bl, 'F'
    jbe hexAddAlpha
    cmp bl, 'a'
    jb hexNext
    cmp bl, 'f'
    ja hexNext
    sub bl, 32           ; Convert lowercase to uppercase
hexAddAlpha:
    sub bl, 'A'
    add bl, 10
    jmp hexAdd
hexAddDigit:
    sub bl, '0'
hexAdd:
    add eax, ebx
hexNext:
    inc esi
    jmp hexToDecLoop
hexToDecDone:
    call WriteInt
    call CrLf
    ret
HexToDec ENDP
