DRAWBUFFER  := $0100  ; Beginning of Drawing Buffer
COLORBUFFER := $0178  ; Beginning of Color Buffer
OAM         := $0200  ; Beginning of OAM Shadow buffer
SOUNDBUFFER := $0300
MAP         := $0400  ; 256 bytes of map columns 
STATUSBAR1  := $0500  ; two rows of nametable 0
STATUSBAR2  := $0540  ; two rows of nametable 1

InitialState := 2
InitialCenter := 4
InitialPlayerSize := 0

MaxPlayerStomp := 6
MaxPlayerSize := 6

GravityValue := 1
JumpVelocity := $F8 ; -8
CollisionTimerValue := 4

DMCIRQenableValue := 0
DMCCounterValue := 2
DMCYsplitValue := 130

StatusbarOffsetEdition := 3
StatusbarOffsetStomp := 13
StatusbarOffsetStompBar := 45
StatusbarOffsetSize := 21
StatusbarOffsetSizeBar := 53

BUTTON_A      = 1 << 7
BUTTON_B      = 1 << 6
BUTTON_SELECT = 1 << 5
BUTTON_START  = 1 << 4
BUTTON_UP     = 1 << 3
BUTTON_DOWN   = 1 << 2
BUTTON_LEFT   = 1 << 1
BUTTON_RIGHT  = 1 << 0

