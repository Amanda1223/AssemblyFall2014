TITLE ASM 32-bit Template

; Description: Worksheet 8, number 3
; Author: Amanda Steidl
; Date: Nov. 10, 2014

INCLUDE Irvine32.inc

	A = 0
	B = 1
	C_ = 2
	D = 3
	F = 4
	

	valA = 90
	valB = 80
	valC = 70
	valD = 60
	MinGrade = 0
	toQuit = 101

	SemiColon = 3Ah
	Space = 20h

.data
	
	welMsg	BYTE	"Welcome to MASM Histogram. After entering your last score, enter 101", 0
	nxtMsg	BYTE	"Next Score? ",0
	histMsg	BYTE	"Your histogram is as follows:",0
	grdMsg	BYTE	"A (90 - 100):B  (80 - 89):C  (70 - 79):D  (60 - 69):F   (0 - 59):",0
	avgMsg	BYTE	"The average of the scores is: ", 0
	
	noGradeMsg	BYTE	"You exited the program without entering any scores.",0
	invalMsg	BYTE	"Invalid entry: Are you finished entering scores?",0
				BYTE	"(101 to exit, or press any key to continue): ",0

	indGradeCount	BYTE	0, 0, 0, 0, 0	;A, B, C, D, F
	gradeCount	BYTE	0
	sumGrades	WORD	?
	average		WORD	?

.code
main PROC

	Call ClrScr
	MOV EDX, OFFSET welMsg
	Call WriteString
	Call Crlf

	;------------------------------------------------------------
	;Initialize Next Score, etc.
	;Use first case as if the first
	;Number is 101 then noGradMsg.
	;------------------------------------------------------------

	MOV EDX, OFFSET nxtMsg
	Call WriteString
	Call ReadDec
	;--------------------
	;if AX is equal toQuit, exit program outputting
	;the noGradeMsg
	;--------------------
	CMP AX, toQuit
	JE noEntry
	JA double_check		;this is a one time call.

	;another possibility, check if gradeCount == 0 before exit loop?
	
	MOV EDX, OFFSET indGradeCount
	MOV EBX, OFFSET sumGrades
	call checkLetter
	INC gradeCount		;increases total number of grades enters

	getNumber:
		
		MOV EDX, OFFSET nxtMsg
		Call WriteString
		Call ReadDec
		CMP AX, toQuit
		JE output
		JA double_check
		MOV EDX, OFFSET indGradeCount
		MOV EBX, OFFSET sumGrades
		call checkLetter
		INC gradeCount

	LOOP getNumber

	double_check:
		MOV EDX, OFFSET invalMsg
		Call WriteString
		Call ReadDec
		CMP AX, toQuit
	JNE getNumber
	JE end_

	output:
		MOV EDX, OFFSET histMsg
		Call WriteString
		Call Crlf
		MOV EDX, OFFSET grdMsg
		MOV EBX, OFFSET indGradeCount
		Call printHist
		Call Crlf

		MOV EDX, OFFSET avgMsg
		Call WriteString
		MOV DX, 0
		MOVZX CX, gradeCount
		MOV AX, sumGrades
		DIV CX
		MOV average, AX	;just to save the average
		MOV AX, average
		Call WriteDec

	JMP end_

	noEntry:
	MOV EDX, OFFSET noGradeMsg
	Call WriteString

	end_:
	Call Crlf 

exit
main ENDP

checkLetter	PROC
;------------------------------------------------------------
	;Description: Figures out if it was an A-F entered, then
	;increments the individual grade count, and adds the number
	;to the total sum of grades accordingly
	;Recieves: OFFSET of individual grade count in EDX, [X]
	; OFFSET of the sum of all the grades in EBX [X]
	; user-entered value in AX register
	;Alters: the offsets of variables passed in at EDX, EBX, ECX
	;		according to cases
;------------------------------------------------------------
PUSH EAX
	ADD [EBX], AX

	CMP AX, valA			;I.E. AX = 75
	JAE isA					;check if : 75 >= 90 no! check next.
	CMP AX, valB
	JAE isB					;check if : 75 >= 80 no! check next
	CMP AX, valC
	JAE isC					;check if : 75 >= 70 yes!, take jmp
	CMP AX, valD
	JAE isD
	CMP AX, minGrade
	JB end_1
	;else is F : no jumps taken

		MOV AL, 1
		ADD [EDX + F], AL
		JMP end_1
	isD:
		MOV AL, 1
		ADD [EDX + D], AL
		JMP end_1
	isC:					;jmps to C, then moves 3 into BL
		MOV AL, 1
		ADD [EDX + C_], AL
		JMP end_1
	isB:
		MOV AL, 1
		ADD [EDX + B], AL
		JMP end_1
	isA:
		MOV AL, 1
		ADD [EDX + A], AL
	end_1:

POP EAX
RET
checkLetter ENDP

printHist	PROC
;------------------------------------------------------------
	;Description: prints out the histogram through loops utilizing
	;		the location of semi-colons and adding spaces.
	;Recieves: Offset of grade message [A (90-100)... etc]
	;		in EDX, and the Offset of the individual grade count
	;		in EBX
	;Alters: none.
;------------------------------------------------------------

	top:
		MOV AL, [EDX]
		CMP AL, 0
		JE end_2

		CMP AL, SemiColon
		Call WriteChar
		JE writeEndOfLine_
		INC EDX
		JMP top

	writeEndOfLine_:
		INC EDX
		
		MOV AL, Space
		Call WriteChar
		MOV AL, [EBX]
		Call WriteDec
		Call Crlf
		INC EBX
	JMP top

	end_2:
RET
printHist ENDP

END main