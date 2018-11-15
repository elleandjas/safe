
#include p18f87k22.inc
	
	    global      c1store, c2store, c3store, c4store, t3store, t3read, t5read,t5store, c1read, c2read, c3read, c4read
	    extern	code1, code2, code3, code4, threetimes, fivetimes ;external storing codes in programme memory subroutines 

;eedata	idata	    
;eepromdata DE 0x12,0x34,0x56
 
	code	

	
	
;***********************storing values in EECON for next time safe is turned on*********************;
eeconstr	    ; Data Memory Value to write
	bcf	EECON1, EEPGD   ; Point to DATA memory
	bcf	EECON1, CFGS    ; Access EEPROM
	clrf	EECON1
	bsf	EECON1, WREN    ; Enable writes

	movlw	0x55 ;
	movwf	EECON2	; Write 55h
	movlw	0xAA	    ;
	movwf	EECON2		    ; Write 0AAh
	bsf	EECON1, WR		    ; Set WR bit to begin write
	btfsc	EECON1, WR ;	     Wait for write to complete GOTO $-2
	goto	$ - 2			; User code execution
	bcf	EECON1, WREN
	return 			 ; Disable writes on write complete (EEIF set)
	

c1store	
	movlw	0x00 
	movwf	EEADRH	    ; Upper bits of Data Memory Address to write
	movlw	0x01  
	movwf	EEADR
	movf	code1, W	    ; Lower bits of Data Memory Address to write ;
	movwf	EEDATA	 
	call	eeconstr	
	return
	
c2store	
	movlw	0x00 ;
	movwf	EEADRH	    ; Upper bits of Data Memory Address to write
	movlw	0x02  ;
	movwf	EEADR
	movf	code2, W ; Lower bits of Data Memory Address to write ;
	movwf	EEDATA	
	call	eeconstr
	return
	
c3store	movlw	0x00 ;
	movwf	EEADRH	    ; Upper bits of Data Memory Address to write
	movlw	0x03  ;
	movwf	EEADR
	movf	code3, W	; Lower bits of Data Memory Address to write ;
	movwf	EEDATA	
	call	eeconstr
	return
	
c4store	movlw	0x00 ;
	movwf	EEADRH	    ; Upper bits of Data Memory Address to write
	movlw	0x04  ;
	movwf	EEADR
	movf	code4, W	; Lower bits of Data Memory Address to write ;
	movwf	EEDATA	
	call	eeconstr
	return

t3store movlw	0x00 ;
	movwf	EEADRH	    ; Upper bits of Data Memory Address to write
	movlw	0x05  ;
	movwf	EEADR
	movf	threetimes, W; Lower bits of Data Memory Address to write ;
	movwf	EEDATA	
	call	eeconstr
	return
t5store movlw	0x00 ;
	movwf	EEADRH	    ; Upper bits of Data Memory Address to write
	movlw	0x06  ;
	movwf	EEADR
	movf	fivetimes, W; Lower bits of Data Memory Address to write ;
	movwf	EEDATA	
	call	eeconstr
	return

c1read  
	clrf	EEDATA
	movlw	0x00 ;
	movwf	EEADRH ; Upper bits of Data Memory Address to read
	movlw	0x01 ;
	movwf	EEADR ; Lower bits of Data Memory Address to read
	bcf	EECON1, EEPGD ; Point to DATA memory
	bcf	EECON1, CFGS ; Access EEPROM
	bsf	EECON1, RD ; EEPROM Read
	nop
	movf	EEDATA, W ; W = EEDATA	
	movwf   code1, 0    ;store eeprom code1 into code1
	return 
	
c2read  
	movlw	0x00 ;
	movwf	EEADRH ; Upper bits of Data Memory Address to read
	movlw	0x02 ;
	movwf	EEADR ; Lower bits of Data Memory Address to read
	bcf	EECON1, EEPGD ; Point to DATA memory
	bcf	EECON1, CFGS ; Access EEPROM
	bsf	EECON1, RD ; EEPROM Read
	nop
	movf	EEDATA, W ; W = EEDATA	
	movwf   code2, 0 ;store eeprom code2 into code2
	return 
	
c3read  
	movlw	0x00 ;
	movwf	EEADRH ; Upper bits of Data Memory Address to read
	movlw	0x03 ;
	movwf	EEADR ; Lower bits of Data Memory Address to read
	bcf	EECON1, EEPGD ; Point to DATA memory
	bcf	EECON1, CFGS ; Access EEPROM
	bsf	EECON1, RD ; EEPROM Read
	nop
	movf	EEDATA, W ; W = EEDATA	
	movwf   code3, 0 ;store eeprom code2 into code3
	return 
	
c4read  
	movlw	0x00 ;
	movwf	EEADRH ; Upper bits of Data Memory Address to read
	movlw	0x04 ;
	movwf	EEADR ; Lower bits of Data Memory Address to read
	bcf	EECON1, EEPGD ; Point to DATA memory
	bcf	EECON1, CFGS ; Access EEPROM
	bsf	EECON1, RD ; EEPROM Read
	nop
	movf	EEDATA, W ; W = EEDATA	
	movwf   code4, 0 ;setting up three times from last stored value 
	return 
t3read  
	movlw	0x00;
	movwf	EEADRH ; Upper bits of Data Memory Address to read
	movlw	0x05 ;
	movwf	EEADR ; Lower bits of Data Memory Address to read
	bcf	EECON1, EEPGD ; Point to DATA memory
	bcf	EECON1, CFGS ; Access EEPROM
	bsf	EECON1, RD ; EEPROM Read
	nop
	movf	EEDATA, W ; W = EEDATA	
	movwf   threetimes, 0 ;setting up three times from last stored value 
	return 
		
t5read  
	movlw	0x00 ;
	movwf	EEADRH ; Upper bits of Data Memory Address to read
	movlw	0x06 ;
	movwf	EEADR ; Lower bits of Data Memory Address to read
	bcf	EECON1, EEPGD ; Point to DATA memory
	bcf	EECON1, CFGS ; Access EEPROM
	bsf	EECON1, RD ; EEPROM Read
	nop
	movf	EEDATA, W ; W = EEDATA	
	movwf   fivetimes, 0 ;setting up three times from last stored value 
	return 

	
	

	
	end 