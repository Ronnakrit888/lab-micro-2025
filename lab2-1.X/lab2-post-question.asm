list p=16f628
#include <p16f628.inc>
	
__CONFIG _HS_OSC & _WDT_OFF & _MCLRE_ON & _CP_OFF & _BOREN_ON & _LVP_OFF

#define	RS  PORTA, 0
#define E   PORTA, 1
#define	RB0 PORTB, 0
#define	RB1 PORTB, 1
#define	RB2 PORTB, 2
#define	RB3 PORTB, 3
    
COM	equ 0x20
DAT	equ 0x21
count1	equ 0x22
count2  equ 0x23
count3	equ 0x24
	
buttonState   equ 0x25
hexChar   equ	0x26

	org 0x000
	movlw	0x07
	movwf	CMCON
	call	init_lcd
	
main_loop
	call read_buttons
	movf	buttonState, w
	call convert_to_hex
	movf	hexChar, w
	call	wr_data
	call	delay
	movlw	b'10000000'	;Move cursor back to home
	call	wr_ins
	goto	main_loop
	goto	$

read_button
	clrf	buttonState
	btfsc	RB3
	bsf	buttonState, 3
	btfsc	RB2
	bsf	buttonState, 2
	btfsc	RB1
	bsf	buttonState, 1
	btfsc	RB0
	bsf	buttonState, 0
	return

convert_to_hex
	movwf	buttonState
	movf	buttonState, w
	andlw	0x0f
	addwf	PCL, f
	retlw	"0"		;0x0
	retlw	"1"		;0x1
	retlw	"2"		;0x2
	retlw	"3"		;0x3
	retlw	"4"		;0x4
	retlw	"5"		;0x5
	retlw	"6"		;0x6
	retlw	"7"		;0x7
	retlw	"8"		;0x8
	retlw	"9"		;0x9
	retlw	"A"		;0xA
	retlw	"B"		;0xB
	retlw	"C"		;0xC
	retlw	"D"		;0xD
	retlw	"E"		;0xE
	retlw	"F"		;0xF
	
init_lcd
	banksel	TRISA
	movlw	0x00
	movwf	TRISA
	movlw	0x0f
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




