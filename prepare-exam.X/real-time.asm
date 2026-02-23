list p=16f628a
    #include <p16f628a.inc>
    
    __CONFIG _HS_OSC & _WDT_OFF & _MCLRE_ON & _CP_OFF & _BOREN_ON & _LVP_OFF
    
; --- Define Pins ---
#define RS  PORTA, 0
#define E   PORTA, 1

; --- Variables (RAM) ---
COM      equ 0x20
DAT      equ 0x21
counter  equ 0x22
count1   equ 0x23
count2   equ 0x24
W_TEMP   equ 0x25    ; ???????????? W ??????? Interrupt
S_TEMP   equ 0x26    ; ???????????? STATUS ??????? Interrupt
HUNDREDS equ 0x27    ; ???????????????
TENS     equ 0x28    ; ??????????????
ONES     equ 0x29    ; ????????????????
TEMP_VAL equ 0x2A    ; ???????????????????????

    org 0x000
    goto main

    org 0x004        ; Interrupt Vector
    goto int_serv

main
    movlw   0x07
    movwf   CMCON    ; ??? Comparator ??? PORTA ???? Digital
    
    call    init_lcd
    call    init_interrupt
    
    clrf    counter  ; ??????????? 0

main_loop
    ; ???????????????????? 1
    movlw   b'10000000' ; ?????????????????????? 1 ???? 1
    call    wr_ins
    
    movlw   'C'
    call    wr_data
    movlw   'o'
    call    wr_data
    movlw   'u'
    call    wr_data
    movlw   'n'
    call    wr_data
    movlw   't'
    call    wr_data
    movlw   ':'
    call    wr_data

    ; ????????????? counter
    call    display_counter
    
    goto    main_loop

; --- LCD Initialization ---
init_lcd
    banksel TRISA
    clrf    TRISA       ; PORTA ???? Output
    movlw   b'00000001' ; RB0 ???? Input (??????)
    movwf   TRISB
    banksel PORTA
    
    call    delay
    movlw   b'00110011' ; Reset sequence
    call    wr_ins
    movlw   b'00110010' ; Set 4-bit mode
    call    wr_ins
    movlw   b'00101000' ; 2 lines, 5x7 font
    call    wr_ins
    movlw   b'00001100' ; Display ON, Cursor OFF
    call    wr_ins
    movlw   b'00000001' ; Clear screen
    call    wr_ins
    return

; --- Interrupt Setup ---
init_interrupt
    bsf     INTCON, GIE  ; Global Interrupt Enable
    bsf     INTCON, INTE ; External Interrupt Enable (RB0)
    bcf     INTCON, INTF ; Clear Flag
    return

; --- Interrupt Service Routine ---
int_serv
    ; 1. Context Saving
    movwf   W_TEMP
    swapf   STATUS, W
    movwf   S_TEMP

    ; 2. Check source
    btfss   INTCON, INTF
    goto    exit_int

    ; 3. Logic: Increment Counter
    incf    counter, F

    ; 4. Clear Flag
    bcf     INTCON, INTF

exit_int
    ; 5. Context Restore
    swapf   S_TEMP, W
    movwf   STATUS
    swapf   W_TEMP, F
    swapf   W_TEMP, W
    retfie

; --- Display Logic (Binary to ASCII) ---
display_counter
    movf    counter, W
    movwf   TEMP_VAL
    clrf    HUNDREDS
    clrf    TENS

    ; ??????????
find_100
    movlw   .100
    subwf   TEMP_VAL, W
    btfss   STATUS, C
    goto    find_10
    movwf   TEMP_VAL
    incf    HUNDREDS, F
    goto    find_100

    ; ?????????
find_10
    movlw   .10
    subwf   TEMP_VAL, W
    btfss   STATUS, C
    goto    find_1
    movwf   TEMP_VAL
    incf    TENS, F
    goto    find_10

find_1
    movf    TEMP_VAL, W
    movwf   ONES

    ; ????????? LCD (??? 0x30 ??????????????? ASCII)
    movf    HUNDREDS, W
    addlw   0x30
    call    wr_data
    movf    TENS, W
    addlw   0x30
    call    wr_data
    movf    ONES, W
    addlw   0x30
    call    wr_data
    return

; --- LCD Functions (4-bit Mode) ---
wr_ins
    movwf   COM
    bcf     RS          ; Command mode
    goto    send_nibbles

wr_data
    movwf   COM
    bsf     RS          ; Data mode

send_nibbles
    ; Send High Nibble
    movf    COM, W
    andlw   0xF0
    movwf   PORTB
    call    strobe
    ; Send Low Nibble
    swapf   COM, W
    andlw   0xF0
    movwf   PORTB
    call    strobe
    call    delay
    return

strobe
    bsf     E
    nop
    bcf     E
    return

delay
    movlw   .20
    movwf   count1
d_loop1
    clrf    count2
d_loop2
    decfsz  count2, F
    goto    d_loop2
    decfsz  count1, F
    goto    d_loop1
    return

    end