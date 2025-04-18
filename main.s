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
currentRenderRow: .res 1
tempColumnAddress: .res 1
tempColorAddress: .res 1

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
    lda PPUSTATUS   ; clear w register by reading Status
    lda #$20        ; nametable 0, TODO: nametable 1
    sta PPUADDR
    lda currentMapColumn 
    tax             ; copy map column number to X
    asl a           ; map columns are 16px, PPU columns are 8px, so x2
    sta PPUADDR

    lda map, x      ; load column type number to A
    asl a
    asl a
    asl a
    asl a           ; x16 (column size)
    sta tempColumnAddress
    ldy #0

    @loop1:
        ldx tempColumnAddress   ; load rendering column offset to X
        inc tempColumnAddress   ; increment the offset
        lda columns, x  ; load block type number to A
        asl a 
        asl a           ; x4 (block size)
        tax             ; copy char type address to X
        lda blocks, x   ; load char number to A
        sta PPUDATA
        inx
        lda blocks, x   ; load char number to A
        sta PPUDATA
        iny
        cpy #15         ; last row
        bcc @loop1

    lda #$20        ; nametable 0, TODO: nametable 1
    sta PPUADDR
    lda currentMapColumn 
    tax             ; copy map column number to X
    asl a           ; map columns are 16px, PPU columns are 8px, so x2
    ora #1          ; add 1 for second column
    sta PPUADDR

    lda map, x      ; load column type number to A
    asl a
    asl a
    asl a
    asl a           ; x16 (column size)
    sta tempColumnAddress
    ldy #0

    @loop2:
        ldx tempColumnAddress   ; load rendering column offset to X
        inc tempColumnAddress   ; increment the offset
        lda columns, x  ; load block type number to A
        asl a 
        asl a           ; x4 (block size)
        tax             ; copy char type address to X
        lda blocks, x   ; load char number to A
        sta PPUDATA
        inx
        lda blocks, x   ; load char number to A
        sta PPUDATA
        iny
        cpy #15         ; last row
        bcc @loop2

    lda #%10000000  ; Enable NMI and horizontal increment
    sta PPUCTRL

    lda currentMapColumn
    and #1
    bne skipColorRender
        lda map, x      ; load column type number to A
        asl a
        asl a
        asl a
        asl a           ; x16 (column size)
        sta tempColumnAddress
        ldy #0

        @loop3:
            lda #$23
            sta PPUADDR
            lda currentMapColumn
            sta tempColorAddress
            lsr tempColorAddress
            tya
            asl a
            asl a
            asl a
            adc #$C0
            adc tempColorAddress
            sta PPUADDR
            ldx tempColumnAddress
            inc tempColumnAddress
            inc tempColumnAddress
            lda columns, x      ; load block type number to A
            tax
            lda blockColors, x  ; load block color number to X
            ; lda #1
            sta PPUDATA
            iny
            cpy #5         ; last row (should be 7, too many cycles)
            bcc @loop3
    skipColorRender:

    ldx currentMapColumn
    inx         ; next column
    cpx #$10    ; over last column?
    bcc :+
        ldx #0  ; back to column 0
    :
    stx currentMapColumn

    rts

MusicEngine:
    rts

.include "nmi.s"
.include "maps.s"
.include "sprites.s"
.include "palettes.s"
.include "chars.s"
