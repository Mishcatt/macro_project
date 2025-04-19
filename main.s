.include "registers.s"
.include "const.s"

.zeropage
buttons:    .res 2

currentState: .res 1

softPPUCTRL:   .res 1
softPPUMASK:   .res 1

dmaflag:    .res 1
drawflag:   .res 1
ppuflag:    .res 1
nmiflag:   .res 1

xscroll:    .res 1
yscroll:    .res 1

currentCenter: .res 1
currentMapColumn: .res 1

currentRenderColumn: .res 1
currentRenderRow: .res 1
currentRenderNametableAddress: .res 1
tempRenderColumn: .res 1

tempColumnAddress: .res 1
tempColorAddress: .res 1
tempMapAddress: .res 1
tempDrawAddressOffset: .res 1

drawingLoop1: .res 1
drawingLoop2: .res 1

temp1: .res 1
temp2: .res 1
temp2a: .res 1
temp3: .res 1
temp3a: .res 1
temp4: .res 1

;leftRenderColumn: .res 30
;rightRenderColumn: .res 30

.segment "HEADER"
  ; .byte "NES", $1A      ; iNES header identifier
  .byte $4E, $45, $53, $1A
  .byte 2               ; 2x 16KB PRG code
  .byte 1               ; 1x  8KB CHR data
  .byte $01, $00        ; mapper 0, vertical mirroring

.segment "VECTORS"
  ;; When an NMI happens (once per frame if enabled) the label nmi:
  .addr nmi
  ;; When the processor first turns on or is reset, it will jump to the label reset:
  .addr reset
  ;; External interrupt IRQ (unused)
  .addr 0

; "nes" linker config requires a STARTUP section, even if it's empty
.segment "STARTUP"

; Main code segment for the program
.segment "CODE"

reset:
    sei		; disable IRQs
    cld		; disable decimal mode
    ldx #$40
    stx $4017	; disable APU frame IRQ
    ldx #$ff 	; Set up stack
    txs		;  .
    inx		; now X = 0
    stx PPUCTRL	; disable NMI
    stx PPUMASK 	; disable rendering
    stx $4010 	; disable DMC IRQs

;; first wait for vblank to make sure PPU is ready
vblankwait1:
    bit PPUSTATUS
    bpl vblankwait1

clear_memory:
    lda #$00
    sta $0000, x
    sta $0100, x
    sta $0200, x
    sta $0300, x
    sta $0400, x
    sta $0500, x
    sta $0600, x
    sta $0700, x
    inx
    bne clear_memory

;; second wait for vblank, PPU is ready after this
vblankwait2:
    bit PPUSTATUS
    bpl vblankwait2

load_palettes:
    lda PPUSTATUS ; clear w register by reading Status
    lda #$3f
    sta PPUADDR
    lda #$00
    sta PPUADDR

    ldx #$00
    @loop:
        lda palettes, x
        sta PPUDATA
        inx
        cpx #$20
        bne @loop

enable_rendering:
    lda #%10000100	; Enable NMI and vertical increment
    sta PPUCTRL
    sta softPPUCTRL
    lda #%00011010	; Enable Sprites and Background
    sta PPUMASK
    sta softPPUMASK
    ; inc drawflag

set_scroll:
    lda #$00
    sta xscroll
    sta yscroll
    ; inc ppuflag

load_initial_sprites:
    ldx #$00
    @loop:
        lda sprites, x
        sta OAM, x         ; Load the sprites into OAM
        inx
        cpx #$1c
        bne @loop
    ; inc dmaflag

main_loop:
    lda nmiflag
    beq main_loop   ; wait for nmi_flag
    dec nmiflag

    jsr readjoyx2   ; read two gamepads

    ; inc xscroll
    ; inc yscroll

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

    ldx #Sprites::Sprite6y
    lda buttons1
    and #BUTTON_UP
    beq :+
        dec OAM, x
    :
    lda buttons1
    and #BUTTON_DOWN
    beq :+
        inc OAM, x
    :

    ; ldx #Sprites::Sprite6x
    lda buttons1
    and #BUTTON_LEFT
    beq noLeftButton
        dec xscroll
        lda xscroll
        cmp #$FF
        bne :+
            lda softPPUCTRL
            eor #%00000001 ; swap nametable 0 and 1
            sta softPPUCTRL
        :
        lda xscroll
        and #%11110000
        bne :+
            dec currentCenter
        :
noLeftButton:
    lda buttons1
    and #BUTTON_RIGHT
    beq noRightButton
        inc xscroll
        bne :+
            lda softPPUCTRL
            eor #%00000001 ; swap nametable 0 and 1
            sta softPPUCTRL
        :
        lda xscroll
        and #%11110000
        bne :+
            inc currentCenter
        :
noRightButton:

    jsr PrepareDrawing
    ; jsr PrepareDrawingTest

    lda currentRenderColumn
    clc
    adc #1                      ; add 1
    and #%1111                  ; wrap around 0-15
    sta currentRenderColumn     ; save
    and #%1000                  ; check nametable
    lsr a                       ; 8 >> 1 = 4
    clc
    adc #$20                     ; nametable0 = $20, nametable1 = $24
    sta currentRenderNametableAddress

    inc ppuflag
    inc drawflag
    inc dmaflag
    jmp main_loop

readjoyx2:
    ldx #$00
    jsr readjoyx    ; X=0: read controller 1
    inx
    ; fall through to readjoyx below, X=1: read controller 2

readjoyx:           ; X register = 0 for controller 1, 1 for controller 2
    lda #$01
    sta JOYPAD1
    sta buttons, x
    lsr a
    sta JOYPAD1
