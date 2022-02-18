irq_monster_row_1:
    IRQ_START()

    .if (COND_DEBUG) SET_BORDER_COLOR_V(COLOR_YELLOW)

    lda ZP_SP_ACTIVE_R1
    sta SPRITEACTIV 
    bne !vic_update+
    jmp !+
!vic_update:
    // Und VIC aktualisieren
    VIC_UPDATE_MONSTER_ROW(0)
!:    
    // Neuen Raster Interrupt setzen
    lda ZP_SP_ACTIVE_R2
    beq !+
    INSTALL_RASTER_VECTOR(irq_monster_row_2)
    SET_RASTER_LINE_A(Rasterline_Monster_R2)
    jmp !finish+
!:
    // Neuen Raster Interrupt setzen
    lda ZP_SP_ACTIVE_R3
    beq !+
    INSTALL_RASTER_VECTOR(irq_monster_row_3)
    SET_RASTER_LINE_A(Rasterline_Monster_R3)
    jmp !finish+
!:
    // Neuen Raster Interrupt setzen
    lda ZP_SP_ACTIVE_R4
    beq !+
    INSTALL_RASTER_VECTOR(irq_monster_row_4)
    SET_RASTER_LINE_A(Rasterline_Monster_R4)
    jmp !finish+
!:
    SET_RASTER_LINE_V(RASTERLINE_SPACESHIP)
    INSTALL_RASTER_VECTOR(BULLETTEST.raster_irq)

!finish:
    // fertig
    .if (COND_DEBUG) SET_BORDER_COLOR_V(COLOR_LIGHTBLUE)
    jmp irq_exit    


irq_monster_row_2:
    IRQ_START()
    .if (COND_DEBUG) SET_BORDER_COLOR_V(COLOR_GREEN)

    lda ZP_SP_ACTIVE_R2
    sta SPRITEACTIV 

    bne !vic_update+
    jmp !+
!vic_update:
    // Und VIC aktualisieren
    VIC_UPDATE_MONSTER_ROW(8)
!:
    // Neuen Raster Interrupt setzen
    lda ZP_SP_ACTIVE_R3
    beq !+
    INSTALL_RASTER_VECTOR(irq_monster_row_3)
    SET_RASTER_LINE_A(Rasterline_Monster_R3)
    jmp !finish+
!:
    // Neuen Raster Interrupt setzen
    lda ZP_SP_ACTIVE_R4
    beq !+
    INSTALL_RASTER_VECTOR(irq_monster_row_4)
    SET_RASTER_LINE_A(Rasterline_Monster_R4)
    jmp !finish+
!:
    SET_RASTER_LINE_V(RASTERLINE_SPACESHIP)
    INSTALL_RASTER_VECTOR(BULLETTEST.raster_irq)
!finish:
    .if (COND_DEBUG) SET_BORDER_COLOR_V(COLOR_LIGHTBLUE)
    jmp irq_exit

irq_monster_row_3:
    IRQ_START()
    .if (COND_DEBUG) SET_BORDER_COLOR_V(COLOR_RED)

    lda ZP_SP_ACTIVE_R3
    sta SPRITEACTIV 

    bne !vic_update+
    jmp !+
!vic_update:
    // Und VIC aktualisieren
    VIC_UPDATE_MONSTER_ROW(16)
!:
    // Neuen Raster Interrupt setzen
    lda ZP_SP_ACTIVE_R4
    beq !+
    INSTALL_RASTER_VECTOR(irq_monster_row_4)
    SET_RASTER_LINE_A(Rasterline_Monster_R4)
    jmp !finish+
!:
    SET_RASTER_LINE_V(RASTERLINE_SPACESHIP)
    INSTALL_RASTER_VECTOR(BULLETTEST.raster_irq)

!finish:
    // fertig
    .if (COND_DEBUG) SET_BORDER_COLOR_V(COLOR_LIGHTBLUE)

    jmp irq_exit

irq_monster_row_4:
    IRQ_START()
    .if (COND_DEBUG) SET_BORDER_COLOR_V(COLOR_PURPLE)

    lda ZP_SP_ACTIVE_R4
    sta SPRITEACTIV 

    bne !vic_update+
    jmp !+
!vic_update:

    // Und VIC aktualisieren
    VIC_UPDATE_MONSTER_ROW(24)
!:    
    // Jetz wieder zur Neuberechnung der Scene
    SET_RASTER_LINE_V(RASTERLINE_SPACESHIP)
    INSTALL_RASTER_VECTOR(BULLETTEST.raster_irq)

    //SET_RASTER_LINE_V(RASTERLINE_SPACESHIP-7)
    //INSTALL_RASTER_VECTOR(ship_base_raster_irq)

    // Fertig
    .if (COND_DEBUG) SET_BORDER_COLOR_V(COLOR_LIGHTBLUE)

    jmp irq_exit

