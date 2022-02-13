.namespace SPRITES {


/*****************************************************************************
* Alle acht Sprites einrichten.
* Kein Sprite ist Multivolor, keine doppelte Breite und keine
* doppelte Höhe.
* Die Farben sind hier noch hard ge-coded.
* Auch die Spriteblocks werden hier berechnet und im Speicher abgelegt.
* Zuletzt werden die Testbyte aktiviert.
*****************************************************************************/
    setup:
        lda #0
        sta SPRITEDOUBLEHEIGHT
        sta SPRITEDOUBLEWIDTH
        sta SPRITEDEEP
        sta SPRITEMULTICOLOR

        lda #%11111111
        sta SPRITEACTIV
        rts

/*****************************************************************************
* Convert virtual positions to real positions
* Es werden die virtuellen positionen auf reale positionen umgerechnet
* und im Zwischenspeicher abgelegt.
* Dei neuen Positionen werden noch NICHT im VIC abgelegt.
*****************************************************************************/
    convert_virtual_xy:
        ldx #8                  // Index für das Sprite, dass wir gerade behandeln.
        ldy #0                  // Alle neunten bits zunächst löschen. Diese werden
                                // in der schleife berechnet und im positiven fall
                                // gesetzt. 
    !loop:
        // X Position übersetzen
        lda VIRT_XPOS-1, x      // Virtuelle x position laden
        asl                     // Reale x position ergibt sich durch Multiplikation
                                // mit 2. Dabei kann natürlich ein Überlauf erfolgen.
                                // Der Überlauf entspricht dem 9, Bit des SPRITESMAXX
                                // für das jeweilige Bit.
        sta REAL_XPOS-1, x      // LSB der X Position speichern (Nicht im VIC) 
        tya
        rol                     // Carry oder Non-Carry Bit in das x-max Byte (Y Register)  
        tay                     // schieben
        
        // Y Position übersetzen
        lda VIRT_YPOS-1, x      // Virtuelle Y Position laden
        sta REAL_YPOS-1, x      // ERgebnis speichern (Nicht im VIC)

        dex                     // Nächstes Sprite bearbeiten
        bne !loop-
        sty SPRITE_XMAX         // Das neunte Bit der Sprites hier ablegen 
        rts
        
/*****************************************************************************
* Aktualisiert alle Positionen der Sprites.
* Richtung und Geschwindigkeit wird aus dem Sprita Data Block
* genommen. Es wird geprüft, ob die neue Position ausserhalb des 
* erlaubten bereiches liegt.
* Die Aktualisierung erfolgt auf Basis der virtuellen Screen-
* daten berechnet. 
*****************************************************************************/
    update_positions:
        ldx #32                 // Updating all sprites
    !loop:
        SPRITE_MOVE_HORIZONTAL()
        SPRITE_MOVE_VERTICAL()
        dex
        bne !loop-
        rts 

}
