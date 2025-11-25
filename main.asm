TITLE NumeraX - Number System Converter
INCLUDE Irvine32.inc

; ============================
; DATA SECTION
; ============================
.data

; ----- Main Menu Text -----
menuTitle   BYTE "=== NumeraX: Number System Converter ===",0
menuOptions BYTE \
    "1. Decimal to Binary",0Dh,0Ah,\
    "2. Decimal to Octal",0Dh,0Ah,\
    "3. Decimal to Hexadecimal",0Dh,0Ah,\
    "4. Binary to Decimal",0Dh,0Ah,\
    "5. Octal to Decimal",0Dh,0Ah,\
    "6. Hexadecimal to Decimal",0Dh,0Ah,\
    "7. Binary <-> Octal / Hexadecimal (Direct Conversions)",0Dh,0Ah,\
    "8. Two's Complement (Binary)",0Dh,0Ah,\
    "9. Quiz Mode",0Dh,0Ah,\
    "10. Speed Test Mode",0Dh,0Ah,\
    "11. Exit",0Dh,0Ah,0

choiceMsg   BYTE "Enter your choice: ",0
invalidMsg  BYTE "Invalid choice. Try again.",0
goodbyeMsg  BYTE "Exiting program... Goodbye!",0

; ----- Direct Conversions Menu -----
directMenuTitle BYTE "=== Direct Conversions ===",0
directMenu BYTE \
    "1. Binary to Octal",0Dh,0Ah,\
    "2. Binary to Hexadecimal",0Dh,0Ah,\
    "3. Octal to Binary",0Dh,0Ah,\
    "4. Hexadecimal to Binary",0Dh,0Ah,\
    "5. Back to Main Menu",0Dh,0Ah,0
directChoice BYTE "Choose conversion type: ",0

; ----- Prompts -----
decPrompt   BYTE "Enter decimal number: ",0
binPrompt   BYTE "Enter binary number: ",0
octPrompt   BYTE "Enter octal number: ",0
hexPrompt   BYTE "Enter hexadecimal number: ",0

; Two's complement prompts
tcPrompt    BYTE "Enter binary number (up to 32 bits): ",0
tcResultMsg BYTE "Two's complement: ",0

; General buffers
inputStr    BYTE 33 DUP(0)     ; user input string
outStr      BYTE 33 DUP(0)     ; result string for conversions
tempStr     BYTE 33 DUP(0)

; For decimal I/O
userChoice  DWORD ?
tempVal     DWORD ?

; ============================
; QUIZ / SPEED TEST DATA
; ============================

quizTitle       BYTE "=== QUIZ MODE ===",0
speedTitle      BYTE "=== SPEED TEST MODE ===",0

quizTypeMenu    BYTE \
 "1. Random Questions (all types)",0Dh,0Ah,\
 "2. Specific Conversion Type",0Dh,0Ah,\
 "3. Back to Main Menu",0Dh,0Ah,0

quizTypePrompt  BYTE "Choose quiz type: ",0

; specific conversion types: 1..12
specificTypeMenu1 BYTE \
 "=== Select Conversion Type ===",0Dh,0Ah,\
 " 1. Decimal to Binary",0Dh,0Ah,\
 " 2. Decimal to Octal",0Dh,0Ah,\
 " 3. Decimal to Hexadecimal",0Dh,0Ah,\
 " 4. Binary to Decimal",0Dh,0Ah,\
 " 5. Binary to Octal",0Dh,0Ah,\
 " 6. Binary to Hexadecimal",0Dh,0Ah, 0
specificTypeMenu2 BYTE \
 " 7. Octal to Decimal",0Dh,0Ah,\
 " 8. Octal to Binary",0Dh,0Ah,\
 " 9. Octal to Hexadecimal",0Dh,0Ah,\
 "10. Hexadecimal to Decimal",0Dh,0Ah,\
 "11. Hexadecimal to Binary",0Dh,0Ah,\
 "12. Hexadecimal to Octal",0Dh,0Ah,\
 "13. Back to Quiz Menu",0Dh,0Ah,0