.enum
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
    SpritePlayerL0y
    SpritePlayerL0i
    SpritePlayerL0a
    SpritePlayerL0x
    SpritePlayerML0y
    SpritePlayerML0i
    SpritePlayerML0a
    SpritePlayerML0x
    SpritePlayerM0y
    SpritePlayerM0i
    SpritePlayerM0a
    SpritePlayerM0x
    SpritePlayerMR0y
    SpritePlayerMR0i
    SpritePlayerMR0a
    SpritePlayerMR0x
    SpritePlayerR0y
    SpritePlayerR0i
    SpritePlayerR0a
    SpritePlayerR0x
    SpritePlayerL1y
    SpritePlayerL1i
    SpritePlayerL1a
    SpritePlayerL1x
    SpritePlayerML1y
    SpritePlayerML1i
    SpritePlayerML1a
    SpritePlayerML1x
    SpritePlayerM1y
    SpritePlayerM1i
    SpritePlayerM1a
    SpritePlayerM1x
    SpritePlayerMR1y
    SpritePlayerMR1i
    SpritePlayerMR1a
    SpritePlayerMR1x
    SpritePlayerR1y
    SpritePlayerR1i
    SpritePlayerR1a
    SpritePlayerR1x
    SpritePlayerL2y
    SpritePlayerL2i
    SpritePlayerL2a
    SpritePlayerL2x
    SpritePlayerML2y
    SpritePlayerML2i
    SpritePlayerML2a
    SpritePlayerML2x
    SpritePlayerM2y
    SpritePlayerM2i
    SpritePlayerM2a
    SpritePlayerM2x
    SpritePlayerMR2y
    SpritePlayerMR2i
    SpritePlayerMR2a
    SpritePlayerMR2x
    SpritePlayerR2y
    SpritePlayerR2i
    SpritePlayerR2a
    SpritePlayerR2x
    SpritePlayerL3y
    SpritePlayerL3i
    SpritePlayerL3a
    SpritePlayerL3x
    SpritePlayerML3y
    SpritePlayerML3i
    SpritePlayerML3a
    SpritePlayerML3x
    SpritePlayerM3y
    SpritePlayerM3i
    SpritePlayerM3a
    SpritePlayerM3x
    SpritePlayerMR3y
    SpritePlayerMR3i
    SpritePlayerMR3a
    SpritePlayerMR3x
    SpritePlayerR3y
    SpritePlayerR3i
    SpritePlayerR3a
    SpritePlayerR3x
    SpritePlayerL4y
    SpritePlayerL4i
    SpritePlayerL4a
    SpritePlayerL4x
    SpritePlayerML4y
    SpritePlayerML4i
    SpritePlayerML4a
    SpritePlayerML4x
    SpritePlayerM4y
    SpritePlayerM4i
    SpritePlayerM4a
    SpritePlayerM4x
    SpritePlayerMR4y
    SpritePlayerMR4i
    SpritePlayerMR4a
    SpritePlayerMR4x
    SpritePlayerR4y
    SpritePlayerR4i
    SpritePlayerR4a
    SpritePlayerR4x
    SpritePlayerL5y
    SpritePlayerL5i
    SpritePlayerL5a
    SpritePlayerL5x
    SpritePlayerML5y
    SpritePlayerML5i
    SpritePlayerML5a
    SpritePlayerML5x
    SpritePlayerM5y
    SpritePlayerM5i
    SpritePlayerM5a
    SpritePlayerM5x
    SpritePlayerMR5y
    SpritePlayerMR5i
    SpritePlayerMR5a
    SpritePlayerMR5x
    SpritePlayerR5y
    SpritePlayerR5i
    SpritePlayerR5a
    SpritePlayerR5x
    SpritePlayerL6y
    SpritePlayerL6i
    SpritePlayerL6a
    SpritePlayerL6x
    SpritePlayerML6y
    SpritePlayerML6i
    SpritePlayerML6a
    SpritePlayerML6x
    SpritePlayerM6y
    SpritePlayerM6i
    SpritePlayerM6a
    SpritePlayerM6x
    SpritePlayerMR6y
    SpritePlayerMR6i
    SpritePlayerMR6a
    SpritePlayerMR6x
    SpritePlayerR6y
    SpritePlayerR6i
    SpritePlayerR6a
    SpritePlayerR6x
    SpritePlayerL7y
    SpritePlayerL7i
    SpritePlayerL7a
    SpritePlayerL7x
    SpritePlayerML7y
    SpritePlayerML7i
    SpritePlayerML7a
    SpritePlayerML7x
    SpritePlayerM7y
    SpritePlayerM7i
    SpritePlayerM7a
    SpritePlayerM7x
    SpritePlayerMR7y
    SpritePlayerMR7i
    SpritePlayerMR7a
    SpritePlayerMR7x
    SpritePlayerR7y
    SpritePlayerR7i
    SpritePlayerR7a
    SpritePlayerR7x
    SpritePlayerL8y
    SpritePlayerL8i
    SpritePlayerL8a
    SpritePlayerL8x
    SpritePlayerML8y
    SpritePlayerML8i
    SpritePlayerML8a
    SpritePlayerML8x
    SpritePlayerM8y
    SpritePlayerM8i
    SpritePlayerM8a
    SpritePlayerM8x
    SpritePlayerMR8y
    SpritePlayerMR8i
    SpritePlayerMR8a
    SpritePlayerMR8x
    SpritePlayerR8y
    SpritePlayerR8i
    SpritePlayerR8a
    SpritePlayerR8x
    SpriteLogo0y
    SpriteLogo0i
    SpriteLogo0a
    SpriteLogo0x
    SpriteLogo1y
    SpriteLogo1i
    SpriteLogo1a
    SpriteLogo1x
    SpriteLogo2y
    SpriteLogo2i
    SpriteLogo2a
    SpriteLogo2x
    SpriteLogo3y
    SpriteLogo3i
    SpriteLogo3a
    SpriteLogo3x
    SpriteLogo4y
    SpriteLogo4i
    SpriteLogo4a
    SpriteLogo4x
    SpriteLogo5y
    SpriteLogo5i
    SpriteLogo5a
    SpriteLogo5x
    SpriteLogo6y
    SpriteLogo6i
    SpriteLogo6a
    SpriteLogo6x
    SpriteLogo7y
    SpriteLogo7i
    SpriteLogo7a
    SpriteLogo7x
    SpriteLogo8y
    SpriteLogo8i
    SpriteLogo8a
    SpriteLogo8x
    SpriteLastByte
.endenum

.enum GameStates
    GameInit = 0
    GameMenu
    GameStart
    GamePlaying
    GameFinish
    GameOver
.endenum

.enum
    StatusbarInit = 0
    StatusbarUpdate
    StatusbarCurrent
.endenum

.enum
    CHAR_0 = 1
    CHAR_1
    CHAR_2
    CHAR_3
    CHAR_4
    CHAR_5
    CHAR_6
    CHAR_7
    CHAR_8
    CHAR_9
    CHAR_A
    CHAR_B
    CHAR_C
    CHAR_D
    CHAR_E
    CHAR_F
    CHAR_G
    CHAR_H
    CHAR_I
    CHAR_J
    CHAR_K
    CHAR_L
    CHAR_M
    CHAR_N
    CHAR_O
    CHAR_P
    CHAR_Q
    CHAR_R
    CHAR_S
    CHAR_T
    CHAR_U
    CHAR_V
    CHAR_W
    CHAR_X
    CHAR_Y
    CHAR_Z
    CHAR_BAR0
    CHAR_BAR1
    CHAR_EMPTY
.endenum

