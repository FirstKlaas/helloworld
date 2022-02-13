.macro PRINT_CHR_VVV(xpos,ypos,chr) {
    PUSH_AXY()
    lda #chr
    ldx #xpos 
    ldy #ypos
    jsr SCREEN.print_char
    PULL_AXY() 
}

.macro PRINT_HEX_VVV(xpos, ypos, value) {
    PUSH_AXY()
    ldx #xpos
    ldy #ypos
    lda #value
    jsr SCREEN.print_hex
    PULL_AXY()
}

.macro PRINT_HEX_VVA(xpos, ypos, value_addr) {
    ldx #xpos
    ldy #ypos
    lda value_addr
    jsr SCREEN.print_hex
}

.macro PRINT_HEX_VVACC(xpos, ypos) {
    ldx #xpos
    ldy #ypos
    jsr SCREEN.print_hex
}

.macro PRINT_STR_ZERO(xpos, ypos, msg) {
    lda #<msg 
    sta stringLo 
    lda #>msg  
    sta stringHi 
    ldx #xpos
    ldy #ypos
    jsr SCREEN.print_zero_str 
}

.macro PRINT_FAST_CHAR_AAV(xpos, ypos, char) {
    ldx ypos 
    ldy xpos
    lda SCREEN.ROW_ADR.hi, x
    sta num1Hi
    lda SCREEN.ROW_ADR.lo ,x
    sta num1
    lda #char
    sta (num1),y 
}

.macro PRINT_FAST_CHAR_AAA(xpos, ypos, char) {
    ldx ypos 
    ldy xpos
    lda SCREEN.ROW_ADR.hi, x
    sta num1Hi
    lda SCREEN.ROW_ADR.lo ,x
    sta num1
    lda char
    sta (num1),y 
}

.macro PRINT_FAST_CHAR_AAACC(xpos, ypos) {
    pha
    ldx ypos 
    ldy xpos
    lda SCREEN.ROW_ADR.hi, x
    sta num1Hi
    lda SCREEN.ROW_ADR.lo ,x
    sta num1
    pla
    sta (num1),y 
}

.macro PRINT_FAST_CHAR_VVACC(xpos, ypos) {
    pha
    ldx #ypos 
    ldy #xpos
    lda SCREEN.ROW_ADR.hi, x
    sta num1Hi
    lda SCREEN.ROW_ADR.lo ,x
    sta num1
    pla
    sta (num1),y 
}

.namespace SCREEN {

    ROW_ADR:
        .lohifill 25, $0400 + 40*i

    player_xy_to_screen_xy:
        txa
        clc
        sbc #24
        bcs !+
        lda #0
        jmp !++
    !:
        lsr 
        lsr
        lsr 
    !:
        tax
        tya
        clc
        sbc #50
        bcs !+
        ldy #0
        rts
    !:
        lsr 
        lsr 
        lsr
        tay        
        rts


    clear:
        ldx #250
        lda #$20
    !:
        sta SCREENRAM-1,x 
        sta SCREENRAM+249,x 
        sta SCREENRAM+499,x
        sta SCREENRAM+749,x
        dex
        bne !-
    rts 
     
    colorize:
        ldx #250
        lda #COLOR_YELLOW
    !:
        sta COLORRAM-1,x
        sta COLORRAM+249,x 
        sta COLORRAM+499,x
        sta COLORRAM+749,x
        dex
        bne !-
        rts

    print_char:                 // Offset = (ypos*40+xpos) + SCREENRAM
        pha                     // Das zu druckende Zeichen sichern
        lda ROW_ADR.hi, y
        sta num1Hi
        lda ROW_ADR.lo , y
        sta num1
        txa
        tay
        pla
        sta (num1),y 
        rts

    print_zero_str:
        // Bildschiradresse der Zeile
        // in num1 und num1Hi ablegen
        lda ROW_ADR.hi, y
        sta num1Hi
        lda ROW_ADR.lo ,y
        sta num1
        txa
        clc
        adc num1
        sta num1
        // Nun ist y wieder frei
        ldy #0
    !:
        lda (stringLo),y 
        cmp #0
        beq print_zero_str_end
        sta (num1), y
        iny 
        jmp !- 

    print_zero_str_end:
        rts
        
    print_hex:
        pha
        lda ROW_ADR.hi, y
        sta num1Hi
        lda ROW_ADR.lo , y
        sta num1
        stx num2
        pla
        jsr MATH.convert_to_hex
        ldy num2
        sta (num1),y 
        txa
        iny
        sta (num1), y
        rts

    /**
        Input:
            X Register = X-Position
            Y Register = Y-Position
        Output:
            A Register = Char Code
            num1       = LSB ScreenAddress
            num1Hi     = MSB ScreenAddress
    */
    read_char:
        lda ROW_ADR.hi, y
        sta num1Hi
        lda ROW_ADR.lo , y
        sta num1
        txa
        tay
        lda (num1), y 
        rts
}