promptNumQuestions BYTE "Enter number of questions: ",0
progressMsg    BYTE "Question ",0
ofMsg          BYTE " of ",0
userAnswerPrompt BYTE "Your answer: ",0
quizCorrectMsg BYTE "Correct!",0
quizWrongMsg   BYTE "Wrong. Correct answer: ",0
scoreMsg       BYTE "Final score: ",0
outOfMsg       BYTE " out of ",0
percentMsg     BYTE " (",0
percentSuffix  BYTE "%)",0
timeMsg        BYTE "Time taken (ms): ",0
playAgainPrompt BYTE "Play again? (1=Yes,2=No): ",0

; question description lines:
qTextDecBin BYTE "Convert decimal to binary: ",0
qTextDecOct BYTE "Convert decimal to octal: ",0
qTextDecHex BYTE "Convert decimal to hexadecimal: ",0
qTextBinDec BYTE "Convert binary to decimal: ",0
qTextBinOct BYTE "Convert binary to octal: ",0
qTextBinHex BYTE "Convert binary to hexadecimal: ",0
qTextOctDec BYTE "Convert octal to decimal: ",0
qTextOctBin BYTE "Convert octal to binary: ",0
qTextOctHex BYTE "Convert octal to hexadecimal: ",0
qTextHexDec BYTE "Convert hexadecimal to decimal: ",0
qTextHexBin BYTE "Convert hexadecimal to binary: ",0
qTextHexOct BYTE "Convert hexadecimal to octal: ",0

; quiz state
numQuestions    DWORD 0
correctAnswers  DWORD 0
questionType    DWORD 0     ; 1..12, or 0 = random
isSpeedTest     DWORD 0     ; 0 = normal quiz, 1 = speed test
startTime       DWORD 0
endTime         DWORD 0

; ============================
; CODE SECTION
; ============================
.code

ClearBuffer PROC
    push eax
    xor eax,eax
CLB1:
    mov [edi],al
    inc edi
    loop CLB1
    pop eax
    ret
ClearBuffer ENDP

ReadLineIntoInputStr PROC
    mov edx, OFFSET inputStr
    mov ecx, SIZEOF inputStr
    call ReadString
    ret
ReadLineIntoInputStr ENDP

ParseBinary PROC
    push ebx
    push esi
    mov esi, OFFSET inputStr
    xor eax,eax  
PB_L1:
    mov bl,[esi]
    cmp bl,0
    je PB_OK 
    cmp bl,'0'
    jb PB_ERR 
    cmp bl,'1'
    ja PB_ERR
    shl eax,1
    sub bl,'0'
    movzx ebx, bl        
    add eax,ebx          
    inc esi
    jmp PB_L1
PB_ERR:
    stc
    jmp PB_DONE
PB_OK:
    clc
PB_DONE:
    pop esi
    pop ebx
    ret
ParseBinary ENDP

ParseOctal PROC
    push ebx
    push esi
    mov esi, OFFSET inputStr
    xor eax,eax 
PO_L1:
    mov bl,[esi]
    cmp bl,0
    je PO_OK 
    cmp bl,'0'
    jb PO_ERR
    cmp bl,'7'
    ja PO_ERR
    sub bl,'0'           
    movzx ebx, bl
    mov edx,8
    mul edx
    add eax,ebx
    inc esi
    jmp PO_L1
PO_ERR:
    stc
    jmp PO_DONE
PO_OK:
    clc
PO_DONE:
    pop esi
    pop ebx
    ret
ParseOctal ENDP

ParseHex PROC
    push ebx
    push esi
    mov esi, OFFSET inputStr
    xor eax,eax
PH_L1:
    mov bl,[esi]
    cmp bl,0
    je PH_OK
    cmp bl,'a'
    jb PH_SKIPLOW
    cmp bl,'f'
    ja PH_SKIPLOW
    sub bl,32
PH_SKIPLOW:
    cmp bl,'0'
    jb PH_ERR
    cmp bl,'9'
    jbe PH_DIG
    cmp bl,'A'
    jb PH_ERR
    cmp bl,'F'
    ja PH_ERR
    sub bl,'A'
    add bl,10
    jmp PH_ADD
