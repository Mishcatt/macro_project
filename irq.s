irq:
    pha         ; back up registers (important)
    txa
    pha
    tya
    pha

    lda #%00001111 ; disable DMC IRQ
    sta DMC_FREQ
    lda #%00000000 ; disable DMC
    sta SND_CHN
    bit SND_CHN

    lda dmcCounter
    beq :+
    dec dmcCounter
        lda #%10001111 ; enable DMC IRQ
        sta DMC_FREQ
        lda #0
        sta DMC_START
        sta DMC_RAW
        lda #1
        sta DMC_LEN
        lda #%00010000 ; enable DMC
        sta SND_CHN
    :

    ; lda dmcCounter
    ; and #%00000001
    ; ora #%00011110
    ; sta PPUMASK

    bit PPUSTATUS

    lda softPPUCTRL
    and #%00000011 ; get current nametable
    asl
    asl ; x4 = $00, $04, $08, $0C
    sta PPUADDR

    lda #dmcYsplitValue
    sta PPUSCROLL

    and #%11111000
    asl
    asl
    sta dmcTemp
    ldx xscroll
    stx PPUSCROLL

    txa
    lsr
    lsr
    lsr
    ora dmcTemp
    sta PPUADDR

    pla            ; restore regs and exit
    tay
    pla
    tax
    pla
    rti