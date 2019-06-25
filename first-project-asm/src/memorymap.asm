    IF !DEF(MEMORYMAP_ASM)
MEMORYMAP_ASM SET 1


; RAM memory 'map' Start        (prefixed with "r_")

; RAM memory 'map' End

; High RAM memory 'map' Start   (prefixed with "h_")
h_inputJoypad       EQU $FF80   ; bit 7 = Start, 6 = Select, 5 = B, 4 = A, 3 = Down, 2 = Up, 1 = Left, 0 = Right
h_inputJoypadPrev   EQU $FF81   ; Contains input from previous frame
h_inputDPadLast     EQU $FF82   ; Contains the DPad input from when it was last pressed (in lower nibble)
h_playerX           EQU $FF83
h_playerY           EQU $FF84
h_isPauzed          EQU $FF85
h_enemyX            EQU $FF86
h_enemyY            EQU $FF87
h_fireballX         EQU $FF88
h_fireballY         EQU $FF89
h_fireballSpeed     EQU $FF8A
h_fireballDirection EQU $FF8B   ; lower nibble contains directions just like the D-PAD
h_fireballIsActive  EQU $FF8C
h_score             EQU $FF8D   ; score is a BCD (Binary Coded Decimal)

h_frameCounter      EQU $FF90
h_isInVBlank        EQU $FF91

; High RAM memory 'map' End

    ENDC    ; end of MEMORYMAP_ASM