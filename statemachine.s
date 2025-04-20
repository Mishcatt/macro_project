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
    jmp stateMachineEnd

stateGamePlaying:

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