    .var COND_DEBUG = true

    .const MONSTER_A_BLK        = (monster_a_1/64)
    .const MONSTER_B_BLK        = (monster_b_1/64)
    .const MONSTER_C_BLK        = (monster_c_1/64)
    .const MONSTER_D_BLK        = (monster_d_1/64)
    .const SPACESHIP_BLK        = (space_ship/64)

    .const NUMBER_OF_SPRITES        =  40
    .const MONSTER_SPACING_V        =  25           // Monster Spacing (from left corner to left corder) horizontal 
    .const MONSTER_SPACING_H        =  25           // Monster Spacing (from top to top) vertically

    .const MONSTER_MIN_X            =  30
    .const MONSTER_MIN_Y            =  60
    .const MONSTER_MAX_Y            = 210           // If a "not dead" monster reaches this line, the player loses the game
    .const MONSTER_COUNT            =  32           // Anzahl der Monster
    .const MONSTER_RASTERLINE_DELTA =   6           // Anzahl der Rasterlinien oberhalb der Y Position

    .const SPRITE_STATE_SPAWNING    = %00000001 
    .const SPRITE_STATE_ALIVE   	= %00000010
    .const SPRITE_STATE_DYING       = %00000100 
    .const SPRITE_STATE_DEAD        = %00001000
    .const SPRITE_KILLABLE          = %10000000

    // Keep the spaceship in the last "slot"
    .const SPACESHIP_SPRITE_INDEX   = NUMBER_OF_SPRITES-1
    .const SPACESHIP_XPOS_LSB       = XPOS_LSB+SPACESHIP_SPRITE_INDEX   
    .const SPACESHIP_XPOS_MSB       = XPOS_MSB+SPACESHIP_SPRITE_INDEX   
    .const SPACESHIP_YPOS           = YPOS+SPACESHIP_SPRITE_INDEX
    .const SPACESHIP_STATE          = SPRITE_STATE+SPACESHIP_SPRITE_INDEX   
    .const SPACESHIP_DX             = SPRITE_DX+SPACESHIP_SPRITE_INDEX
    .const SPACESHIP_DY             = SPRITE_DY+SPACESHIP_SPRITE_INDEX
    
    .const GAME_STATE_INTRO         = %00000001
    .const GAME_STATE_PLAY          = %00000010
    .const GAME_STATE_DEFEAT        = %00000100
    .const GAME_STATE_VICTORY       = %00001000
    .const GAME_STATE_CREDITS       = %00010000           
    
    .const GAME_NEW_DELAY           = 50            // Number of frames, before a new games can be started
    .const RASTERLINE_SPACESHIP     = 227

    .import source "constants.asm"
    .import source "main_macros.asm"
            
    .print "First message: " + toHexString(msg_start_game)

    *=$02 "ZeroPage Variables" virtual 
        TempByte:               .byte $00
        TempWord:               .word $0000
        num1:                   .byte $00
        num1Hi:                 .byte $00
        num2:                   .byte $00
        num2Hi:                 .byte $00
        fgColor:                .byte $00
        JoyXDirection:          .byte $00
        JoyYDirection:          .byte $00
        Sprite0Anim:            .byte $00
        Current_Rasterline:     .byte $00
        Rasterline_Scene:       .byte $00
        Rasterline_BossShip:    .byte $00
        Rasterline_Monster_R1:  .byte $00
        Rasterline_Monster_R2:  .byte $00
        Rasterline_Monster_R3:  .byte $00
        Rasterline_Monster_R4:  .byte $00
        Rasterline_MR1_MSB:     .byte $00
        Rasterline_MR2_MSB:     .byte $00
        Rasterline_MR3_MSB:     .byte $00
        Rasterline_MR4_MSB:     .byte $00
        Rasterline_City:        .byte $00
        stringLo:               .byte $00
        stringHi:               .byte $00
        frameCounterLo:         .byte $00
        frameCounterHi:         .byte $00     
        firePause:              .byte $00   // Number of frames between two shots     
        bFireCounter:           .byte $00   // Zaehler fuer die Frames zwischen zwei Schuessen.  
        MonsterDownLines:       .byte $00   // Anzahl der Linien, die ein Monster nach unten bewegt werden soll.
        MonsterAlive:           .byte $00   // Anzahl der Monster, die noch leben
        GlobalGameState:        .byte $00
        ZP_GameState_Play:      .byte $00
        ZP_GameState_Victory:   .byte $00
        ZP_GameState_Defeat:    .byte $00  
        ZP_GameState_Credits:   .byte $00  
        ZP_GameState_Intro:     .byte $00  
        ZP_New_Game_Delay:      .byte $00   // Number of Frames before a new game can be started 
        ZP_ScoreLo:             .byte $00
        ZP_ScoreHi:             .byte $00
        ZP_Level:               .byte $00
        ZP_BG_COLLISION:        .byte $00
        ZP_SP_ACTIVE_R1:        .byte $00
        ZP_SP_ACTIVE_R2:        .byte $00
        ZP_SP_ACTIVE_R3:        .byte $00
        ZP_SP_ACTIVE_R4:        .byte $00
        ZP_MONSTER_DOWN_FLAG:   .byte $00
        ZP_MONSTER_SPEED_RIGHT: .byte $00
        ZP_MONSTER_SPEED_LEFT:  .byte $00
        

