.namespace SPACESHIP {


    move_right:
        lda SPACESHIP_XPOS_LSB
        clc
        adc #1
        sta SPACESHIP_XPOS_LSB
        bcc !+
        inc SPACESHIP_XPOS_MSB
    !:
        rts

}