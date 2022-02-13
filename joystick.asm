.namespace JOYSTICK {
    /*****************************************************************************
    * Joystick anfragen
    *****************************************************************************/
    check:
        lda $dc00           // get input from port 2 only
        ldy #0              // this routine reads and decodes the
        ldx #0              // joystick/firebutton input data in
        lsr                 // the accumulator. this least significant
        bcs !+              // 5 bits contain the switch closure
        dey                 // information. if a switch is closed then it
    !:  lsr                 // produces a zero bit. if a switch is open then
        bcs !+              // it produces a one bit. The joystick dir-
        iny                 // ections are right, left, forward, backward
    !:  lsr                 // bit3=right, bit2=left, bit1=backward,
        bcs !+              // bit0=forward and bit4=fire button.
        dex                 // at rts time dx and dy contain 2's compliment
    !:  lsr                 // direction numbers i.e. $ff=-1, $00=0, $01=1.
        bcs !+              // dx=1 (move right), dx=-1 (move left),
        inx                 // dx=0 (no x change). dy=-1 (move up screen),
    !:  lsr                 // dy=0 (move down screen), dy=0 (no y change).
        stx JoyXDirection   // the forward joystick position corresponds
        sty JoyYDirection   // to move up the screen and the backward
        rts                 // position to move down screen.
                            //
                            // at rts time the carry flag contains the fire
                            // button state. if c=1 then button not pressed.
                            // if c=0 then pressed.
}