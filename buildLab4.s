# PearceLab4.s by Britton Pearce
@
@ Define the constants for this code. 

OUTPUT = 1 @ Used to set the selected GPIO pins to output only. 
ON     = 1 @ Turn the LED on.
OFF    = 0 @ Turn the LED off.

RED    = 5 @ Pin number from wiringPi for red led
YELLOW = 4 @ Pin number from wiringPi for yellow led
GREEN  = 3 @ Pin number from wiringPi for green led
BLUE   = 2 @ Pin number from wiringPi for blue led

.text
.balign 4
.global main 
main:

@ check the setup of the GPIO to make sure it is working right. 
@ To use the wiringPiSetup function just call it on return:
@    r0 - contains the pass/fail code 

        bl      wiringPiSetup
        mov     r1,#-1
        cmp     r0, r1
        bne     init  @ Everything is OK so continue with code.
        ldr     r0, =ErrMsg
        bl      printf
        b       errorout  @ There is a problem with the GPIO exit code.      

@ set the blue LED mode to output
init:

        ldr     r0, =blue_LED
        ldr     r0, [r0]
        mov     r1, #OUTPUT
        bl      pinMode

@ set the green LED mode to output

        ldr     r0, =green_LED
        ldr     r0, [r0]
        mov     r1, #OUTPUT
        bl      pinMode

@ set the yellow LED mode to output

        ldr     r0, =yellow_LED
        ldr     r0, [r0]
        mov     r1, #OUTPUT
        bl      pinMode

@ set the red LED mode to output

        ldr     r0, =red_LED
        ldr     r0, [r0]
        mov     r1, #OUTPUT
        bl      pinMode
 
@ Turn on the red LED for the duration of the   program

        ldr     r0, =red_LED
        ldr     r0, [r0]
        mov     r1, #ON
        bl      digitalWrite

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
b main

GotNum:
ldr r0, =userSelection
ldr r0, [r0]

# Select which cup the user input - restart on fail
cmp r0, #1
moveq r1, #6
ldreq r2, =smallCount
ldreq r8, =BrewSmallLight
beq GotCupSize
cmp r0, #2
moveq r1, #8
ldreq r2, =mediumCount
ldreq r8, =BrewMediumLight
beq GotCupSize
beq GotCupSize
cmp r0, #3
moveq r1, #10
ldreq r2, =largeCount
ldreq r8, =BrewLargeLight
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

@ Call the light function
blx r8

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

# Return to the beginning of the program
b main

WaterEmpty:
ldr r0, =WaterEmptyStr
bl printf
@ Blink the red  light 

        ldr     r0, =red_LED
        ldr     r0, [r0]
        mov     r1, #OFF
        bl      digitalWrite
	ldr r0, =delayMS
	ldr r0, [r0]
	mov r1, #5
	mul r0, r0, r1
	bl delay

        ldr     r0, =red_LED
        ldr     r0, [r0]
        mov     r1, #ON
        bl      digitalWrite
	ldr r0, =delayMS
	ldr r0, [r0]
	mov r1, #5
	mul r0, r0, r1
	bl delay

        ldr     r0, =red_LED
        ldr     r0, [r0]
        mov     r1, #OFF
        bl      digitalWrite
	ldr r0, =delayMS
	ldr r0, [r0]
	mov r1, #5
	mul r0, r0, r1
	bl delay

        ldr     r0, =red_LED
        ldr     r0, [r0]
        mov     r1, #ON
        bl      digitalWrite
	ldr r0, =delayMS
	ldr r0, [r0]
	mov r1, #5
	mul r0, r0, r1
	bl delay


        ldr     r0, =red_LED
        ldr     r0, [r0]
        mov     r1, #OFF
        bl      digitalWrite
	ldr r0, =delayMS
	ldr r0, [r0]
	mov r1, #5
	mul r0, r0, r1
	bl delay

        ldr     r0, =red_LED
        ldr     r0, [r0]
        mov     r1, #ON
        bl      digitalWrite
	ldr r0, =delayMS
	ldr r0, [r0]
	mov r1, #5
	mul r0, r0, r1
	bl delay

errorout:
exit:
	@ Turn off the red light
        ldr     r0, =red_LED
        ldr     r0, [r0]
        mov     r1, #OFF
        bl      digitalWrite

@ Set exit code
mov r0, #0
@ Exit
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

@ Functions to control the lights for their corresponding cup sizes
BrewSmallLight:
	push {lr}
	ldr r0, =yellow_LED
	ldr r0, [r0]
	mov r1, #ON
	bl digitalWrite

	ldr r0, =delayMS
	ldr r0, [r0]
	mov r1, #6
	mul r0, r0, r1
	bl delay

	ldr r0, =yellow_LED
	ldr r0, [r0]
	mov r1, #OFF
	bl digitalWrite
	pop {pc}

BrewMediumLight:
	push {lr}
	ldr r0, =green_LED
	ldr r0, [r0]
	mov r1, #ON
	bl digitalWrite

	ldr r0, =delayMS
	ldr r0, [r0]
	mov r1, #8
	mul r0, r0, r1
	bl delay

	ldr r0, =green_LED
	ldr r0, [r0]
	mov r1, #OFF
	bl digitalWrite
	pop {pc}

BrewLargeLight:
	push {lr}
	ldr r0, =blue_LED
	ldr r0, [r0]
	mov r1, #ON
	bl digitalWrite

	ldr r0, =delayMS
	ldr r0, [r0]
	mov r1, #10
	mul r0, r0, r1
	bl delay

	ldr r0, =blue_LED
	ldr r0, [r0]
	mov r1, #OFF
	bl digitalWrite
	pop {pc}

@ Empty out the input buffer
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
ErrMsg: .asciz "Pins not working!\n"

IntInputPtrn: .asciz "%d"
CharInputPtrn: .asciz  " %c"
FlushStdOutPtrn: .asciz "%[^\n]"
BitBucket: .skip 400

blue_LED   : .word BLUE
green_LED  : .word GREEN
yellow_LED : .word YELLOW
red_LED    : .word RED

delayMS: .word 1000  @ Set delay for one second. 

