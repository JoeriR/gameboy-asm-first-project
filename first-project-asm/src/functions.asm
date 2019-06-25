    IF !DEF(FUNCIONS_ASM)
FUNCIONS_ASM SET 1

INCLUDE "hardware.inc"

    


SECTION "Functions", ROM0[$3300]



; Copy bytes of memory from de to hl
; @param de, A pointer to the bytes to be copied
; @param hl, A pointer to the start where the bytes need to be copied to
; @param bc, Size of the bytes to be copied
Memcpy:
    ld a, [de]
    ld [hli], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, Memcpy
    ret

; Clears the first 32 tiles from VRAM
PrepareVram:
    ld hl, _VRAM
    ld a, $FF
.loop
    ld [hl], 0
    inc hl

    cp a, l
    jr nz, .loop            ; jump if (a != 0)

    ret

; Zeroes out a part of memory
; @param bc, A pointer to the start of the area
; @param de, Amount of bytes to be zeroed out
ZeroOutArea:
    ld a, $0              ; Set limit into hl
    ld h, b
    ld l, c
    add hl, de
    ld d, 0
.loop
    ld a, 0
    ld [bc], a
    inc bc

    ; compare first byte of bc and hl
    ld a, b
    cp a, h
    jr nz, .loop            ; jump if (a != l)

    ; compare second byte of bc and hl
    ld a, c
    cp a, l
    jr nz, .loop            ; jump if (a != l)s

    ret


    ENDC ; FUNCTIONS_ASM