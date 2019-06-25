INCLUDE "hardware.inc"

INCLUDE "init.asm"
INCLUDE "functions.asm"
INCLUDE "memorymap.asm"
INCLUDE "player.asm"
INCLUDE "fireball.asm"
INCLUDE "collisiondetection.asm"
INCLUDE "respawnEnemy.asm"
INCLUDE "score.asm"



SECTION "Interrupt Filler", ROM0[$0]

REPT $40 - $0
    db 0
ENDR



SECTION "VBlank Interrupt Handler", ROM0[$40]
OnVBlankInterrupt:
    ld hl, h_isInVBlank
    ld [hl], $FF
    reti                ; return and re-enable interrupts



SECTION "Header", ROM0[$100]

EntryPoint: ; This is where execution begins
    di ; Disable interrupts
    jp Start ; Leave this tiny space

REPT $150 - $106
    db 0
ENDR





SECTION "Game code", ROM0[$1500]

Start:

    ; pre-init
    ; Move the stackpointer to the end of WRAM, in order to clear up HRAM for storage
    ld sp, $DFFF

    call Init

Gameloop:

.readAndCopyInput
    ld a, %11011111     ; Select Buttons
    ldh [$FF00], a

    ldh a, [$FF00]      ; Read Buttons
    ldh a, [$FF00]
    ld c, %11110000     ; prepare bitmask
    or a, c             ; set upper nibble (contains irrelevant data)

    swap a              ; Store buttonbits in upper nibble

    ld b, a             ; Store button data in b


    ld a, %11101111     ; Select DPAD
    ldh [$FF00], a

    ldh a, [$FF00]      ; Read DPAD
    ldh a, [$FF00]

    or a, c             ; set upper nibble (contains irrelevant data)

    and a, b            ; Combine button results

    ldh [h_inputJoypad], a 

    ldh a, [h_inputJoypad]
    ld e, a

    ldh a, [h_inputJoypadPrev]
    ld d, a

    ; Save input for next frame
    ld a, e     ; CARE: e value might change
    ldh [h_inputJoypadPrev], a

    ; If DPAD was pressed, update h_inputDPadLast
    ld b, %00001111
    and a, b
    cp a, b

    jr nc, .skipUpdateDPadLast
    ldh [h_inputDPadLast], a

.skipUpdateDPadLast

    ld c, 0     ; c contains a boolean for wether A is pressed


.handleSelect
    bit 6, e
    jr nz, .handleStart

    jp Start            ; Reset the game

.handleStart
    bit 7, e
    jr nz, .handlePauzeState
    
    bit 7, d            ; Start has to be pressed down, not held
    jr z, .handlePauzeState

    ld b, %11111111
    ldh a, [h_isPauzed] ; Toggle pauzed state
    xor a, b
    ldh [h_isPauzed], a

.handlePauzeState
    ldh a, [h_isPauzed]
    bit 0, a
    jp nz, WaitVBlank2

.handlePlayer
    call HandlePlayer

.handleCollision
    ; Load fireball position into B and C
    ldh a, [h_fireballX]
    ld b, a
    ldh a, [h_fireballY]
    ld c, a

    ; Loads h_enemyX into H and h_enemyY into L
    ldh a, [h_enemyX]
    ld h, a
    ldh a, [h_enemyY]
    ld l, a

    call HandleCollisionDetection

    ld b, a
    ld a, $00
    cp a, b
    jr z, .handleFireball

    ; Despawn fireball on collision
    ld a, $EE
    ldh [h_fireballX], a
    ldh [h_fireballY], a

    ld a, $00
    ldh [h_fireballIsActive], a

    ; Respawn enemy with RNG
    call RespawnEnemy
    
    ; Increment player score
    call IncrementScore

.handleFireball
    call HandleFireball

; Wait for VBlank
WaitVBlank2:

    ld hl, h_isInVBlank
    xor a           ; a = 0
    ld [hl], a

.loop
    halt            ; Wait for VBlank interrupt
    nop 

    cp a, [hl]      ; Check if we're in VBlank
    jr z, .loop

DuringVBlank:
    ; Update player position in OAM
    ldh a, [h_playerX]
    ld [_OAMRAM + 1], a

    ldh a, [h_playerY]
    ld [_OAMRAM], a

    ; Update enemy position
    ldh a, [h_enemyX]
    ld [_OAMRAM + 5], a

    ldh a, [h_enemyY]
    ld [_OAMRAM + 4], a

    ; Update fireball position
    ldh a, [h_fireballX]
    ld [_OAMRAM + 9], a

    ldh a, [h_fireballY]
    ld [_OAMRAM + 8], a

    ; Increment h_frameCounter
    ldh a, [h_frameCounter]
    inc a
    ldh [h_frameCounter], a

    call UpdateScoreDisplay

    ; Clear pauzed text on-screen
    ld a, 0
    ld hl, _SCRN0 + 17
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a

    ; Draw pauzed on-screen if the game is pauzed
    ldh a, [h_isPauzed]
    bit 0, a
    jr z, .waitVBlankOver

    ld a, $0D
    ld hl, _SCRN0 + 17
    ld [hl+], a
    inc a
    ld [hl+], a
    inc a
    ld [hl+], a


.waitVBlankOver
    ld a, [rLY]
    cp 0 ; Check if the LCD is past VBlank
    jr nz, .waitVBlankOver

    ; Reset h_isInVBlank
    xor a           ; a = 0
    ldh [h_isInVBlank], a

    jp Gameloop

