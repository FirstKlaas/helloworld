.namespace KI {

    update:
        ldx #8
    !loop:
        lda KI_MSB-1,x   // HighByte für den call laden 
        beq !+                  // Wenn das Highbyte der Adresse 0 ist,
                                // dann gibt es keinen call.
        sta update_ki_call+2    // Highbyte in den call schreiben.
        lda KI_LSB-1,x   // LowByte für den call laben
        sta update_ki_call+1    // Un in die adresse des Aufrufs 
                                // schreiben
        txa
        pha 
    update_ki_call:
        jsr $0000
        pla
        tax
    !:
        dex
        bne !loop-
        rts

}