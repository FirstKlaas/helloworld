.macro SETUP_SPRITES() {
    lda #0
    sta SPRITEDOUBLEHEIGHT
    sta SPRITEDOUBLEWIDTH
    sta SPRITEDEEP
    sta SPRITEMULTICOLOR
}

/*****************************************************************************
Berechnung des VIC Registers für das neunte Bit des X Positionen. 
******************************************************************************/
.macro CALC_9TH_BIT_XPOS() {
    ldy #0
    .for (var i=0; i<8; i++) {
        ldx ACTIVE_SPRITES+i
        lda XPOS_MSB,x
        ror
        tya
        ror 
        tay
    }
    tya    
}


.macro ADD_NEGATIVE_AAAA(num, numHi, delta) {
        clc 
        lda XPOS_LSB
        adc SPRITE_DX-1,x 
        sta XPOS_LSB
        bcs !+ 
        ldy XPOS_MSB 
        dey 
        sta XPOS_MSB
    !:
    
}

.namespace SPRITES {




    update_xpos:
        ldx #MONSTER_COUNT
    !loop:
        lda SPRITE_DX-1,x
        beq !next+                  // Bei 0 muss nichts gemacht werden
        bmi !negative_direction+
        clc
        adc XPOS_LSB-1,x 
        sta XPOS_LSB-1,x
        lda XPOS_MSB-1,x
        adc #0
        sta XPOS_MSB-1,x
        jmp !next+
    !negative_direction:
        clc 
        lda XPOS_LSB-1,x
        adc SPRITE_DX-1,x 
        sta XPOS_LSB-1,x
        bcs !next+ 
        ldy XPOS_MSB-1,x 
        dey
        tya 
        sta XPOS_MSB-1,x
    !next:
        dex 
        bne !loop-
        rts
    
    update_ypos:
        ldx #MONSTER_COUNT
    !loop:
        lda YPOS-1,x
        beq !+ 
        clc
        adc SPRITE_DY-1,x 
        sta YPOS-1,x
    !:
        dex 
        bne !loop-
        rts
}


