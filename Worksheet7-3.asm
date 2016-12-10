TITLE Worksheet7 

; Description: Solution for worksheet 7 number 3
; Author: Amanda Steidl
; Date: Nov. 4, 2014
; Worksheet7-2.asm
INCLUDE Irvine32.inc

Block = 0DBh
Space = 20h

BlockColor = lightGray + (16 * lightGray)
BuildColor = lightMagenta + (16 * black)
ScreenColor = black + (16 * black)
TextColor = white + (16 * black)

CornerX = 30
CornerY = 3

Window_Width = 30
Window_Height = 14

.data
	currentX_Msg BYTE	"X = 1", 0
	currentY_Msg BYTE	"Y = 1", 0
	current_X BYTE 1			;remember X == DH
	current_Y BYTE 1			;remember Y == DL
.code
main PROC
	; First we clear the screen
	Call ClrScr

	;Set up the screen before calling MakeWindow to calculate X / Y
	MOV EDX, OFFSET currentX_Msg
	Call WriteString
	Call Crlf
	MOV EDX, OFFSET currentY_Msg
	Call WriteString
	Call Crlf

	;Set up the window
	Call MakeWindow
	MOV EAX, BuildColor		; Change text color for smiley.
	Call SetTextColor

	MOV DH, CornerY+1
	MOV DL, CornerX+1
	Call Gotoxy			; Call Gotoxy to place cursor using x=DL, y=DH.

	Call Clear_Buffer
	;----------------------Enter Decision Loop------------------
	GetKey:
	Call ReadChar	; Waits for keystroke and puts it into AL.
	CMP AL, "u"		; If input="u", go to MoveUp routine.
	JE MoveUp
	CMP AL, "d"		; If input="d", go to MoveDown routine.
	JE MoveDown
	CMP AL, "l"		; If input="l", go to MoveLeft routine.
	JE MoveLeft
	CMP AL, "r"		; If input="r", go to MoveRight routine.
	JE MoveRight
	CMP AL, "q"		; If input="q", go to QuitProgram.
	JE QuitProgram
	CMP AL, "1"
	JE TurnOn		; If input = "1", go to TurnOn
	CMP AL, "0"
	JE TurnOff		; If input = "0", go to TurnOff
	JMP GetKey		; We only reach this point if keystroke was NOTA.
					; So then we just jump back to GetKey.
	;----------------------------Move Up------------------------
	MoveUp:
		CMP DH, CornerY+1
		JE GetKey		; If we are at the top, can't move up. So go back to GetKey.
		DEC DH
		DEC Current_Y
		PUSH EDX
		MOV DL, 4
		MOV DH, 1
		Call Gotoxy
		MOV EAX, TextColor
		Call SetTextColor
		MOVZX EAX, Current_Y
		Call WriteDec
		MOV AL, 20h
		Call WriteChar
		POP EDX
		Call Gotoxy
		JMP GetKey
	;------------------------------MoveDown---------------------
	MoveDown:
		CMP DH, CornerY+Window_Height		; Similar to MoveUp
		JE GetKey
		INC DH
		INC Current_Y
		PUSH EDX
		MOV DL, 4
		MOV DH, 1
		Call Gotoxy
		MOV EAX, TextColor
		Call SetTextColor
		MOVZX EAX, Current_Y
		Call WriteDec
		MOV AL, 20h
		Call WriteChar
		POP EDX
		Call Gotoxy
		JMP GetKey
	;------------------------------MoveLeft----------------------
	MoveLeft:
		CMP DL, CornerX+1		; Similar to MoveUp
		JE GetKey
		DEC DL
		DEC Current_X
		PUSH EDX
		MOV DL, 4
		MOV DH, 0
		Call Gotoxy
		MOV EAX, TextColor
		Call SetTextColor
		MOVZX EAX, Current_X
		Call WriteDec
		MOV AL, 20h
		Call WriteChar
		POP EDX
		Call Gotoxy
		JMP GetKey
	;-----------------------------MoveRight-----------------------
	MoveRight:
		CMP DL, CornerX+Window_Width	; Similar to MoveUp
		JE GetKey
		INC DL
		INC Current_X
		PUSH EDX
		MOV DL, 4
		MOV DH, 0
		Call Gotoxy
		MOV EAX, TextColor
		Call SetTextColor
		MOVZX EAX, Current_X
		Call WriteDec
		MOV AL, 20h
		Call WriteChar
		POP EDX
		Call Gotoxy
		JMP GetKey
	;----------------------------TurnOn------------------------
	TurnOn:
		;need to see if it is already on? ... how...
		;does it matter though since if it keeps changing the color to the same thing?
		MOV EAX, BuildColor		; Change text color for blocks.
		Call SetTextColor
		MOV AL, Block			; print character on screen as block
		Call WriteChar
		Call Gotoxy
		JMP GetKey
	;----------------------------TurnOff------------------------
	TurnOff:
		;MOV EAX, ScreenColor
		;Call SetTextColor
		MOV AL, Space
		Call WriteChar
		Call Gotoxy
		JMP GetKey
	;----------------------Quit Program------------------
	QuitProgram:
	MOV DH,0				; Here we replace cursor at top,
	MOV DL,0				
	Call Gotoxy
	MOV EAX, ScreenColor	; change back to default color.
	Call SetTextColor
	exit					; and exit program.
main ENDP
;--------------------------------------------------------------------
MakeWindow PROC
; MakeWindow is limited to this program, since it uses
; a number of symbolic constants. Could easily rework it so that
; corner x and y, width, height, and even color are passed
; in through registers.
;--------------------------------------------------------------------
	MOV EAX, BlockColor
	Call SetTextColor
	MOV AL, Block
	;-------------------Top Line of Window-----------------
	MOV DH, CornerY
	MOV DL, CornerX
	Call Gotoxy
	MOV ECX, Window_Width+2
	L1:
		Call WriteChar
		LOOP L1
	;------------------Bottom Line of Window----------------
	MOV DH, CornerY+Window_Height+1
	MOV DL, CornerX
	Call Gotoxy
	MOV ECX, Window_Width+2
	L2:
		Call WriteChar
		LOOP L2
	;-----------------Left Side of Window-------------------------------
	MOV DH, CornerY
	MOV DL, CornerX
	Call Gotoxy
	MOV ECX, Window_Height+2
	L3:
		Call WriteChar
		INC DH
		Call Gotoxy
		Loop L3
	;-------------------Right side of window-----------------------
	MOV DH, CornerY
	MOV DL, CornerX+Window_Width+1
	Call Gotoxy
	MOV ECX, Window_Height+2
	L4:
		Call WriteChar
		INC DH
		Call Gotoxy
		Loop L4
	RET
MakeWindow ENDP

;----------------------------------------------------
Clear_Buffer	PROC
;-----------------------------------------------------
; This procedure simply reads 15 characters from the keyboard buffer
; in order to clear it. ECX and EDX are affected. So these are
; pushed and popped.
;-----------------------------------------------------
	PUSH EDX
	PUSH ECX
	PUSH EBX
	MOV ECX, 15
	L1:
		Call ReadKey	; ReadKey returns first buffered keystroke or 0 to AL.
		LOOP L1
	POP EBX
	POP ECX
	POP EDX
	RET
Clear_Buffer	ENDP


END main