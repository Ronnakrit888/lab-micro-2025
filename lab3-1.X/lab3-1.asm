#include "p16f628.inc"
__CONFIG _CP_OFF & _WDT_OFF & _PWRTE_ON & _HS_OSC
ctr equ	0x20
    org 0x00
    goto main
    org	0x004
    goto isr
    
main 
    movlw	0xff
    banksel	TRISB
    clrf	TRISB
    movlw	TRISA
    movlw	b'10000100'	; Prescale (1:32)
    banksel	OPTION_REG
    movwf	OPTION_REG
    banksel	PORTB

    clrf PORTB		;output = 0
    bsf INTCON,T0IE	;enable TMR0 interrupt
    
    ; Basic 4 Mhz
    ; Auto Prescale 4/4 = 1 Mhz
    ; 1 Mhz = 1 us
    ; 1 us * 32 = 32 us
    ; 5000 us / 32 us = 156.25 ticks
    ; 256 - 156 = 100 
    
    movlw .100		;timer value = 100 (decimal)->(4.992 mS)
    movwf TMR0		;start timer
    bsf INTCON,GIE	;enable Global interrupt
    clrf ctr
	
loop
    goto loop		;wait for timer overflow
isr
    movlw .100		;timer value for 5mS next int. 
    movwf TMR0		;start timer
    bcf INTCON, T0IF	;clear TMR0 int. flag
    
    ; 1 Interrupt happens every 4.992 ms
    ; 1 Sec (1000 ms) : 1000 / 4.992 = 200.32 Interrupt
    
    incf ctr,F		;add 1 to our software counter
    movlw .200		;200 x 4.992 mS = 1 Sec.
    subwf ctr, W	;subtract W from our counter
    btfss STATUS, Z	;is the result Zero? (Does ctr == 196?)
    retfie		;NO: Not a full second yet, go back to main loop
    comf PORTB,F	;YES: 1 second has passed! Toggle all bits on PORTB
    clrf ctr		;Reset software counter for the next second
    retfie		;Return to main loop
    end


