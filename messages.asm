#include p18f87k22.inc

	
	extern LCD_Setup, LCD_Write_Message 
	extern delay
	global Mnewp, Mpin, Mincpin;, M3inc, MlockMoldp, 
	
	
acs0		udata_acs   ; reserve data space in access ram
counter		res 1	
myTable_1	res 1

acs_ovr         access_ovr 		

tables		udata	0x400		
myArray		res 0xff	    ; reserve 128 bytes for message data
	
		
	code	
;**************loading data into table****************************************
writeLCD 	

	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movf	myTable_1, 0	; bytes to read
	movwf 	counter		; our counter register
loop 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter		; count down to zero
	
	bra	loop		; keep going until finished
	
	movf    myTable_1, 0
	lfsr	FSR2, myArray
	
	call	LCD_Write_Message

	return
;**********************messages*************************     
	
	
myTable	 

Mnewp	data	    "Enter new pin\n"	; message, plus carriage return
	movlw       .14         ; length of data
	movwf       myTable_1
	call        writeLCD
	return
	
	
Mpin	data	    "Enter pin\n"	; message, plus carriage return
	movlw       .10        ; length of data
	movwf       myTable_1
	call        writeLCD
	return
	
	
;Moldp	data	    "Enter old pin\n"	; message, plus carriage return
;	constant    myTable_1 =.14	; length of data
;	call        writeLCD
;	return
	
	
Mincpin	data	    "Incorrect\n"	; message, plus carriage return
	movlw       .10         ; length of data
	movwf       myTable_1
	call        writeLCD
	return
	
;M3inc	data	    "3 incorrect, locked\n"	; message, plus carriage return
;	constant    myTable_1 =.20	; length of data
;	call        writeLCD
;	return
;	
;Mlock	data	    "LOCKED\n"	; message, plus carriage return
;	constant    myTable_1 =.7	; length of data
;	call        writeLCD
;	return
	
	

	
	end