INCLUDE "memorymap.asm"

SECTION "PlayerCode", ROM0[$3400]

; Handles player actions after button input has been obtained
; 
; @param e = h_inputJoypad
; @param d = h_inputJoypadPrev
HandlePlayer:

.handleRight
    bit 0, e
    jr nz, .handleLeft

    ldh a, [h_playerX]
    cp a, 160
    jr z, .handleLeft

    inc a
    ldh [h_playerX], a

.handleLeft
    bit 1, e
    jr nz, .handleUp

    ldh a, [h_playerX]
    cp a, 8
    jr z, .handleUp

    dec a
    ldh [h_playerX], a

.handleUp
    bit 2, e
    jr nz, .handleDown

    ldh a, [h_playerY]
    cp a, 16 + 8 + 1            ; Screen offset + border + 1 extra pixel
    jr z, .handleDown

    dec a
    ldh [h_playerY], a

.handleDown
    bit 3, e
    jr nz, .return

    ldh a, [h_playerY]
    cp a, 152
    jr z, .return

    inc a
    ldh [h_playerY], a

.return
    ret