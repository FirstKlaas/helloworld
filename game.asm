.namespace GAME {

    .macro SET_MONSTER_ROW_COLOR(row, color) {
            ldx #8
        !:
            lda #color
            sta SPRITE_COLOR-1+(row*8),x
            dex
            bne !-
    }

    .macro SET_MONSTER_ROW_YPOS(row, ypos) {
            ldx #8
        !:
            lda #ypos
            sta VIRT_YPOS-1+(row*8),x
            dex
            bne !-
    }

    .macro SET_MONSTER_ROW_BLOCK(row, block) {
            ldx #8
        !:
            lda #block
            sta SPRITE_BLOCK-1+(row*8),x
            dex
            bne !-
    }

    .macro SET_MONSTER_ROW_XPOS(row, start, dx) {
            ldx #8
            lda #start
        !:
            sta VIRT_XPOS-1+(row*8),x
            adc #dx
            dex
            bne !-        
    }
    
    
    /*************************************************************************
    * Initialisierung des Hauptscreens
    * Aufteilung der Sprites:
    *   - Sprite 00-07 Monster erste Reihe
    *   - Sprite 08-15 Monster zweite Reihe
    *   - Sprite 16-23 Monster dritte Reihe
    *   - Sprite 24-30 Unbenutzt
    *   - Sprite 31 Spaceship
    *************************************************************************/
    init:
        
        SET_MONSTER_ROW_BLOCK(0, MONSTER_A_BLK)
        SET_MONSTER_ROW_BLOCK(1, MONSTER_B_BLK)
        SET_MONSTER_ROW_BLOCK(2, MONSTER_C_BLK)
        SET_MONSTER_ROW_BLOCK(3, MONSTER_D_BLK)
        
        
        SET_MONSTER_ROW_COLOR(0, COLOR_YELLOW)
        SET_MONSTER_ROW_COLOR(1, COLOR_ORANGE)
        SET_MONSTER_ROW_COLOR(2, COLOR_GREEN)
        SET_MONSTER_ROW_COLOR(3, COLOR_RED)
        
        
        SET_MONSTER_ROW_YPOS(0, 55)
        SET_MONSTER_ROW_YPOS(1, 80)
        SET_MONSTER_ROW_YPOS(2,105)
        SET_MONSTER_ROW_YPOS(3,130)
        
        
        SET_MONSTER_ROW_XPOS(0, 20, 15)
        SET_MONSTER_ROW_XPOS(1, 20, 15)
        SET_MONSTER_ROW_XPOS(2, 20, 15)
        SET_MONSTER_ROW_XPOS(3, 20, 15)


    .macro UPDATE_VIC_XPOS_X(idx) {
        lda REAL_XPOS,x 
        sta SPRITE0X+(2*idx) 
    }
    
    .macro UPDATE_VIC_YPOS_X(idx) {
        lda REAL_YPOS,x 
        sta SPRITE0Y+(2*idx)
    }

    .macro UPDATE_VIC_COLOR_X(idx) {
        lda SPRITE_COLOR,x 
        sta SPRITE0COLOR+idx        
    }
    
    .macro UPDATE_VIC_DATA_X(idx) {
        lda SPRITE_BLOCK,x
        sta SPRITE0DATA+idx
    }
    
    // Es werden die acht aktiven Sprites in
    // das VIC geschrieben.
    // Die indizes der acht sprites stehen ab der Adresse 
    // ACTIVE_SPRITES
    update_vic:
        .for (var i=0; i<8; i++) {
            ldx ACTIVE_SPRITES+i
            UPDATE_VIC_XPOS_X(i)
            UPDATE_VIC_YPOS_X(i)
            UPDATE_VIC_COLOR_X(i)
            UPDATE_VIC_DATA_X(i)            
        }
        rts
}