PH_DIG:
    sub bl,'0'
PH_ADD:
    movzx ebx, bl
    shl eax,4
    add eax,ebx
    inc esi
    jmp PH_L1
PH_ERR:
    stc
    jmp PH_DONE
PH_OK:
    clc
PH_DONE:
    pop esi
    pop ebx
    ret
ParseHex ENDP


DecToBinStr PROC
    pushad
    mov ebx,eax
    mov edi, OFFSET outStr
    mov ecx, SIZEOF outStr
    call ClearBuffer

    mov edi, OFFSET outStr
    add edi,31
    mov BYTE PTR [edi],0
    dec edi

    mov ecx,32
DTB_L1:
    mov eax,ebx
    and eax,1
    add al,'0'
    mov [edi],al
    shr ebx,1
    dec edi
    loop DTB_L1
    mov esi, OFFSET outStr
DTB_FIND1:
    mov al,[esi]
    cmp al,'0'
    jne DTB_COPY
    cmp BYTE PTR [esi+1],0
    je DTB_COPY
    inc esi
    jmp DTB_FIND1
DTB_COPY:
    mov edi, OFFSET outStr
DTB_COPY_L:
    mov al,[esi]
    mov [edi],al
    inc esi
    inc edi
    cmp al,0
    jne DTB_COPY_L

    popad
    ret
DecToBinStr ENDP

DecToOctStr PROC
    pushad
    mov ebx,eax
    mov edi, OFFSET outStr
    mov ecx, SIZEOF outStr
    call ClearBuffer

    mov edi, OFFSET outStr
    add edi,31
    mov BYTE PTR [edi],0
    dec edi

DTO_L1:
    mov eax,ebx
    xor edx,edx
    mov ecx,8
    div ecx
    add dl,'0'
    mov [edi],dl
    mov ebx,eax
    cmp ebx,0
    jne DTO_CONT
    jmp DTO_SHIFT
DTO_CONT:
    dec edi
    jmp DTO_L1

DTO_SHIFT:
    mov esi,edi
    mov edi, OFFSET outStr
DTO_SH2:
    mov al,[esi]
    mov [edi],al
    inc esi
    inc edi
    cmp al,0
    jne DTO_SH2

    popad
    ret
DecToOctStr ENDP

DecToHexStr PROC
    pushad
    mov ebx,eax
    mov edi, OFFSET outStr
    mov ecx, SIZEOF outStr
    call ClearBuffer

    mov edi, OFFSET outStr
    add edi,31
    mov BYTE PTR [edi],0
    dec edi

DTH_L1:
    mov eax,ebx
    xor edx,edx
    mov ecx,16
    div ecx
    mov dl,dl
    cmp dl,9
    jbe DTH_DIG
    add dl,7
DTH_DIG:
    add dl,'0'
    mov [edi],dl
    mov ebx,eax
    cmp ebx,0
    jne DTH_CONT
    jmp DTH_SHIFT
DTH_CONT:
    dec edi
    jmp DTH_L1

DTH_SHIFT:
    mov esi,edi
    mov edi, OFFSET outStr
DTH_SH2:
    mov al,[esi]
    mov [edi],al
    inc esi
    inc edi
    cmp al,0
    jne DTH_SH2

    popad
    ret
DecToHexStr ENDP

; ----- Decimal to Binary -----
DoDecToBin PROC
    mov edx, OFFSET decPrompt
    call WriteString
    call ReadInt 
    call DecToBinStr
    mov edx, OFFSET outStr
    call WriteString
    call Crlf
    ret
DoDecToBin ENDP

; ----- Decimal to Octal -----
DoDecToOct PROC
    mov edx, OFFSET decPrompt
    call WriteString
    call ReadInt
    call DecToOctStr
    mov edx, OFFSET outStr
    call WriteString
    call Crlf
    ret
DoDecToOct ENDP

; ----- Decimal to Hex -----
DoDecToHex PROC
    mov edx, OFFSET decPrompt
    call WriteString
    call ReadInt
    call DecToHexStr
    mov edx, OFFSET outStr
    call WriteString
    call Crlf
    ret
