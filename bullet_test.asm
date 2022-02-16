.namespace BULLETTEST {

    .const NUMBER_OF_BULLETS=2
    .const BULLET_START_ROW=22
    .const BULLETCHAR=$f0

    BXPOS: .fill NUMBER_OF_BULLETS, $00
    BYPOS: .fill NUMBER_OF_BULLETS, $00
    BLASTYPOS: .fill NUMBER_OF_BULLETS, $15
    BULLET_CHAR: .fill NUMBER_OF_BULLETS, $42

    .print "Bullet XPOS " + toHexString(BXPOS)
    
    FREE:  .fill NUMBER_OF_BULLETS, $01   // Flag, ob dieser Slot frei ist. 1 = Frei / 0 = Belegt

    TX: .byte $00
    TY: .byte $00
    
    

    /****************************************
     */
    update_spaceship_scene:
        // Between two fire button presses
        // there needs to be a cerain delay
        // FireButton is only allowed, if
        // bFireCounter is Zero
        jsr clear_bullets
        ldx bFireCounter
        beq !read_joystick+ 
        dex
        stx bFireCounter
        jmp !update+
    !read_joystick:
        jsr JOYSTICK.check
        bcs !update+

    !fire:
        lda firePause               // After this shot, there is an idle
                                    // before the next shot.
        sta bFireCounter
        lda SPACESHIP_XPOS_LSB
        sec                         // Set carry to borrow from
                                    // Offset innerhalb des Sprites und linken
                                    // Rahmen berücksichtigen 
        sbc #12                     // 12-24= -12
        sta num2                    // Neuen Wert (Low Byte) merken.
        lda SPACESHIP_XPOS_MSB      // Nun 0 vom Hi Byte abziehen, damit
        sbc #0                      // Das carry Bit aus der vorherigen 
        sta num2Hi                  // Subtraction berücksichtigt wird.
        lda num2                    // Das reduzierte Low Byte holen
        and #%00000111              // Die letzten drei Bits sind der Offset im Zeichen
        tay                         // Offset im Y Register sichern
        lda num2Hi
        ror 
        lda num2                    // Alten Wert wieder holen.
        ror                         // LSBit über das Carry in das
        lsr                         // Byte schieben und durch 8 teilen
        lsr                         // (Dreimal schieben)
        tax
        jsr shoot
    !update:
        jsr update_xpos
        jsr move_bullets_up
        jsr draw_bullets

        rts


    free_all_bullets:
        ldx #NUMBER_OF_BULLETS
    !:
        lda #1
        sta FREE-1,x
        dex 
        bne !-
        rts 
        
    /****************************************
    Schuss abfeuern.
    Im Akku muss sich die X Position
    des Schusses befinden. Die X-Position
    wird als Zeichen X [0-39] erwartet.

    Im Y Register befindet sich der Offset
    [0-7] innerhalb des Screen X Bytes, an
    der der Schuss stattgefunden hat.
    
    Zunächst wird ein freier Slot gesucht.
    Ist kein freier Slot mehr vorhanden, 
    dann wird kein Schuss abgefeuert und
    das Carry Bit ist vor dem Rücksprung
    gesetzt.

    Wird ein Slot gefunden, dann wird die
    X Position aus den im X Register über-
    gebenen Wert gestetz und die Y Position
    auf 25.
    *****************************************/
    shoot:
        
        stx TX                  // Schuss Position sichern.
        sty TY                  // Offset sichern

    find_free_slot:
        ldx #NUMBER_OF_BULLETS
    !:
        lda FREE-1,x 
        beq !next+              // Wenn 0, dann belegt
    !slot_found:
        dex                     // Nun hat X den index in den bullet slots
                                // der frei ist.
        lda #0
        sta FREE,x 
        lda TX                  // Schussposition wieder herstellen
        sta BXPOS,x             // X Position in der Bullet Tabelle sichern
        lda TY
        clc
        adc #BULLETCHAR
        sta BULLET_CHAR,x
        lda #BULLET_START_ROW   // Bullet beginnt ganz unten
        sta BYPOS,x             // Y-Position in der Bullet Tabelle sichern

        clc
        rts    
    !next:
        dex
        bne !- 
    !no_free_slot:
        sec                     // Set Carry Bit to signal no free slot.
        rts

    /**
      Alle Kugeln auf dem Screen zeichen. Dabei wird an die Stelle der alten Position
      ein Leerzeichen ausgegeben. Es wird davon ausgegangen, dass die y und y Positionen
      bereits aktualisiert wurden.
    */
    draw_bullets:
        ldx #NUMBER_OF_BULLETS
    !loop:
        lda FREE-1,x 
        bne !next+              // Wert ungleich 0 => freier slot.
        // Bullet zeichnen
        txa                     // Y Register sichern
        pha
        lda BXPOS-1,x           // Screen XPos laden 
        sta TX 
        lda BYPOS-1,x 
        sta TY
        lda BULLET_CHAR-1, x
        PRINT_FAST_CHAR_AAACC(TX, TY)
        pla
        tax
    !next:
        dex
        bne !loop-
        rts

    clear_bullets:
        ldx #NUMBER_OF_BULLETS
    !loop:
        lda BXPOS-1,x           // Screen XPos laden 
        sta TX 
        lda BYPOS-1,x 
        sta TY
        txa 
        pha
        PRINT_FAST_CHAR_AAV(TX, TY, $20)
        pla
        tax
        dex
        bne !loop-
        rts

    move_bullets_up:
        ldx #NUMBER_OF_BULLETS
    !loop:
        lda FREE-1,x 
        bne !next+          // Wenn Slot frei ist, dann ignorieren
        ldy BYPOS-1,x       // Y Position laden
        tya 
        sta BLASTYPOS-1,x   // Aktuelle als letzte Position merken    
        dey                 // Und verringern
        bne !save_new_pos+  // Wenn 0, dann slot wieder frei machen
        lda #1              // Slot wieder frei machen
        sta FREE-1,x        
    !save_new_pos:
        tya
        sta BYPOS-1,x       // Neue Position speichen
    !next:
        dex
        bne !loop-
        rts
    
    init:
        // Das Ship initial positionieren
        lda #30
        sta SPACESHIP_XPOS_LSB
        lda #219
        sta SPACESHIP_YPOS
        lda #1
        sta SPACESHIP_XPOS_MSB        
        rts

    update_xpos:
        lda JoyXDirection
        beq !next+                  // Bei 0 muss nichts gemacht werden
        bmi !negative_direction+
        clc
        adc SPACESHIP_XPOS_LSB 
        sta SPACESHIP_XPOS_LSB
        bcc !next+
        inc SPACESHIP_XPOS_MSB
        jmp !next+
    !negative_direction:
        clc 
        lda SPACESHIP_XPOS_LSB
        adc JoyXDirection 
        sta SPACESHIP_XPOS_LSB
        bcs !next+ 
        dec SPACESHIP_XPOS_MSB 
    !next:
        rts
    
    raster_irq:
        IRQ_START()
        .if (COND_DEBUG) SET_BORDER_COLOR_V(COLOR_BLACK)

        // VIC aktualisieren
        lda #%00000001          // Momentan besteht das Schiff aus nur einem Sprite
        sta SPRITEACTIV
        
        lda SPACESHIP_YPOS
        lda #228
        sta SPRITE0Y
        lda SPACESHIP_XPOS_LSB
        sta SPRITE0X
        lda SPACESHIP_XPOS_MSB
        sta SPRITESMAXX
        lda #SPACESHIP_BLK
        sta SPRITE0DATA
        lda #COLOR_WHITE
        sta SPRITE0COLOR

        // Jetz wieder zur Neuberechnung der Scene
        SET_RASTER_LINE_A(Rasterline_Scene)
        INSTALL_RASTER_VECTOR(update_scene)

        .if (COND_DEBUG) SET_BORDER_COLOR_V(COLOR_LIGHTBLUE)
        jmp irq_exit

    // ===============================================================
    // Test each bullet for collision with a monster.
    // If we have a collision. Disable the bullet and mark monster 
    // as dead.
    // ===============================================================
    check_for_collisions:
        ldx #NUMBER_OF_BULLETS
    
    !bullet_loop:
        // Is this bullet active?
        lda FREE-1,x 
        bne !next_bullet+       // Bullet slot is free (!= 0)
                                // So we don't test at all
        // Checking the monsters
        // starting from low to high
        ldy #MONSTER_COUNT

    !monster_loop:
        lda SPRITE_STATE-1,y    // Load state of the monster
        cmp #SPRITE_STATE_ALIVE // Is monster alive?
        beq !+                  // Yes, so continue
        jmp !next_monster+      // No, so we check next monster
    !:
        lda BYPOS-1,x
        lda YPOS-1,y
        sec 
        sbc #42
        lsr                     // Y_Position durch 8 teilen, 
        lsr                     // um auch Zeichen Y zu kommen
        lsr 
                                // Das die Kugel auch im Monster ist.
        cmp BYPOS-1,x

        beq !check_x_pos+       // Kugel ist auf der gleichen Höhe, wie 
                                // das Monster
        bcs !next_monster+      // Bullet Y Pos < Monster (Screen) Y Pos
                                // So we don't neew to check X Positions
                                // and skip complete row.

        jmp !next_bullet+       // Kugel ist unterhalb der Monsterreihe
                                // Damit kann der Test beendet werden, weil
                                // alle weitern Monter höher sind.
    !check_x_pos:    
        lda BXPOS-1,X
        lda XPOS_MSB-1,y
        ror 
        lda XPOS_LSB-1,y 
        ror 
        lsr 
        lsr 
        sec 
        sbc #2 
        cmp BXPOS-1,X
        beq !monster_hit+
        clc 
        adc #1 
        cmp BXPOS-1,X
        beq !monster_hit+ 
        bcs !next_monster+ 
        jmp !next_bullet+

    !monster_hit:
        // Set monster state to dead 
        lda #SPRITE_STATE_DEAD
        sta SPRITE_STATE-1,y 
        // Free bullet slot
        lda #1 
        sta FREE-1,x 

        // Raise Score
        // y register is free to use, because we jump to
        // to the next bullet
        tya 
        // Divide monster offset by 8 to get the 
        // row.
        lsr                      
        lsr 
        lsr
        tay
        lda #$50
        sed
    !score_loop:
        sbc #$10
        dey 
        bne !score_loop- 
        clc
        adc ZP_ScoreLo 
        sta ZP_ScoreLo
        lda #0
        adc ZP_ScoreHi
        sta ZP_ScoreHi
        cld

        // Check next bullet
        jmp !next_bullet+
        
    !next_monster:
        dey
        bne !monster_loop-

    !next_bullet:
        dex 
        bne !bullet_loop-
        rts


check_barricade_collision:
    ldx ZP_BARRICADE_ROW
    lda SCREEN.ROW_ADR.lo,x
    sta num2 
    lda SCREEN.ROW_ADR.hi,x 
    sta num2Hi
    ldx #NUMBER_OF_BULLETS
!loop:
    lda FREE-1,x 
    bne !next+

    lda BYPOS-1,x 
    cmp #20
    bne !next+
    // Same row. Now check xpos
    ldy BXPOS-1,x 
    lda (num2), y
    cmp #20
    beq !next+
    cmp #$60
    beq !next+
    
    lda #1 
    sta FREE-1,x 

!next:
    dex 
    bne !loop- 
    rts
}
