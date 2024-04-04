# PearceLab5.s by Britton Pearce
@
@ Define the constants for this code. 

OUTPUT = 1 @ Used to set the selected GPIO pins to output only. 
INPUT  = 0  

PUD_UP   = 2  
PUD_DOWN = 1 

LOW  = 0 
HIGH = 1

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
 @ set the mode to input-BLUE

        ldr     r0, =buttonBlue
        ldr     r0, [r0]
        mov     r1, #INPUT
        bl      pinMode

@ set the mode to input - GREEN

        ldr     r0, =buttonGreen
        ldr     r0, [r0]
        mov     r1, #INPUT
        bl      pinMode

@ set the mode to input- YELLOW

        ldr     r0, =buttonYellow
        ldr     r0, [r0]
        mov     r1, #INPUT
        bl      pinMode

@ set the mode to input - RED

        ldr     r0, =buttonRed
        ldr     r0, [r0]
        mov     r1, #INPUT
        bl      pinMode

@ Prompt the user to turn on the machine
ldr r0, =TurnOnStr
bl printf

@ Wait for the user to 'turn on' the coffee machine
TurnOn:
bl WaitForButtonPress
cmp r0, #0
bne TurnOn

@ Turn on the red LED for the duration of the   program

        ldr     r0, =red_LED
        ldr     r0, [r0]
        mov     r1, #ON
        bl      digitalWrite

# Welcome and prompt the user
ldr r0, =WelcomeStr
bl printf

MainProgramLoop:
ldr r0, =SelectCupStr
bl printf

# Get user input
bl WaitForButtonPress

cmp r0, #0
beq exit

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
b MainProgramLoop

GotCupSize:
# Make Sure the cup size is less than remaining water
ldr r4, =waterOz
ldr r4, [r4]
cmp r1, r4
ble SaveStats
ldr r0, =WaterInsufficientStr
bl printf
b MainProgramLoop

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
b MainProgramLoop

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

# Reads a char from stdin ignoring preceding white space
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

@ Wait for a pin button to be pressed and return the button code
WaitForButtonPress:
push {lr}

@
@  Set the registers to debounce switches and handle buttons 
@  held down,.
@
    mov r8,  #0xff 
    mov r9,  #0xff
    mov r10, #0xff    
    mov r11, #0xff 


@ Start the loop to read all the buttons. 

ButtonLoop:

@ Delay a few miliseconds to help debounce the switches. 
@
    ldr  r0, =delayMS
    ldr  r0, [r0]
    mov r0, #250
    BL   delay

ReadBLUE:
@ Read the value of the blue button. If it is HIGH (i.e., not
@ pressed) read the next button and set the previous reading
@ value to HIGH. 
@ Otherwise the current value is LOW (pressed). If it was LOW
@ that last time the button is still pressed down. Do not record
@ this as a new pressing.
@ If it was HIGH the last time and LOW now then record the 
@ button has been pressed.
@
    ldr    r0,  =buttonBlue
    ldr    r0,  [r0]
    BL     digitalRead 
    cmp    r0, #HIGH   @ Button is HIGH read next button
    moveq  r9, r0      @ Set last time read value to HIGH 
    beq    ReadGREEN

    @ The button value is LOW.
    @ If it was LOW the last time it is still down. 
    cmp    r9, #LOW    @ was the last time it was called also
                       @ down?
    beq    ReadGREEN   @ button is still down read next button
                       @ value. 
     
    mov    r9, r0  @ This is a new button press. 
	mov r0, #3
    b      ReturnButton @ Branch to print the blue button was pressed. 

ReadGREEN:
@ See comments on BLUE button on how this code works. 
@
    ldr    r0,  =buttonGreen
    ldr    r0,  [r0]
    BL     digitalRead  
    cmp    r0, #HIGH
    moveq  r10, r0
    beq    ReadYELLOW   

    cmp    r10, #LOW
    beq    ReadYELLOW  

    mov    r10, r0
	mov r0, #2
    b      ReturnButton

ReadYELLOW:
@ See comments on BLUE button on how this code works. 
@
    ldr    r0,  =buttonYellow
    ldr    r0,  [r0]
    BL     digitalRead 
    cmp    r0, #HIGH
    moveq  r11, r0
    beq    ReadRED 
 
    cmp    r11, #LOW
    beq    ReadRED

    mov    r11, r0
	mov r0, #1
    b      ReturnButton

ReadRED:
@ See comments on BLUE button on how this code works. 
@
    ldr    r0,  =buttonRed
    ldr    r0,  [r0]
    BL     digitalRead 
    cmp    r0, #HIGH
    moveq  r8, r0
    beq    ButtonLoop
 
    cmp    r8, #LOW
    beq    ButtonLoop
 
    mov    r8, r0
	mov r0, #0
    b     ReturnButton 

ReturnButton:

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

TurnOnStr: .asciz "Press red button to power on\n"
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

blue_LED   : .word BLUE
green_LED  : .word GREEN
yellow_LED : .word YELLOW
red_LED    : .word RED

buttonBlue:   .word 7 @Blue button
buttonGreen:  .word 0 @Green button
buttonYellow: .word 6 @Yellow button
buttonRed:    .word 1 @Red button

delayMS: .word 1000  @ Set delay for one second. 

BitBucket: .skip 400

