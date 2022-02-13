.namespace COLLISION {
    
    /****************************************
      Check the eight corners and sides
      if te sprite collides with a character
    *****************************************/
        
    check_monster_sprites:
      lda ZP_BG_COLLISION
      beq !return+            // Wenn das Register 0 ist, dann gibt es keine
                              // Kollisionen. 
      ldy #8
    !:
      rol 
      bcc !no_hit+ 
      pha
      lda #SPRITE_STATE_DEAD
      sta (num1), y 
      pla
    !no_hit:
      dey 
      bne !-
    !return:
      rts        
}
