.print "SPRITE DX: " + toHexString(SPRITE_DX)

.macro SET_MONSTER_DOWN_SIZE_V(number_of_lines) {
    lda #NUMBER_OF_SPRITES
    sta MonsterDownLines
}


.namespace MONSTER {

    update:
        // Alle Monster einer Reihe laufen in die gleiche Richtung
        // Monster, deren State "DEAD" ist, werden bei der Betrachtung ignoriert
        // Im X Register ist der Offset, bei dem wir beginnen.
        stx TempByte
        lda SPRITE_DX, x
        bne !+ 
        rts
    !:  
                  
        bmi update_left


    update_right:
        // Monsters are moving to the right
        // Check the right border of
        // the rightmost sprite in the row
        // that is not dead.
        ldy #8
        txa 
        clc
        adc #7 
        tax
    !loop:
        lda SPRITE_STATE, x         // If the most significant is zero, we
        cmp #SPRITE_STATE_DEAD
        bne !rightmost+
        dex 
        dey 
        bne !loop-
        rts

    !rightmost:
        lda XPOS_MSB, x             // If the most significant is zero, we
        bne !+                      // are fine.
        rts
    !:
        lda XPOS_LSB, x
        cmp #60                     // Testweise gegen 266 testen (10 im lsb)
        bcs !+
        rts 
    !: 
        lda ZP_MONSTER_SPEED_LEFT   // Testweise die Bewegung des ersten Sprites
                                    // nach links drehen.
        ldx TempByte                // Self modified 
        jsr set_horizontal_speed   
        // Eigentlich fertig, nun noch alle Monster nach unten schieben
        // Daher das Flag setzen
        lda #1 
        sta ZP_MONSTER_DOWN_FLAG
        rts
        
    update_left:
        // Nun das Monster finden, dass am weitesten links
        // und nicht tot ist
        ldy #8                      // Maximal acht monster pruefen
    !loop: 
        lda SPRITE_STATE, x         // If the most significant is zero, we
        cmp #SPRITE_STATE_DEAD
        bne !left_most+
        inx 
        dey 
        bne !loop-
        rts                         // All sprites in the row are dead
    !left_most:
        lda XPOS_MSB, x             // If the most significant is zero,
        beq !+                      // the monsters are fare away.
        rts 
    !:   
        lda XPOS_LSB, x             
        cmp #24                     // Testweise gegen 266 testen (10 im lsb)
        bcc !+
        rts 
    !: 
        lda ZP_MONSTER_SPEED_RIGHT  // Bewegung der Monster nach rechts (+1)
        ldx TempByte                // Original Offset wieder setzen
        jsr set_horizontal_speed    // nach rechts drehen.
        lda #1                      // Flag setzen, um zu kennzeichnen, dass die
        sta ZP_MONSTER_DOWN_FLAG    // Monster nach unten bewegt werden müssen.
        rts

    set_horizontal_speed:
        ldy #8
    !:
        sta SPRITE_DX, x
        inx
        dey
        bne !-
        rts


    update_move_down:
        ldx #MONSTER_COUNT
    !:    
        lda YPOS-1,x 
        clc
        adc MonsterDownLines 
        sta YPOS-1,x
        dex 
        bne !-
        rts

    /**
        Finde das (lebende) Monster, das am niedrigsten ist, also
        die höchste Y Position hat. 
        
        Da beim Start die Monster mit aufsteigendem Index nach weiter
        nach unten platziert werden, wird als rückwärts (absteigender
        index) das erste Monster Sprite gesucht, das nicht den Status
        "DEAD" hat.
    */
    find_lowest:
        //lda YPOS+MONSTER_COUNT-1
        //rts 
        
        ldx #MONSTER_COUNT
    !:
        lda SPRITE_STATE-1,x 
        cmp #SPRITE_STATE_DEAD
        bne !found+                 // Wenn das DEAD Bit nicht gesetzt ist, 
                                    // Dann haben wir unser Sprite
        dex
        bne !- 
        // Alle Sprites durchlaufen
        // und kein Sprite ist sichtbar.
        // Dann carry gesetzt, um diesen
        // Zustand zu signalisieren
        sec
        rts 
    !found:
        lda YPOS-1,x 
        clc 
        rts 

}
