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

    playerX: .res 1
    playerY: .res 1
    playerMaxYleft: .res 1
    playerMaxY: .res 1
    playerMaxYright: .res 1
    playerObjectCollision: .res 1
    playerVelocityY: .res 1 ; used vor gravity calculation
    playerTempVelocityY: .res 1 ; used for player position
    playerVelocityX: .res 1
    playerTempVelocityX: .res 1

    currentCenter: .res 1
    currentMapColumn: .res 1

    currentRenderColumn: .res 1
    tempRenderColumn: .res 1
    currentRenderRow: .res 1
    currentRenderNametableAddress: .res 1
    tempRenderNametableAddress: .res 1

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
    temp3b: .res 1
    temp4: .res 1
    temp4a: .res 1

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
    bit PPUSTATUS ; clear w register by reading Status
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
        cpx #64
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
    lda #InitialCenter
    sta currentCenter
    asl
    sta currentMapColumn

main_loop:
    lda nmiflag
    beq main_loop   ; wait for nmi_flag

    jsr readjoyx2   ; read two gamepads

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
    jsr PrepareColors

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

vblankLoop:
    bit PPUSTATUS  ; check for sprite 0 clear
    bvs vblankLoop ; loop if still set (still in previous vBlank)

sprite0loop:
    bit PPUSTATUS   ; check for sprite 0 set
    bmi skipSpriteCheck
    bvc sprite0loop ; loop if still clear

    lda #0
    sta PPUSCROLL
    lda #%10000000
    sta PPUCTRL
    bit PPUSTATUS

skipSpriteCheck:
    lda #0
    sta nmiflag
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

; Character memory
.segment "CHARS"
    .incbin "macro.chr", 0, 8192
