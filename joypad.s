readjoyx2:
    ldx #$00
    jsr readjoyx    ; X=0: read controller 1
    inx
    ; fall through to readjoyx below, X=1: read controller 2

readjoyx:           ; X register = 0 for controller 1, 1 for controller 2
    lda #$01
    sta JOYPAD1
    sta buttons1, x
    lsr a
    sta JOYPAD1
@loop:
    lda JOYPAD1, x
    and #%00000011  ; ignore bits other than controller
    cmp #$01        ; Set carry if and only if nonzero
    rol buttons1, x  ; Carry -> bit 0; but 7 -> Carry
    bcc @loop
    rts