DoDecToHex ENDP

; ----- Binary to Decimal -----
DoBinToDec PROC
    mov edx, OFFSET binPrompt
    call WriteString
    call ReadLineIntoInputStr
    call ParseBinary
    jc BTD_ERR
    call WriteDec
    call Crlf
    ret
BTD_ERR:
    mov edx, OFFSET invalidMsg
    call WriteString
    call Crlf
    ret
DoBinToDec ENDP

; ----- Octal to Decimal -----
DoOctToDec PROC
    mov edx, OFFSET octPrompt
    call WriteString
    call ReadLineIntoInputStr
    call ParseOctal
    jc OTD_ERR
    call WriteDec
    call Crlf
    ret
OTD_ERR:
    mov edx, OFFSET invalidMsg
    call WriteString
    call Crlf
    ret
DoOctToDec ENDP

; ----- Hex to Decimal -----
DoHexToDec PROC
    mov edx, OFFSET hexPrompt
    call WriteString
    call ReadLineIntoInputStr
    call ParseHex
    jc HTD_ERR
    call WriteDec
    call Crlf
    ret
HTD_ERR:
    mov edx, OFFSET invalidMsg
    call WriteString
    call Crlf
    ret
DoHexToDec ENDP

; ----- Direct Conversions -----
; BINARY -> OCTAL
DoBinToOct PROC
    mov edx, OFFSET binPrompt
    call WriteString
    call ReadLineIntoInputStr
    call ParseBinary
    jc DBTO_ERR
    call DecToOctStr
    mov edx, OFFSET outStr
    call WriteString
    call Crlf
    ret
DBTO_ERR:
    mov edx, OFFSET invalidMsg
    call WriteString
    call Crlf
    ret
DoBinToOct ENDP

; BINARY -> HEX
DoBinToHex PROC
    mov edx, OFFSET binPrompt
    call WriteString
    call ReadLineIntoInputStr
    call ParseBinary
    jc DBTH_ERR
    call DecToHexStr
    mov edx, OFFSET outStr
    call WriteString
    call Crlf
    ret
DBTH_ERR:
    mov edx, OFFSET invalidMsg
    call WriteString
    call Crlf
    ret
DoBinToHex ENDP

; OCTAL -> BINARY
DoOctToBin PROC
    mov edx, OFFSET octPrompt
    call WriteString
    call ReadLineIntoInputStr
    call ParseOctal
    jc DOTB_ERR
    call DecToBinStr
    mov edx, OFFSET outStr
    call WriteString
    call Crlf
    ret
DOTB_ERR:
    mov edx, OFFSET invalidMsg
    call WriteString
    call Crlf
    ret
DoOctToBin ENDP

; HEX -> BINARY
DoHexToBin PROC
    mov edx, OFFSET hexPrompt
    call WriteString
    call ReadLineIntoInputStr
    call ParseHex
    jc DHTB_ERR
    call DecToBinStr
    mov edx, OFFSET outStr
    call WriteString
    call Crlf
    ret
DHTB_ERR:
    mov edx, OFFSET invalidMsg
    call WriteString
    call Crlf
    ret
DoHexToBin ENDP

; ============================
; TWO'S COMPLEMENT (BINARY)
; ============================
TwosComplement PROC
    ; read and validate binary
    mov edx, OFFSET tcPrompt
    call WriteString
    call ReadLineIntoInputStr
    call ParseBinary
    jc TC_ERR 

    mov esi, OFFSET inputStr
TC_INV:
    mov al,[esi]
    cmp al,0
    je TC_ADD1
    cmp al,'0'
    je TC_MAKE1
    cmp al,'1'
    je TC_MAKE0
    jmp TC_ERR
TC_MAKE1:
    mov BYTE PTR [esi],'1'
    jmp TC_NEXT
TC_MAKE0:
    mov BYTE PTR [esi],'0'
TC_NEXT:
    inc esi
    jmp TC_INV

TC_ADD1:
    dec esi       
    mov bl,1     
