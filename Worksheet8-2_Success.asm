TITLE ASM 32-bit Template

; Description: Worksheet 8, number 2
; Author: Amanda Steidl
; Date: Nov. 8, 2014

INCLUDE Irvine32.inc


.data
	outMsg		BYTE	"Your fraction reduces to: ",0
	welcomeMsg	BYTE	"Welcome to the Fraction Reducer!" , 0
	MsgInput1	BYTE	"Please input the numerator positive integer(at most a 16-bit): ", 0
	userInput1	WORD	?
	MsgInput2	BYTE	"Please input the denominator at most positive integer(at most a 16-bit): ", 0
	userInput2	WORD	?
	denError	BYTE	"ERROR: You cannot divide by 0! Answer is undefined!",0
	numError	BYTE	"Zero divided by any number is 0" , 0

	
.code


main PROC
	Call ClrScr
	MOV EDX, OFFSET welcomeMsg
	Call WriteString
	Call Crlf

	MOV EDX, OFFSET MsgInput1
	Call WriteString
	Call ReadDec
	MOV userInput1, AX

	MOV EDX, OFFSET MsgInput2
	Call WriteString
	Call ReadDec
	MOV userInput2, AX
	MOV BX, AX					;BX now has second input
	MOV AX, userInput1			;AX now has first input
	;----------------------------
	;"Idiot-Proofing" comparisons
	;----------------------------
	
	;Check if the numerator is 0... answer will be zero
	CMP AX, 0
	JE displayNumError

	;Check if the denominator is 0... answer is undefined
	CMP BX, 0
	JNE compareValue

	;"ERROR" messages
	MOV EDX, OFFSET denError
	Call WriteString
	Call Crlf
	JMP exit_
	displayNumError:
	MOV EDX, OFFSET numError
	Call WriteString
	Call Crlf
	JMP exit_

	;----------------------------
	;Set-Up Proc
	;----------------------------
	compareValue:
	MOV EDX, OFFSET outMsg
	CMP AX, BX
	JAE startProcInput2
	
	MOVZX ECX, AX
	JMP proc_

	startProcInput2:
	MOVZX ECX, BX

	proc_:
	Call reduceFraction
	
	exit_:
EXIT
main ENDP


;----------------------------------------------------------------------------
;Description: Reduces fraction if needed. Outputs.
;Recieves: Counter for loop in ECX, AX contains user input1, BX contains user input 2
;			Offset outMsg EDX
;Returns: nothing
;----------------------------------------------------------------------------
reduceFraction PROC

	PUSH EDI
	PUSH ESI
	PUSH EDX
		L1:
			MOV DX, 0
			;AX currently has userInput1
			PUSH EAX	;will save input1
				DIV CX
				CMP DX, 0
				MOV SI, AX	;saves the quotient of first in SI
			POP EAX
				JNE endLoop

			MOV DX, 0
			PUSH EAX	;will save input1
				MOV AX, BX
				DIV CX
				CMP DX, 0
				MOV DI, AX	;saves the quotient of second in DI
			POP EAX		;returns value input1 into AX
			JE output

			;if not equal, move correct output
			MOV SI, AX			;input value 1
			MOV	DI, BX			;input value 2


			endLoop:
		LOOP L1

		output:
	POP EDX
		Call WriteString
	
		MOV AX, SI
		Call WriteDec
		MOV AL, 2Fh
		Call WriteChar

		MOV AX, DI
		Call WriteDec
		Call Crlf

	POP ESI
	POP EDI
RET
reduceFraction ENDP

end main