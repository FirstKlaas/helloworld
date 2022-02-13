
.namespace INTRO {

    show:
        jsr SCREEN.clear
        jsr SCREEN.colorize
        SET_BACKGROUND_COLOR_V(COLOR_BLACK)
        SET_BORDER_COLOR_V(COLOR_GREY)

        PRINT_STR_ZERO(10,20,msg_start_game)
    !:
        jsr JOYSTICK.check
        bcs !-
        rts

}
