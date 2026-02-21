    list p=16f877
    #include<p16f877.inc>
    __CONFIG _CP_OFF & _WDT_OFF & _BODEN_ON & _PWRTE_ON & _HS_OSC &_WRT_ENABLE_ON & _LVP_OFF
    
    org		0x000
    banksel	ADCON1
    bsf		ADCON1, ADFM
    clrf	TRISC
    movlw	0x01
    movwf	TRISA
    
    banksel	ADCON0

main_loop
    call	read_adc
    clrf	PORTC
    call	check_buttons
    goto	main_loop
    
read_adc
    clrf	ADCON0
    bsf		ADCON0, ADCS1
    bsf		ADCON0, ADON
    ;b'10000001'
    
    nop
    nop
    
    bsf		ADCON0,	GO
    
wait_adc
    btfsc	ADCON0, GO
    goto	wait_adc
    return
    
check_buttons
    
    movf    ADRESH, W
    btfsc   STATUS, Z	    ;If ADRESH = 0, check low_range
    goto    check_low_range
    
    ; Check SW1
    sublw   d'2'
    btfss   STATUS, C	    ;IF ADRESH >= 2, It will have Carry Out in instruction 'sublw'
    goto    is_sw1
    
    ; Check SW2
    goto    is_sw2

check_low_range
    banksel ADRESL
    movf    ADRESL, W
    banksel PORTC
    sublw   d'50'
    btfsc   STATUS, C
    goto    leds_off
    
    goto    is_sw3
    
is_sw1
    bsf	    PORTC, 0
    return

is_sw2
    bsf	    PORTC, 1
    return

is_sw3
    bsf	    PORTC, 2
    return

leds_off
    clrf    PORTC
    return
    end
    

    
    
    
    
    
    
    


