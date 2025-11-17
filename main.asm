TITLE NumeraX - Number System Converter
INCLUDE Irvine32.inc

.data
menuTitle   BYTE "=== NumeraX: Number System Converter ===", 0
menuOptions BYTE \
    "1. Decimal to Binary", 0Dh,0Ah,\
    "2. Decimal to Octal", 0Dh,0Ah,\
    "3. Decimal to Hexadecimal", 0Dh,0Ah,\
    "4. Binary to Decimal", 0Dh,0Ah,\
    "5. Octal to Decimal", 0Dh,0Ah,\
    "6. Hexadecimal to Decimal", 0Dh,0Ah,\
    "7. Binary <-> Octal / Hexadecimal", 0Dh,0Ah,\
    "8. Two's Complement Representation", 0Dh,0Ah,\
    "9. Quiz Mode", 0Dh,0Ah,\
    "10. Speed Test Mode", 0Dh,0Ah,\
    "11. Exit", 0Dh,0Ah,0

choice BYTE "Enter your choice: ", 0
invalidMsg  BYTE "Invalid choice. Try again.", 0
goodbyeMsg  BYTE "Exiting program... Goodbye!", 0

userChoice DWORD ?
inputBuffer BYTE 32 DUP(0)
outputBuffer BYTE 32 DUP(0)

score DWORD ?
questionCount DWORD ?
startTime DWORD ?
endTime DWORD ?


;data for TwosComplement Procedure
msg1 byte "Enter number : ",0
two_c_print byte "Two's complement : ",0
buffer byte 33 DUP(0) ,0
final byte 33 DUP(0) ,0


.code
main PROC
    call Clrscr

mainMenuLoop:
    ;display 
    mov edx, OFFSET menuTitle
    call WriteString
    call CrLf

    mov edx, OFFSET menuOptions
    call WriteString
    call CrLf

    mov edx, OFFSET choice
    call WriteString
    call ReadInt
    mov userChoice, eax

    cmp eax, 1
    je do_DecToBin
    cmp eax, 2
    je do_DecToOct
    cmp eax, 3
    je do_DecToHex
    cmp eax, 4
    je do_BinToDec
    cmp eax, 5
    je do_OctToDec
    cmp eax, 6
    je do_HexToDec
    cmp eax, 7
    je do_DirectConversions
    cmp eax, 8
    je do_TwosComplement
    cmp eax, 9
    je do_QuizMode
    cmp eax, 10
    je do_SpeedTest
    cmp eax, 11
    je ExitProgram

    ; Invalid choice
    mov edx, OFFSET invalidMsg
    call WriteString
    call CrLf
    jmp mainMenuLoop


do_DecToBin:
     call DecToBin
    jmp returnToMenu

do_DecToOct:
     call DecToOct
    jmp returnToMenu

do_DecToHex:
     call DecToHex
    jmp returnToMenu

do_BinToDec:
     call BinToDec
    jmp returnToMenu

do_OctToDec:
     call OctToDec
    jmp returnToMenu

do_HexToDec:
     call HexToDec
    jmp returnToMenu

do_DirectConversions:
     call DirectConversions
    jmp returnToMenu

do_TwosComplement:
     call TwosComplement
    jmp returnToMenu

do_QuizMode:
     call QuizMode
    jmp returnToMenu

do_SpeedTest:
     call SpeedTestMode
    jmp returnToMenu

returnToMenu:
    call CrLf
    jmp mainMenuLoop

    mov edx, OFFSET goodbyeMsg
    call WriteString
    call CrLf
    exit

main ENDP

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

TwosComplement PROC
xor eax, eax
mov edx, offset msg1 
call WriteString

mov edx,offset buffer
mov ecx,33
call ReadString

mov esi, offset buffer
mov edi, offset final

copy:
mov al, [esi]
mov [edi], al
cmp al,0
je invert
inc esi
inc edi
jmp copy

invert:
mov edi, offset final

invertloop:
mov al, [edi]
cmp al,0
je addOne
cmp al , '0'
je make1
cmp al, '1'
je make0

jmp nextInvert

make1:
mov BYTE PTR [edi], '1'
jmp nextInvert

make0:
mov BYTE PTR [edi], '0'
jmp nextInvert

nextInvert:
inc edi
jmp invertloop

addOne:
mov edi, offset final

findEnd: 
cmp BYTE PTR[edi],0
je doAdd
inc edi
jmp findEnd

doAdd:
dec edi
mov bl,1

addLoop:
cmp edi,offset final
jl doneAdd
mov al,[edi]

cmp al, '1'
je bitOne

cmp bl, 1
jne noCarry
mov BYTE PTR [edi],'1'
mov bl,0
jmp doneAdd

noCarry:
jmp doneAdd

bitOne:
cmp bl,1
jne doneAdd
mov BYTE PTR [edi], '0'
dec edi
jmp addLoop

doneAdd:
mov edx, offset two_c_print 
call WriteString
mov edx, offset final
call WriteString
call crlf
ret
TwosComplement ENDP

END main


