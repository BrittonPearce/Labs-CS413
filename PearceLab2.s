@ Britton Pearce
@ BP0082@uah.edu
@ CS-413-01 Spring 2024 Lab 2

.global main
main:

	@ Welcome the user 
	ldr r0, =WelcomeStr
	bl printf
	b PromptUser

	ErrorInput:
	ldr r0, =ErrorInputStr
	bl printf

	@ Prompt and get user input
	PromptUser:
	ldr r0, =PromptStr
	bl printf
	bl GetInput
	cmp r0, #0
	beq ErrorInput
	
	@ The operands will be the same regardless of the call so go ahead and push them to the stack
	ldr r4, =UserOperand1
	ldr r4, [r4]
	cmp r4, #0
	blt ErrorInput
	ldr r5, =UserOperand2
	ldr r5, [r5]
	cmp r5, #0
	blt ErrorInput
	push {r4, r5}

	@ Select the correct subroutine call
	ldr r0, =UserOperator
	ldr r0, [r0]
	
	TryForMul:
	cmp r0, #42
	bne TryForAdd
	bl MyMul
	b AddMulResult

	TryForAdd:
	cmp r0, #43
	bne TryForSub
	bl MyAdd
	b AddMulResult

	TryForSub:
	cmp r0, #45
	bne TryForDiv
	bl MySub
	pop {r1}
	ldr r0, =ResultStr
	bl printf
	b PromptContinue

	TryForDiv:
	cmp r0, #47
	bne BadOperator
	bl MyDiv

	pop {r1}
	cmp r1, #-1
	beq DivByZeroError
	ldr r0, =ResultStr
	bl printf
	pop {r1}
	ldr r0, =ModResultStr
	bl printf
	
	b PromptContinue

	@ Display the results:
	AddMulResult:
	pop {r1}
	cmp r1, #-1
	beq OverflowError
	ldr r0, =ResultStr
	bl printf
	b PromptContinue 

	@ Report if the operator is invalid
	BadOperator:
	ldr r0, =ErrorOperatorStr
	bl printf
	b PromptUser

	@ Report if a divide  by zero error occurred
	DivByZeroError:
	ldr r0, =ErrorDivByZeroStr
	bl printf
	b PromptContinue
	
	@ Display the error if one wasfound
	OverflowError:

	ldr r0, =ErrorOverflowStr
	bl printf

	@ Prompt the user to continue or quit
	PromptContinue:
	 
	ldr r0, =PromptContinueStr
	bl printf
	ldr r0, =ContinueInputPtrn
	ldr r1, =UserOperator
	bl scanf
	cmp r0, #0
	beq exit	
	ldr r1, =UserOperator
	ldr r1, [r1]
	cmp r1, #121
	beq PromptUser

	
	exit:
	mov r7, #0x01
	svc 0

@ Pops two operands from the stack and multiplies, then pushes the result onto the stack 
MyMul:
	pop {r0, r1}
	umull r2, r3, r1, r0
	@ Overflow Check - If r3 != 0 then overflow occurred
	cmp r3, #0
	movne r2, #-1
	push {r2}
	mov pc, lr

@ Pops two operands from the stack and adds, then pushes the result onto the stack 
MyAdd:
	pop {r0, r1}
	adds r0, r1, r0
	movvs r0, #-1
	push {r0}
	mov pc, lr

@ Pops two operands from the stack and subtracts, then pushes the result onto the stack 
MySub:
	pop {r0, r1}
	sub r0, r0, r1
	push {r0}
	mov pc, lr

@
MyDiv:
	pop {r0, r1}
	cmp r1, #0
	beq DivByZero
	MyDivLoop:
	cmp r0, r1
	blt MyDivDone
	add r2, r2, #1
	sub r0, r0, r1
	b MyDivLoop

	MyDivDone:
	push {r0}
	push {r2}
	b ExitMyDiv
	
	DivByZero:
	mov r0, #-1
	mov r1, #-1
	push {r0, r1}
	ExitMyDiv:
	mov pc, lr
	
@ GetInput subroutine takees no parameters - just loads input into global variables
GetInput:
	push {lr}

	@ Get User input
	ldr r0, =IntInputPtrn
	ldr r1, =UserOperand1
	bl scanf
	cmp r0, #0
	bleq FlushError
	beq GetInputReturn

	ldr r0, =CharInputPtrn
	ldr r1, =UserOperator
	bl scanf
	cmp r0, #0
	bleq FlushError
	beq GetInputReturn

	ldr r0, =IntInputPtrn
	ldr r1, =UserOperand2
	bl scanf
	cmp r0, #0
	bleq FlushError

	GetInputReturn:
	pop {pc}

@ Flushes STDIN and sets Z = 1
FlushError:
	push {lr}
	ldr r0, =FlushStdOutPtrn
	ldr r1, =BitBucket
	bl scanf
	mov r0, #0
	cmp r0, #0
	pop {pc}

.data
.balign 4
WelcomeStr: .asciz "Welcome to the 4-function calculator for Lab 2 by Britton Pearce.\n"

.balign 4
PromptStr: .asciz "Please enter two non-negative integers surrounding an operator (+, -, *, /): \n"

.balign 4
PromptContinueStr: .asciz "Do you want to continue? (y, n):\n"

.balign 4
ResultStr: .asciz "Result is: %d\n"

.balign 4
ModResultStr: .asciz "Remainder: %d\n"

.balign 4
ErrorInputStr: .asciz "Error: Invalid Input!\n"

.balign 4
ErrorOperatorStr: .asciz "Error: Invalid Operator!\n"

.balign 4
ErrorOverflowStr: .asciz "Error: Integer Overflow!\n"

.balign 4
ErrorDivByZeroStr: .asciz "Error: Divide by zero!\n"


.balign 4
UserOperand1: .word 0

.balign 4
UserOperand2: .word 0

.balign 4
UserOperator: .word 0

.balign 4
CharInputPtrn: .asciz " %c "

.balign 4
IntInputPtrn: .asciz "%d"

.balign 4
IntOutputPtrn: .asciz "%d\n"

.balign 4
ContinueInputPtrn: .asciz " %c"

.balign 4
FlushStdOutPtrn: .asciz "%[^\n]"

.balign 4
BitBucket: .skip 100*4

