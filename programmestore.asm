
#include p18f87k22.inc
	
	    global      c1store, c2store, c3store, c4store, t3store, t3read, t5read, c1read, c2read, c3read, c4read
	    extern	UART_Setup, UART_Transmit_Message  ; external UART subroutines
	    extern	LCD_Setup, LCD_Write_Message, clear_display, LCD_Send_Byte_I, LCD_delay_x4us    ; external LCD subroutines
	    extern	Mnewp, Mpin, Mincpin, M3inc, Mlock, Moldp, Munlock, Msuc, Mstar, Mbreach ;external messages subroutines
	    extern	code1, code2, code3, code4, threetimes, fivetimes ;external storing codes in programme memory subroutines 
	    
		
	code	

	
	
;***********************storing values in EECON for next time safe is turned on*********************;
eeconstr	    ; Data Memory Value to write
	bcf	EECON1, EEPGD   ; Point to DATA memory
	bcf	EECON1, CFGS    ; Access EEPROM
	bsf	EECON1, WREN    ; Enable writes

	bcf	INTCON, GIE		    ; Disable Interrupts
	movlw	0x55 ;
	movwf	EECON2	; Write 55h
	movlw	0xAA	    ;
	movwf	EECON2		    ; Write 0AAh
	bsf	EECON1, WR		    ; Set WR bit to begin write
	btfsc	EECON1, WR ;	     Wait for write to complete GOTO $-2
	bsf	INTCON, GIE		    ; Enable Interrupts		   ; User code execution
	bcf	EECON1, WREN
	return 			 ; Disable writes on write complete (EEIF set)
	

c1store	
	movlw	0x0d 
	movwf	EEADRH	    ; Upper bits of Data Memory Address to write
	movlw	0x0e  
	movwf	EEADR
	movf	code1	    ; Lower bits of Data Memory Address to write ;
	movwf	EEDATA	 
	call	eeconstr	
	return
	
c2store	
	movlw	0x03 ;
	movwf	EEADRH	    ; Upper bits of Data Memory Address to write
	movlw	0x04  ;
	movwf	EEADR
	movf	code2 ; Lower bits of Data Memory Address to write ;
	movwf	EEDATA	
	call	eeconstr
	return
	
c3store	movlw	0x05 ;
	movwf	EEADRH	    ; Upper bits of Data Memory Address to write
	movlw	0x06  ;
	movwf	EEADR
	movf	code3	; Lower bits of Data Memory Address to write ;
	movwf	EEDATA	
	call	eeconstr
	return
	
c4store	movlw	0x07 ;
	movwf	EEADRH	    ; Upper bits of Data Memory Address to write
	movlw	0x08  ;
	movwf	EEADR
	movf	code4	; Lower bits of Data Memory Address to write ;
	movwf	EEDATA	
	call	eeconstr
	return

t3store movlw	0x09 ;
	movwf	EEADRH	    ; Upper bits of Data Memory Address to write
	movlw	0x0a  ;
	movwf	EEADR
	movf	threetimes; Lower bits of Data Memory Address to write ;
	movwf	EEDATA	
	call	eeconstr
	return
t5store movlw	0x0b ;
	movwf	EEADRH	    ; Upper bits of Data Memory Address to write
	movlw	0x0c  ;
	movwf	EEADR
	movf	fivetimes; Lower bits of Data Memory Address to write ;
	movwf	EEDATA	
	call	eeconstr
	return

c1read  
	movlw	0x0d ;
	movwf	EEADRH ; Upper bits of Data Memory Address to read
	movlw	0x0e ;
	movwf	EEADR ; Lower bits of Data Memory Address to read
	bcf	EECON1, EEPGD ; Point to DATA memory
	bcf	EECON1, CFGS ; Access EEPROM
	bcf	EECON1, RD ; EEPROM Read
	nop
	movf	EEDATA, W ; W = EEDATA	
	movwf   threetimes, 0 ;setting up three times from last stored value 
	return 
	
c2read  
	movlw	0x03 ;
	movwf	EEADRH ; Upper bits of Data Memory Address to read
	movlw	0x04 ;
	movwf	EEADR ; Lower bits of Data Memory Address to read
	bcf	EECON1, EEPGD ; Point to DATA memory
	bcf	EECON1, CFGS ; Access EEPROM
	bcf	EECON1, RD ; EEPROM Read
	nop
	movf	EEDATA, W ; W = EEDATA	
	movwf   code2, 0 ;setting up three times from last stored value 
	return 
	
c3read  
	movlw	0x05 ;
	movwf	EEADRH ; Upper bits of Data Memory Address to read
	movlw	0x06 ;
	movwf	EEADR ; Lower bits of Data Memory Address to read
	bcf	EECON1, EEPGD ; Point to DATA memory
	bcf	EECON1, CFGS ; Access EEPROM
	bcf	EECON1, RD ; EEPROM Read
	nop
	movf	EEDATA, W ; W = EEDATA	
	movwf   code3, 0 ;setting up three times from last stored value 
	return 
	
c4read  
	movlw	0x07 ;
	movwf	EEADRH ; Upper bits of Data Memory Address to read
	movlw	0x08 ;
	movwf	EEADR ; Lower bits of Data Memory Address to read
	bcf	EECON1, EEPGD ; Point to DATA memory
	bcf	EECON1, CFGS ; Access EEPROM
	bcf	EECON1, RD ; EEPROM Read
	nop
	movf	EEDATA, W ; W = EEDATA	
	movwf   code4, 0 ;setting up three times from last stored value 
	return 
t3read  
	movlw	0x09 ;
	movwf	EEADRH ; Upper bits of Data Memory Address to read
	movlw	0x0a ;
	movwf	EEADR ; Lower bits of Data Memory Address to read
	bcf	EECON1, EEPGD ; Point to DATA memory
	bcf	EECON1, CFGS ; Access EEPROM
	bcf	EECON1, RD ; EEPROM Read
	nop
	movf	EEDATA, W ; W = EEDATA	
	movwf   threetimes, 0 ;setting up three times from last stored value 
	return 
		
t5read  
	movlw	0x09 ;
	movwf	EEADRH ; Upper bits of Data Memory Address to read
	movlw	0x0a ;
	movwf	EEADR ; Lower bits of Data Memory Address to read
	bcf	EECON1, EEPGD ; Point to DATA memory
	bcf	EECON1, CFGS ; Access EEPROM
	bcf	EECON1, RD ; EEPROM Read
	nop
	movf	EEDATA, W ; W = EEDATA	
	movwf   fivetimes, 0 ;setting up three times from last stored value 
	return 

	
	

	
	end 