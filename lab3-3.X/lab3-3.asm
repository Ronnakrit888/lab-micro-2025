#include "p16f628.inc"
__CONFIG _CP_OFF & _WDT_OFF & _PWRTE_ON & _HS_OSC

ctr     equ 0x20        ; 1ms counter (runs 1 to 20)
	org 0x000
	goto main
	org 0x004
	goto isr

main
	movlw   0x07        ; Turn off comparators
	movwf   CMCON       ; Set pins to digital I/O mode
    
	banksel TRISB
	clrf    TRISB       ; PORTB as output
	movlw   b'00010000' ; RA4 as input for switch 
	movwf   TRISA
  
	movlw   b'10000001' 
	movwf   OPTION_REG  ; 
	; Bit 5 (TOCS = 0) : Internal Clock
	; Bit 3 (PSA = 0)  : assign To Time Module 
	; Bit 3 (PSA = 0)  : Prescale assign to Timer0
	; Bit 0-2 : Prescale : 1:4
    
	banksel PORTB
	clrf    PORTB       ; 
	clrf    ctr
	
	; Prescale 1:4 = 0.25 Mhz
	; T = 4 us
	; 1000 us / 4 us = 250 tick
	; 256 - 250 = 6
    
	movlw   .6		; Preload for 1ms 
	movwf   TMR0
    
	bsf     INTCON, T0IE	; Enable TMR0 interrupt 
	bsf     INTCON, GIE	; Enable Global interrupt
    

loop
	goto    loop		; Wait for interrupts [cite: 100]

isr
	movlw   .6		; Reload for next 1ms
	movwf   TMR0
	bcf     INTCON, T0IF	; Clear flag 
    
	incf    ctr, F		; Increment 1ms counter
    
    ; Reset cycle if counter reaches 20 (20ms)
	movlw   .20		; Load 20 to w
	subwf   ctr, W		; W - ctr 
	btfsc   STATUS, Z	; 
	clrf    ctr
    
    ; START OF PULSE (At ctr = 0, turn ON)
	movlw   .1
	subwf   ctr, W
	btfsc   STATUS, Z
	bsf     PORTB, 1    ; RB1 High

    ; Check Switch (RA4) to decide when to turn OFF
	btfss   PORTA, 4    ; If RA4 is High, go to Mode 2 (2ms)
	goto    mode_1ms
	goto    mode_2ms

; Turn OFF after 1ms (at ctr = 1)
mode_1ms:   movlw   .1
	    subwf   ctr, W
	    btfss   STATUS, Z
	    bcf     PORTB, 1    ; Turn OFF
	    retfie

; Turn OFF after 2ms (at ctr = 2)
mode_2ms:   movlw   .2
	    subwf   ctr, W
	    btfss   STATUS, Z
	    goto    check_off
	    retfie
	    
check_off:  movlw   .2
	    subwf   ctr, W
	    btfsc   STATUS, C   ; If ctr > 2
	    bcf     PORTB, 1    ; Turn OFF
	    retfie
	    end