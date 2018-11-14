#include p18f87k22.inc

	
	extern LCD_Setup, LCD_Write_Message 
	extern delay
	global Mnewp, Mpin, Mincpin, M3inc, Mlock,Moldp, Munlock, Msuc, Mstar, Mbreach, Mspeak
	
	
acs0		udata_acs   ; reserve data space in access ram
counter		res 1	
myTable_1	res 1


acs_ovr         access_ovr 		

tables		udata	0x400		
myArray		res 0xff	    ; reserve 128 bytes for message data
	
		
	code	
;**************loading data into table****************************************
writeLCD1 	
	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable1)		; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable1)		; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable1)	; address of data in PM
	call    writeLCD
	return 
	
writeLCD2 	
	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable2)		; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable2)		; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable2)	; address of data in PM
	call    writeLCD
	return 	

writeLCD3 	

	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable3)		; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable3)		; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable3)	; address of data in PM
	call    writeLCD
	return 

writeLCD4 	
	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable4)		; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable4)		; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable4)	; address of data in PM
	call    writeLCD
	return 
	
writeLCD5 	
	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable5)		; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable5)		; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable5)	; address of data in PM
	call    writeLCD
	return 
	
writeLCD6 	
	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable6)		; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable6)		; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable6)	; address of data in PM
	call    writeLCD
	return 

writeLCD7 	
	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable7)		; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable7)		; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable7)	; address of data in PM
	call    writeLCD
	return 
	
writeLCD8 	
	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable8)		; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable8)		; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable8)	; address of data in PM
	call    writeLCD
	return 

writeLCD9 	
	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable9)		; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable9)		; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable9)	; address of data in PM
	call    writeLCD
	return 

writeLCD10 	
	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable10)		; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable10)		; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable10)	; address of data in PM
	call    writeLCD
	return 	
	
writeLCD11 	
	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable11)		; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable11)		; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable11)	; address of data in PM
	call    writeLCD
	return 	

writeLCD
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
	movlw       .13		; length of data
	movwf       myTable_1
	call        writeLCD1
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
;	
;***************************EE PROM ROUTINE *********************************************
;#include p18f87k22.inc
;	
;	    global      c1store, c2store, c3store, c4store, t3store, t3read
;	    extern	UART_Setup, UART_Transmit_Message  ; external UART subroutines
;	    extern	LCD_Setup, LCD_Write_Message, clear_display, LCD_Send_Byte_I, LCD_delay_x4us    ; external LCD subroutines
;	    extern	Mnewp, Mpin, Mincpin, M3inc, Mlock, Moldp, Munlock, Msuc, Mstar, Mbreach ;external messages subroutines
;	    extern	code1, code2, code3, code4, threetimes 
;	    
;	    
;acs0		udata_acs   ; reserve data space in access ram
;counter		res 1	
;myTable_1	res 1
;meesage1	res 1
;message2	res 1
;message3	res 1
;
;acs_ovr         access_ovr 		
;
;tables		udata	0x400		
;myArray		res 0xff	    ; reserve 128 bytes for message data
;	
;		
;	code	
;
;;***********************storing values in EECON for next time safe is turned on*********************;
;c1store	
;	movlw	0x01 
;	movwf	EEADRH	    ; Upper bits of Data Memory Address to write
;	movlw	0x02  
;	movwf	EEADR
;	movf	code1	    ; Lower bits of Data Memory Address to write ;
;	movwf	EEDATA	 
;	call	eeconstr	
;	return
;	
;c2store	
;	movlw	0x03 ;
;	movwf	EEADRH	    ; Upper bits of Data Memory Address to write
;	movlw	0x04  ;
;	movwf	EEADR
;	movf	code2 ; Lower bits of Data Memory Address to write ;
;	movwf	EEDATA	
;	call	eeconstr
;	return
;	
;c3store	movlw	0x05 ;
;	movwf	EEADRH	    ; Upper bits of Data Memory Address to write
;	movlw	0x06  ;
;	movwf	EEADR
;	movf	code3	; Lower bits of Data Memory Address to write ;
;	movwf	EEDATA	
;	call	eeconstr
;	return
;	
;c4store	movlw	0x07 ;
;	movwf	EEADRH	    ; Upper bits of Data Memory Address to write
;	movlw	0x08  ;
;	movwf	EEADR
;	movf	code4	; Lower bits of Data Memory Address to write ;
;	movwf	EEDATA	
;	call	eeconstr
;	return
;
;t3store movlw	0x09 ;
;	movwf	EEADRH	    ; Upper bits of Data Memory Address to write
;	movlw	0x0a  ;
;	movwf	EEADR
;	movf	threetimes; Lower bits of Data Memory Address to write ;
;	movwf	EEDATA	
;	call	eeconstr
;	return
;	
;t3read  
;	movlw	0x09 ;
;	movwf	EEADRH ; Upper bits of Data Memory Address to read
;	movlw	0x0a ;
;	movwf	EEADR ; Lower bits of Data Memory Address to read
;	bcf	EECON1, EEPGD ; Point to DATA memory
;	bcf	EECON1, CFGS ; Access EEPROM
;	bcf	EECON1, RD ; EEPROM Read
;	nop
;	movf	EEDATA, W ; W = EEDATA	
;	movwf   threetimes, 0 ;setting up three times from last stored value 
;	return 
;	
;eeconstr	    ; Data Memory Value to write
;	bcf	EECON1, EEPGD   ; Point to DATA memory
;	bcf	EECON1, CFGS    ; Access EEPROM
;	bsf	EECON1, WREN    ; Enable writes
;
;	bcf	INTCON, GIE		    ; Disable Interrupts
;	movlw	0x55 ;
;	movwf	EECON2	; Write 55h
;	movlw	0xAA	    ;
;	movwf	EECON2		    ; Write 0AAh
;	bsf	EECON1, WR		    ; Set WR bit to begin write
;	btfsc	EECON1, WR ;	     Wait for write to complete GOTO $-2
;	bsf	INTCON, GIE		    ; Enable Interrupts		   ; User code execution
;	bcf	EECON1, WREN
;	return 			 ; Disable writes on write complete (EEIF set)
;	
;	
;	end 