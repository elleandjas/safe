	#include p18f87k22.inc
	
	    global      delay, code1, code2, code3, code4, threetimes, fivetimes
	    extern	UART_Setup, UART_Transmit_Message						; external UART subroutines
	    extern	LCD_Setup, LCD_Write_Message, clear_display, LCD_Send_Byte_I, LCD_delay_x4us    ; external LCD subroutines
	    extern	Mnewp, Mpin, Mincpin, M3inc, Mlock, Moldp, Munlock, Msuc, Mstar, Mbreach, Mspeak	;external messages subroutines
	    extern      c1store, c2store, c3store, c4store, t3store, t5store, t3read, t5read, c1read, c2read, c3read, c4read 
	
;**************reserving bytes in access ram**********************
acs0		udata_acs   ; reserve data space in access ram
counter		res 1	    ; reserve one byte for a counter variable	    
comp	    	res 1
row_store	res 1	    ; row code for keypad eg 0111 is the first row 
col_store	res 1	    ; column code for keypad eg 0111 is the first column
address		res 1
lock		res 1	    ;if 0 the safe is unlocked, if 1 the safe is locked
code1		res 1
code2		res 1
code3		res 1
code4		res 1
checktostart	res 1	    ;this is the value read by the keypad function 
flag		res 1	    ; to check whether the value is one of the keys or half stored rows/cols
wrongflag       res 1
threetimes	res 1	    ;also going to store in programme memory so that is only moved when the door is unlocked successful
delay_count	res 1	    
delay_countL    res 1	    
delay_countG    res 1	
delay_countT    res 1	
LED		res 1
voicebyte	res 1	    ;if the voice byte is low or high 	
fivetimes       res 1       ;five voice command attempts allowed
flasher		res 1 


rst	code	0	    ; reset vector
	goto	setup

pdata	code		    ; a section of programme memory for storing data
		
;******************data in ****************************	

main	code
; ********************** Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	LCD_Setup	; setup LCD
	goto	start
	
;*****************keyboard set up******************

start	
 	banksel PADCFG1				; PADCFG1 is not in Access Bank!!
enable	bsf	PADCFG1, REPU, BANKED		; PortE pull-ups on
	movlb	0x00				; set BSR back to Bank 0
	
	clrf	LATE
	
VCMD_OPEN = 0				   ;set up code for the voice software
VCMD_CLOSE = 1
VCMD_OPENJ = 2
VCMD_CLOSEJ = 3 ;is this necessary 
	
	call t3read
	call t5read
	call c1read
	call c2read
	call c3read
	call c4read 
	
;	call store			;enters new pin 
;********************* safe setup ********************
	
locked? movlw	0x00
	movwf	lock, ACCESS       ;making the safe unlocked to start NEED TO FIGURE OUT LOCK MECHANISM
	
	movlw   0xf0		   ;upper nibbles input lower nibbles output 
	movwf   TRISD		;PORT F output for lEDs
	clrf    PORTD
	clrf	wrongflag 
			  ;LCD message telling you to enter the initial pin
			  
	call	clear_display
	;call	t3read 
	call    resetbreach
;******************** which command to go to *******************;
	
checkb	call	keypad
	movlw	0xeb		  ;eb is address of button B
	cpfseq	checktostart	    
	goto	checkc
        call	unlockp
	movlw	0x00
	cpfsgt	wrongflag	    ;checks if wrong pin has been flagged, skips if more than 0  
	call	unlock		    ;UNLOCKS THE SAFE!!!!!
checkc	call	keypad
	movlw	0xed		    ;ed is address of button C
	cpfseq	checktostart	   
	goto	checks	    	    
        call	locker		    ;lock the safe again 
;checkd	call   keypad
;	movlw  0xee		    ;ee is address of buttonD
;	cpfseq checktostart	   
;	nop
;	goto   setvoice		    ;calls set voice pasd=sword subroutine 
checks	call   keypad
	movlw  0x7e		    ;7e is address of button *
	cpfseq checktostart	    
	goto	check#
	call    voice		    ;calls the voce unlocking subroutine 
check#	call	keypad
	movlw	0xde		    ;de is address of button #
	cpfseq	checktostart	   
	goto	checkb
	call	delay
	call	unlockp		    ;if correct pin was entered the wrongflag = 0
	movlw	0x00
	cpfsgt	wrongflag 	
	call	store		    ;calls pin store subroutine (need message saying store)

	goto	checkb		    ;loops back to checking for command buttons
        

	
	
	
;###################### storing pin number #################################
store	
      ;checking if the buttons have been released 
	
	call	release
	call	Mnewp
