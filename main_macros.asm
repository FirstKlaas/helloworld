.macro SET_GAME_STATE(state) {
    lda #state
    sta GlobalGameState
}

.macro  UPDATE_VIC() {
    // First write the y-position
    // Dies ist ein Sonderfall, da immer alle acht Sprites
    // auf einer Höhe sind. Daher kann ich
    // die YPOS vom ersten Sprite holen und 
    // für alle acht Sprites in die VIC Register schreiben
    ldx ACTIVE_SPRITES
    lda YPOS,x
    .for (var spnum=0; spnum<8; spnum++) {
        sta SPRITE0Y+[2*spnum]
    }

    // Nun die X-Position aktualisieren         
    .for (var i=0; i<8; i++) {
        ldx ACTIVE_SPRITES+i
        lda XPOS_LSB,x
        sta SPRITE0X+[2*i]
        lda SPRITE_COLOR,x
        sta SPRITE0COLOR+i
        lda SPRITE_DATA_BLOCK,x
        sta SPRITE0DATA+i
    } 

    CALC_9TH_BIT_XPOS()
    sta SPRITESMAXX
}

.macro VIC_UPDATE_MONSTER_ROW(offset) {
    lda YPOS+offset
    .for (var spnum=0; spnum<8; spnum++) {
        sta SPRITE0Y+[2*spnum]
    }

    // Nun die X-Position aktualisieren         
    .for (var i=0; i<8; i++) {
        lda XPOS_LSB+i+offset
        sta SPRITE0X+[2*i]
        lda SPRITE_COLOR+i+offset
        sta SPRITE0COLOR+i
        lda SPRITE_DATA_BLOCK+i+offset
        sta SPRITE0DATA+i
    } 

    //lda #%11111111
    //sta SPRITEACTIV

    ldy #0
    .for (var i=0; i<8; i++) {
        lda XPOS_MSB+i+offset
        ror
        tya
        ror 
        tay
    }
    sty SPRITESMAXX    
}


.macro SET_ACTIVE_SPRITES() {
    .for (var i=0; i<8; i++) {
        lda ACTIVE_SPRITES+i 
        rol                         // Wenn höchstes bit gesetzt, dann ist sprite slot
                                    // nicht aktiv. Daher oberstes Bit in das Carry Bit 
                                    // schieben
        txa                         // Im Y Register liegt das Ergebnis 
        ror                         // Das Carry bit reinschieben
        tax
    }
    // Nun sind alle Bits verkehrt herum
    // Also alle Bits invertieren
    eor #$ff
    sta SPRITEACTIV
}

.macro DISABLE_SPRITE(idx) {
    lda ACTIVE_SPRITES+idx
    ora #%10000000
    sta ACTIVE_SPRITES+idx
}

.macro ENABLE_SPRITE(idx) {
    lda ACTIVE_SPRITES+idx
    and #%01111111
    sta ACTIVE_SPRITES+idx
}

.macro ACTIVATE_ALL_SPRITES() {
    lda #$ff
    sta SPRITEACTIV
}

.macro SET_ACTIVE_SPRITE_SET(start_index) {
    .for (var i=0; i<8; i++) {
        lda #[i+start_index]
        sta ACTIVE_SPRITES+i
    }    
}

.macro INIT_MONSTER_ROW_VVV(row, color, data_blk) {
    lda #[MONSTER_MIN_Y+row*MONSTER_SPACING_V]
    .for (var i=0; i<8; i++) {
        sta YPOS+(8*row)+i                  // Alle haben die gleiche Höhe
    }

    lda #color            
    .for (var i=0; i<8; i++) {
        sta SPRITE_COLOR+(8*row)+i          // Alle die gleiche Farbe
    }

    lda #data_blk
    .for (var i=0; i<8; i++) {
        sta SPRITE_DATA_BLOCK+(row*8)+i     // Alle den gleichen Datenblock
    }

    lda #MONSTER_MIN_X
    sta XPOS_LSB+(8*row)
    .for (var i=0; i<7; i++) {
        ADD_8BIT_TO_16BIT_AAAA(XPOS_LSB+(8*row)+i, XPOS_MSB+(8*row)+i, MONSTER_SPACING_H, XPOS_LSB+1+(8*row)+i, XPOS_MSB+1+(8*row)+i)    
    }

    lda #0
    .for (var i=0; i<8; i++) {
        sta XPOS_MSB+(row*8)+i     
    }

    lda #1
    .for (var i=0; i<8; i++) {
        sta SPRITE_DX+(row*8)+i     
    }

    lda #0
    .for (var i=0; i<8; i++) {
        sta SPRITE_DY+(row*8)+i     
    }

    lda #SPRITE_STATE_ALIVE
    .for (var i=0; i<8; i++) {
        sta SPRITE_STATE+(row*8)+i     // Alle den gleichen Datenblock
    }

}


.macro INIT_MONSTER() {
    // Die Anzahl der Linien, die ein Monster am Ender
    // der Reihe nach unten geht.
    lda #5
    sta MonsterDownLines
    // Zu beginn leben alle Monster 
    lda #MONSTER_COUNT 
    sta MonsterAlive

    INIT_MONSTER_ROW_VVV(0, COLOR_YELLOW, MONSTER_A_BLK)
    INIT_MONSTER_ROW_VVV(1, COLOR_GREEN, MONSTER_B_BLK)
    INIT_MONSTER_ROW_VVV(2, COLOR_RED, MONSTER_C_BLK)
    INIT_MONSTER_ROW_VVV(3, COLOR_PURPLE, MONSTER_D_BLK)
}


.print "###########################################"
.print "Start XPOS LSB        : $" + toHexString(XPOS_LSB)
.print "Start XPOS MSB        : $" + toHexString(XPOS_MSB)
.print "Start YPOS            : $" + toHexString(YPOS)
.print "Start Active Sprites  : $" + toHexString(ACTIVE_SPRITES)
.print "Current Rasterline    : $" + toHexString(Current_Rasterline)
.print "###########################################"
.print Rasterline_Monster_R1
            
        .macro ACK_ANY_IRQ() {
            asl $d019	// Ack any previous raster interrupt
            bit $dc0d   // reading the interrupt control registers 
            bit $dd0d	// clears them    
        }

        .macro IRQ_SAVE_REGISTER(label) {
            sta label+1
            stx label+3
            sty label+5    
        }

        .macro IRQ_START() {
            IRQ_SAVE_REGISTER(irq_exit)
            ACK_ANY_IRQ()
            lda REG_RASTERLINE
            sta Current_Rasterline            
        }
        
        .macro IRQ_EXIT() {
            lda #0
            ldx #0
            ldy #0
            rti    
        }

        .macro INSTALL_CHARSET() {
            lda #%00011000
            sta $d018    
        }

        .macro UPDATE_MONSTER_RASTER_LINES() {
            .for (var row=0; row<4; row++) {
                lda YPOS+(row*8)
                sbc #MONSTER_RASTERLINE_DELTA
                sta Rasterline_Monster_R1+row
            }            
        }
