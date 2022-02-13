

.namespace MONSTER {

    update:
        // Da alle Monster in die gleiche Richtung laufen
        // reicht mir auch die Richtung des ersten Sprites
        // zu kennen.
        lda SPRITE_DX
        beq update_done             // 0 = No movement
        bmi update_left

    update_right:
        // Monsters are moving to the right
        // Check the right border of
        // the rightmost sprite inthe row
        lda XPOS_MSB+7               // If the most significant is zero, we
        beq update_done             // are fine.
        lda XPOS_LSB+7
        cmp #60                     // Testweise gegen 266 testen (10 im lsb)
        bcc update_done 
        lda #$ff                    // Testweise die Bewegung des ersten Sprites
                                    // nach links drehen.
        jsr set_horizontal_speed   
             
        // Eigentlich fertig, nun noch alle Monster nach unten schieben
        jmp update_move_down

    update_left: 
        lda XPOS_MSB                // If the most significant is non zero, we
        bne update_done             // are fine.
        lda XPOS_LSB
        cmp #24                     // Testweise gegen 266 testen (10 im lsb)
        bcs update_done 
        lda #$01                    // Bewegung der Monster
        jsr set_horizontal_speed    // nach rechts drehen.
        jmp update_move_down

    update_move_down:
        ldx #MONSTER_COUNT
    !:    
        lda YPOS-1,x 
        adc MonsterDownLines 
        sta YPOS-1,x
        dex 
        bne !-
        jmp update_done

    update_done:
        rts

    set_horizontal_speed:
        ldx #MONSTER_COUNT
    !:
        sta SPRITE_DX-1, X
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
