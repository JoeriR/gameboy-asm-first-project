INCLUDE "memorymap.asm"



SECTION "Collision Detection Code", ROM0[$3500]

; Handles collision detection for 2 8x8 squares
;
; @param B, x-position of square 1
; @param C, y-position of square 1
;
; @param H, x-position of square 2
; @param L, y-position of square 2
;
; @returns A, zero if no collision, not-zero if collision
HandleCollisionDetection:
    ; Check upper-left corner
    call .checkPosition
    cp a, 0
    jr nz, .returnTrue

    ; Check upper-right corner
    ld a, 8
    add a, b
    ld b, a
    call .checkPosition
    cp a, 0
    jr nz, .returnTrue

    ; Check bottom-right corner
    ld a, 8
    add a, c
    ld c, a
    call .checkPosition
    cp a, 0
    jr nz, .returnTrue

    ; Check bottom-left corner
    ld a, b
    sub a, 8
    ld b, a
    call .checkPosition
    cp a, 0
    jr nz, .returnTrue

    jr .returnFalse


; Check one position
.checkPosition
    ld a, h
    cp a, b
    jr nc, .returnFalse

    add a, 8
    cp a, b
    jr c, .returnFalse

    ld a, l
    cp a, c
    jr nc, .returnFalse

    add a, 8
    cp a, c
    jr c, .returnFalse

    ; Break on collision
    ;ld b, b

    jr .returnTrue

.returnTrue
    ld a, $FF
    ret

.returnFalse
    ld a, $00
    ret
