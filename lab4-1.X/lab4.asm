;Lab 4-1 Vref module 
#include "p16f628.inc"
__CONFIG _WDT_OFF & _LVP_OFF & _PWRTE_ON & _HS_OSC
	
;	    org	    0x000
;movlw	    0x07	    ; Turn off comparators
;movwf	    CMCON	    ; Set pins to digital/Vref mode
;banksel	    TRISA
;bsf	    TRISA, 2	    ; Set RA2 as input to not interfere with Vref
;banksel	    VRCON	    ;bank 1
;movlw	    b'11001100'	    ;Enable VR, output RA2, high range, lowest voltage 
;	    
;	    ; Bit 7 (VREN) 1 is enable
;	    ; Bit 6 (VROE) 1 is output as RA2
;	    ; Bit 5 (VRR) 1 is Vref Low range, 0 is Vref High range
;	    ; Bit 4  not implement (read as 0)
;	    ; Bit 3-0 (VR)
;	    
;	    ; Vref when VRR = 1 : (VR<3:0> / 24) * VDD
;	    ; Vref when VRR = 0 : 1/4 * VDD + (VR<3:0> / 32) * VDD
;	    
;movwf	    VRCON   ;set VRCON reg.
;goto	    $	    ;halt
;	    end 

;Lab 4-2 Vref & CMP module 
	    org	    0x000	
    banksel	    CMCON	    ;bank
    movlw	    b'00000010'	    ;2 CMP common Vin+ -> VR, CMP1@RA0
    movwf	    CMCON
    
    banksel	    TRISB	    ;bank1
    clrf	    TRISB	    ;PORTB as output
    movlw	    0xaf	    ;Enable VR, output VR, high range
    movwf	    VRCON	    ;set VRCON reg.
    
    banksel	    PORTB	    ;bank0
    movlw	    0xff
    movwf	    PORTB	    ;turn on LED @RB0
    ;b'10101111'
    ;Bit 7 (VREN = 1)
    ;Bit 5 (VRR = 0) High Range
    ;Bit 3-0 (VR = 1111) 15
    ;Vref around 3.59 V
loop	    
    ; If RA0 > Vref (3.59 V) -> C1OUT = 0
    ; If RA0 < Vref (3.59 V) -> C1OUT = 1
    banksel	    CMCON
    btfss	    CMCON, C1OUT
    goto	    led_on
    
led_off
    banksel PORTB
    movlw   0x00            ; OFF LED
    movwf   PORTB
    goto    loop            ; Loop back check

led_on
    
    banksel PORTB
    movlw   0xFF            ; on LED
    movwf   PORTB
    goto    loop            ; Loop back check
    end
    

