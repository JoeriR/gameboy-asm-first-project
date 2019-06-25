INCLUDE "memorymap.asm"



SECTION "fireballCode", ROM0[$3200]

; Handles the fireball
; The fireball gets spawned when it's offscreen and the A-button is pressed
; While on-screen the fireball will update it's position every frame
;
; @param e = h_inputJoypad
; @param d = h_inputJoypadPrev
HandleFireball:
    ; Get fireballX and fireballY, put them into b and c
    ldh a, [h_fireballX]
    ld b, a
    ldh a, [h_fireballY]
    ld c, a

    ; Get fireballSpeed and fireballDirection, put them into h and l
    ldh a, [h_fireballSpeed]
    ld h, a
    ldh a, [h_fireballDirection]
    ld l, a

    ; If fireball is NOT active, check to spawn it, otherwise update it
    ldh a, [h_fireballIsActive]
    cp a, 0
    jp z, .checkToSpawnFireball

    jp .updateFireballPosition

    
.checkToSpawnFireball
    ; Check if the A-button was pressed on this frame
    bit 4, e
    jp nz, .return

    ; Check if the A-button was not held on the previous frame
    bit 4, d
    jp z, .return

    ; Get the last pressed direction instead, then spawnFireball


.spawnFireball
    ; Set fireballX and Y equal to the player's position
    ldh a, [h_playerX]
    ld b, a
    ldh a, [h_playerY]
    ld c, a

    ; Set fireballDirection equal to directions pressed on the DPAD unless no directions were pressed, use h_inputDPadLast instead
    ld a, %00001111
    and a, e

    cp a, %00001111
    jr c, .setFireballDirection
    ldh a, [h_inputDPadLast]


.setFireballDirection
    ld l, a
    ldh [h_fireballDirection], a

    ; Change fireballSpeed to 8 for this frame only ( NOTE: fireballSpeed should NOT be written back to HRAM in further code!)
    ld h, 8

    ld a, $FF
    ldh [h_fireballIsActive], a


.updateFireballPosition
    
    ; Break if B-Button is pressed
    ; bit 5, e
    ; jr nz, .skipBreakpoint
    ; ;ld b, b
; .skipBreakpoint

.updateFireballRight
    bit 0, l
    jr nz, .updateFireBallLeft

    ld a, b        ; b still contains FireballX
    add a, h
    ld b, a

.updateFireBallLeft
    bit 1, l
    jr nz, .updateFireballUp

    ld a, b        ; b still contains FireballX
    sub a, h
    ld b, a

.updateFireballUp
    bit 2, l
    jr nz, .updateFireballDown

    ld a, c        ; c still contains FireballY
    sub a, h
    ld c, a

.updateFireballDown
    bit 3, l
    jp nz, .writeFireballPosition

    ld a, c    	    ; c still contains FireballY
    add a, h
    ld c, a

.writeFireballPosition
    ld a, b
    ldh [h_fireballX], a

    ld a, c
    ldh [h_fireballY], a

.checkFireballOffscreen
    ld a, 168
    cp a, b                 ; If the ball is offscreen (x > 160 + 8)
    jr c, .setFireballInactive

    ld a, 160
    cp a, c
    jr c, .setFireballInactive

    ; Ball will also despawn if it touches the horizontal bar
    ld a, 24
    cp a, c
    jr nc, .setFireballInactive

    jr .return

.setFireballInactive

    ld a, $EE
    ldh [h_fireballX], a
    ldh [h_fireballY], a

    ld a, 0
    ldh [h_fireballIsActive], a

.return
    ret