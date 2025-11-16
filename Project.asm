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


