//*******************************************************************************
//*** Farben                                                                  ***
//*******************************************************************************
    .const COLOR_BLACK         = $00           //schwarz
    .const COLOR_WHITE         = $01           //weiß
    .const COLOR_RED           = $02           ////rot
    .const COLOR_CYAN          = $03           //türkis
    .const COLOR_PURPLE        = $04           //lila
    .const COLOR_GREEN         = $05           //grün
    .const COLOR_BLUE          = $06           //blau
    .const COLOR_YELLOW        = $07           //gelb
    .const COLOR_ORANGE        = $08           //orange
    .const COLOR_BROWN         = $09           //braun
    .const COLOR_PINK          = $0a           //rosa
    .const COLOR_DARKGREY      = $0b           //dunkelgrau
    .const COLOR_GREY          = $0c           //grau
    .const COLOR_LIGHTGREEN    = $0d           //hellgrün
    .const COLOR_LIGHTBLUE     = $0e           //hellblau
    .const COLOR_LIGHTGREY     = $0f           //hellgrau

//*******************************************************************************
//*** Die VIC II Register  -  ANFANG                                          ***
//*******************************************************************************
    .const VICBASE             = $d000         //(RG) = Register-Nr.
    .const SPRITE0X            = $d000         //(00) X-Position von Sprite 0
    .const SPRITE0Y            = $d001         //(01) Y-Position von Sprite 0
    .const SPRITE1X            = $d002         //(02) X-Position von Sprite 1
    .const SPRITE1Y            = $d003         //(03) Y-Position von Sprite 1
    .const SPRITE2X            = $d004         //(04) X-Position von Sprite 2
    .const SPRITE2Y            = $d005         //(05) Y-Position von Sprite 2
    .const SPRITE3X            = $d006         //(06) X-Position von Sprite 3
    .const SPRITE3Y            = $d007         //(07) Y-Position von Sprite 3
    .const SPRITE4X            = $d008         //(08) X-Position von Sprite 4
    .const SPRITE4Y            = $d009         //(09) Y-Position von Sprite 4
    .const SPRITE5X            = $d00a         //(10) X-Position von Sprite 5
    .const SPRITE5Y            = $d00b         //(11) Y-Position von Sprite 5
    .const SPRITE6X            = $d00c         //(12) X-Position von Sprite 6
    .const SPRITE6Y            = $d00d         //(13) Y-Position von Sprite 6
    .const SPRITE7X            = $d00e         //(14) X-Position von Sprite 7
    .const SPRITE7Y            = $d00f         //(15) Y-Position von Sprite 7
    .const SPRITESMAXX         = $d010         //(16) Höhstes BIT der jeweiligen X-Position
                                               //        da der BS 320 Punkte breit ist reicht
                                               //        ein BYTE für die X-Position nicht aus!
                                               //        Daher wird hier das 9. Bit der X-Pos
                                               //        gespeichert. BIT-Nr. (0-7) = Sprite-Nr.
    .const CTRLREG1            = $0d11         // Controlregister 1. Each Bit has a different function
                                               // Bit 7: Bit 9 of RASTERLINE
    .const REG_RASTERLINE      = $d012         // Current raster line (read) or to trigger IRQ (write)
    .const SPRITEACTIV         = $d015         //(21) Bestimmt welche Sprites sichtbar sind
                                               //        Bit-Nr. = Sprite-Nr.
    .const SPRITEDOUBLEHEIGHT  = $d017         //(23) Doppelte Höhe der Sprites
                                               //        Bit-Nr. = Sprite-Nr.
    .const SCREENMEMORYCTRL    = $d018         // Wo liegt der Zeichensatz und der Screen memory  
    .const IRQSTATUS           = $d019         // Status Register für den Interrupt
    .const INTERRUPTMASK       = $d01a
    .const SPRITEDEEP          = $d01b         //(27) Legt fest ob ein Sprite vor oder hinter
                                               //        dem Hintergrund erscheinen soll.
                                               //        Bit = 1: Hintergrund vor dem Sprite
                                               //        Bit-Nr. = Sprite-Nr.
    .const SPRITEMULTICOLOR    = $d01c         //(28) Bit = 1: Multicolor Sprite 
                                               //        Bit-Nr. = Sprite-Nr.
    .const SPRITEDOUBLEWIDTH   = $d01d         //(29) Bit = 1: Doppelte Breite des Sprites
                                               //        Bit-Nr. = Sprite-Nr.
    .const SPRITESPRITECOLL    = $d01e         //(30) Bit = 1: Kollision zweier Sprites
                                               //        Bit-Nr. = Sprite-Nr.
                                               //        Der Inhalt wird beim Lesen gelöscht!!
    .const SPRITEBACKGROUNDCOLL= $d01f         //(31) Bit = 1: Sprite / Hintergrund Kollision
                                               //        Bit-Nr. = Sprite-Nr.
                                               //        Der Inhalt wird beim Lesen gelöscht!
    .const BORDER_COLOR        = $d020        
    .const BACKGROUND_COLOR    = $d021
    .const SPRITEMULTICOLOR0   = $d025         //(37) Spritefarbe 0 im Multicolormodus
    .const SPRITEMULTICOLOR1   = $d026         //(38) Spritefarbe 1 im Multicolormodus
    .const SPRITE0COLOR        = $d027         //(39) Farbe von Sprite 0
    .const SPRITE1COLOR        = $d028         //(40) Farbe von Sprite 1
    .const SPRITE2COLOR        = $d029         //(41) Farbe von Sprite 2
    .const SPRITE3COLOR        = $d02a         //(42) Farbe von Sprite 3
    .const SPRITE4COLOR        = $d02b         //(43) Farbe von Sprite 4
    .const SPRITE5COLOR        = $d02c         //(44) Farbe von Sprite 5
    .const SPRITE6COLOR        = $d02d         //(45) Farbe von Sprite 6
    .const SPRITE7COLOR        = $d02e         //(46) Farbe von Sprite 7

    .const COLORRAM            = $d800
//*******************************************************************************
//*** Die VIC II Register  -  ENDE                                            ***
//*******************************************************************************


    .const IRQVECTOR           = $0314             // LSB IRQ Routine (MSB in $0315)

    .const SCREENRAM           = $0400             //Beginn des Bildschirmspeichers
    .const SPRITE0DATA         = SCREENRAM+$03f8   //Sprite-Pointer für die                                                   //Adresse der Sprite-0-Daten
    .const SPRITE1DATA         = SCREENRAM+$03f9   //wie eben, nur für Sprite-1
    
    .const CIA1_A              = $dc00             //Adresse des CIA1-A
    .const CIA1_B              = $dc01             //Adresse des CIA1-B

    .const INPUT_NONE          = $00               // Es wurde noch kein Port gewählt
    .const INPUT_JOY1          = $01               // Joystick in Port-1
    .const INPUT_JOY2          = $02               // oder 2
    .const JOY_UP              = %00000001         // Joystick rauf
    .const JOY_DOWN            = %00000010         // Joystick runter
    .const JOY_LEFT            = %00000100         // Joystick links
    .const JOY_RIGHT           = %00001000         // Joystick rechts
    .const JOY_FIRE            = %00010000         // Joystick FEUER!


    .const GAME_SPEED           = 3 // Alle drei Frames ein Screen update
