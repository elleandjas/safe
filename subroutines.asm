#include p18f87k22.inc

    global  keypad, compare, voice, unlock, release, delay, delayL, delayG, delayT, resetbreach, timeout, red, green, ledoff, redflash
    extern  clear_display
    extern  Mnewp, Mpin, Mincpin, M3inc, Mlock,Moldp, Munlock, Msuc, Mstar, Mbreach, Mspeak
    extern  t3store, t5store, lockstore, lockread
    extern  code1, code2, code3, code4, threetimes, fivetimes, checktostart, flag, wrongflag, delay_count, delay_countL, delay_countG, delay_countT, LED, voicebyte, flasher, col_store, row_store, lock
    
    code 
    
    
;******************* keypad read ****************************			
	;this routine reads the manual entry on the keypad by storing rows and columns of entry, with particular row and column corresponding to a particular key. 
	;the routine uses port E, when code runs you are able to see the LEDS on this port light corresponding to the rows and columns pressed on the keypad. 
keypad	
outin   movlw	0x0f		    ;to read the rows 0x0f = 00001111
	movwf	TRISE, ACCESS	    ;inputs 0-3, outputs 4-7
	call	delay		    ;delay lets the pin settle 
rowstore
	movff	PORTE, row_store    ;stores row number 	
inout   movlw	0xf0		    ;to read th e columns 0xf0 = 1111000
	movwf	TRISE, ACCESS	    ;outputs 0-3, inputs 4-7
	call	delay 
colstore		    
	movff	PORTE, col_store    ;column number is stored
	call	delay 
	
read    movf	row_store, 0	    ;moving row store to Wreg
	iorwf	col_store, 0	    ;OR ing col sotre and row store to get full address of button in 8 bits 
	movwf	checktostart	    ;storing w in check to start		    ;e.g. 2 = second column, first row = 1011 0111
	call	delay
				    
	return

;***************** COMPARE subroutine if correct numbers stored *************
	
	;a subroutine which only lets the code store if the computer has correctly registered the rows and columns. during testing the computer may only store rows, which does not correspond to a number on the keypad. 
	;the result of this subroutine is a high or low 'flag' determining whether a correct number has been read. 
	
compare	
	clrf	flag		;sets the flag to 0     
zero    movlw	0xbe
	cpfseq 	checktostart 
	goto	one
	return
one	movlw	0x77		    
	cpfseq 	checktostart	    
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
	setf	flag			;if no correct number stored (0-9) the flag is set high. 
	return
	
;******************* RELEASE button check****************; 	
				    ;if the button is released, then the computer can begin to store the next button which may be a pin entry or a new action 
release				    ;checking if the buttons have been released 
	call	keypad
	movlw	0xff		    ;if there is a no button pressed the row and column will be 0xff
	cpfseq	checktostart, 0
	goto	release
	return 
	
;********************* UNLOCK *******************
unlock  setf	lock
	movff   lock, PORTH
	call	lockstore 
	call	Munlock
	call	green
	call    delayG
	call    ledoff
	call    resetbreach
	
	 return 
	
;********************* VOICE ROUTINE ****************************	
voice   call    clear_display
	call	Mspeak	
	movlw   0x02	
	call	delayT			;the amount of time the 'speak now' message is displayed for is the time the user has to get a correct voice store	
	
voicecheck				;if IO1 has been set high by a correct 
	movff	PORTD, voicebyte
	movlw	0x7f
	cpfsgt	voicebyte		;comapring voicebyte (input from portD) with 7F, if more than pin7 is lit and it skips a line
	goto    incvoice
	call    clear_display
	call	unlock
	return
	
incvoice
	call    clear_display
	call	Mincpin
	call	red
	call    delayG
	call	ledoff 
	decfsz  fivetimes
	call    t5store
	movlw   0x00
	cpfsgt  fivetimes, 0
	call    timeout
	return 

	
;******************** RESET BREACH  ***************
	;resets the number of allowed pin entries and voice entries
	;3 tries for pin and 5 tries for voice entry 
resetbreach
	movlw	0x03
	movwf	threetimes, 0 
	call	t3store   ;restoring 3 into the programme memory 
	movlw	0x05
	movwf	fivetimes, 0
	call    t5store
	return
	
	
	
;*********************** safe has been BREACHED ********************	
	
timeout
	call	clear_display		    
	call	Mbreach
	call	redflash	    ;the time delay in redflash prevents the user from opening attempting to open the safe until it has finished
	call    resetbreach	    ;resets the number of allowed attempts to 5 and 3 for voice and keypad entry respectively
	call	clear_display 
	return 
	
;*********************** LED sequences *******************************
green   
	movlw   0x01
	movwf   LED, ACCESS	    ;turns green LED on, used for unlocking the safe
	movff   LED, PORTD
	return
	
red	movlw   0x02		    ;turns red on when incorrect password
	movwf   LED, ACCESS
	movff   LED, PORTD
	return
ledoff				    ;turns both leds off 
	movlw   0x00 
	movwf   LED, ACCESS
	movff   LED, PORTD
	return 
	
redflash			    ;makes red KED flash continuously for that the safe is breached and unaccessible 
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
	
;*********************** delay ****************************
delay	movlw   0xff			;smallest delay
	movwf   delay_count   	                                                 
delay1	decfsz	delay_count		; decrement until zero
	bra	delay1
	return
	
delayL  movlw	0xff			;second smallest delay, calls smaller delay ff times
	movwf   delay_countL
delayL1	call    delay
	decfsz  delay_countL
	bra	delayL1
	return 

delayG  movlw	0xff 			;second largest delay, calls second smallest ff times
	movwf   delay_countG
delayG1	call    delayL
	decfsz  delay_countG
	bra	delayG1
	return 
	
delayT					;the longest delay, the other routines specify how many of these delays they want 
	movwf   delay_countT
delayT1	call    delayG
	decfsz  delay_countT
	bra	delayT1
	return 	
	
;*******************************************************************	
	end