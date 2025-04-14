.include "registers.s"

DRAWBUFFER := $0100  ; Beginning of Drawing Buffer
OAM        := $0200  ; Beginning of OAM Shadow buffer

sprite0y = 0
sprite0x = 3
sprite1y = 4
sprite1x = 7
sprite2y = 8
sprite2x = 11
sprite3y = 12
sprite3x = 15
sprite4y = 16
sprite4x = 19
sprite5y = 20
sprite5x = 23
sprite6y = 24
sprite6x = 27

buttons1 = buttons
buttons2 = buttons + 1

.zeropage
buttons:    .res 2

softPPUCTRL:   .res 1
softPPUMASK:   .res 1

dmaflag:    .res 1
drawflag:   .res 1
ppuflag:    .res 1
nmi_flag:   .res 1

xscroll:    .res 1
yscroll:    .res 1

currentRenderColumn: .res 1
currentRenderRow:    .res 1

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

main:
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
    lda nmi_flag
    beq main_loop   ; wait for nmi_flag
    dec nmi_flag

    jsr readjoyx2   ; read two gamepads

    ; inc xscroll
    ; inc yscroll

    ldx #sprite2y
    inc OAM, x
    ldx #sprite2x
    inc OAM, x
    ldx #sprite3y
    dec OAM, x
    ldx #sprite3x
    dec OAM, x
    ldx #sprite4y
    inc OAM, x
    ldx #sprite4x
    dec OAM, x
    ldx #sprite5y
    dec OAM, x
    ldx #sprite5x
    inc OAM, x

    ldx #sprite6y
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

    ldx #sprite6x
    lda buttons1
    and #BUTTON_LEFT
    beq :+
        dec OAM, x
    :
    lda buttons1
    and #BUTTON_RIGHT
    beq :+
        inc OAM, x
    :

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
    lda PPUSTATUS ; clear w register by reading Status
    lda #$20      ; nametable 0
    sta PPUADDR
    ldx currentRenderColumn
    stx PPUADDR

    inx         ; next column
    cpx #$20    ; over last column?
    bcc :+
        ldx #0  ; back to column 0
    :
    stx currentRenderColumn

    ldx #$00
    lda #0
    sta PPUDATA
    lda #5
    sta PPUDATA
    lda #0
    sta PPUDATA
    lda #6
    sta PPUDATA
    lda #0
    sta PPUDATA
    lda #5
    sta PPUDATA
    rts

MusicEngine:
    rts

;--------------------------------------
; NMI - the NMI handler
nmi:
    pha         ; back up registers (important)
    txa
    pha
    tya
    pha

    @check_dma_flag:
        lda dmaflag
        beq @check_draw_flag
            lda #0      ; do sprite DMA
            sta OAMADDR   ; conditional via the 'dmaflag' flag
            lda #>OAM
            sta OAMDMA
            dec dmaflag

    @check_draw_flag:
        lda drawflag          ; do other PPU drawing (NT/Palette/whathaveyou)
        beq @check_ppu_flag ; conditional via the 'drawflag' flag
            bit PPUSTATUS         ; clear VBl flag, reset PPUSCROLL/PPUADDR toggle
            jsr DoDrawing     ; draw the stuff from the drawing buffer
            dec drawflag

    @check_ppu_flag:
        lda ppuflag
        beq @music_handler
            lda softPPUMASK   ; copy buffered PPUCTRL/PPUMASK (conditional via ppuflag)
            sta PPUMASK
            lda softPPUCTRL
            sta PPUCTRL
            bit PPUSTATUS
            lda xscroll    ; set X/Y scroll (conditional via ppuflag)
            sta PPUSCROLL
            lda yscroll
            sta PPUSCROLL
            dec ppuflag

    @music_handler:
        jsr MusicEngine

    lda #1         
    sta nmi_flag   ; set the nmi_flag flag so that main_loop will continue

    pla            ; restore regs and exit
    tay
    pla
    tax
    pla
    rti

sprites:
    .byte $00, $00, $00, $00 	; Why do I need these here?
    .byte $00, $00, $00, $00    ; Ypos, Index, Attributes, Xpos
    .byte $60, $02, $00, $60
    .byte $64, $03, $00, $70
    .byte $68, $04, $00, $80
    .byte $6C, $05, $00, $90
    .byte $70, $06, $00, $A0

palettes:
    ; Background Palette
    .byte $0f, $00, $00, $00
    .byte $0f, $00, $00, $00
    .byte $0f, $00, $00, $00
    .byte $0f, $00, $00, $00

    ; Sprite Palette
    .byte $0f, $20, $00, $00
    .byte $0f, $00, $00, $00
    .byte $0f, $00, $00, $00
    .byte $0f, $00, $00, $00

; Character memory
.segment "CHARS"
    ; (00)
    .byte $00, $00, $00, $00, $00, $00, $00, $00 ; Low bytes of characters
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

    .byte %11011011	; W (06)
    .byte %11011011
    .byte %11011011
    .byte %11011011
    .byte %11011011
    .byte %11011011
    .byte %01100110
    .byte %01100110
    .byte $00, $00, $00, $00, $00, $00, $00, $00
