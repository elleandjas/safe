	#include p18f87k22.inc
	
	    extern	UART_Setup, UART_Transmit_Message  ; external UART subroutines
	    extern  LCD_Setup, LCD_Write_Message, clear_display, LCD_Send_Byte_I, LCD_delay_x4us, LCD_Send_Byte_D	 	   ; external LCD subroutines
	
	

	    ;**************reserving bytes in access ram**********************
acs0	udata_acs   ; reserve data space in access ram
counter	    res 1   ; reserve one byte for a counter variable
delay_count res 1   ; reserve one byte for counter in the delay routine
comp        res 1
row_store   res 1
col_store   res 1
address     res 1
a0       res 1
a1       res 1
a        res 1
lock     res 1    ;if 0 the safe is unlocked, if 1 the safe is locked
code1	 res 1
code2	 res 1
code3	 res 1
code4	 res 1
checktostart res 1 


		

tables	udata	0x400    ; reserve data anywhere in RAM (here at 0x400)
myArray res 0xff    ; reserve 128 bytes for message data

rst	code	0    ; reset vector
	goto	setup

pdata	code    ; a section of programme memory for storing data

	
	
	;******************data in ****************************	
;myTable 
;	data	    "DCBA#9630852*741\n"	; message, plus carriage return
;	constant    myTable_1 =.16	; length of data	

main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	LCD_Setup	; setup LCD
	goto	start
	
	;*****************keyboard set up******************
	
start	
 	banksel PADCFG1				; PADCFG1 is not in Access Bank!!
enable	bsf PADCFG1, REPU, BANKED		; PortE pull-ups on
	movlb 0x00				; set BSR back to Bank 0
	
	clrf  LATE
	
	
	;*********************safe setup********************
	
locked? movlw  0x00
	movwf  lock, ACCESS       ;making the safe unlocked to start NEED TO FIGURE OUT LOCK MECHANISM
	
myTable	 
	data	    "Choose your pin\n"	; message, plus carriage return
	constant    myTable_1 =.15	; length of data
	
	
keycheck1
	call keypad
	movwf checktostart
	movlw 0xff
	cpfslt checktostart, 0
	goto keycheck1
	movff checktostart, code1
release1
	call keypad
	movwf checktostart
	movlw 0xff
	cpfseq checktostart, 0
	goto release1

	
keycheck2
	call keypad
	movwf checktostart
	movlw 0xff
	cpfslt checktostart, 0
	goto keycheck2
	movff checktostart, code2
release2
	call keypad
	movwf checktostart
	movlw 0xff
	cpfseq checktostart, 0
	goto release2
	
keycheck3
	call keypad
	movwf checktostart
	movlw 0xff
	cpfslt checktostart, 0
	goto keycheck3
	movff checktostart, code3
release3
	call keypad
	movwf checktostart
	movlw 0xff
	cpfseq checktostart, 0
	goto release3

keycheck4
	call keypad
	movwf checktostart
	movlw 0xff
	cpfslt checktostart, 0
	goto keycheck4
	movff checktostart, code4
release4
	call keypad
	movwf checktostart
	movlw 0xff
	cpfseq checktostart, 0
	goto release4
	
	goto $
	

	
	
	
;*******************keypad subroutine****************************	
		

keypad	
outin   movlw 0x0f			;to read the rows 0x0f = 00001111
	movwf TRISE, ACCESS	;inputs 0-3, outputs 4-7
	
rowstore
	movff PORTE, row_store	    ;stores row number 
	call delay
	call delay
inout   movlw 0xf0  	          ;to read th e columns 0xf0 = 1111000
	movwf TRISE, ACCESS       ;outputs 0-3, inputs 4-7
	call delay
	call delay
colstore		    
	movff PORTE, col_store		;column number is stored
	call delay 
	call delay 
	
read    movf  row_store, 0	    ;moving row store to Wreg
	iorwf col_store, 0	    ;OR ing col sotre and row store to get full address of button in 8 bits 
				    ;e.g. 2 = second column, first row = 1011 0111

	return

	
	;*****************comparison subroutine*************
	
compare movlw 0x77
	cpfseq 	checktostart
	goto two
	goto   
two	movlw 0xb7
	cpfseq 	checktostart
	goto three
	return 
three	movlw 0xd7
	cpfseq 	checktostart
	goto four
	return 
four	movlw 0x7b
	cpfseq 	checktostart
	goto five
	return 
five	movlw 0xbb
	cpfseq 	checktostart
	goto six
	return 
six	movlw 0xeb
	cpfseq 	checktostart
	goto seven
	return 
seven	movlw 0x7d
	cpfseq 	checktostart
	goto eight
	return 
eight	movlw 0xbd
	cpfseq 	checktostart
	goto nine
	return 
nine	movlw 0xdd
	cpfseq 	checktostart
	
	return 
	
	
	
	
	;**************put keyboard on to lcd converter ***********
   

rbitcheck 
	movlw 0x03    
	btfss  row_store, 0x03
	movwf  a0, ACCESS
	movlw 0x02    
	btfss  row_store, 0x02
	movwf  a0, ACCESS
	movlw 0x01  
	btfss  row_store, 0x01
	movwf  a0, ACCESS
	movlw 0x00  
	btfss  row_store, 0x00
	movwf  a0, ACCESS
	
	call delay	


cbitcheck 
	movlw 0x03*4    
	btfss  col_store, 0x07
	movwf  a1, ACCESS
	movlw 0x02*4    
	btfss  col_store, 0x06
	movwf  a1, ACCESS
	movlw 0x01*4    
	btfss  col_store, 0x05
	movwf  a1, ACCESS
	movlw 0x00    
	btfss  col_store, 0x04
	movwf  a1, ACCESS
	
	
	call delay
	

adder  movf  a1, 0
       addwf  a0, 0
    
       movwf  a 
   
	call delay	

	
	

	
	; **************loading data into table****************************************
tableload 	

	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	myTable_1	; bytes to read
	movwf 	counter		; our counter register
loop 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter		; count down to zero
	
	
	bra	loop		; keep going until finished
	
	

	;********************output to displays************************		

	
rstart		; output message to LCD (leave out "\n")
	lfsr	FSR2, myArray
	movf    a, 0
	addwf   PLUSW2, 0
	
	
	movlw   0x00
	call	LCD_Write_Message

	

	call delay

     
     
 

    
	;***************** clear lcd *************************
			
LCDclear  
	movlw 0xFF
	movwf TRISD, ACCESS    ;port d is now an input
	movff PORTD, comp
	movlw 0x00
	cpfsgt comp, ACCESS
	goto	LCDclear
	call	clear_display
	
	
	call delay

	goto start  
	
	
	;***********************delay****************************
	; a delay subroutine if you need one, times around loop in delay_count
delay	movlw  0x04
	movwf   delay_count	
delay1	decfsz	delay_count	; decrement until zero
	bra delay1
	return

	

	
	end 
	