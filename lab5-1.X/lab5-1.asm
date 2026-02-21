    list p=16f877
    #include<p16f877.inc>
    __CONFIG _CP_OFF & _WDT_OFF & _BODEN_ON & _PWRTE_ON & _HS_OSC &_WRT_ENABLE_ON & _LVP_OFF
    
    org	    0x000
    banksel ADCON1
    bsf	    ADCON1, ADFM
    ;1 = Right justified. 6 Most Significant bits of ADRESH are read as ?0?.
    ;0 = Left justified. 6 Least Significant bits of ADRESL are read as ?0?.
    
    movlw   0x00
    movwf   TRISB	;PORTB is output
    movwf   TRISC	;PORTC is output
    
    banksel ADCON0
    movlw   b'10000001'	;clk=Fosc/32
    movwf   ADCON0
    
next
    bsf	    ADCON0, 2	;Go!
    
loop
    btfsc   ADCON0, 2	;Wait until DONE = 0
    goto    loop
    
    banksel ADRESL	;Bank 1
    movf    ADRESL, W	;Get Result
    
    banksel PORTC	;Bank 0
    movwf   PORTC	;Display
    movf    ADRESH, W	;Get Result
    movwf   PORTB	;Display
    goto    next	;Next Conversion
    end
    
    
    
    
    
    
    
    
    
    
    
    


