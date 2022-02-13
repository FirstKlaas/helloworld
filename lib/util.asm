.macro DISABLE_CIA_INTERRUPTS() {
    lda #%01111111	//Disable CIA IRQ's
    sta $dc0d
    //sta $dd0
}

.macro BANKOUT_KERNAL_BASIC() {
    lda #$35	//Bank out kernal and basic
    sta $01    
}

.macro RETURN_FROM_IRQ() {
    pla
    tay
    pla 
    tax
    pla
    rti    
}

.macro PUSH_AXY() {
    pha
    txa
    pha
    tya
    pha
}

.macro PULL_AXY() {
    pla
    tay
    pla
    tax
    pla
}

.macro ENABLE_RASTER_IRQ() {
    lda #%00000001
    sta INTERRUPTMASK
}

.macro DISABLE_RASTER_IRQ() {
    lda INTERRUPTMASK
    and #%11111110
    sta INTERRUPTMASK
}

.macro SET_RASTER_LINE_V(line) {
    lda #line        // In dieser Zeile soll der Interrupt erfolgen
    sta REG_RASTERLINE   // In das Register schreiben.
    lda $d011        // Nun noch das 9te Bit löschen
    and #%01111111
    sta $d011
}

.macro SET_RASTER_LINE_A(line_adr) {
    lda line_adr         // In dieser Zeile soll der Interrupt erfolgen
    sta REG_RASTERLINE   // In das Register schreiben.
    lda $d011            // Nun noch das 9te Bit löschen
    and #%01111111
    sta $d011
}

.macro SET_RASTER_LINE_HIGH_A(line_adr) {
    lda line_adr         // In dieser Zeile soll der Interrupt erfolgen
    sta REG_RASTERLINE   // In das Register schreiben.
    lda $d011            // Nun noch das 9te Bit löschen
    ora #%10000000
    sta $d011
}

.macro SET_VECTOR_AA(function, adr) {
    lda #<function
    sta adr
    lda #>function
    sta adr+1
}

.macro SET_RASTER_CLB_V(function) {
    SET_VECTOR_AA(function, $0314)
}

.macro FAST_RASTER_IRQ_AV(function, rasterline) {
    // Set the IRQ routine vector 
    SET_VECTOR_AA(function, $0314)

    // Set the rasterline we want the interrupt to occur
    SET_RASTER_LINE_V(rasterline)
}

.macro FAST_RASTER_IRQ_AA(function, rasterline_adr) {
    // Set the IRQ routine vector 
    SET_VECTOR_AA(function, $0314)

    // Set the rasterline we want the interrupt to occur
    SET_RASTER_LINE_A(rasterline_adr)
}

.macro SET_BORDER_COLOR_V(color) {
    lda #color
    sta BORDER_COLOR    
}

.macro SET_BACKGROUND_COLOR_V(color) {
    lda #color
    sta BACKGROUND_COLOR
}


.macro INSTALL_RASTER_VECTOR(function) {
    lda #<function
    sta $fffe 
    lda #>function
    sta $ffff 
}

.macro TURN_OFF_SPRITES() {
    lda #$00
    sta SPRITEACTIV    
}

.macro ENABLE_SPRITES(mask) {
    lda #mask
    sta SPRITEACTIV    
}

