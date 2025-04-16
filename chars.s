; Character memory
.segment "CHARS"
    ; background (00)
    .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; Low bytes of characters
    .byte $00, $00, $00, $00, $00, $00, $00, $00 ; High bytes of characters

    .byte %00011000	; A (01)
    .byte %00111100
    .byte %01100110
    .byte %11000011
    .byte %11111111
    .byte %11111111
    .byte %11000011
    .byte %11000011
    .byte $00, $00, $00, $00, $00, $00, $00, $00 ; High bytes of characters

    .byte %11000011	; H (02)
    .byte %11000011
    .byte %11000011
    .byte %11111111
    .byte %11111111
    .byte %11000011
    .byte %11000011
    .byte %11000011
    .byte $00, $00, $00, $00, $00, $00, $00, $00 ; High bytes of characters

    .byte %11111111	; E (03)
    .byte %11111111
    .byte %11000000
    .byte %11111100
    .byte %11111100
    .byte %11000000
    .byte %11111111
    .byte %11111111
    .byte $00, $00, $00, $00, $00, $00, $00, $00

    .byte %11000000	; L (04)
    .byte %11000000
    .byte %11000000
    .byte %11000000
    .byte %11000000
    .byte %11000000
    .byte %11111111
    .byte %11111111
    .byte $00, $00, $00, $00, $00, $00, $00, $00

    .byte %01111110	; O (05)
    .byte %11100111
    .byte %11000011
    .byte %11000011
    .byte %11000011
    .byte %11000011
    .byte %11100111
    .byte %01111110
    .byte $00, $00, $00, $00, $00, $00, $00, $00

    .byte %00000001
    .byte %00000010
    .byte %00011100
    .byte %00101100
    .byte %00110100
    .byte %00111000
    .byte %01000000
    .byte %10000000

    .byte %10000000
    .byte %01000000
    .byte %00111000
    .byte %00110100
    .byte %00101100
    .byte %00011100
    .byte %00000010
    .byte %00000001 
