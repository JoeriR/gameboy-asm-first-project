INCLUDE "hardware.inc"

INCLUDE "memorymap.asm"
INCLUDE "functions.asm"

INCLUDE "tiledata/spriteTileData.asm"
INCLUDE "tiledata/backgroundTiles.asm"

SECTION "initCode", ROM0[$3000]


Init:

; Turn off the LCD
.waitVBlank
    ld a, [rLY]
    cp 144 ; Check if the LCD is past VBlank
    jr c, .waitVBlank

    xor a ; ld a, 0 ; We only need to reset a value with bit 7 reset, but 0 does the job
    ld [rLCDC], a ; We will have to write to LCDC again later, so it's not a bother, really.

    call PrepareVram

    ; Copy sprite tile data to VRAM
    ld de, SpriteTileData
    ld hl, _VRAM
    ld bc, SpriteTileDataEnd - SpriteTileData
    call Memcpy

    ; Copy background tile data to VRAM
    ld de, BackgroundTileData
    ld hl, $9000
    ld bc, BackgroundTileDataEnd - BackgroundTileData
    call Memcpy


    ; Clear OAM
    ld bc, _OAMRAM      ; Start of OAM
    ld de, $9F          ; size of OAM
    call ZeroOutArea

    ; Clear background
    ld bc, _SCRN0
    ld de, _SCRN1 - _SCRN0
    call ZeroOutArea

    ; Put horzontal bar on screen
    ld a, $0C
    ld hl, _SCRN0 + 32

REPT 20
    ld [hl+], a
ENDR


    ; Load player sprite into OAM and put it on screen at pos (32,32)
    ld hl, _OAMRAM
    ld a, 32
    ld [hl+], a
    ld [hl+], a
    ld a, 1
    ld [hl+], a
    ld a, 0
    ld [hl+], a

    ; Load enemy sprite into OAM
    ld a, 80
    ld [hl+], a
    ld [hl+], a
    ld a, 2
    ld [hl+], a
    ld a, 0
    ld [hl+], a

    ; Load fireball sprite into OAM (off-screen)
    ld a, 200
    ld [hl+], a
    ld [hl+], a
    ld a, 3
    ld [hl+], a
    ld a, 0
    ld [hl+], a


    ; Zero out HRAM
    ld bc, _HRAM            ; Start of HRAM
    ld de, $FFFE - _HRAM    ; size of HRAM
    call ZeroOutArea

    ; Init HRAM
    ld a, $FF
    ldh [h_inputJoypad], a
    ldh [h_inputJoypadPrev], a

    ld a, %11111110
    ldh [h_inputDPadLast], a    ; Default to DPAD-right pressed

    ld a, $00
    ldh [h_isPauzed], a

    ld a, 70
    ldh [h_playerX], a
    ldh [h_playerY], a

    ld a, 120
    ldh [h_enemyX], a
    ldh [h_enemyY], a

    ld a, 200
    ldh [h_fireballX], a
    ldh [h_fireballY], a

    ld a, 2
    ldh [h_fireballSpeed], a

    ld a, %11111111
    ldh [h_fireballDirection], a

    ld a, %00000000
    ldh [h_fireballIsActive], a

    ldh [h_score], a
    
    ldh [h_isInVBlank], a

    ; Init display registers
    ld a, %11100100
    ld [rBGP], a

    ld a, %11100000
    ld [rOBP0], a
    ld [rOBP1], a

    xor a ; faster than ld a, 0
    ld [rSCY], a
    ld [rSCX], a
    

    ; Disable sound
    ld [rNR52], a

    ; Enable timer, at slowest frequency (4096 Hz)
    ld a, %00000100
    ldh [rTAC], a

    ; Turn screen on, enable sprite_drawing, display background 
    ld a, %10000011
    ld [rLCDC], a

    ; messing around with sound, based on the gameboy bootrom's "chime" sound effect
; .initSound
;     ld hl, $ff26
;     ld c, $11
;     ld a, $80
;     ld [hl-], a
;     ld [$ff11], a

;     inc c
;     ld a, $f3
;     ld [$ff12], a
;     ld [hl-], a
;     ld a, $77

;     ld [hl], a

; .playChimeSound
;     ld c, $13
;     ld e, $c1
;     ld a, e

;     ld [$ff13], a
;     inc c

;     ld a, $87
;     ld [$ff14], a



    ld a, STATF_MODE01
    ldh [rSTAT], a

    ld a, IEF_VBLANK
    ldh [rIE], a

    ;Finish init by re-enabling interrupts
    ei

    ret