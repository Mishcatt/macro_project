;--------------------------------------
; NMI - the NMI handler
nmi:
    pha         ; back up registers (important)
    txa
    pha
    tya
    pha
    bit PPUSTATUS ; reset PPUSCROLL/PPUADDR toggle

    @check_dma_flag:
        lda dmaflag
        beq @check_draw_flag
            lda #0      ; do sprite DMA
            sta OAMADDR   ; conditional via the 'dmaflag' flag
            lda #>OAM
            sta OAMDMA
            dec dmaflag

    @check_draw_flag:
        lda drawflag          ; do other PPU drawing (NT/Palette/whathaveyou)
        beq @check_ppu_flag ; conditional via the 'drawflag' flag
            bit PPUSTATUS         ; clear VBl flag, reset PPUSCROLL/PPUADDR toggle
            jsr DoDrawing     ; draw the stuff from the drawing buffer
            dec drawflag

    @check_ppu_flag:
        lda ppuflag
        beq @music_handler
            lda softPPUMASK   ; copy buffered PPUCTRL/PPUMASK (conditional via ppuflag)
            sta PPUMASK
            lda softPPUCTRL
            sta PPUCTRL
            bit PPUSTATUS
            lda xscroll    ; set X/Y scroll (conditional via ppuflag)
            sta PPUSCROLL
            lda yscroll
            sta PPUSCROLL
            dec ppuflag

    @music_handler:
        jsr MusicEngine

    lda #1         
    sta nmiflag   ; set the nmi_flag flag so that main_loop will continue

    pla            ; restore regs and exit
    tay
    pla
    tax
    pla
    rti