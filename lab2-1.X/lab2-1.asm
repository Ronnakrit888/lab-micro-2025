list p=16f628
#include <p16f628a.inc>
	
__CONFIG _HS_OSC & _WDT_OFF & _MCLRE_ON & _CP_OFF & _BOREN_ON & _LVP_OFF

#define	RS  PORTA, 0
#define E   PORTA, 1
    
COM	equ 0x20
DAT	equ 0x21
count1	equ 0x22
count2  equ 0x23
count3	equ 0x24

	org 0x000
	movlw	0x07
	movwf	CMCON
	call	init_lcd
	movlw	"C"
	call	wr_data
	movlw	"o"
	call	wr_data
	movlw	"E"
	call	wr_data
	goto	$

init_lcd
	banksel	TRISA
	movlw	0x00
	movwf	TRISA
	movwf	TRISB
	banksel	PORTA
	clrf	PORTA
	clrf	PORTB
	call	delay
	movlw	b'00110011'	;Set LCD status
	call	wr_ins		;Write command to LCD
	movlw	b'00110010'	;Set LCD status
	call	wr_ins
	movlw	b'00101000'	;4-bit mode, 2 lines, 5x7 char
	call	wr_ins
	movlw	b'00001100'	;turn on LCD, cursor off
	call	wr_ins
	movlw	b'00000110'	;entry mode, incr addr
	call	wr_ins
	movlw	b'00000001'	;clear DDRAM
	call	wr_ins
	return
	
wr_ins
	bcf RS			;RS = 0
	bsf E			;E = 1
	movwf	COM		;Get paramter from w
	andlw	0xf0		;Mask low nibble
	movwf	PORTB		;Send to LCD
	call	enable		;Enable LCD
	swapf	COM,W		;Swap low-high nibble
	andlw	0xf0		;Mask low nibble
	movwf	PORTB		;Send to LCD
	call	enable		;Enable LCD
	return

wr_data
	bsf RS			;RS = 1
	bsf E			;E = 1
	movwf	DAT		;Get parameter from W
	andlw   0xf0		;Mask low nibble
	movwf	PORTB		;Send to LCD
	call	enable
	swapf	DAT,W		;Swap low-high nibble
	andlw	0xf0		;Mask low nibble
	movwf	PORTB
	call	enable
	return

enable	
	bcf E			;E = 0
	call delay
	bsf E			;E = 1
	return

delay	
	movlw	.50		;W = 50 (demical)
	movwf	count1

loop1	clrf	count2
loop2	decfsz	count2
	goto	loop2
	decfsz	count1
	goto	loop1
	return
	end
	
	