TC_ADDL:
    cmp esi, OFFSET inputStr
    jb TC_DONEADD
    mov al,[esi]
    cmp al,'0'
    je TC_ZERO
    ; currently '1'
    cmp bl,1
    jne TC_NOCH
    mov BYTE PTR [esi],'0'
    jmp TC_MOVELEFT
TC_ZERO:
    cmp bl,1
    jne TC_NOCH
    mov BYTE PTR [esi],'1'
    mov bl,0
TC_NOCH:
TC_MOVELEFT:
    dec esi
    jmp TC_ADDL

TC_DONEADD:
    mov edx, OFFSET tcResultMsg
    call WriteString
    mov edx, OFFSET inputStr
    call WriteString
    call Crlf
    ret

TC_ERR:
    mov edx, OFFSET invalidMsg
    call WriteString
    call Crlf
    ret
TwosComplement ENDP

; ============================
; DIRECT CONVERSIONS MENU
; ============================
DirectConversionsMenu PROC
DCLoop:
    call Crlf
    mov edx, OFFSET directMenuTitle
    call WriteString
    call Crlf
    mov edx, OFFSET directMenu
    call WriteString
    mov edx, OFFSET directChoice
    call WriteString
    call ReadInt
    mov userChoice,eax

    cmp eax,1
    je DC_BinOct
    cmp eax,2
    je DC_BinHex
    cmp eax,3
    je DC_OctBin
    cmp eax,4
    je DC_HexBin
    cmp eax,5
    je DC_Exit

    mov edx, OFFSET invalidMsg
    call WriteString
    call Crlf
    jmp DCLoop

DC_BinOct:
    call DoBinToOct
    jmp DCLoop
DC_BinHex:
    call DoBinToHex
    jmp DCLoop
DC_OctBin:
    call DoOctToBin
    jmp DCLoop
DC_HexBin:
    call DoHexToBin
    jmp DCLoop

DC_Exit:
    ret
DirectConversionsMenu ENDP

; ============================
; QUIZ / SPEED TEST CORE
; ============================

; AskQuestion
; IN: EAX = questionType (1..12)
; OUT: increments correctAnswers on success
AskQuestion PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    mov ebx,eax

    mov eax,256
    call RandomRange
    mov tempVal,eax

    cmp ebx,1
    je Q_DecBin
    cmp ebx,2
    je Q_DecOct
    cmp ebx,3
    je Q_DecHex
    cmp ebx,4
    je Q_BinDec
    cmp ebx,5
    je Q_BinOct
    cmp ebx,6
    je Q_BinHex
    cmp ebx,7
    je Q_OctDec
    cmp ebx,8
    je Q_OctBin
    cmp ebx,9
    je Q_OctHex
    cmp ebx,10
    je Q_HexDec
    cmp ebx,11
    je Q_HexBin
    ; else 12
    jmp Q_HexOct

; ----- 1: Decimal to Binary -----
Q_DecBin:
    mov edx, OFFSET qTextDecBin
    call WriteString
    mov eax,tempVal
    call WriteDec
    call Crlf

    mov edx, OFFSET userAnswerPrompt
    call WriteString
    call ReadLineIntoInputStr
    call ParseBinary      
    jc Q_WrongNoShow      

    mov ebx,tempVal
    cmp eax,ebx
    jne Q_WrongShowBin
    jmp Q_Correct

Q_WrongShowBin:
    mov edx, OFFSET quizWrongMsg
    call WriteString
    mov eax,tempVal
    call DecToBinStr
    mov edx, OFFSET outStr
    call WriteString
    call Crlf
    jmp Q_End

; ----- 2: Decimal to Octal -----
Q_DecOct:
    mov edx, OFFSET qTextDecOct
    call WriteString
    mov eax,tempVal
    call WriteDec
    call Crlf

    mov edx, OFFSET userAnswerPrompt
    call WriteString
    call ReadLineIntoInputStr
    call ParseOctal
    jc Q_WrongNoShow

    mov ebx,tempVal
    cmp eax,ebx
    jne Q_WrongShowOct
    jmp Q_Correct

