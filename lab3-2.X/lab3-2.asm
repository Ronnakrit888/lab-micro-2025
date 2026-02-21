#include "p16f628.inc"
__CONFIG _CP_OFF & _WDT_OFF & _PWRTE_ON & _HS_OSC
    
    org 0x00
    goto main
    org	0x004
    goto isr
    
main
    banksel	TRISB		;switch to TRISB reg. bank
    clrf	TRISB		;PORTB is output
    movlw	b'10100001'	;set prescaler to TMR0
    banksel	OPTION_REG	;switch to OPTION reg. bank
    movwf	OPTION_REG	;set OPTION reg. value
    
    ; Bit 5 (TOCS = 1) : Counter Mode
    ; Bit 4 (TOSE = 0) : Rising Edge
    ; Bit 3 (PSA = 0)  : Prescale assign to Timer0
    ; Bit 0-2 : Prescale : 1:4 ( Click 4 times to make it call 1 interupt)
    
    banksel	PORTB		;switch to PORTB bank
    clrf	PORTB		;output = 0
    bsf		INTCON,T0IE	;enable TMR0 interrupt
    movlw	.255		;counter value start at 255 (decimal)
    movwf	TMR0		;start counter
    bsf		INTCON,GIE	;enable Global int
    
loop
    goto	loop		;wait for external clock
isr
    movlw	.255		;counter value start at 255 
    movwf	TMR0		;start counter
    bcf		INTCON, T0IF	;clear TMR0 int. flag
    comf	PORTB,F		;toggle PORTB
    retfie
    end


