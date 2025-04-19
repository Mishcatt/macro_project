DoDrawing:
    lda #%10000100  ; Enable NMI and vertical increment
    sta PPUCTRL
    bit PPUSTATUS   ; clear w register by reading Status

    lda currentRenderColumn ; 32 pixel column
    and #%111               ; 8 columns per nametable
    asl 
    asl 
    sta tempRenderColumn ; 8 pixel column

    ldx #0 ; start at offset 0
    ldy #0
    draw1:
        lda currentRenderNametableAddress
        sta PPUADDR
        tya
        clc
        adc tempRenderColumn
        sta PPUADDR
        lda DRAWBUFFER + 0, x   ; 5 cycles
        sta PPUDATA             ; 4 cycles
        lda DRAWBUFFER + 1, x
        sta PPUDATA
        lda DRAWBUFFER + 2, x
        sta PPUDATA
        lda DRAWBUFFER + 3, x
        sta PPUDATA
        lda DRAWBUFFER + 4, x
        sta PPUDATA
        lda DRAWBUFFER + 5, x
        sta PPUDATA
        lda DRAWBUFFER + 6, x
        sta PPUDATA
        lda DRAWBUFFER + 7, x
        sta PPUDATA
        lda DRAWBUFFER + 8, x
        sta PPUDATA
        lda DRAWBUFFER + 9, x
        sta PPUDATA
        lda DRAWBUFFER + 10, x
        sta PPUDATA
        lda DRAWBUFFER + 11, x
        sta PPUDATA
        lda DRAWBUFFER + 12, x
        sta PPUDATA
        lda DRAWBUFFER + 13, x
        sta PPUDATA
        lda DRAWBUFFER + 14, x
        sta PPUDATA
        lda DRAWBUFFER + 15, x
        sta PPUDATA
        lda DRAWBUFFER + 16, x
        sta PPUDATA
        lda DRAWBUFFER + 17, x
        sta PPUDATA
        lda DRAWBUFFER + 18, x
        sta PPUDATA
        lda DRAWBUFFER + 19, x
        sta PPUDATA
        lda DRAWBUFFER + 20, x
        sta PPUDATA
        lda DRAWBUFFER + 21, x
        sta PPUDATA
        lda DRAWBUFFER + 22, x
        sta PPUDATA
        lda DRAWBUFFER + 23, x
        sta PPUDATA
        lda DRAWBUFFER + 24, x
        sta PPUDATA
        lda DRAWBUFFER + 25, x
        sta PPUDATA
        lda DRAWBUFFER + 26, x
        sta PPUDATA
        lda DRAWBUFFER + 27, x
        sta PPUDATA
        lda DRAWBUFFER + 28, x
        sta PPUDATA
        lda DRAWBUFFER + 29, x
        sta PPUDATA
        txa
        adc #30 ; add offset 30 to DRAWBUFFER
        tax
        iny
        cpy #4
        beq draw1end
        jmp draw1
    draw1end:

    rts

PrepareDrawingTest:
    ldy #0
    @loop2:
        lda #1   ; load char number to A
        sta DRAWBUFFER, y
        iny
        cpy #120         ; last row
        bcc @loop2
    rts

PrepareDrawing:
    ldy #0
    sty temp2a
    lda currentRenderColumn
    asl
    sta temp2

    @drawing3:
        lda temp2
        ora temp2a ; add map offset
        tax
        lda map, x
        asl
        asl
        asl
        asl
        sta temp3
        lda #0
        sta temp3a

        @drawing2A:
            lda temp3
            clc
            adc temp3a ; add column offset
            tax
            inc temp3a ; 0 ... 14
            lda columns, x
            asl
            asl ; x4
            sta temp4

            @drawing1A:
                ldx temp4  ; 0 1
                lda blocks, x
                sta DRAWBUFFER, y
                iny
                inx
                lda blocks, x
                sta DRAWBUFFER, y
                iny

            lda temp3a
            cmp #15
            bcc @drawing2A

        lda temp2
        ora temp2a ; add map offset
        tax
        inc temp2a ; 0 1
        lda map, x
        asl
        asl
        asl
        asl
        sta temp3
        lda #0
        sta temp3a

        @drawing2B:
            lda temp3
            clc
            adc temp3a ; add column offset
            tax
            inc temp3a ; 0 ... 14
            lda columns, x
            asl
            asl ; x4
            sta temp4

            @drawing1B:
                ldx temp4   ; 2 3
                inx         ;
                inx         ;
                lda blocks, x
                sta DRAWBUFFER, y
                iny
                inx
                lda blocks, x
                sta DRAWBUFFER, y
                iny
            
            lda temp3a
            cmp #15
            bcc @drawing2B
        
        lda temp2a
        cmp #2
        bcc @drawing3
    rts