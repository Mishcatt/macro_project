stateGameInit:

    jmp stateMachineEnd

stateGameMenu:

    jmp stateMachineEnd

stateGameStart:
    lda #1
    sta drawflag
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

    lda #InitialPlayerSize
    sta playerSize

    lda #0
    sta collisionTimer
    sta playerStomp

    jsr initStatusbar

    jmp stateMachineEnd

stateGamePlaying:
    inc logoWaveStep
    lda logoWaveStep
    and #%01111111
    lsr
    lsr
    tay

    lda Sinusoid, y
    sta OAM+SpriteLogo0y
    iny
    iny
    lda Sinusoid, y
    sta OAM+SpriteLogo1y
    iny
    iny
    lda Sinusoid, y
    sta OAM+SpriteLogo2y
    iny
    iny
    lda Sinusoid, y
    sta OAM+SpriteLogo3y
    iny
    iny
    lda Sinusoid, y
    sta OAM+SpriteLogo4y
    iny
    iny
    lda Sinusoid, y
    sta OAM+SpriteLogo5y
    iny
    iny
    lda Sinusoid, y
    sta OAM+SpriteLogo6y
    iny
    iny
    lda Sinusoid, y
    sta OAM+SpriteLogo7y
    iny
    iny
    lda Sinusoid, y
    sta OAM+SpriteLogo8y

    inc OAM+Sprite2y
    inc OAM+Sprite2x
    dec OAM+Sprite3y
    dec OAM+Sprite3x
    inc OAM+Sprite4y
    dec OAM+Sprite4x
    dec OAM+Sprite5y
    inc OAM+Sprite5x


    jsr getCurrentGroundLevel
    jsr applyGravity
    jsr applyControls
    jsr applyCollisions

    ; lda playerY
    ; ldx #SpritePlayerM0y
    ; sta OAM, x ; store player sprite Y position

    lda playerStomp
    cmp #6
    bcc :+
        lda #0
        sta playerStomp
        inc playerSize
    :

    lda playerSize
    cmp #6
    bcc :+
        lda #6
        sta playerSize
        sta playerStomp
    :

    jsr updateStatusbar
    jsr updatePlayerSprites

    jmp stateMachineEnd

stateGameFinish:

    jmp stateMachineEnd

stateGameOver:

    jmp stateMachineEnd

getCurrentGroundLevel:
    ldx currentMapColumn
    lda MAP, x
    ; clc
    ; adc playerGroundCollision
    asl
    asl
    asl
    asl ; x16
    sta temp2 ; left column address
    sta temp3 ; center column address
    sta temp4 ; right column address
    tax

    lda columns+13, x
    sta currentColumnDestructible
    
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
            lda MAP, x
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
            lda MAP, x
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
            ; ldx currentColumnDestructible
            ; beq :+
            ;     clc
            ;     adc playerWeight
            ; :
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
            ; ldx currentColumnDestructible
            ; beq :+
            ;     clc
            ;     adc playerWeight
            ; :
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
            ; ldx currentColumnDestructible
            ; beq :+
            ;     clc
            ;     adc playerWeight
            ; :
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

