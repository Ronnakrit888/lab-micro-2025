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
	movlw	b'11111111'	;assign PORTA as input
	movwf	TRISA	
	movlw	b'00000001'	;assign PORTB0 as input, other as output
	movwf	TRISB
	bcf     STATUS, RP0     ; NEW: Return to Bank 0

	movlw	0x07		;turn off comparator
	movwf	CMCON
	clrf	PORTB
	clrf	PORTA		;initialize PORTA
	
	bcf INTCON,  1		;clear INT Flag
	bsf INTCON,  7		;enable GIE
	bsf INTCON,  4		;enable Ext. Int.

test	btfss	PORTA, 0	;check PORTA0
	goto	clrb_1		;if PORTA0 = 0, goto clrb_1
	bsf	PORTB, 1	;if PORTA0 = 1, PORTB1 = 1
	goto	test		;check PORTA0 again
clrb_1	bcf	PORTB, 1
	goto	test
int_serv    bsf	    PORTB,2	;if Ext. Int. occurs
	    bcf	    INTCON, INTF	; NEW: Clear the flag so it doesn't loop forever
	    retfie                  ; NEW: Return to main code
	    end
	
	
