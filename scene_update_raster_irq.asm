.macro DETERMINE_ACTIVE_SPRITES(offset, target) {
        lda target                      // If already all monsters have been killed
        beq !finish+                    // skip calculation
        ldx #8
        ldy #0
    !loop:
        lda #0 
        sta [!flag+]+1
        lda SPRITE_STATE-1+offset,x 
        cmp #SPRITE_STATE_DEAD
        beq !dead+
        lda #1 
        sta [!flag+]+1
    !dead:
        tya 
        asl
    !flag:  
        ora #0 
        tay

    !next_loop:
        dex 
        bne !loop-
        sty target     
    !finish:
}


update_scene:
    IRQ_START()
    .if (COND_DEBUG) SET_BORDER_COLOR_V(COLOR_BLUE)

    // Save value for background collisions
    lda SPRITEBACKGROUNDCOLL
    sta ZP_BG_COLLISION

    // Framecounter erhöhen
    clc 
    lda frameCounterLo
    adc #1 
    sta frameCounterLo
    bcc !+ 
    inc frameCounterHi
!:

    // Quasi eine if-then-else Kette, um 
    // in Abhängigkeit des Spielstatus zu handeln
    lda GlobalGameState

    // IF GAME_STATE_PLAY
check_game_state_play:
    bit ZP_GameState_Play
    beq check_game_state_victory 
    jmp on_game_state_play

    // IF GAME_STATE_VICTORY
check_game_state_victory:
    bit ZP_GameState_Victory
    beq check_game_state_defeat 
    jmp on_game_state_victory 

    // IF GAME_SATE_DEFEAT
check_game_state_defeat:
    bit ZP_GameState_Defeat
    beq check_game_state_unknown 
    jmp on_game_state_defeat

    // ELSE
check_game_state_unknown:
    jmp irq_exit

// ----------------------------------------------
// GAME STATE PLAY
//
// ----------------------------------------------
on_game_state_play:
    lda #0 
    sta ZP_MONSTER_DOWN_FLAG
    ldx #0
    jsr MONSTER.update    
    ldx #8
    jsr MONSTER.update    
    ldx #16
    jsr MONSTER.update    
    ldx #24
    jsr MONSTER.update

    lda ZP_MONSTER_DOWN_FLAG 
    beq !+ 
    jsr MONSTER.update_move_down
!:
    jsr SPRITES.update_xpos 

    // Da wir noch nicht abschießen können, werden wohl alle Monster leben
    // Im Akku steht die niedrigste Y Position
    UPDATE_MONSTER_RASTER_LINES()

    jsr BULLETTEST.update_spaceship_scene

    /* Animation des ersten Monsters */
    ldx Sprite0Anim
    lda AnimaData,x
    .for (var i=0; i<8; i++) {
        sta SPRITE_DATA_BLOCK+i
    }

    lda Anim_Monster_C_Live, x 
    .for (var i=0; i<8; i++) {
        sta SPRITE_DATA_BLOCK+16+i
    }
    
    inx
    txa
    and #15
    sta Sprite0Anim

    // Software Collision Check with bullets
    jsr BULLETTEST.check_for_collisions

    // Jetzt die Active Sprites pro Reihe
    // Ermitteln und in Variablen speichern
    DETERMINE_ACTIVE_SPRITES(0,ZP_SP_ACTIVE_R1)
    DETERMINE_ACTIVE_SPRITES(8,ZP_SP_ACTIVE_R2)
    DETERMINE_ACTIVE_SPRITES(16,ZP_SP_ACTIVE_R3)
    DETERMINE_ACTIVE_SPRITES(24,ZP_SP_ACTIVE_R4)

    // Das niedrigste Monster finden, das nicht tot ist.
    // Wenn dieses Monster zu niedrig ist, dann hat der Spieler
    // verloren.
    // Wenn Carry gesetzt, dann sind alle Monster tot
    jsr MONSTER.find_lowest
    bcc check_monster_low_position 

    // Alle Monster tot => Gewonnen
    SET_GAME_STATE(GAME_STATE_VICTORY)
    jmp next_raster_irq

