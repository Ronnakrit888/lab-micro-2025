    list p=16f628
    #include <p16f628.inc>
	
    __CONFIG _HS_OSC & _WDT_OFF & _MCLRE_ON & _CP_OFF & _BOREN_ON & _LVP_OFF
    
    int_count	equ 0x20

    org 0x000
    goto start
    org 0x004
    goto int_serv
    
start	
	bsf     STATUS, RP0     ; Select Bank 1
	movlw	b'00111111'	;select Ext. Int. Rising Edge
	movwf	OPTION_REG
	movlw	b'11110000'	;assign PORTA0-3 as output, other as input
	movwf	TRISA	
	movlw	b'00000001'	;assign PORTB0 as input, other as output
	movwf	TRISB
	bcf     STATUS, RP0     ; NEW: Return to Bank 0

	movlw	0x07		;turn off comparator
	movwf	CMCON
	clrf	PORTB
	clrf	PORTA		;initialize PORTA
	clrf	int_count
	
	bcf INTCON,  INTF	;clear INT Flag
	bsf INTCON,  GIE	;enable GIE
	bsf INTCON,  INTE	;enable Ext. Int.
	
loop    goto    loop

int_serv    incf    int_count, F
	    movf    int_count, W
	    andlw   0x0f
	    movwf   PORTA
	    bcf	    INTCON, INTF
	    retfie                  ; NEW: Return to main code
	    end
	
	


