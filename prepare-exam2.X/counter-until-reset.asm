list p=16f628a
    #include <p16f628a.inc>
    __CONFIG _HS_OSC & _WDT_OFF & _PWRTE_ON & _LVP_OFF

; --- Register Definitions ---
#define RS  PORTA, 0
#define E   PORTA, 1

; --- Variables ---
W_TEMP    equ 0x20
S_TEMP    equ 0x21
ctr_tmr   equ 0x22    ; Software prescaler for 1 second
sec_count equ 0x23    ; The actual seconds (0-255)
rb0_count equ 0x24    ; Count how many times RB0 was pressed
TEMP_VAL  equ 0x25
HUNDREDS  equ 0x26
TENS      equ 0x27
ONES      equ 0x28

COM	  equ 0x29
DAT	  equ 0x30
count1	  equ 0x31

    org 0x00
    goto main

    org 0x004
    goto isr

main
    movlw   0x07
    movwf   CMCON       ; Set PORTA to digital
    
    call    init_ports
    call    init_lcd
    call    init_ints   ; Setup Timer0 and External RB0
    
    clrf    sec_count
    clrf    rb0_count
    clrf    ctr_tmr

main_loop
    ; Line 1: Display Seconds
    movlw   b'10000000' ; LCD Row 1
    call    wr_ins
    movf    sec_count, W
    call    display_3_digits

    ; Line 2: Display RB0 Reset count
    movlw   b'11000000' ; LCD Row 2
    call    wr_ins
    movf    rb0_count, W
    call    display_3_digits

    goto    main_loop

; --- Interrupt Service Routine ---
isr
    ; Context Saving
    movwf   W_TEMP
    swapf   STATUS, W
    movwf   S_TEMP

    ; Check if Timer0 Interrupt
    btfsc   INTCON, T0IF
    goto    timer_logic

    ; Check if RB0 External Interrupt
    btfsc   INTCON, INTF
    goto    rb0_logic

    goto    exit_isr

timer_logic
    
    ; Basic 4 Mhz
    ; Auto Prescale 4 / 4 = 1 Mhz
    ; 1 Mhz = 1 us
    ; 1 us * 32 = 32 us
    ; 5000 us / 32 us = 156.25 ticks
    ; 256 - 156 = 100
    movlw   .100        ; Reload Timer0 for ~5ms
    movwf   TMR0
    bcf     INTCON, T0IF
    
    incf    ctr_tmr, F
    movlw   .200        ; 200 * 5ms = 1 Second
    subwf   ctr_tmr, W
    btfss   STATUS, Z
    goto    exit_isr
    
    clrf    ctr_tmr     ; One second has passed
    incf    sec_count, F
    goto    exit_isr

rb0_logic
    clrf    sec_count   ; Reset the timer to 0
    incf    rb0_count, F ; Count the reset event
    bcf     INTCON, INTF ; Clear External Flag
    ; Note: In real hardware, add a small delay here for debounce

exit_isr
    swapf   S_TEMP, W
    movwf   STATUS
    swapf   W_TEMP, F
    swapf   W_TEMP, W
    retfie

; --- Initialization ---
init_ports
    banksel TRISA
    clrf    TRISA       ; PORTA = Out
    movlw   0x01        ; RB0 = In, others = Out
    movwf   TRISB
    
    movlw   b'10000100' ; Prescale 1:32
    movwf   OPTION_REG
    banksel PORTB
    return

init_ints
    movlw   .100
    movwf   TMR0
    movlw   b'10110000' ; GIE=1, T0IE=1, INTE=1 (RB0)
    movwf   INTCON
    return

; --- LCD Support (4-bit Mode) ---
display_3_digits
    movwf   TEMP_VAL
    clrf    HUNDREDS
    clrf    TENS
d_100
    movlw   .100
    subwf   TEMP_VAL, W
    btfss   STATUS, C
    goto    d_10
    movwf   TEMP_VAL
    incf    HUNDREDS, F
    goto    d_100
d_10
    movlw   .10
    subwf   TEMP_VAL, W
    btfss   STATUS, C
    goto    d_1
    movwf   TEMP_VAL
    incf    TENS, F
    goto    d_10
d_1
    movf    HUNDREDS, W
    addlw   0x30
    call    wr_data
    movf    TENS, W
    addlw   0x30
    call    wr_data
    movf    TEMP_VAL, W
    addlw   0x30
    call    wr_data
    return

init_lcd
    call    delay_short
    movlw   b'00110010' ; 4-bit mode
    call    wr_ins
    movlw   b'00101000' ; 2 lines
    call    wr_ins
    movlw   b'00001100' ; Display ON
    call    wr_ins
    movlw   b'00000001' ; Clear
    call    wr_ins
    return

wr_ins
    bcf     RS
    goto    lcd_send
wr_data
    bsf     RS
lcd_send
    movwf   DAT
    andlw   0xF0
    movwf   PORTB
    bsf     E
    nop
    bcf     E
    swapf   DAT, W
    andlw   0xF0
    movwf   PORTB
    bsf     E
    nop
    bcf     E
    call    delay_short
    return

delay_short
    movlw   .250
    movwf   count1
lp  decfsz  count1, F
    goto    lp
    return

    end