keycheck1			    ;checking if there is a value other than ff stored in checktostart
	call	keypad
	movlw	0xff
	cpfslt	checktostart, 0
	goto	keycheck1
	call	compare 
	movlw	0x00
	cpfseq	flag, 0
	goto	keycheck1 
	movff	checktostart, code1   ;first key is stored in code 1 
	call	c1store
	call	clear_display
	call	Mstar
release1			    ;checking if the buttons have been released 
	call	release
keycheck2			    ;checking if there is a value other than ff stored in checktostart
	call	keypad
	movlw	0xff
	cpfslt	checktostart, 0
	goto	keycheck2
	call	compare 
	movlw	0x00
	cpfseq	flag, 0
	goto	keycheck2 
	movff	checktostart, code2
	call	c2store
	call	Mstar
release2
	call	release	
keycheck3			    ;checking if there is a value other than ff stored in checktostart
	call	keypad
	movlw	0xff
	cpfslt	checktostart, 0
	goto	keycheck3
	call	compare 
	movlw	0x00
	cpfseq	flag, 0
	goto	keycheck3
	movff	checktostart, code3
	call	c3store
	call	Mstar
release3     
	call	release
keycheck4   ;checking if there is a value other than ff stored in checktostart
	call	keypad
	movlw	0xff
	cpfslt	checktostart, 0
	goto	keycheck4
	call	compare 
	movlw	0x00
	cpfseq	flag, 0
	goto	keycheck4 
	movff	checktostart, code4
	call	c4store
	call	 Mstar
release4     
	call	release
	
	call	clear_display
	call	Msuc
	
	return

;CCCCCCCCCCCCCCCCCC RE-LOCK SAFE CCCCCCCCCCCCCCCCCCCCCCCCC
	
locker
	call	clear_display
	call	release
	setf	lock
	
	call	Mlock
	
	
	
	return 

;BBBBBBBBBBBBBBBBBB UNLOCK WITH PIN ENTRY BBBBBBBBBBBBBBBBBBBBB
	
    ;in code1, code2, code3 and code4 is the 1 byte address of each pin number
    ;to start entering the pin to unlock press B button, so first check if button b is pressed
    ;is also used before storing a new pin 
    

unlockp call	clear_display
	clrf	wrongflag
	call    Mpin		    ;LCD messsage 'Enter pin'
        call	release
        call	delay
b1check				    ;checking if there is a value other than ff stored in checktostart
        call	keypad
	movlw	0xff
	cpfslt	checktostart, 0
	goto	b1check
	call	compare 
	movlw	0x00
	cpfseq	flag, 0
	goto	b1check             ;looping back to the check for the first button being poressed 
	call    clear_display
	call    Mstar
	movf	checktostart, 0     ;a button has been pressed, comapre to code1, the first number in the stored password 
	cpfseq	code1		    ;checking if button pressed is the same as stored, skip if equal to 
	incf	wrongflag, 1, 0	    ;flagged if entered password is not equal to stored, but will still compare the other numbers for real life effect
r1check	call	release
	nop
b2check				    ;check number 2
	call	keypad
	movlw	0xff
	cpfslt	checktostart, 0
	goto	b2check
	call	compare 
	movlw	0x00
	cpfseq	flag, 0
	goto	b2check
	call	Mstar
	movf	checktostart, 0    
	cpfseq	code2		    
	incf	wrongflag, 1, 0	   
	nop
r2check	call	release
	nop
b3check				    ;check number 3!
        call	keypad
	movlw	0xff
	cpfslt	checktostart, 0
	goto	b3check
	call	compare 
	movlw	0x00
	cpfseq	flag, 0
	goto	b3check  
	call    Mstar
	movf	checktostart, 0      
	cpfseq	code3		    
	incf	wrongflag, 1, 0	    
	nop
r3check	call    release
	
b4check	nop			    ;check number 4!
	call	keypad
	movlw	0xff
	cpfslt	checktostart, 0
	goto	b4check
	call	compare 
	movlw	0x00
	cpfseq	flag, 0
	goto	b4check   
	call    Mstar
	movf	checktostart, 0    
	cpfseq	code4		    
	incf	wrongflag, 1, 0	    
	nop
r4check	call	release
	
	call	clear_display
	
	movlw	0x00
	cpfsgt	wrongflag
	return 
	call	Mincpin		; displays 'incorrect password' on the LCD
	call    red
	call    delayG
	call	ledoff 
	decfsz  threetimes	;decreases the incorrect password counter by 1
	call    t3store		;store threetimes in programme memory 
	movlw   0x00
	cpfsgt  threetimes     ;if three incorrect codes are entered, then timeout is given. if not returns to main page 
	call    timeout
	return

;******************* keypad read ****************************			

keypad	
outin   movlw	0x0f			;to read the rows 0x0f = 00001111
	movwf	TRISE, ACCESS	    ;inputs 0-3, outputs 4-7
	call	delay
