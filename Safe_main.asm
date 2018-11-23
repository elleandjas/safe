	#include p18f87k22.inc
	
	    global      code1, code2, code3, code4, threetimes, fivetimes, checktostart, flag, wrongflag, delay_count, delay_countL, delay_countG, delay_countT 
	    global      LED, voicebyte, flasher, col_store, row_store, lock
	    extern	LCD_Setup, LCD_Write_Message, clear_display, LCD_Send_Byte_I, LCD_delay_x4us    ; external LCD subroutines
	    extern	Mnewp, Mpin, Mincpin, M3inc, Mlock, Moldp, Munlock, Msuc, Mstar, Mbreach, Mspeak	;external messages subroutines
	    extern      c1store, c2store, c3store, c4store, t3store, t5store, t3read, t5read, c1read, c2read, c3read, c4read, lockstore, lockread    ;external programmestore subroutines
	    extern	keypad, compare, voice, unlock, release, delay, delayL, delayG, delayT, resetbreach, timeout, red, green, ledoff, redflash     ;subroutines used in simple1 made external

	
;**************reserving space in ACCESS ram**********************
acs0		udata_acs   ; reserve data space in access ram 
row_store	res 1	    ; row code for keypad eg (0111 is the first row) 
col_store	res 1	    ; column code for keypad eg (0111 is the first column)
lock		res 1	    ; if 0 the safe is unlocked, if 1 the safe is locked
		
code1		res 1	    ; STORE subroutine
code2		res 1
code3		res 1
code4		res 1
		
checktostart	res 1	    ; this is the value read by the keypad function 
flag		res 1	    ; to check whether the value is one of the keys or half stored rows/cols COMPARE subroutine
wrongflag       res 1	    ; if an incorrect pin entry this value is high KEYPAD subroutine
threetimes	res 1	    ; how many wrong attempts at pin entry remain
fivetimes       res 1       ;five voice command attempts allowed	
LED		res 1	    
flasher		res 1 
voicebyte	res 1	    ;if the voice byte is low or high 	
       
delay_count	res 1	     
delay_countL    res 1	    
delay_countG    res 1	
delay_countT    res 1	
    

;************************** setup **************************************
rst	code	0	    ; reset vector
	goto	setup
pdata	code		    ; a section of programme memory for storing data
main	code
; ********************** Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	LCD_Setup	; setup LCD
	goto	start
	
;*****************keyboard set up***********************************************

start	
 	banksel PADCFG1				; PADCFG1 is not in Access Bank
enable	bsf	PADCFG1, REPU, BANKED		; PortE pull-ups on
	movlb	0x00				; set BSR back to Bank 0
	
	clrf	LATE
;***************** read values from EE_PROM memory ********************************************* 
	
	call t3read     ;getting the pre-stored values from the last time the safe was switched on from ee memory
	call t5read	;this routine takes a while 
	call c1read
	call c2read
	call c3read
	call c4read 
	call lockread

;********************* safe setup ********************
	movlw   0x00		;whether the safe is unlocked or locked, port is the input for lock circuit	   
	movwf   TRISJ, ACCESS	
	clrf    PORTJ
	call	delay 
	movff   lock, PORTJ
	
	
	movlw   0xf0			;upper nibbles input lower nibbles output 
	movwf   TRISD, ACCESS		;PORT D output for lEDs
	clrf    PORTD
	call	delay 
	
	
	clrf	wrongflag		;clears wrong pin indicator	 
	call	clear_display		;clears lcd to begin
	
;********************preliminary data collection to see how long delays are****************
;	movlw   0x00	    
;	movwf   TRISJ, ACCESS
;oscill	movlw   0x00			;a four instruction routine output to oscilloscope to measure the length of one execution 
;	movwf   PORTJ, 0 
;        movlw   0xff
;	movwf   PORTJ, 0
;	goto    oscill
	
;******************** ACTION LOOP (lock,unlock,voice unlock, reset pin) *******************;
	
checkb	call	keypad		    ;b on keypad is unlock with pin entry
	movlw	0xeb		    ;eb is column/row no. of button B
	cpfseq	checktostart	    
	goto	checkc
        call	unlockp
	movlw	0x00
	cpfsgt	wrongflag	    ;checks if wrong pin has been flagged, skips if more than 0  
	call	unlock		    ;UNLOCKS THE SAFE

checkc	call	keypad		    ;c on keypad locks the safe
	movlw	0xed		    ;ed is column/row no. of button C
	cpfseq	checktostart	   
	goto	checks	    	    
        call	locker		    ;lock 

checks	call   keypad		    ;* on keypad is unlock with voice entry
	movlw  0x7e		    ;7e is column/row no. of button *
	cpfseq checktostart	    
	goto	check#
	call    voice		    ;calls the voce unlocking subroutine 

check#	call	keypad		    ;# on keypad is reset the pincode
	movlw	0xde		    ;de is column/row no. of button #
	cpfseq	checktostart	   
	goto	checkb
	call	delay
	call	unlockp		    ;if correct pin was entered the wrongflag = 0
	movlw	0x00
	cpfsgt	wrongflag 	
	call	store		    ;calls pin store subroutine 

	goto	checkb		    ;loops back to beginning of ACTION routine 
        


	
;###################### storing pin number #################################
	;routine sets the pincode and stores it into EE_PROM memory 
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
	clrf	lock
	call    lockstore 
	call	Mlock
	movff   lock, PORTH

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

;******************************************************************************************************
	
	call	clear_display    ;when the safe turns off the LCD screen needs to be cleared. can do this by locking the safe 
	end 
	
	
	