applyControls:
    lda #0
    sta tempButtons1
    sta tempButtons2

    lda buttons1
    cmp previousButtons1
    beq :+
        eor previousButtons1
        and buttons1
        sta tempButtons1
        lda buttons1
        sta previousButtons1
    :
    
    lda buttons2
    cmp previousButtons2
    beq :+
        eor previousButtons2
        and buttons2
        sta tempButtons2
        lda buttons2
        sta previousButtons2
    :

    lda tempButtons1
    and #BUTTON_SELECT
    beq :+
        lda #StatusbarUpdate
        sta statusbarState
        inc playerStomp
        lda playerStomp
        cmp #MaxPlayerStomp
        bcc :+
            lda #MaxPlayerStomp
            sta playerStomp
    :

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

    checkLeftButton:
        ; ldx #Sprites::Sprite6x
        lda buttons1
        and #BUTTON_LEFT
        beq checkRightButton

            lda OAM+SpritePlayerM0a
            ora #%01000000
            sta OAM+SpritePlayerM0a

            ldx playerMaxYleft
            inx
            cpx playerY
            bcc checkRightButton
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
                    sec 
                    sbc #5
                    and #%01111111 ; only 0-127
                    sta currentDrawingColumn
                    lda #1
                    sta drawflag
                :

    checkRightButton:
        lda buttons1
        and #BUTTON_RIGHT
        beq checkAButton

            lda OAM+SpritePlayerM0a
            and #%10111111
            sta OAM+SpritePlayerM0a

            ldx playerMaxYright
            inx
            cpx playerY
            bcc checkAButton
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
                    adc #5
                    and #%01111111 ; only 0-127
                    sta currentDrawingColumn
                    lda #1
                    sta drawflag
                :
    checkAButton:
        lda buttons1
        and #BUTTON_A
        beq checkAButtonRelease
            lda playerY
            cmp playerMaxY
            bne :+
                ldx playerSize
                lda JumpVelocity, x
                sta playerVelocityY
                dec playerY
            :

    checkAButtonRelease:

    checkButtonEnd:

    rts

applyGravity:
    lda playerY
    cmp playerMaxY
    bcs applyGravityEnd
        lda #0
        sta playerGroundCollision
        lda playerVelocityY
        clc
        adc #GravityValue
        sta playerVelocityY
        and #%10000000
        sta temp1 ; store sign value
        lda playerVelocityY
        lsr
        ora temp1
        lsr ; /4
        ora temp1 ; restore sign
        sta playerTempVelocityY

        lda playerY
        clc
        adc playerTempVelocityY
        cmp playerMaxY
        bcc :+
            lda #1
            sta playerGroundCollision
            lda playerMaxY
        :
        sta playerY
        rts

    applyGravityEnd:
        lda #0
        sta playerVelocityY
        sta playerTempVelocityY
        lda #1
        sta playerGroundCollision
        rts

applyCollisions:
    lda collisionTimer
    beq :+
        dec collisionTimer
        rts
    :
        lda currentColumnDestructible
        beq cancelCollision

            lda playerGroundCollision
            cmp playerPreviousCollision
            beq applyCollisionsEnd ; check if no change

                sta playerPreviousCollision

                lda #CollisionTimerValue
                sta collisionTimer

                lda playerGroundCollision
                beq cancelCollision ; check if collision is zero

                    lda currentCenter
                    sta lastCollisionColumn
                    sta currentDrawingColumn
                    asl
                    tax
                    lda playerSize
                    sta currentColumnDestructionOffset
                    clc 
                    adc MAP, x
                    sta MAP, x
                    inx 
                    lda playerSize
                    clc 
                    adc MAP, x
                    sta MAP, x
                    lda #1
                    sta drawflag
                    rts

            cancelCollision:
                lda currentColumnDestructionOffset
                beq applyCollisionsEnd
                    lda lastCollisionColumn
                    sta currentDrawingColumn
                    asl
                    tax
                    lda MAP, x
                    sec 
                    sbc currentColumnDestructionOffset
                    sta MAP, x 
                    inx
                    lda MAP, x
                    sec
                    sbc currentColumnDestructionOffset
                    sta MAP, x
                    lda #0
                    sta currentColumnDestructionOffset
                    sta playerPreviousCollision
                    lda #1
                    sta drawflag
                    rts

    applyCollisionsEnd:

    rts

initStatusbar:
    lda #CHAR_EMPTY

    ldx #$80
    :
        dex
        sta STATUSBAR1, x
    bne :-

    lda #StatusbarUpdate
    sta statusbarState
    sta drawStatusbar1Flag
    sta drawStatusbar2Flag

    rts

