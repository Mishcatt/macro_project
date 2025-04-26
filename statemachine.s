stateGameInit:

    jmp stateMachineEnd

stateGameMenu:

    jmp stateMachineEnd

stateGameStart:
    lda stateTemp1
    cmp #9
    beq :+
        sta currentDrawingColumn
        inc stateTemp1
        jmp stateMachineEnd
    :
    lda #255
    sta currentDrawingColumn
    lda #GameStates::GamePlaying
    sta currentState

    lda #167
    sta playerMaxYleft
    sta playerMaxY ; set ground level
    sta playerMaxYright
    sta playerY

    jmp stateMachineEnd

stateGamePlaying:
    ldx #Sprites::Sprite2y
    inc OAM, x
    ldx #Sprites::Sprite2x
    inc OAM, x
    ldx #Sprites::Sprite3y
    dec OAM, x
    ldx #Sprites::Sprite3x
    dec OAM, x
    ldx #Sprites::Sprite4y
    inc OAM, x
    ldx #Sprites::Sprite4x
    dec OAM, x
    ldx #Sprites::Sprite5y
    dec OAM, x
    ldx #Sprites::Sprite5x
    inc OAM, x

    jsr getCurrentGroundLevel
    
    lda buttons1
    and #BUTTON_UP
    beq :+ 
        lda playerY
        beq :+
            dec playerY
    :
    lda buttons1
    and #BUTTON_DOWN
    beq :+
        lda playerY
        cmp playerMaxY ; check for ground
        bcs :+
            inc playerY
    :

    ; ldx #Sprites::Sprite6x
    lda buttons1
    and #BUTTON_LEFT
    beq noLeftButton

        ldx #Sprites::Sprite6Attributes
        lda OAM, x
        ora #%01000000
        sta OAM, x

        ldx playerMaxYleft
        inx
        cpx playerY
        bcc noLeftButton
            bne :+
                dec playerY
            :
            dec xscroll
            lda xscroll
            cmp #$FF
            bne :+
                lda softPPUCTRL
                eor #%00000001 ; swap nametable 0 and 1
                sta softPPUCTRL
            :
            lda xscroll
            and #%00001111  ; check if crossing 16px column boundary
            cmp #%00001111  ; check for 15
            bne :+
                dec currentMapColumn
                lda currentMapColumn
                lsr
                sta currentCenter ; store 32px column number
                clc 
                sbc #4
                and #%01111111 ; only 0-127
                sta currentDrawingColumn
            :
    noLeftButton:
    lda buttons1
    and #BUTTON_RIGHT
    beq noRightButton

        ldx #Sprites::Sprite6Attributes
        lda OAM, x
        and #%10111111
        sta OAM, x

        ldx playerMaxYright
        inx
        cpx playerY
        bcc noRightButton
            bne :+
                dec playerY
            :
            inc xscroll
            bne :+
                lda softPPUCTRL
                eor #%00000001 ; swap nametable 0 and 1
                sta softPPUCTRL
            :
            lda xscroll
            and #%00001111  ; check if crossing 16px column boundary
            bne :+          ; check for 0
                inc currentMapColumn
                lda currentMapColumn
                lsr
                sta currentCenter ; store 32px column number
                clc 
                adc #4
                and #%01111111 ; only 0-127
                sta currentDrawingColumn
            :
    noRightButton:

    lda playerY
    ldx #Sprites::Sprite6y
    sta OAM, x ; store player sprite Y position

    jmp stateMachineEnd

stateGameFinish:

    jmp stateMachineEnd

stateGameOver:

    jmp stateMachineEnd

getCurrentGroundLevel:
    ldx currentMapColumn
    lda map, x
    asl
    asl
    asl
    asl ; x16
    sta temp2 ; left column address
    sta temp3 ; center column address
    sta temp4 ; right column address
    tax
    
    lda columns+14, x
    sta temp2a ; left column special byte
    sta temp3a ; center column special byte
    sta temp4a ; right column special byte
    
    lda columns+15, x
    sta playerMaxYleft
    sta playerMaxY
    sta playerMaxYright

    lda xscroll 
    and #%00001111
    sta temp1 ; store player pixel offset in column

    checkRightGroundLevel:
        lda temp1
        cmp #%00001111  ; check for 15 - last pixel on right
        bne checkLeftGroundLevel
            ldx currentMapColumn
            inx
            lda map, x
            asl
            asl
            asl
            asl ; x16
            sta temp4 ; right column address
            tax
            lda columns+14, x
            sta temp4a ; right column special byte
            lda columns+15, x
            sta playerMaxYright

    checkLeftGroundLevel:
        lda temp1
        bne checkGroundLevelSpecial ; check for 0 - first pixel on left
            ldx currentMapColumn
            dex
            lda map, x
            asl
            asl
            asl
            asl ; x16
            sta temp2 ; left column address
            tax
            lda columns+14, x
            sta temp2a ; left column special byte
            lda columns+15, x
            sta playerMaxYleft
    
    checkGroundLevelSpecial:
        lda temp3a 
        beq checkRightGroundLevelSpecial
            sec
            sbc #1
            asl
            asl
            asl
            asl ; x16
            clc
            adc temp1 ; add pixel offset
            tax
            lda specialHeightMapAbs, x
            sta playerMaxY

    checkRightGroundLevelSpecial:
        lda temp4a 
        beq checkLeftGroundLevelSpecial
            lda temp1
            clc 
            adc #1
            and #%00001111
            sta temp3b ; store (xscroll+1) % 15
            lda temp4a
            sec
            sbc #1
            asl
            asl
            asl
            asl ; x16
            clc
            adc temp3b
            tax
            lda specialHeightMapAbs, x
            sta playerMaxYright
    
    checkLeftGroundLevelSpecial:
        lda temp2a 
        beq checkGroundLevelEnd
            lda temp1
            sec 
            sbc #1
            and #%00001111
            sta temp3b ; store (xscroll-1) % 15
            lda temp2a
            sec
            sbc #1
            asl
            asl
            asl
            asl ; x16
            clc
            adc temp3b
            tax
            lda specialHeightMapAbs, x
            sta playerMaxYleft
    checkGroundLevelEnd:
    rts

JumpTable:
    .addr stateGameInit
    .addr stateGameMenu
    .addr stateGameStart
    .addr stateGamePlaying
    .addr stateGameFinish
    .addr stateGameOver