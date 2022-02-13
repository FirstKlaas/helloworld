.const MONSTER_XMIN      = 18
.const MONSTER_XMAX      = 57

.macro DISTRIBUTE_MONSTERS_V(dx) {
    lda VIRT_XPOS
    adc #dx
    ldx #6
!:
    sta VIRT_XPOS,x
    adc #dx
    dex
    bne !-
}

check_monster_boundaries:
    // X min position prüfen
    lda VIRT_XPOS
    cmp #MONSTER_XMIN       // virt. X pos < x min?  
    bcs !+                  // Nein
    // Linke Seite unterschritten
    lda #MONSTER_XMIN
    sta cmb_nx+1                // Achtung selbst modifizierender code
    lda #$01
    sta cmb_ndx+1
    jmp cmb_nx                 
!:
    // X max position prüfen
    lda VIRT_XPOS
    cmp #MONSTER_XMAX
    bcc !end+
    // Linke Seite unterschritten
    lda #MONSTER_XMAX
    sta cmb_nx+1                // Achtung selbst modifizierender code
    lda #$ff
    sta cmb_ndx+1
cmb_nx:    
    lda #100
    sta VIRT_XPOS           // Position auf xpos xmin setzen
    DISTRIBUTE_MONSTERS_V(16)
    
cmb_ndx:
    lda #2                      // Richtungswechsel = > Nach rechts
    ldx #7
!:
    sta DELTA_X-1,x
    dex
    bne !-

    // Nun noch alle Monstersprites nach unten verschieben
    ldx #7
    lda VIRT_YPOS
    clc
    adc #4                      // Um 4 Zeilen nachunten
    cmp #$c0
    bcc !+
    lda #40
!:  
    sta VIRT_YPOS-1,x 
    dex
    bne !-

!end:
    rts
