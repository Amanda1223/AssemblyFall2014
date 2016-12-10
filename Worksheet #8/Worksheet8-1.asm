TITLE ASM 32-bit Template

; Description: Worksheet 8, number 1
; Author: Amanda Steidl
; Date: Nov. 10, 2014

INCLUDE Irvine32.inc

output_X = 30			;"column 30" - DL will be first line of output
output_Y = 10			;"row 10"	- DH will be second line of output
semi = 3Bh				;value of semi-colon in hexadecimal
multiply = 78h			;x for the multiplication in the output
space = 20h				;space character that may or may not be used in the output
equationLine = 5Fh

lowA = 0
highA = 1
lowB = 2
highB = 3

.data
	welMsg	BYTE	"64 Digit Hexadecimal Multiplier", 0
	Input_Msg	BYTE	"Low DWORD of A = ;High DWORD of A = ;Low DWORD of B = ;High DWORD of B = ;" , 0
		;semi-colons are "place" holders, they will not be printed in the output
	value	DWORD	0, 0, 0, 0
		;value @ 0 is lowA, 1 is highA, 2 is lowB, 3 is HighB
	totalProduct	DWORD	4 DUP(0)

.code
main PROC
	Call ClrScr

	MOV EDX, OFFSET welMsg
	Call WriteString
	Call Crlf
	Call Crlf

	MOV EDX, OFFSET Input_Msg
	MOV EBX, OFFSET value
	MOV ECX, LENGTHOF Input_Msg	
	read_write:
		MOV AL, [EDX]
		CMP AL, semi
		JNE write_

			Call ReadHex
			MOV [EBX], EAX
			ADD EBX, TYPE value
		JMP end_

		write_:
			MOV AL, [EDX]
			Call WriteChar
		end_:
			INC EDX
	LOOP read_write

	MOV AX, WORD PTR [value + (lowA + 2)]
	SHL EAX, (TYPE value * TYPE value)
	MOV AX, WORD PTR [value + lowA]

	MOV BX, WORD PTR [value + (lowB * (TYPE value + 1))]
	SHL EBX, (TYPE value * TYPE value)
	MOV BX, WORD PTR [value + (lowB * TYPE value)]
	

	MUL EBX
	MOV [totalProduct + (TYPE totalProduct)], EDX
	MOV [totalProduct], EAX

	MOV AX, WORD PTR [value + (TYPE value + 2)]	
	SHL EAX, (TYPE value * TYPE value)
	MOV AX, WORD PTR [value + (TYPE value)]

	MOV BX, WORD PTR [value + (lowB * (TYPE value + 1))]
	SHL EBX, (TYPE value * TYPE value)
	MOV BX, WORD PTR [value + (lowB * TYPE value)]
	MUL EBX
	;gets correct product of highA * lowB

	CLC
	ADC	[totalProduct + (TYPE totalProduct)], EAX
	ADC [totalProduct + (TYPE totalProduct * 2)], EDX
	ADC [totalProduct + (TYPE totalProduct * 3)], 0
	;NOW: correct for the TWO partial sums

	;LOW A TO BE STORED IN EAX
	MOV AX, WORD PTR [value + (lowA + 2)]
	SHL EAX, (TYPE value * TYPE value)
	MOV AX, WORD PTR [value + lowA]
	
	MOV BX, WORD PTR [value + (highB * TYPE value + 2)]
	SHL EBX, (TYPE value * TYPE value)
	MOV BX, WORD PTR [value + (highB * TYPE value)]
	MUL EBX
	;product of lowA * highB
	;NOW: "low" of LA*HB is in EAX, "high" of LA*HB is in EDX
	CLC
	ADC	[totalProduct + (TYPE totalProduct)], EAX
	ADC [totalProduct + (TYPE totalProduct * 2)], EDX
	ADC [totalProduct + (TYPE totalProduct * 3)], 0

	;NOW :correct for the THREE partial sums
	MOV AX, WORD PTR [value + (TYPE value + 2)]
	SHL EAX, (TYPE value * TYPE value)
	MOV AX, WORD PTR [value + (TYPE value)]	

	MOV BX, WORD PTR [value + (highB * TYPE value + 2)]
	SHL EBX, (TYPE value * TYPE value)
	MOV BX, WORD PTR [value + (highB * TYPE value)]
	MUL EBX
	CLC
	ADC [totalProduct + (TYPE totalProduct * 2)], EAX
	ADC [totalProduct + (TYPE totalProduct * 3)], EDX

	MOV ECX, OFFSET value
	MOV EBX, OFFSET totalProduct
	Call printMultiplication
exit
main ENDP


printMultiplication	PROC
;------------------------------------------------------------
	;Description: Prints out the multiplication "operation"
	;Recieves: Offset product in EBX, Offset of values in ECX
	;Alters: none.
;------------------------------------------------------------
PUSHAD
	MOV DL, output_X
	MOV DH, output_Y
	Call Gotoxy	
	MOV EAX, [ECX + (highA * 4)]
	Call WriteHex
	MOV EAX, [ECX + (lowA * 4)]
	Call WriteHex
	MOV DL, (output_X - 2)
	MOV DH, (output_Y + 1)
	Call Gotoxy
	MOV AL, multiply
	Call WriteChar
	MOV AL, space
	CALL WriteChar
	MOV EAX, [ECX + (highB * 4)]
	Call WriteHex
	MOV EAX, [ECX + (lowB * 4)]
	Call WriteHex
	MOV DL, output_X
	MOV DH, (output_Y + 2)
	Call Gotoxy
	MOV ECX, 16
	MOV AL, equationLine
	writeLine_:
		Call WriteChar
	LOOP writeLine_
	MOV DL, (output_X - 16)
	MOV DH, (output_Y + 3)
	Call Gotoxy
	MOV EAX, [EBX + (3*4)]
	Call WriteHex
	MOV EAX, [EBX + (2*4)]
	Call WriteHex
	MOV EAX, [EBX + (1*4)]
	Call WriteHex
	MOV EAX, [EBX]
	Call WriteHex
	
	MOV DL, 0
	MOV DH, (output_Y + 8)
	Call Gotoxy
POPAD
RET
printMultiplication ENDP

END main