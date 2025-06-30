DRAWBUFFER  := $0100  ; Beginning of Drawing Buffer
COLORBUFFER := $0178  ; Beginning of Color Buffer
OAM         := $0200  ; Beginning of OAM Shadow buffer
SOUNDBUFFER := $0300
MAP         := $0400  ; 256 bytes of map columns 
STATUSBAR1  := $0500  ; two rows of nametable 0
STATUSBAR2  := $0540  ; two rows of nametable 1

InitialState := 2
InitialCenter := 4
InitialPlayerWeight := 1

gravityValue := 1
jumpVelocity := $F8 ; -8
collisionTimerValue := 4

dmcIRQenableValue := 0
dmcCounterValue := 2
dmcYsplitValue := 130

emptyTile := $25

statusbar_offset_stomp := 13
statusbar_offset_size := 21

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

famicon:
    .byte $10, $0B, $17, $13, $0D, $19, $18, $25, $02, $08

text_stomp:
    .byte $1D, $1E, $19, $17, $1A, emptyTile

text_size:
    .byte emptyTile, $1D, $13, $24, $0F, emptyTile

konamiCode:
    .byte $08, $08, $04, $04, $02, $01, $02, $01, $40, $80
