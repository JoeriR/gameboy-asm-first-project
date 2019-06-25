INCLUDE "hardware.inc"

INCLUDE "memorymap.asm"
INCLUDE "functions.asm"

SECTION "Respawn Enemy Code", ROM0[$3600]

; Calculates and sets the Enemy's respawn point
; His x-position is: h_frameCounter % 168 AND IF < 8 THEN 8 is added
; His y-position is: 
RespawnEnemy:
.prepareX
    ; Calc enemyX based on frameCounter
    ldh a, [h_frameCounter]

.frameCounterLoop
    cp a, 160
    jr c, .checkLeftOffscreen

    sub a, 160

.checkLeftOffscreen
    cp a, 8
    jr nc, .setX

    add a, 8

.setX
    ldh [h_enemyX], a

.prepareY
    ; Calc enemyY based on the timer
    ldh a, [rTIMA]

.timerCounterLoop
    cp a, 152
    jr c, .checkUpperOffscreen

    sub a, 152

.checkUpperOffscreen
    cp a, 24
    jr nc, .setY

    add a, 24

.setY
    ldh [h_enemyY], a

.return
    ret