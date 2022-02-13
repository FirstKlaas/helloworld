.macro SCRORE_RESET() {
    lda #0
    sta ZP_ScoreHi
    sta ZP_ScoreLo
}

.macro SCORE_ADD_V(amount)
    lda #amount
    clc
    sed
    adc ZP_ScoreLo 
    sta ZP_ScoreLo
    lda #0
    adc ZP_ScoreHi
    sta ZP_ScoreHi
    cld

.macro SCORE_ADD_ACC()
    clc
    sed
    adc ZP_ScoreLo 
    sta ZP_ScoreLo
    lda #0
    adc ZP_ScoreHi
    sta ZP_ScoreHi
    cld

.namespace SCORE {

    msg_score:
        .encoding "screencode_upper"
        .text "SCORE"
        .byte $00

    msg_level:
        .encoding "screencode_upper"
        .text "LEVEL"
        .byte $00
    
    print_score:
        PRINT_STR_ZERO(0, 0, msg_score)
        lda ZP_ScoreHi
        lsr 
        lsr 
        lsr 
        lsr 
        ora #48
        PRINT_FAST_CHAR_VVACC(6,0)
        lda ZP_ScoreHi
        and #$f 
        ora #48
        PRINT_FAST_CHAR_VVACC(7,0)

        lda ZP_ScoreLo
        lsr 
        lsr 
        lsr 
        lsr 
        ora #48
        PRINT_FAST_CHAR_VVACC(8,0)
        lda ZP_ScoreLo
        and #$f 
        ora #48
        PRINT_FAST_CHAR_VVACC(9,0)
        
        rts

    print_level:
        PRINT_STR_ZERO(32, 0, msg_level)
        lda ZP_Level
        and #$0f
        ora #48 
        lda #48
        PRINT_FAST_CHAR_VVACC(39,0)
        lda ZP_Level
        lsr 
        lsr 
        lsr 
        lsr 
        ora #48
        PRINT_FAST_CHAR_VVACC(38,0)
        
        rts

    
}