@loop:
    lda JOYPAD1, x
    and #%00000011  ; ignore bits other than controller
    cmp #$01        ; Set carry if and only if nonzero
    rol buttons, x  ; Carry -> bit 0; but 7 -> Carry
    bcc @loop
    rts

DoDrawing:
    lda #%10000100  ; Enable NMI and vertical increment
    sta PPUCTRL
    bit PPUSTATUS   ; clear w register by reading Status
    ;lda #$20        ; nametable 0, TODO: nametable 1
    ;sta PPUADDR
    ;lda currentRenderColumn 
    ;sta tempMapAddress

    ;lda #30
    ;sta drawingLoop1
    ;lda #4
    ;sta drawingLoop2

    lda currentRenderColumn ; 32 pixel column
    and #%111               ; 8 columns per nametable
    asl 
    asl 
    sta tempRenderColumn ; 8 pixel column

    ldx #0 ; start at offset 0
    ldy #0
    draw1:
        lda currentRenderNametableAddress
        sta PPUADDR
        tya
        clc
        adc tempRenderColumn
        sta PPUADDR
        lda DRAWBUFFER + 0, x   ; 5 cycles
        sta PPUDATA             ; 4 cycles
        lda DRAWBUFFER + 1, x
        sta PPUDATA
        lda DRAWBUFFER + 2, x
        sta PPUDATA
        lda DRAWBUFFER + 3, x
        sta PPUDATA
        lda DRAWBUFFER + 4, x
        sta PPUDATA
        lda DRAWBUFFER + 5, x
        sta PPUDATA
        lda DRAWBUFFER + 6, x
        sta PPUDATA
        lda DRAWBUFFER + 7, x
        sta PPUDATA
        lda DRAWBUFFER + 8, x
        sta PPUDATA
        lda DRAWBUFFER + 9, x
        sta PPUDATA
        lda DRAWBUFFER + 10, x
        sta PPUDATA
        lda DRAWBUFFER + 11, x
        sta PPUDATA
        lda DRAWBUFFER + 12, x
        sta PPUDATA
        lda DRAWBUFFER + 13, x
        sta PPUDATA
        lda DRAWBUFFER + 14, x
        sta PPUDATA
        lda DRAWBUFFER + 15, x
        sta PPUDATA
        lda DRAWBUFFER + 16, x
        sta PPUDATA
        lda DRAWBUFFER + 17, x
        sta PPUDATA
        lda DRAWBUFFER + 18, x
        sta PPUDATA
        lda DRAWBUFFER + 19, x
        sta PPUDATA
        lda DRAWBUFFER + 20, x
        sta PPUDATA
        lda DRAWBUFFER + 21, x
        sta PPUDATA
        lda DRAWBUFFER + 22, x
        sta PPUDATA
        lda DRAWBUFFER + 23, x
        sta PPUDATA
        lda DRAWBUFFER + 24, x
        sta PPUDATA
        lda DRAWBUFFER + 25, x
        sta PPUDATA
        lda DRAWBUFFER + 26, x
        sta PPUDATA
        lda DRAWBUFFER + 27, x
        sta PPUDATA
        lda DRAWBUFFER + 28, x
        sta PPUDATA
        lda DRAWBUFFER + 29, x
        sta PPUDATA
        txa
        adc #30 ; add offset 30 to DRAWBUFFER
        tax
        iny
        cpy #4
        beq draw1end
        jmp draw1
    draw1end:

    ; lda currentRenderColumn
    ; clc
    ; adc #4
    ; cmp #32     ; over last column?
    ; bcc :+
    ;     lda #0  ; back to column 0
    ; :
    ; sta currentRenderColumn

    rts

PrepareDrawingTest:
    ldy #0
    @loop2:
        lda #1   ; load char number to A
        sta DRAWBUFFER, y
        iny
        cpy #120         ; last row
        bcc @loop2
    rts

PrepareDrawing:
    ldy #0
    sty temp2a
    lda currentRenderColumn
    asl
    sta temp2

    @drawing3:
        lda temp2
        ora temp2a ; add map offset
        tax
        ;inc temp2a ; 0 1
        lda map, x
        asl
        asl
        asl
        asl
        sta temp3
        lda #0
        sta temp3a

        @drawing2A:
            lda temp3
            clc
            adc temp3a ; add column offset
            tax
            inc temp3a ; 0 ... 14
            lda columns, x
            asl
            asl ; x4
            sta temp4

            @drawing1A:
                ldx temp4  ; 0 1
                lda blocks, x
                sta DRAWBUFFER, y
                iny
                inx
                lda blocks, x
                sta DRAWBUFFER, y
                iny

            lda temp3a
            cmp #15
            bcc @drawing2A

        lda temp2
        ora temp2a ; add map offset
        tax
        inc temp2a ; 0 1
        lda map, x
        asl
        asl
        asl
        asl
        sta temp3
        lda #0
        sta temp3a

        @drawing2B:
            lda temp3
            clc
            adc temp3a ; add column offset
            tax
            inc temp3a ; 0 ... 14
            lda columns, x
            asl
            asl ; x4
            sta temp4

            @drawing1B:
                ldx temp4   ; 2 3
                inx         ;
                inx         ;
                lda blocks, x
                sta DRAWBUFFER, y
                iny
                inx
                lda blocks, x
                sta DRAWBUFFER, y
                iny
            
            lda temp3a
            cmp #15
            bcc @drawing2B
        
        lda temp2a
        cmp #2
        bcc @drawing3
    rts

MusicEngine:
    rts

.include "nmi.s"
.include "maps.s"
.include "sprites.s"
.include "palettes.s"
.include "chars.s"
