#include p18f87k22.inc

    global  keypad, compare, voice, unlock, release, delay, delayL, delayG, delayT, resetbreach, timeout, red, green, ledoff, redflash
    extern  clear_display
    extern  Mnewp, Mpin, Mincpin, M3inc, Mlock,Moldp, Munlock, Msuc, Mstar, Mbreach, Mspeak
    extern  t3store, t5store
    extern  code1, code2, code3, code4, threetimes, fivetimes, checktostart, flag, wrongflag, delay_count, delay_countL, delay_countG, delay_countT, LED, voicebyte, flasher, col_store, row_store, lock
    
    
    code 
    
    
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
	
;*********************pin unlock  *******************
unlock  clrf	lock
	call	Munlock
	call	green
	call    delayG
	call    ledoff
	call    resetbreach
	
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
	
	
	end