Q_WrongShowOct:
    mov edx, OFFSET quizWrongMsg
    call WriteString
    mov eax,tempVal
    call DecToOctStr
    mov edx, OFFSET outStr
    call WriteString
    call Crlf
    jmp Q_End

; ----- 3: Decimal to Hex -----
Q_DecHex:
    mov edx, OFFSET qTextDecHex
    call WriteString
    mov eax,tempVal
    call WriteDec
    call Crlf

    mov edx, OFFSET userAnswerPrompt
    call WriteString
    call ReadLineIntoInputStr
    call ParseHex
    jc Q_WrongNoShow

    mov ebx,tempVal
    cmp eax,ebx
    jne Q_WrongShowHex
    jmp Q_Correct

Q_WrongShowHex:
    mov edx, OFFSET quizWrongMsg
    call WriteString
    mov eax,tempVal
    call DecToHexStr
    mov edx, OFFSET outStr
    call WriteString
    call Crlf
    jmp Q_End

; ----- 4: Binary to Decimal -----
Q_BinDec:
    ; Generate binary from decimal tempVal
    mov eax,tempVal
    call DecToBinStr
    mov edx, OFFSET qTextBinDec
    call WriteString
    mov edx, OFFSET outStr
    call WriteString
    call Crlf

    mov edx, OFFSET userAnswerPrompt
    call WriteString
    call ReadInt         
    mov ebx,tempVal
    cmp eax,ebx
    jne Q_WrongShowInt
    jmp Q_Correct

Q_WrongShowInt:
    mov edx, OFFSET quizWrongMsg
    call WriteString
    mov eax,tempVal
    call WriteDec
    call Crlf
    jmp Q_End

; ----- 5: Binary to Octal -----
Q_BinOct:
    mov eax,tempVal
    call DecToBinStr
    mov edx, OFFSET qTextBinOct
    call WriteString
    mov edx, OFFSET outStr
    call WriteString
    call Crlf

    mov edx, OFFSET userAnswerPrompt
    call WriteString
    call ReadLineIntoInputStr
    call ParseOctal
    jc Q_WrongNoShow

    mov ebx,tempVal
    cmp eax,ebx
    jne Q_WrongShowOct
    jmp Q_Correct

; ----- 6: Binary to Hex -----
Q_BinHex:
    mov eax,tempVal
    call DecToBinStr
    mov edx, OFFSET qTextBinHex
    call WriteString
    mov edx, OFFSET outStr
    call WriteString
    call Crlf

    mov edx, OFFSET userAnswerPrompt
    call WriteString
    call ReadLineIntoInputStr
    call ParseHex
    jc Q_WrongNoShow

    mov ebx,tempVal
    cmp eax,ebx
    jne Q_WrongShowHex
    jmp Q_Correct

; ----- 7: Octal to Decimal -----
Q_OctDec:
    mov eax,tempVal
    call DecToOctStr
    mov edx, OFFSET qTextOctDec
    call WriteString
    mov edx, OFFSET outStr
    call WriteString
    call Crlf

    mov edx, OFFSET userAnswerPrompt
    call WriteString
    call ReadInt
    mov ebx,tempVal
    cmp eax,ebx
    jne Q_WrongShowInt
    jmp Q_Correct

; ----- 8: Octal to Binary -----
Q_OctBin:
    mov eax,tempVal
    call DecToOctStr
    mov edx, OFFSET qTextOctBin
    call WriteString
    mov edx, OFFSET outStr
    call WriteString
    call Crlf

    mov edx, OFFSET userAnswerPrompt
    call WriteString
    call ReadLineIntoInputStr
    call ParseBinary
    jc Q_WrongNoShow

    mov ebx,tempVal
    cmp eax,ebx
    jne Q_WrongShowBin
    jmp Q_Correct

