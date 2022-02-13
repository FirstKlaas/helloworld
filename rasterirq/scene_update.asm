.namespace RASTER_ROUTINES {

    /*****************************************************************************
    * Der Raster Interrupt, der den Framecounter runterzählt.
    * Wenn der Framecounter bei 0 angekommen ist, dann wird die gesmte
    * Szene aktualisiert und der Counter reinitialisiert. Der Wert für
    * den Gamecounter ist GAME_SPEED.
    *****************************************************************************/
    scene_update:
        ldy REG_RASTERLINE
        sty RL_CURRENT
        lda IRQSTATUS
        bmi do_raster_irq
        lda $dc0d                          // sonst, CIA-IRQ bestätigen  
        cli                                // IRQs erlauben
        jmp $ea31

    do_raster_irq:
        PRINT_HEX_VVA(20,20, RL_CURRENT)
        // Bestätigen, dass der IRQ behandelt wurde
        sta IRQSTATUS    
        lda RL_CURRENT

        // Rasterline for Scene setup?
        cmp RL_SCENE
        bne !monster_row_one+


        jsr JOYSTICK.check      // Ergebnisse liegen in JoyXDirection und
        lda #0
        rol                     // Fire Button in Akku schieben
        sta JoyFireButton       // In der Zero Page ablegen 
        clc                     // Carry bit löschen, weil bas bit
                                // noch gesetzt ist, wenn der Feuer
                                // Knopf nicht gedrückt ist

        // Framecounter um 1 verringern
        // Wenn 0 erreicht ist, dann die Szene
        // aktualisieren.
        // Dies sollte in dem Raster IRQ erfolgen, der den meisten zeitlicher Puffer hat.
        ldy FrameCounter
        dey
        sty FrameCounter
        beq !update_scene+
        RETURN_FROM_IRQ()

    !update_scene:
        // Framecounter auf 0 gegangen.
        // Neu setzen
        lda #GAME_SPEED
        sta FrameCounter

        // Komplette Szenen neu berechnen
        jsr KI.update                   // Die Logik der einzelnen Sprites verrechnen
        jsr SPRITES.update_positions    // Neue Position berechnen (in virtuellen Daten)
        jsr SPRITES.convert_virtual_xy  // Virtuelle auf reale Positionen mappen
        
        sei
        SET_RASTER_LINE_A(RL_M1)
        cli
        RETURN_FROM_IRQ()

    !monster_row_one:
        cmp RL_M1
        bne !monster_row_two+
        SET_BORDER_COLOR_V(COLOR_LIGHTGREEN)
        PRINT_HEX_VVA(11,13, RL_CURRENT)
        jsr GAME.update_vic             // Neuen Stand in VIC schreiben
        
        .for (var i=0; i<8; i++) {
            lda #[i+8]
            sta ACTIVE_SPRITES+i
        }

        jsr debug
        sei
        SET_RASTER_LINE_A(RL_M2)
        cli
        RETURN_FROM_IRQ()

    !monster_row_two:
        cmp RL_M2
        bne !exit+
        SET_BORDER_COLOR_V(COLOR_RED)
        PRINT_HEX_VVA(11,13, RL_CURRENT)
        jsr GAME.update_vic             // Neuen Stand in VIC schreiben
        .for (var i=0; i<8; i++) {
            lda #[i]
            sta ACTIVE_SPRITES+i
        }
        jsr debug
        sei
        SET_RASTER_LINE_A(RL_M1)
        cli
        jmp !exit+

    !exit:
        RETURN_FROM_IRQ()



    debug:
        .if (DEBUG) {
            .for (var i=0; i<8; i++) {
                PRINT_HEX_VVA(5+3*i, 10,ACTIVE_SPRITES+i)
            }
        }
        rts

    /*************************************************************************


    *************************************************************************/
    show_monster_irq:
        lda IRQSTATUS    
        bmi !+
        cli
        jmp !exit+
    !:
        sta IRQSTATUS
        ldy REG_RASTERLINE
        sty RL_CURRENT

        ldx #8
        .for (var i=0; i<8; i++) {
            stx ACTIVE_SPRITES+i
            inx
        }
        jsr GAME.update_vic
        
    !exit:
        RETURN_FROM_IRQ()

}