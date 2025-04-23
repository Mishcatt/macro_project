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
    sta playerMaxY ; set ground level
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

    lda #167
    sta playerMaxY ; set ground level
    
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

    lda playerY
    ldx #Sprites::Sprite6y
    sta OAM, x

    ; ldx #Sprites::Sprite6x
    lda buttons1
    and #BUTTON_LEFT
    beq noLeftButton

        ldx #Sprites::Sprite6Attributes
        lda OAM, x
        ora #%01000000
        sta OAM, x

        dec xscroll
        lda xscroll
        cmp #$FF
        bne :+
            lda softPPUCTRL
            eor #%00000001 ; swap nametable 0 and 1
            sta softPPUCTRL
        :
        lda xscroll
        and #%00011111  ; check if crossing column boundary
        cmp #%00011111  ; check for 31
        bne :+          
            dec currentCenter
            lda currentCenter
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

        inc xscroll
        bne :+
            lda softPPUCTRL
            eor #%00000001 ; swap nametable 0 and 1
            sta softPPUCTRL
        :
        lda xscroll
        and #%00011111  ; check if crossing column boundary
        bne :+          ; check for 0
            inc currentCenter
            lda currentCenter
            clc 
            adc #4
            and #%01111111 ; only 0-127
            sta currentDrawingColumn
        :
    noRightButton:
    jmp stateMachineEnd

stateGameFinish:

    jmp stateMachineEnd

stateGameOver:

    jmp stateMachineEnd

JumpTable:
    .addr stateGameInit
    .addr stateGameMenu
    .addr stateGameStart
    .addr stateGamePlaying
    .addr stateGameFinish
    .addr stateGameOver