check_spaceship_boundaries:
    // Nun die Game Elemente aktualisieren
    /*
    lda SPACESHIP_X
    
    cmp #$22
    bcs !+
    lda #$22
    sta SPACESHIP_X
!:
    cmp #$8a
    bcc !+ 
    lda #$8a
    sta SPACESHIP_X
!:
    */
    rts