check_monster_low_position:
    cmp #MONSTER_MAX_Y
    bcc !+
    SET_GAME_STATE(GAME_STATE_DEFEAT)
!:
    jmp next_raster_irq

// ----------------------------------------------
// GAME STATE VICTORY
//
// ----------------------------------------------
on_game_state_victory:
    jsr SCREEN.clear
    PRINT_STR_ZERO(11,5,msg_victory_1)
    PRINT_STR_ZERO(6,7,msg_victory_2)
    jsr BULLETTEST.clear_bullets
    jsr BULLETTEST.free_all_bullets
    ldx ZP_New_Game_Delay
    bne !+
    jmp start_new_game
!:
    dex
    stx ZP_New_Game_Delay
    jmp next_raster_irq

// ----------------------------------------------
// GAME STATE DEFEAT
//
// ----------------------------------------------
on_game_state_defeat:
    PRINT_STR_ZERO(8,6,msg_defeated)
    jsr BULLETTEST.clear_bullets
    jsr BULLETTEST.free_all_bullets
    ldx ZP_New_Game_Delay
    bne !+
    jmp start_new_game
!:
    dex
    stx ZP_New_Game_Delay
    jmp next_raster_irq

// ---------------------------------------------
// START NEW GAME
//
// ----------------------------------------------
start_new_game:
    PRINT_STR_ZERO(10,10, msg_start_game)
    // TODO: Hier müsste noch eine "Warte-
    // schleife" hin, weil sonst bei gedrücktem
    // Feuerknopf das spiel sofort wieder losgeht.
    jsr JOYSTICK.check
    bcc !+
    jmp next_raster_irq
!:
    jsr SCREEN.clear
    SET_GAME_STATE(GAME_STATE_PLAY)

    INIT_MONSTER()

!loop:
    sta SPRITE_STATE-1,x 
    dex
    bne !loop-

    // Alle wieder nach "rechts" bewegen
    lda #1 
    ldx #MONSTER_COUNT 
!loop:
    sta SPRITE_DX-1,x 
    dex
    bne !loop-


    // Alle Sprites wieder auf "active/sichtbar" setzen.
    lda #255 
    sta ZP_SP_ACTIVE_R1
    sta ZP_SP_ACTIVE_R2
    sta ZP_SP_ACTIVE_R3
    sta ZP_SP_ACTIVE_R4
    
    // Nach dem Neustart nicht sofort feuern
    lda #50
    sta bFireCounter        // Vor dem ersten Schuss eine längere Pause


!:
    jmp next_raster_irq

next_raster_irq:
    jsr SCORE.print_level
    jsr SCORE.print_score
    lda GlobalGameState
    cmp #GAME_STATE_PLAY
    beq !+
    SET_RASTER_LINE_V(RASTERLINE_SPACESHIP)
    INSTALL_RASTER_VECTOR(BULLETTEST.raster_irq)
    jmp !exit+
!:
    lda ZP_SP_ACTIVE_R1
    beq !+
    INSTALL_RASTER_VECTOR(irq_monster_row_1)
    SET_RASTER_LINE_A(Rasterline_Monster_R1)
    jmp !exit+
!:
    lda ZP_SP_ACTIVE_R2
    beq !+
    INSTALL_RASTER_VECTOR(irq_monster_row_2)
    SET_RASTER_LINE_A(Rasterline_Monster_R2)
    jmp !exit+
!:
    lda ZP_SP_ACTIVE_R3
    beq !+
    INSTALL_RASTER_VECTOR(irq_monster_row_3)
    SET_RASTER_LINE_A(Rasterline_Monster_R3)
    jmp !exit+
!:
    lda ZP_SP_ACTIVE_R4
    beq !+
    INSTALL_RASTER_VECTOR(irq_monster_row_4)
    SET_RASTER_LINE_A(Rasterline_Monster_R4)
    jmp !exit+
!:
    SET_RASTER_LINE_V(RASTERLINE_SPACESHIP)
    INSTALL_RASTER_VECTOR(BULLETTEST.raster_irq)
!exit:
    .if (COND_DEBUG) SET_BORDER_COLOR_V(COLOR_LIGHTBLUE)
    jmp irq_exit    