; ----- 9: Octal to Hex -----
Q_OctHex:
    mov eax,tempVal
    call DecToOctStr
    mov edx, OFFSET qTextOctHex
    call WriteString
    mov edx, OFFSET outStr
    call WriteString
    call Crlf

    mov edx, OFFSET userAnswerPrompt
    call WriteString
    call ReadLineIntoInputStr
    call ParseHex
    jc Q_WrongNoShow

    mov ebx,tempVal
    cmp eax,ebx
    jne Q_WrongShowHex
    jmp Q_Correct

; ----- 10: Hex to Decimal -----
Q_HexDec:
    mov eax,tempVal
    call DecToHexStr
    mov edx, OFFSET qTextHexDec
    call WriteString
    mov edx, OFFSET outStr
    call WriteString
    call Crlf

    mov edx, OFFSET userAnswerPrompt
    call WriteString
    call ReadInt
    mov ebx,tempVal
    cmp eax,ebx
    jne Q_WrongShowInt
    jmp Q_Correct

; ----- 11: Hex to Binary -----
Q_HexBin:
    mov eax,tempVal
    call DecToHexStr
    mov edx, OFFSET qTextHexBin
    call WriteString
    mov edx, OFFSET outStr
    call WriteString
    call Crlf

    mov edx, OFFSET userAnswerPrompt
    call WriteString
    call ReadLineIntoInputStr
    call ParseBinary
    jc Q_WrongNoShow

    mov ebx,tempVal
    cmp eax,ebx
    jne Q_WrongShowBin
    jmp Q_Correct

; ----- 12: Hex to Octal -----
Q_HexOct:
    mov eax,tempVal
    call DecToHexStr
    mov edx, OFFSET qTextHexOct
    call WriteString
    mov edx, OFFSET outStr
    call WriteString
    call Crlf

    mov edx, OFFSET userAnswerPrompt
    call WriteString
    call ReadLineIntoInputStr
    call ParseOctal
    jc Q_WrongNoShow

    mov ebx,tempVal
    cmp eax,ebx
    jne Q_WrongShowOct
    jmp Q_Correct

; ----- Shared branches -----
Q_WrongNoShow:
    mov edx, OFFSET quizWrongMsg
    call WriteString
    call Crlf
    jmp Q_End

Q_Correct:
    mov edx, OFFSET quizCorrectMsg
    call WriteString
    call Crlf
    ; increment correctAnswers
    mov eax, correctAnswers
    inc eax
    mov correctAnswers,eax

Q_End:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
AskQuestion ENDP

RunQuizCore PROC
    ; Choose quiz type
QuizTypeLoop:
    call Crlf
    mov edx, OFFSET quizTypeMenu
    call WriteString
    mov edx, OFFSET quizTypePrompt
    call WriteString
    call ReadInt
    mov userChoice,eax

    cmp eax,1
    je QT_Random
    cmp eax,2
    je QT_Specific
    cmp eax,3
    je QT_Back
    mov edx, OFFSET invalidMsg
    call WriteString
    call Crlf
    jmp QuizTypeLoop

QT_Random:
    mov questionType,0
    jmp QT_NextStep

QT_Specific:
SpecificLoop:
    call Crlf
    mov edx, OFFSET specificTypeMenu1
    call WriteString
    mov edx, OFFSET specificTypeMenu2
    call WriteString
    mov edx, OFFSET quizTypePrompt
    call WriteString
    call ReadInt
    mov userChoice,eax
    cmp eax,13
    je QuizTypeLoop
    cmp eax,1
    jl SpecificLoop
    cmp eax,12
    jg SpecificLoop
    mov questionType,eax
    jmp QT_NextStep

QT_Back:
    ret

QT_NextStep:
    ; Ask num questions
    mov edx, OFFSET promptNumQuestions
    call WriteString
    call ReadInt
    mov numQuestions,eax

    mov correctAnswers,0

    mov eax,isSpeedTest
    cmp eax,0
    je QNoTime
    call GetMseconds
    mov startTime,eax
QNoTime:
    mov ecx,numQuestions
    mov ebx,0
QLoop:
    inc ebx

    mov edx, OFFSET progressMsg
    call WriteString
    mov eax,ebx
    call WriteDec
    mov edx, OFFSET ofMsg
    call WriteString
    mov eax,numQuestions
    call WriteDec
    call Crlf

    mov eax,questionType
    cmp eax,0
    jne UseFixed
    mov eax,12
    call RandomRange
    inc eax