updateStatusbar:
    lda statusbarState
    cmp #StatusbarUpdate
    bne updateStatusbarEnd
        ldx #6
        @updateStatusbarLoop:
            dex

            lda TextEdition, x
            sta STATUSBAR1+StatusbarOffsetEdition, x

            lda TextStomp, x
            sta STATUSBAR1+StatusbarOffsetStomp, x

            txa
            cmp playerStomp
            bcc :+
                lda #CHAR_BAR0
                jmp :++
            :
                lda #CHAR_BAR1
            :
            sta STATUSBAR1+StatusbarOffsetStompBar, x

            lda TextSize, x
            sta STATUSBAR1+StatusbarOffsetSize, x

            txa
            cmp playerSize
            bcc :+
                lda #CHAR_BAR0
                jmp :++
            :
                lda #CHAR_BAR1
            :
            sta STATUSBAR1+StatusbarOffsetSizeBar, x
            txa
        bne @updateStatusbarLoop

        lda TextEdition+6
        sta STATUSBAR1+StatusbarOffsetEdition+6

        lda #1
        sta drawStatusbar1Flag
        inc statusbarState

    updateStatusbarEnd:
    rts

updatePlayerSprites:
    lda playerSize
    asl ; x2 
    tax
    lda PlayerSpritesJumpTable, x    ; Low byte
    sta tempAddr
    lda PlayerSpritesJumpTable+1, x  ; High byte
    sta tempAddr+1
    
    ldy #SpritePlayerR8i
    ldx #45
    lda playerY
    sec
    sbc #64
    sta temp1
    lda #5
    sta temp2
    jmp (tempAddr)

    updatePlayerSprites0:
        dex
        bmi :+  ; if x == 0
            lda PlayerSpritesSize0, x
            jsr updatePlayerSpritesInternal
            jmp updatePlayerSprites0
        :

        jmp updatePlayerSpritesReady

    updatePlayerSprites1:
        dex
        bmi :+  ; if x == 0
            lda PlayerSpritesSize1, x
            jsr updatePlayerSpritesInternal
            jmp updatePlayerSprites1
        :
        jmp updatePlayerSpritesReady

    updatePlayerSprites2:
        dex
        bmi :+  ; if x == 0
            lda PlayerSpritesSize2, x
            jsr updatePlayerSpritesInternal
            jmp updatePlayerSprites2
        :
        jmp updatePlayerSpritesReady

    updatePlayerSprites3:
        dex
        bmi :+  ; if x == 0
            lda PlayerSpritesSize3, x
            jsr updatePlayerSpritesInternal
            jmp updatePlayerSprites3
        :
        jmp updatePlayerSpritesReady

    updatePlayerSprites4:
        dex
        bmi :+  ; if x == 0
            lda PlayerSpritesSize4, x
            jsr updatePlayerSpritesInternal
            jmp updatePlayerSprites4
        :
        jmp updatePlayerSpritesReady

    updatePlayerSprites5:
        dex
        bmi :+  ; if x == 0
            lda PlayerSpritesSize5, x
            jsr updatePlayerSpritesInternal
            jmp updatePlayerSprites5
        :
        jmp updatePlayerSpritesReady

    updatePlayerSprites6:
        dex
        bmi :+  ; if x == 0
            lda PlayerSpritesSize6, x
            jsr updatePlayerSpritesInternal
            jmp updatePlayerSprites6
        :
        jmp updatePlayerSpritesReady

    updatePlayerSpritesReady:
        rts

updatePlayerSpritesInternal:
    sta OAM, y
    dey
    lda temp1
    sta OAM,y
    dey
    dey
    dey
    
    dec temp2
    bne :+
        lda #5
        sta temp2
        lda temp1
        clc
        adc #8
        sta temp1
    :

    rts

PlayerSpritesJumpTable:
    .addr updatePlayerSprites0
    .addr updatePlayerSprites1
    .addr updatePlayerSprites2
    .addr updatePlayerSprites3
    .addr updatePlayerSprites4
    .addr updatePlayerSprites5
    .addr updatePlayerSprites6

StateJumpTable:
    .addr stateGameInit
    .addr stateGameMenu
    .addr stateGameStart
    .addr stateGamePlaying
    .addr stateGameFinish
    .addr stateGameOver