.enum
    SPRITE_ZERO = 0
    SPRITE_NES
    SPRITE_IQ
    SPRITE_FAMICOM
    SPRITE_TERMINATOR
    SPRITE_SZNEQZ
    SPRITE_F
    SPRITE_A
    SPRITE_M
    SPRITE_I
    SPRITE_C
    SPRITE_O
    SPRITE_N
    SPRITE_1
    SPRITE_7
    SPRITE_EMPTY
.endenum

; Famicon:
;     .byte $10, $0B, $17, $13, $0D, $19, $18, $25, $02, $08

TextEdition:
    .byte CHAR_E, CHAR_D, CHAR_I, CHAR_T, CHAR_I, CHAR_O, CHAR_N

TextStomp:
    .byte CHAR_S, CHAR_T, CHAR_O, CHAR_M, CHAR_P, CHAR_EMPTY

TextSize:
    .byte CHAR_EMPTY, CHAR_S, CHAR_I, CHAR_Z, CHAR_E, CHAR_EMPTY

; KonamiCode:
;     .byte $08, $08, $04, $04, $02, $01, $02, $01, $40, $80

PlayerSpritesSize0:  ; from lowest to highest
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_SZNEQZ, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY

PlayerSpritesSize1:  ; from lowest to highest
    .byte SPRITE_EMPTY, SPRITE_EMPTY, $20, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, SPRITE_EMPTY, $10, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY

PlayerSpritesSize2:  ; from lowest to highest
    .byte SPRITE_EMPTY, $31, $32, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, $21, $22, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, $11, $12, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY

PlayerSpritesSize3:  ; from lowest to highest
    .byte SPRITE_EMPTY, $43, $44, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, $33, $34, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, $23, $24, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, $13, $14, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY

PlayerSpritesSize4:  ; from lowest to highest
    .byte SPRITE_EMPTY, $55, $56, $57, SPRITE_EMPTY
    .byte SPRITE_EMPTY, $45, $46, $47, SPRITE_EMPTY
    .byte SPRITE_EMPTY, $35, $36, $37, SPRITE_EMPTY
    .byte SPRITE_EMPTY, $25, $26, $27, SPRITE_EMPTY
    .byte SPRITE_EMPTY, $15, $16, $17, SPRITE_EMPTY
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY

PlayerSpritesSize5:  ; from lowest to highest
    .byte SPRITE_EMPTY, $78, $79, $7A, $7B
    .byte SPRITE_EMPTY, $68, $69, $6A, $6B
    .byte SPRITE_EMPTY, $58, $59, $5A, $5B
    .byte SPRITE_EMPTY, $48, $49, $4A, $4B
    .byte SPRITE_EMPTY, $38, $39, $3A, $3B
    .byte SPRITE_EMPTY, $28, $29, $2A, $2B
    .byte SPRITE_EMPTY, $18, $19, $1A, $1B
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY
    .byte SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY, SPRITE_EMPTY

PlayerSpritesSize6:  ; from lowest to highest
    .byte $D0, $D1, $D2, $D3, $D4
    .byte $C0, $C1, $C2, $C3, $C4
    .byte $B0, $B1, $B2, $B3, $B4
    .byte $A0, $A1, $A2, $A3, $A4
    .byte $90, $91, $92, $93, $94
    .byte $80, $81, $82, $83, $84
    .byte $70, $71, $72, $73, $74
    .byte $60, $61, $62, $63, $64
    .byte $50, $51, $52, $53, $54

Sinusoid:
    .byte 215, 216, 218, 219, 220, 221, 221, 222, 222, 222, 221, 221, 220, 219, 218, 216
    .byte 215, 214, 212, 211, 210, 209, 209, 208, 208, 208, 209, 209, 210, 211, 212, 214
    .byte 215, 216, 218, 219, 220, 221, 221, 222, 222, 222, 221, 221, 220, 219, 218, 216
    .byte 215, 214, 212, 211, 210, 209, 209, 208, 208, 208, 209, 209, 210, 211, 212, 214

; Triangular:
;     .byte 217, 218, 219, 220, 221, 222, 223, 224, 223, 222, 221, 220, 219, 218, 217, 216
;     .byte 215, 214, 213, 212, 211, 210, 209, 208, 209, 210, 211, 212, 213, 214, 215, 216
;     .byte 217, 218, 219, 220, 221, 222, 223, 224, 223, 222, 221, 220, 219, 218, 217, 216
;     .byte 215, 214, 213, 212, 211, 210, 209, 208, 209, 210, 211, 212, 213, 214, 215, 216
