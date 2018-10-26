	#include p18f87k22.inc
	
	    extern	UART_Setup, UART_Transmit_Message  ; external UART subroutines
	    extern  LCD_Setup, LCD_Write_Message, clear_display   ; external LCD subroutines
	
	
	
acs0	udata_acs   ; reserve data space in access ram
counter	    res 1   ; reserve one byte for a counter variable
delay_count res 1   ; reserve one byte for counter in the delay routine
comp        res 1
row_store   res 1
col_store   res 1
address     res 1

;     bsf EECON2, EEPGD
;     bcf EECON2, CFGS
;     BSF EECON2, WREN
;     movlw 0x01
;     
	


tables	udata	0x400    ; reserve data anywhere in RAM (here at 0x400)
myArray res 0xff    ; reserve 128 bytes for message data

rst	code	0    ; reset vector
	goto	setup

pdata	code    ; a section of programme memory for storing data
	
	; ******* myTable, data in programme memory, and its length *****
myTable data	    "Jasmine and elle micros!\n"	; message, plus carriage return
	constant    myTable_l=.24	; length of data
	
main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup LCD
	goto	start
	
	; ******* Main programme ****************************************
start 	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	myTable_l	; bytes to read
	movwf 	counter		; our counter register
loop 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter		; count down to zero
	
	
	
	bra	loop		; keep going until finished
		
rstart	movlw	myTable_l-1	; output message to LCD (leave out "\n")
	lfsr	FSR2, myArray
	call	LCD_Write_Message

	movlw	myTable_l	; output message to UART
	lfsr	FSR2, myArray
	call	UART_Transmit_Message 
	
	call    delay
	call    delay
	
    ;*************** keypad code***************************
	
 	banksel PADCFG1				; PADCFG1 is not in Access Bank!!
enable	bsf PADCFG1, REPU, BANKED		; PortE pull-ups on
	movlb 0x00				; set BSR back to Bank 0
	
	clrf  LATE
	
outin  movlw 0x0f				;reading the rows
	movwf TRISE, ACCESS	;inputs 0-3, outputs 4-7
	
	
	movlw  0x04
	movwf   delay_count
	call delay
	
rowstore
	movff PORTE, row_store	    ;stores row number 
	
inout  movlw 0xf0  	
	movwf TRISE, ACCESS
	
	movlw  0x04
	movwf   delay_count
	call delay
	
colstore
	movff PORTE, col_store
	
read    movf  row_store, 0
	iorwf col_store, 0
	movwf address
	movlw 0x0
	movwf TRISH, ACCESS
	movff address, PORTH

    ;***************** clear lcd *************************
;			
;button  movlw 0xFF
;	movwf TRISD, ACCESS    ;port d is now an input
;	movff PORTD, comp
;	movlw 0x00
;	cpfsgt comp, ACCESS
;	goto	button
;	call	clear_display
	
mynTable data	    "cleared\n"	; message, plus carriage return
	constant    mynTable_l=.22
	
mainn	code
	; ******* Programme FLASH read Setup Code ***********************
setupn	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup LCD
	goto	start
	
	; ******* Main programme ****************************************
startn 	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(mynTable)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(mynTable)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(mynTable)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	mynTable_l	; bytes to read
	movwf 	counter		; our counter register
loopn 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter		; count down to zero
	
	
	
	bra	loop		; keep going until finished
		
rstartn	movlw	mynTable_l-1	; output message to LCD (leave out "\n")
	lfsr	FSR2, myArray
	call	LCD_Write_Message

	movlw	mynTable_l	; output message to UART
	lfsr	FSR2, myArray
	call	UART_Transmit_Message 
	
	call    delay
	
	goto    $  
			; goto current line in code

	; a delay subroutine if you need one, times around loop in delay_count
delay	decfsz	delay_count	; decrement until zero
	bra delay
	return

	
	goto start
	
	end 
	