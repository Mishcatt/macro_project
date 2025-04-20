.include "registers.s"
.include "const.s"

.zeropage
    buttons:    .res 2

    currentState: .res 1
    tempAddr: .res 2
    stateTemp1: .res 1

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

    currentDrawingColumn: .res 1

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

load_initial_sprites:
    ldx #$00
    @loop:
        lda sprites, x
        sta OAM, x         ; Load the sprites into OAM
        inx
        cpx #$1c
        bne @loop
    ; inc dmaflag

set_scroll:
    lda #$00
    sta xscroll
    sta yscroll
    ; inc ppuflag

enable_rendering:
    lda #%10000100	; Enable NMI and vertical increment
    sta PPUCTRL
    sta softPPUCTRL
    lda #%00011010	; Enable Sprites and Background
    sta PPUMASK
    sta softPPUMASK
    ; inc drawflag

initial_variables:
    lda #InitialState
    sta currentState

main_loop:
    lda nmiflag
    beq main_loop   ; wait for nmi_flag
    dec nmiflag

    jsr readjoyx2   ; read two gamepads

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

    stateMachine:
        lda currentState
        asl ; x2 
        tax
        lda JumpTable, x        ; Low byte
        sta tempAddr
        lda JumpTable+1, x      ; High byte
        sta tempAddr+1
        jmp (tempAddr)          ; Jump to the handler
    stateMachineEnd:

    jsr PrepareDrawing
    ; jsr PrepareDrawingTest

    ; lda currentRenderColumn
    lda currentDrawingColumn
    ; clc
    ; adc #1                      ; add 1
    and #%1111                  ; wrap around 0-15
    sta currentRenderColumn     ; save
    ; sta currentDrawingColumn
    and #%1000                  ; check nametable
    lsr a                       ; 8 >> 1 = 4
    clc
    adc #$20                     ; nametable0 = $20, nametable1 = $24
    sta currentRenderNametableAddress

    inc ppuflag
    inc drawflag
    inc dmaflag
    jmp main_loop

.include "statemachine.s"
.include "joypad.s"
.include "drawing.s"

MusicEngine:
    rts

.include "nmi.s"
.include "maps.s"
.include "sprites.s"
.include "palettes.s"
.include "chars.s"
