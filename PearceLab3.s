# PearceLab3.s by Britton Pearce

.global  main
main:

# Welcome and prompt the user
ldr r0, =WelcomeStr
bl printf

ldr r0, =SelectCupStr
bl printf

# Get user input
ldr r0, =IntInputPtrn
ldr r1, =userSelection

bl scanf
cmp r0, #0
bne GotNum
bl CheckCharInput
bl FlushError

GotNum:
ldr r0, =userSelection
ldr r0, [r0]

# Select which cup the user input - restart on fail
cmp r0, #1
moveq r1, #6
ldreq r2, =smallCount
beq GotCupSize
cmp r0, #2
moveq r1, #8
ldreq r2, =mediumCount
beq GotCupSize
cmp r0, #3
moveq r1, #10
ldreq r2, =largeCount
beq GotCupSize
b main

GotCupSize:
# Make Sure the cup size is less than remaining water
ldr r4, =waterOz
ldr r4, [r4]
cmp r1, r4
ble SaveStats
ldr r0, =WaterInsufficientStr
bl printf
b main

# Move water level, cup memory address, and cup size to safe registers
SaveStats:
# Cup size
mov r10, r1 
# Cup memory
mov r11, r2 
# Water level
mov r9, r4 

# Prompt ready to brew
ReadyBrew:
ldr r0, =ReadyBrewStr
bl printf
bl CheckCharInput
# TODO: Handle read char failure
# Check if user char is 'B' and reprompt if not
cmp r0, #66
bne ReadyBrew

# Lower water level 
Update:
sub r9, r9, r10
ldr r0, =waterOz
str r9, [r0]
# Increment cup uses
ldr r0, [r11]
add r0, r0, #1
str r0, [r11]

# Prompt rrefill and exit if water is too low
cmp r9, #6
blt WaterEmpty

# Return to thhe beginning of the program
b main

WaterEmpty:
ldr r0, =WaterEmptyStr
bl printf

mov r0, #0

exit:
mov r7, #0x01
svc 0

# Readds a char from stdin ignoring preceding white space
# If the char is an exit or secret code then perform the necessary operationssss
# return the char that  was read in (to upper)
CheckCharInput:
	push {lr}
	ldr r0, =CharInputPtrn
	ldr r1, =userChar
	bl scanf

	# Create to-upper bit mask
	mov r0, #0xffffffff
	mov r1, #32
	eor r2, r0, r1

	# load user char and peerform to-upper
	ldr r0, =userChar
	ldr r0, [r0]
	and r0, r0, r2
	#Check if the char is shutdown key
	cmp r0, #84
	beq exit
	# Check if the char is secret code ('S')
	cmp r0, #83	
	bne ReturnCharInput
	
	# Output the secret information
	push {r0}
	ldr r0, =WaterDisplayStr
	ldr r1, =waterOz
	ldr r1, [r1]
	bl printf
	ldr r0, =SmallCupStr
	ldr r1, =smallCount
	ldr r1, [r1]
	bl printf
	ldr r0, =MediumCupStr
	ldr r1, =mediumCount
	ldr r1, [r1]
	bl printf
	ldr r0, =LargeCupStr
	ldr r1, =largeCount
	ldr r1, [r1]
	bl printf
	pop {r0}

	ReturnCharInput:	
	pop {pc}

FlushError:
	push {lr}
	ldr r0, =FlushStdOutPtrn
	ldr r1, =BitBucket
	bl scanf
	pop {pc}

.data
.balign 4
waterOz: .word 48
smallCount: .word 0
mediumCount: .word 0
largeCount: .word 0

userSelection: .word 0
userChar: .word 0

WelcomeStr: .asciz "Welcome to the Coffee Maker\nInsert K-cup and press B to begin making coffee\nPresss T to turn off the machine\n\n"
SelectCupStr: .asciz "Select cup size 1 (Small 6oz), 2 (Medium 8oz), or 3 (large 10oz): \n"
ReadyBrewStr: .asciz "Ready to brew! (Press 'B'): \n"
WaterInsufficientStr: .asciz "Insufficient water to fill cup!\n"
WaterEmptyStr: .asciz "Please refill water.\n"
WaterDisplayStr: .asciz "Water level: %doz\n"
SmallCupStr: .asciz "Small Cups used: %d\n"
MediumCupStr: .asciz "Medium Cups used: %d\n"
LargeCupStr: .asciz "Large Cups used: %d\n\n"

IntInputPtrn: .asciz "%d"
CharInputPtrn: .asciz  " %c"
FlushStdOutPtrn: .asciz "%[^\n]"
BitBucket: .skip 400