BasicUpstart2(main)

    *=$4000 "Program"

    .import source "lib\util.asm"
    .import source "screen.asm"
    .import source "math.asm"
    .import source "joystick.asm"
    .import source "collision.asm"
    .import source "lib\sprite.asm"   
    .import source "spaceship.asm"     
    .import source "score.asm"
    
AnimaData:
    .byte MONSTER_A_BLK, MONSTER_A_BLK, MONSTER_A_BLK, MONSTER_A_BLK
    .byte MONSTER_A_BLK, MONSTER_A_BLK, MONSTER_A_BLK, MONSTER_A_BLK
    .byte MONSTER_A_BLK+1, MONSTER_A_BLK+1, MONSTER_A_BLK+1, MONSTER_A_BLK+1
    .byte MONSTER_A_BLK+1, MONSTER_A_BLK+1, MONSTER_A_BLK+1, MONSTER_A_BLK+1

Anim_Monster_C_Live:
    .fill 8, MONSTER_C_BLK
    .fill 8, MONSTER_C_BLK+1

.import source "intro_screen.asm"
.import source "monster_update.asm"

/***********************************************
    MAIN PROGRAM LOOP
************************************************/
main:

    lda #GAME_STATE_INTRO
    sta ZP_GameState_Intro
    lda #GAME_STATE_PLAY
    sta ZP_GameState_Play
    lda #GAME_STATE_DEFEAT
    sta ZP_GameState_Defeat
    lda #GAME_STATE_VICTORY
    sta ZP_GameState_Victory
    lda #GAME_STATE_CREDITS
    sta ZP_GameState_Credits

    lda #$02 
    sta ZP_MONSTER_SPEED_RIGHT
    lda #$ff
    sta ZP_MONSTER_SPEED_LEFT

    lda GAME_NEW_DELAY
    sta ZP_New_Game_Delay

    // Framecounter Initialisieren
    lda #0
    sta frameCounterLo 
    sta frameCounterHi 

    // Charset setzen
    lda #%00011000
    sta SCREENMEMORYCTRL
    
    // Show Intro Screen
    SET_GAME_STATE(GAME_STATE_INTRO)
    jsr INTRO.show

    SET_GAME_STATE(GAME_STATE_PLAY)
    // Die Feuerpause vor dem ersten Schuss
    // ist größer
    lda #5                  // 5 Frames Pause zwischen zwei schuessen
    sta firePause
    lda #50
    sta bFireCounter        // Vor dem ersten Schuss eine längere Pause

    // Keine vergrößerten Sprites und 
    // kein Multicolor Sprite
    lda #0
    sta SPRITEDOUBLEHEIGHT
    sta SPRITEDOUBLEWIDTH
    sta SPRITEDEEP
    sta SPRITEMULTICOLOR

    // System zum Feuern initialisieren
    jsr BULLETTEST.init
    
    sei
    
    SET_ACTIVE_SPRITE_SET(0)    // Erste Monsterreihe aktivieren

    lda #244                    // Hier soll die Scene neu berechnet werden
    sta Rasterline_Scene

    // Initial bewegen sich die Monster nach rechts
    lda #1 
    jsr MONSTER.set_horizontal_speed

    INIT_MONSTER()
    SET_ACTIVE_SPRITES()
    UPDATE_MONSTER_RASTER_LINES()
    DISABLE_CIA_INTERRUPTS()
    BANKOUT_KERNAL_BASIC()
    SET_BACKGROUND_COLOR_V(COLOR_BLACK)
    SET_BORDER_COLOR_V(COLOR_BLACK)
    INSTALL_RASTER_VECTOR(update_scene)
    SET_RASTER_LINE_A(Rasterline_Scene)
    ACK_ANY_IRQ()
    ENABLE_RASTER_IRQ()

    jsr SCREEN.colorize
    jsr SCREEN.clear

    lda #0
    sta Sprite0Anim

    cli
main_end:
    jmp main_end

.import source "scene_update_raster_irq.asm"
.import source "monster_raster_irq.asm"
.import source "bullet_test.asm"
 

irq_exit:
    IRQ_EXIT()    

    msg_start_game:
        .encoding "screencode_upper"
        .text "PRESS FIRE TO START"
        .byte $00

    msg_defeated:
        .encoding "screencode_upper"
        .text "YOU HAVE BEEN DEFEATED"
        .byte $00

    msg_victory_1:
        .encoding "screencode_upper"
        .text "CONGRATULATIONS"
        .byte $00

    msg_victory_2:
        .encoding "screencode_upper"
        .text "YOU SAVED THE HUMAN KIND."
        .byte $00

    *=$3100 "Virtual Sprite Data"
        
    ACTIVE_SPRITES:
        .fill 8, 0

    XPOS_LSB:
        .fill NUMBER_OF_SPRITES, 0

    XPOS_MSB:
        .fill NUMBER_OF_SPRITES, 0

    YPOS:
        .fill NUMBER_OF_SPRITES, 0

    SPRITE_COLOR:
        .fill NUMBER_OF_SPRITES, 0

    SPRITE_DATA_BLOCK:
        .fill NUMBER_OF_SPRITES, 0

    SPRITE_DX:
        .fill NUMBER_OF_SPRITES, 1

    SPRITE_DY:
        .fill NUMBER_OF_SPRITES, 0

    SPRITE_STATE:
        .fill NUMBER_OF_SPRITES, SPRITE_STATE_ALIVE

    *=$2000 "Charset"
        .import source "data\invader_charset.asm"

    *=$3400 "Spritedata"
    .align $40
    spritedata:
        .import source "data\monster.asm"
