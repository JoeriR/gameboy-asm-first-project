INCLUDE "hardware.inc"

INCLUDE "memorymap.asm"
INCLUDE "functions.asm"



Section "Score Code", ROM0[$3800]

; Score is treated as a Binary Coded Decimal
IncrementScore:
    ldh a, [h_score]
    inc a
    daa                 ; Binary coded decimal magic
    
    ldh [h_score], a

    ret


; Only use this during VBlank!
UpdateScoreDisplay:          ; The difficult part
    ldh a, [h_score]
    ld b, a

    ; Calc lower digit from lower nibble
    ld a, %00001111
    and a, b
    inc a                   ; A has to incremented to match the offset in Background tile memory since 0 is used for a blank tile

    ; Load background position into HL
    ld hl, _SCRN0 + 1
    ld [hl], a

    ; Calc higher digit from higher nibble
    ld a, %11110000
    and a, b
    swap a
    inc a                   ; correct offset

    ld hl, _SCRN0
    ld [hl], a


.return
    ret