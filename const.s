DRAWBUFFER  := $0100  ; Beginning of Drawing Buffer
COLORBUFFER := $0178  ; Beginning of Color Buffer
OAM         := $0200  ; Beginning of OAM Shadow buffer
SOUNDBUFFER := $0300
MAP         := $0400

InitialState := 2
InitialCenter := 4
InitialPlayerWeight := 1

gravityValue := 1
jumpVelocity := $F8 ; -8
collisionTimerValue := 4

dmcCounterValue := 2
dmcYsplitValue := 130

.enum Sprites
    Sprite0y = 0
    Sprite0Index
    Sprite0Attributes
    Sprite0x
    Sprite1y
    Sprite1Index
    Sprite1Attributes
    Sprite1x
    Sprite2y
    Sprite2Index
    Sprite2Attributes
    Sprite2x
    Sprite3y
    Sprite3Index
    Sprite3Attributes
    Sprite3x
    Sprite4y
    Sprite4Index
    Sprite4Attributes
    Sprite4x
    Sprite5y
    Sprite5Index
    Sprite5Attributes
    Sprite5x
    Sprite6y
    Sprite6Index
    Sprite6Attributes
    Sprite6x
    Sprite7y
    Sprite7Index
    Sprite7Attributes
    Sprite7x
    Sprite8y
    Sprite8Index
    Sprite8Attributes
    Sprite8x
.endenum

buttons1 = buttons
buttons2 = buttons + 1

.enum  GameStates
    GameInit = 0
    GameMenu
    GameStart
    GamePlaying
    GameFinish
    GameOver
.endenum

konamiCode:
    .byte $08, $08, $04, $04, $02, $01, $02, $01, $40, $80
