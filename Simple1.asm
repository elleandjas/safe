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
character   res 1
a0       res 1
a1       res 1
a        res 1

	
	
	
	

tables	udata	0x400    ; reserve data anywhere in RAM (here at 0x400)
myArray res 0xff    ; reserve 128 bytes for message data

rst	code	0    ; reset vector
	goto	setup

pdata	code    ; a section of programme memory for storing data

	
	
	;******************data in ****************************	
myTable 
	data	    "DCBA#9630852*741\n"	; message, plus carriage return
	constant    myTable_1 =.16	; length of data	

main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup LCD
	goto	start
	
	;*****************keyboard ******************
start  
 	banksel PADCFG1				; PADCFG1 is not in Access Bank!!
enable	bsf PADCFG1, REPU, BANKED		; PortE pull-ups on
	movlb 0x00				; set BSR back to Bank 0
	
	clrf  LATE
	
outin   movlw 0x0f				;reading the rows
	movwf TRISE, ACCESS	;inputs 0-3, outputs 4-7
	
	
	movlw  0xff
	movwf   delay_count
	call delay
	
rowstore
	movff PORTE, row_store	    ;stores row number 
	
inout  movlw 0xf0  	
	movwf TRISE, ACCESS
	
	
	movlw  0xff
	movwf   delay_count
	call delay
	
colstore
	movff PORTE, col_store
	
read    movf  row_store, 0
	iorwf col_store, 0
	movwf address
	movlw 0x00
	movwf TRISH, ACCESS
	movff address, PORTH
	
	;**************put keyboard on to lcd converter ***********
;	
;one	movlw  b'00110001'
;	movwf  0x77, ACCESS
 ;********************************************     

 
 
 
 
 

rbitcheck 
	movlw 0x00    
	btfss  col_store, 0x00
	movwf  a0, ACCESS
	movlw 0x01    
	btfss  col_store, 0x01
	movwf  a0, ACCESS
	movlw 0x02  
	btfss  col_store, 0x02
	movwf  a0, ACCESS
	movlw 0x03    
	btfss  col_store, 0x03
	movwf  a0, ACCESS
	
	movlw  0xff
     movwf   delay_count
     call delay	


cbitcheck 
	movlw 0x03    
	btfss  col_store, 0x03
	movwf  a1, ACCESS
	movlw 0x02    
	btfss  col_store, 0x02
	movwf  a1, ACCESS
	movlw 0x01    
	btfss  col_store, 0x01
	movwf  a1, ACCESS
	movlw 0x00    
	btfss  col_store, 0x00
	movwf  a1, ACCESS
	
	
	
	
	movlw  0xff
	movwf   delay_count
	call delay
	

adder  movf  a1, 0
       addwf  a1
       addwf  a1
       addwf  a1
       addwf  a0
       movf   a0
       movwf  a 
       
     movlw  0xff
     movwf   delay_count
     call delay	

	
;     movlw      b'11110000'
;     movf      address
;     lfsr	FSR2, 0
      
;     movlw      0x01
;     call	LCD_Write_Message 
	

	
	; **************loading data into table****************************************
tableloa 	

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
	
	  movlw  0xff
     movwf   delay_count
     call delay	


	;********************output to displays************************		
rstart		; output message to LCD (leave out "\n")
	lfsr	FSR2, myArray
	movf    a, 0
	addwf   PLUSW2, 0
	
	
	movlw   0x01 
	call	LCD_Write_Message

;	movlw	myTable_1	; output message to UART
;	lfsr	FSR2, myArray
;	call	UART_Transmit_Message 
	
	movlw  0xff
	movwf   delay_count
	call delay

     
     
   

    
	;***************** clear lcd *************************
;			
;button  movlw 0xFF
;	movwf TRISD, ACCESS    ;port d is now an input
;	movff PORTD, comp
;	movlw 0x00
;	cpfsgt comp, ACCESS
;	goto	button
;	call	clear_display

	;***********************delay****************************
	; a delay subroutine if you need one, times around loop in delay_count
delay	decfsz	delay_count	; decrement until zero
	bra delay
	return

	
	goto start
	
	end 
	