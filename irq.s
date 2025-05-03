irq:
    pha
    lda #0
    sta DMC_START
    lda #16
    sta DMC_LEN
    pla
    rti