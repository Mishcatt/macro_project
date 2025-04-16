map: ; 16 columns = 1 screen
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; suburb

columns: ; 15 blocks = 1 column, 1 byte padding
    .byte $00, $01, $02, $03, $00, $01, $02, $03, $00, $01, $02, $03, $00, $01, $02, $ff ; house

blocks: ; 4 chars (8x8) = 1 block (16x16)
    .byte $00, $00, $00, $00 ; sky
    .byte $01, $01, $01, $01 ; grass
    .byte $02, $02, $02, $02 ; water
    .byte $03, $03, $03, $03 ; city

blockColors: ; 1 pallete index per block
    .byte $00
    .byte $55
    .byte $AA
    .byte $FF
