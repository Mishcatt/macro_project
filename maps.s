map: ; 16 columns = 1 screen
    .byte $01, $01, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00 ; field
    .byte $01, $01, $01, $00, $01, $01, $01, $01, $01, $00, $01, $01, $01, $01, $00, $00 ; rural
    .byte $02, $03, $00, $00, $02, $03, $00, $00, $02, $03, $00, $00, $02, $03, $00, $00 ; farm
    .byte $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03 ; silo
    .byte $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04 ; highway
    .byte $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05 ; magazine
    .byte $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06 ; suburb
    .byte $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07 ; city
    .byte $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08 ; highrise
    .byte $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09 ; city
    .byte $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a ; suburb
    .byte $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b ; magazine
    .byte $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c ; highway
    .byte $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d ; silo
    .byte $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e ; farm
    .byte $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f ; rural

columns: ; 14 blocks = 1 column, 1 byte special, 1 byte ground level
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $0f, $00, 167 ; field
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $01, $0f, $00, 151 ; rural
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $10, $12, $01, $0f, $01, 167 ; maluch_1
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $11, $13, $01, $0f, $02, 167 ; maluch_2
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $14, $16, $01, $0f, $01, 167 ; maluch_1_low
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $15, $17, $01, $0f, $02, 167 ; maluch_2_low
    .byte $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $0f, $00, 167 ; house
    .byte $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $0f, $00, 167 ; house
    .byte $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $0f, $00, 167 ; house
    .byte $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $0f, $00, 167 ; house
    .byte $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0f, $00, 167 ; house
    .byte $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0f, $00, 167 ; house
    .byte $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0f, $00, 167 ; house
    .byte $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0f, $00, 167 ; house
    .byte $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0f, $00, 167 ; house
    .byte $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $00, 167 ; house

blocks: ; 4 chars (8x8) = 1 block (16x16) [LU 1, LD 3, RU 2, RD 4]
    .byte $31, $31, $31, $31 ; $00 sky
    .byte $31, $31, $31, $31 ; $01 grass
    .byte $02, $02, $02, $02 ; water
    .byte $03, $03, $03, $03 ; city
    .byte $04, $04, $04, $04 ; sky
    .byte $05, $05, $05, $05 ; grass
    .byte $06, $06, $06, $06 ; water
    .byte $07, $07, $07, $07 ; city
    .byte $08, $08, $08, $08 ; sky
    .byte $09, $09, $09, $09 ; grass
    .byte $0a, $0a, $0a, $0a ; water
    .byte $0b, $0b, $0b, $0b ; city
    .byte $0c, $0c, $0c, $0c ; sky
    .byte $0d, $0d, $0d, $0d ; grass
    .byte $0e, $0e, $0e, $0e ; water
    .byte $30, $2f, $30, $2f ; $0f frame
    .byte $70, $80, $71, $81 ; $10 maluch_A
    .byte $72, $82, $73, $83 ; $11 maluch_B
    .byte $90, $73, $91, $73 ; $12 maluch_C
    .byte $92, $73, $93, $73 ; $13 maluch_D
    .byte $74, $84, $75, $85 ; $14 maluch_A_LOW
    .byte $76, $86, $77, $87 ; $15 maluch_B_LOW
    .byte $94, $73, $95, $73 ; $16 maluch_C_LOW
    .byte $96, $73, $97, $73 ; $17 maluch_D_LOW

blockColors: ; 1 pallete index per macroblock (32x32), 4 palettes max
    .byte $01 ; $00 sky
    .byte $02 ; $01 grass
    .byte $02
    .byte $03
    .byte $00
    .byte $01
    .byte $02
    .byte $03
    .byte $00
    .byte $01
    .byte $02
    .byte $03
    .byte $00
    .byte $01
    .byte $02
    .byte $03
    .byte $01 ; $10 maluch_A
    .byte $01 ; $11 maluch_B
    .byte $02 ; $12 maluch_C
    .byte $02 ; $13 maluch_D
    .byte $01 ; $14 maluch_A_LOW
    .byte $01 ; $15 maluch_B_LOW
    .byte $02 ; $16 maluch_C_LOW
    .byte $02 ; $17 maluch_D_LOW

maluch1HeightMapAbs:
    .byte 167, 164, 163, 162, 161, 160, 159, 158
    .byte 158, 158, 158, 158, 158, 158, 158, 158
maluch2HeightMapAbs:
    .byte 158, 158, 158, 159, 160, 161, 162, 163
    .byte 163, 163, 163, 163, 163, 163, 164, 167

specialHeightMap:
maluch1HeightMapDiff: ; $01
    .byte 0, 3, 4, 5, 6, 7, 8, 9
    .byte 9, 9, 9, 9, 9, 9, 9, 9
maluch2HeightMapDiff: ; $02
    .byte 9, 9, 9, 8, 7, 6, 5, 4
    .byte 4, 4, 4, 4, 4, 4, 3, 0