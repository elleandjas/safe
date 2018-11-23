#include p18f87k22.inc

	
	extern LCD_Setup, LCD_Write_Message 
	global Mnewp, Mpin, Mincpin, M3inc, Mlock,Moldp, Munlock, Msuc, Mstar, Mbreach, Mspeak
	
	
acs0		udata_acs   ; reserve data space in access ram
counter		res 1	    ; reserve byte for onter used in writeLCD subroutine
myTable_1	res 1       ; storage byte for the length of the message


;acs_ovr         access_ovr 		

tables		udata	0x400		
myArray		res 0xff	    ; reserve 128 bytes for message data
	
		
	code	
;**************loading data into table****************************************
writeLCD1 	
	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable1)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable1)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable1)	; address of data in PM
	call    writeLCD	; universal write to LCD subroutine using TBLD
	return 
	
writeLCD2 	
	lfsr	FSR0, myArray	
	movlw	upper(myTable2)		
	movwf	TBLPTRU		
	movlw	high(myTable2)		
	movwf	TBLPTRH		
	movlw	low(myTable2)	
	return 	

writeLCD3 	

	lfsr	FSR0, myArray	
	movlw	upper(myTable3)		
	movwf	TBLPTRU		
	movlw	high(myTable3)		
	movwf	TBLPTRH		
	movlw	low(myTable3)	
	call    writeLCD
	return 

writeLCD4 	
	lfsr	FSR0, myArray	
	movlw	upper(myTable4)		
	movwf	TBLPTRU		
	movlw	high(myTable4)		
	movwf	TBLPTRH		
	movlw	low(myTable4)	
	call    writeLCD
	return 
	
writeLCD5 	
	lfsr	FSR0, myArray		
	movlw	upper(myTable5)		
	movwf	TBLPTRU		
	movlw	high(myTable5)		
	movwf	TBLPTRH		
	movlw	low(myTable5)	
	call    writeLCD
	return 
	
writeLCD6 	
	lfsr	FSR0, myArray	
	movlw	upper(myTable6)		
	movwf	TBLPTRU		
	movlw	high(myTable6)		
	movwf	TBLPTRH		
	movlw	low(myTable6)	
	call    writeLCD
	return 

writeLCD7 	
	lfsr	FSR0, myArray	
	movlw	upper(myTable7)		
	movwf	TBLPTRU		
	movlw	high(myTable7)		
	movwf	TBLPTRH		
	movlw	low(myTable7)	
	call    writeLCD
	return 
	
writeLCD8 	
	lfsr	FSR0, myArray	
	movlw	upper(myTable8)		
	movwf	TBLPTRU		
	movlw	high(myTable8)		
	movwf	TBLPTRH		
	movlw	low(myTable8)	
	call    writeLCD
	return 

writeLCD9 	
	lfsr	FSR0, myArray	
	movlw	upper(myTable9)		
	movwf	TBLPTRU		
	movlw	high(myTable9)		
	movwf	TBLPTRH		
	movlw	low(myTable9)	
	call    writeLCD
	return 

writeLCD10 	
	lfsr	FSR0, myArray	
	movlw	upper(myTable10)		
	movwf	TBLPTRU		
	movlw	high(myTable10)		
	movwf	TBLPTRH		
	movlw	low(myTable10)	
	call    writeLCD
	return 	
	
writeLCD11 	
	lfsr	FSR0, myArray	
	movlw	upper(myTable11)		
	movwf	TBLPTRU		
	movlw	high(myTable11)		
	movwf	TBLPTRH		
	movlw	low(myTable11)	
	call    writeLCD
	return 	

	
	
writeLCD			; subroutine called by each message 
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
	
myTable1 	 
Mnewp	data	    "Enter new pin\n"	; message, plus carriage return       
	movlw       .13			; length of data
	movwf       myTable_1		; storing length in myTable_1
	call        writeLCD1		; subroutine that writes to the LCD
	return
myTable2	
Mpin	data	    "Enter pin\n"	; message, plus carriage return
	movlw       .9			; length of data
	movwf       myTable_1
	call        writeLCD2
	return
myTable3 	
Moldp	data	    "Enter old pin\n"	; message, plus carriage return
	movlw       .13			; length of data
	movwf       myTable_1	
	call        writeLCD3
	return

myTable4	
Mincpin	data	    "Incorrect\n"	; message, plus carriage return
	movlw       .9		; length of data
	movwf       myTable_1
	call        writeLCD4
	return
myTable5	
M3inc	data	    "3 incorrect, locked\n"	; message, plus carriage return
	movlw       .19			; length of data
	movwf       myTable_1
	call        writeLCD
	return
myTable6	
Mlock	data	    "LOCKED\n"	; message, plus carriage return
	movlw       .6			; length of data
	movwf       myTable_1	
	call        writeLCD6
	return
myTable7	
Munlock	data	    "UNLOCKED\n"	; message, plus carriage return
	movlw       .8			; length of data
	movwf       myTable_1	
	call        writeLCD7
	return
	
myTable8	
Msuc	data	    "Success\n"	; message, plus carriage return
	movlw       .7			; length of data
	movwf       myTable_1	
	call        writeLCD8
	return
	
myTable9	
Mstar	data	    "*\n"	; message, plus carriage return
	movlw       .1			; length of data
	movwf       myTable_1	
	call        writeLCD9
	return
	
myTable10	
Mbreach	data	    "SAFE BREACH\n"	; message, plus carriage return
	movlw       .11			; length of data
	movwf       myTable_1	
	call        writeLCD10
	return	
myTable11 
Mspeak  data       "Speak now\n"
	movlw       .9			; length of data
	movwf       myTable_1	
	call        writeLCD11
	return		
	
	end