rowstore
	movff	PORTE, row_store	    ;stores row number 	
inout   movlw	0xf0		    ;to read th e columns 0xf0 = 1111000
	movwf	TRISE, ACCESS	    ;outputs 0-3, inputs 4-7
	call	delay 
colstore		    
	movff	PORTE, col_store	    ;column number is stored
	call	delay 
	
read    movf	row_store, 0	    ;moving row store to Wreg
	iorwf	col_store, 0	    ;OR ing col sotre and row store to get full address of button in 8 bits 
	movwf	checktostart	    ;storing w in check to start		    ;e.g. 2 = second column, first row = 1011 0111
	call	delay
				    
	return

;***************** comparison subroutine if correct numbers stored *************
	
compare clrf	flag		    ;this is useful for when the button is pressed half way through a keypad
zero    movlw	0xbe
	cpfseq 	checktostart 
	goto	one
	return
one	movlw	0x77		    ;and the row and columns arent both stored properly. There are 
	cpfseq 	checktostart	    ;
	goto	two 
	return
two	movlw	0xb7
	cpfseq 	checktostart
	goto	three
	return
three	movlw	0xd7 
	cpfseq 	checktostart
	goto	four
	return
four	movlw	0x7b
	cpfseq 	checktostart
	goto	five
	return
five	movlw	0xbb
	cpfseq 	checktostart
	goto	six
	return
six	movlw	0xeb
	cpfseq 	checktostart
	goto	seven
	return
seven	movlw	0x7d
	cpfseq 	checktostart
	goto	eight
	return
eight	movlw	0xbd
	cpfseq	checktostart
	goto	nine
	return
nine	movlw	0xdd
	cpfseq 	checktostart
	setf	flag
	return
	
;******************* release from command button ****************; 	
	
release      ;checking if the buttons have been released 
	call	keypad
	movlw	0xff
	cpfseq	checktostart, 0
	goto	release
	return 
	
;****************** unlock safe *******************
unlock  clrf	lock
	call	Munlock
	call	green
	call    delayG
	call    ledoff
	call    resetbreach
	
	return 
;*********************** delay ****************************
delay	movlw   0xff 
	movwf   delay_count	
delay1	decfsz	delay_count	; decrement until zero
	bra	delay1
	return
	
delayL  movlw	0xff	
	movwf   delay_countL
delayL1	call    delay
	decfsz  delay_countL
	bra	delayL1
	return 

delayG  movlw	0xff	
	movwf   delay_countG
delayG1	call    delayL
	decfsz  delay_countG
	bra	delayG1
	return 
	
delayT				   ;the longest delays require an argument for how many delay G you want 
	movwf   delay_countT
delayT1	call    delayG
	decfsz  delay_countT
	bra	delayT1
	return 	
	
;******************** reset 5 and 3 count for breach ***************
resetbreach
	movlw	0x03
	movwf	threetimes, 0 
	call	t3store   ;restoring 3 into the programme memory 
	movlw	0x05
	movwf	fivetimes, 0
	call    t5store
	return
	
	
	
;*********************** safe has been breached ********************	
	
timeout
	call	clear_display
	call	Mbreach
	call	redflash 
	
	call    resetbreach
	call	clear_display 
	return 
	
;********************* voice unlock ****************************	
voice   call    clear_display
	call	Mspeak
	movlw   0x02
	call	delayT			;might need to be shorter than this 	
	
voicecheck
	movff	PORTD, voicebyte
	movlw	0x7f
	cpfsgt	voicebyte    ;comapring voicebyte (input from portD) with 7F, if more than pin7 is lit and it skips a line
	goto    incvoice
	call    clear_display
	call	unlock
	return
	
incvoice
	call    clear_display
	call	red
	call    delayG
	call	ledoff 
	call	Mincpin
	decfsz  fivetimes
	movlw   0x00
	cpfsgt  fivetimes, 0
	call    t5store
	call    timeout
	return 
;*********************** LED sequences *******************************
green   
	movlw   0x01
	movwf   LED, ACCESS
	movff   LED, PORTD
	return
	
red	movlw   0x02
	movwf   LED, ACCESS
	movff   LED, PORTD
	return
ledoff
	movlw   0x00 
	movwf   LED, ACCESS
	movff   LED, PORTD
	return 
	
redflash
	movlw	0xff
	movwf	flasher
redflash1
	call	red
	call	delayG 
	call	ledoff
	call	delayG
	decfsz	flasher
	goto	redflash1
	return 
	
;*********************** end of sequence *********************
	
	call	clear_display    ;when the safe turns off the LCD screen needs to be cleared. can do this by locking the safe 
	end 
	
	
	
