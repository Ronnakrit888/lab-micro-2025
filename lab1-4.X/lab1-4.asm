    list p=16f628
    #include <p16f628.inc>
	
    __CONFIG _HS_OSC & _WDT_OFF & _MCLRE_ON & _CP_OFF & _BOREN_ON & _LVP_OFF
   
    org 0x000
    goto start
    org 0x004
    goto int_serv
    
start	
	bsf     STATUS, RP0     ; Select Bank 1
	movlw	b'00111111'	;select Ext. Int. Rising Edge
	movwf	OPTION_REG
	movlw	b'11111110'	;assign PORTA0 as output, other as input
	movwf	TRISA	
	movlw	b'11110000'	;assign PORTB0-3 as output, other as input
	movwf	TRISB
	bcf     STATUS, RP0     ; NEW: Return to Bank 0

	movlw	0x07		;turn off comparator
	movwf	CMCON
	movf	PORTB, W
	clrf	PORTA		;initialize PORTA
	
	bcf INTCON,  RBIF	;clear RB change Flag
	bsf INTCON,  GIE	;enable GIE
	bsf INTCON,  RBIE	;enables the RB port change interrupt
	
loop    goto    loop

int_serv    movlw   b'00000001'
	    movwf   PORTA
	    movf    PORTB, W
	    bcf	    INTCON, RBIF
	    retfie                  ; NEW: Return to main code
	    end
	
	