UseFixed:
    call AskQuestion

    call Crlf
    loop QLoop

    mov eax,isSpeedTest
    cmp eax,0
    je QNoEndTime
    call GetMseconds
    mov endTime,eax
QNoEndTime:
    mov edx, OFFSET scoreMsg
    call WriteString
    mov eax,correctAnswers
    call WriteDec
    mov edx, OFFSET outOfMsg
    call WriteString
    mov eax,numQuestions
    call WriteDec

    mov eax,correctAnswers
    mov ebx,100
    mul ebx 
    mov ebx,numQuestions
    xor edx,edx
    div ebx  
    mov edx, OFFSET percentMsg
    call WriteString
    call WriteDec
    mov edx, OFFSET percentSuffix
    call WriteString
    call Crlf

    mov eax,isSpeedTest
    cmp eax,0
    je SkipTime
    mov eax,endTime
    sub eax,startTime
    mov edx, OFFSET timeMsg
    call WriteString
    call WriteDec
    call Crlf
SkipTime:
PlayAgainLoop:
    mov edx, OFFSET playAgainPrompt
    call WriteString
    call ReadInt
    cmp eax,1
    je RunQuizCore
    cmp eax,2
    je PQ_Done
    mov edx, OFFSET invalidMsg
    call WriteString
    call Crlf
    jmp PlayAgainLoop

PQ_Done:
    ret
RunQuizCore ENDP

; ----- QuizMode: uses RunQuizCore with timer off -----
QuizMode PROC
    mov isSpeedTest,0
    mov edx, OFFSET quizTitle
    call WriteString
    call Crlf
    call RunQuizCore
    ret
QuizMode ENDP

; ----- SpeedTestMode: uses RunQuizCore with timer on -----
SpeedTestMode PROC
    mov isSpeedTest,1
    mov edx, OFFSET speedTitle
    call WriteString
    call Crlf
    call RunQuizCore
    ret
SpeedTestMode ENDP

; ============================
; MAIN PROGRAM
; ============================
main PROC
    call Clrscr
    call Randomize

MainMenuLoop:
    call Crlf
    mov edx, OFFSET menuTitle
    call WriteString
    call Crlf
    mov edx, OFFSET menuOptions
    call WriteString
    mov edx, OFFSET choiceMsg
    call WriteString
    call ReadInt
    mov userChoice,eax

    cmp eax,1
    je MM_DecBin
    cmp eax,2
    je MM_DecOct
    cmp eax,3
    je MM_DecHex
    cmp eax,4
    je MM_BinDec
    cmp eax,5
    je MM_OctDec
    cmp eax,6
    je MM_HexDec
    cmp eax,7
    je MM_Direct
    cmp eax,8
    je MM_Twos
    cmp eax,9
    je MM_Quiz
    cmp eax,10
    je MM_Speed
    cmp eax,11
    je MM_Exit

    mov edx, OFFSET invalidMsg
    call WriteString
    call Crlf
    jmp MainMenuLoop

MM_DecBin:
    call DoDecToBin
    jmp MainMenuLoop
MM_DecOct:
    call DoDecToOct
    jmp MainMenuLoop
MM_DecHex:
    call DoDecToHex
    jmp MainMenuLoop
MM_BinDec:
    call DoBinToDec
    jmp MainMenuLoop
MM_OctDec:
    call DoOctToDec
    jmp MainMenuLoop
MM_HexDec:
    call DoHexToDec
    jmp MainMenuLoop
MM_Direct:
    call DirectConversionsMenu
    jmp MainMenuLoop
MM_Twos:
    call TwosComplement
    jmp MainMenuLoop
MM_Quiz:
    call QuizMode
    jmp MainMenuLoop
MM_Speed:
    call SpeedTestMode
    jmp MainMenuLoop

MM_Exit:
    mov edx, OFFSET goodbyeMsg
    call WriteString
    call Crlf
    exit
main ENDP

END main
