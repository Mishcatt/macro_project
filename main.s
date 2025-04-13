

PPUCTRL   := $2000 	; VPHB SINN 	W 	NMI enable (V), PPU master/slave (P), sprite height (H), background tile select (B), sprite tile select (S), increment mode (I), nametable select / X and Y scroll bit 8 (NN)
PPUMASK   := $2001 	; BGRs bMmG 	W 	color emphasis (BGR), sprite enable (s), background enable (b), sprite left column enable (M), background left column enable (m), greyscale (G)
PPUSTATUS := $2002 	; VSO- ---- 	R 	vblank (V), sprite 0 hit (S), sprite overflow (O); read resets write pair for $2005/$2006
OAMADDR   := $2003 	; AAAA AAAA 	W 	OAM read/write address
OAMDATA   := $2004 	; DDDD DDDD 	RW 	OAM data read/write
PPUSCROLL := $2005 	; XXXX XXXX YYYY YYYY 	Wx2 	X and Y scroll bits 7-0 (two writes: X scroll, then Y scroll)
PPUADDR   := $2006 	; ..AA AAAA AAAA AAAA 	Wx2 	VRAM address (two writes: most significant byte, then least significant byte)
PPUDATA   := $2007 	; DDDD DDDD 	RW 	VRAM data read/write 

OAMDMA    := $4014 	; AAAA AAAA 	W 	OAM DMA high address: Copy 256 bytes from $xx00-$xxFF into OAM via OAMDATA ($2004)

SQ1_VOL   := $4000 	; DDLC VVVV 	W   Duty (D), envelope loop / length counter halt (L), constant volume (C), volume/envelope (V) Pulse 1
SQ1_SWEEP := $4001 	; EPPP NSSS 	W   Sweep unit: enabled (E), period (P), negate (N), shift (S) 
SQ1_LO    := $4002 	; TTTT TTTT 	W   Timer low (T) 
SQ1_HI    := $4003 	; LLLL LTTT 	W   Length counter load (L), timer high (T) 

SQ2_VOL   := $4004 	; DDLC VVVV 	W   Duty (D), envelope loop / length counter halt (L), constant volume (C), volume/envelope (V) Pulse 2
SQ2_SWEEP := $4005 	; EPPP NSSS 	W   Sweep unit: enabled (E), period (P), negate (N), shift (S) 
SQ2_LO    := $4006 	; TTTT TTTT 	W   Timer low (T) 
SQ2_HI    := $4007 	; LLLL LTTT 	W   Length counter load (L), timer high (T) 

TRI_LINEAR :=$4008  ; CRRR RRRR 	W   Length counter halt / linear counter control (C), linear counter load (R) Triangle
TRI_LO    := $400A 	; TTTT TTTT 	W   Timer low (T) 
TRI_HI    := $400B 	; LLLL LTTT 	W   Length counter load (L), timer high (T), set linear counter reload flag 

NOISE_VOL := $400C 	; --LC VVVV 	W   Envelope loop / length counter halt (L), constant volume (C), volume/envelope (V) Noise
NOISE_LO  := $400E 	; L--- PPPP 	W   Loop noise (L), noise period (P) 
NOISE_HI  := $400F 	; LLLL L--- 	W   Length counter load (L) 

DMC_FREQ  := $4010 	; IL-- RRRR 	W   IRQ enable (I), loop (L), frequency (R) DMC
DMC_RAW   := $4011 	; -DDD DDDD 	W   Load counter (D) 7-bit DAC
DMC_START := $4012 	; AAAA AAAA 	W   Sample address (A) Start address = $C000 + $40*$xx
DMC_LEN   := $4013 	; LLLL LLLL 	W   Sample length (L) = $10*$xx + 1 bytes (128*$xx + 8 samples)

SND_CHN   := $4015 	; ---D NT21 	W   Enable DMC (D), noise (N), triangle (T), and pulse channels (2/1)
                    ; IF-D NT21 	R   DMC interrupt (I), frame interrupt (F), DMC active (D), length counter > 0 (N/T/2/1) 

JOY1      := $4016 	; ---- -EES     W   Controller port latch bit (S), Expansion port latch bits (E)
                    ; ---D DDDD     R   Input data lines D4 D3 D2 D1 D0

JOY2      := $4017 	; MI-- ---- 	W   Frame Counter Mode (M, 0 = 4-step, 1 = 5-step), IRQ inhibit flag (I)
                    ; ---D DDDD     R   Input data lines D4 D3 D2 D1 D0
                    ;                   D0 	NES standard controller, Famicom hardwired controller
                    ;                   D1 	Famicom expansion port controller
                    ;                   D2 	Famicom microphone (controller 2 only)
                    ;                   D3 	Zapper light sense
                    ;                   D4 	Zapper trigger 

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
  lda PPUSTATUS
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
  lda #%10000000	; Enable NMI
  sta PPUCTRL
  lda #%00010000	; Enable Sprites
  sta PPUMASK

forever:
  jmp forever

nmi:
  ldx #$00 	; Set SPR-RAM address to 0
  stx OAMADDR
@loop:	lda hello, x 	; Load the hello message into SPR-RAM
  sta OAMDATA
  inx
  cpx #$1c
  bne @loop
  rti

hello:
  .byte $00, $00, $00, $00 	; Why do I need these here?
  .byte $00, $00, $00, $00
  .byte $60, $01, $00, $80
  .byte $64, $01, $00, $84
  .byte $68, $01, $00, $88
  .byte $6C, $01, $00, $8C
  .byte $70, $01, $00, $90

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
  .byte %10000010	; H (00)
  .byte %11000001
  .byte %11000010
  .byte %11111111
  .byte %11111111
  .byte %11000011
  .byte %11000011
  .byte %11000011
  .byte $00, $00, $00, $00, $00, $00, $00, $00 ; High bytes of characters

  .byte %10011010	; E (01)
  .byte %11100101
  .byte %11000000
  .byte %11111100
  .byte %11111100
  .byte %11000000
  .byte %11111111
  .byte %11111111
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11000000	; L (02)
  .byte %11000000
  .byte %11000000
  .byte %11000000
  .byte %11000000
  .byte %11000000
  .byte %11111111
  .byte %11111111
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %01111110	; O (03)
  .byte %11100111
  .byte %11000011
  .byte %11000011
  .byte %11000011
  .byte %11000011
  .byte %11100111
  .byte %01111110
  .byte $00, $00, $00, $00, $00, $00, $00, $00
