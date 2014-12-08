$include(Random.asm)
$include(LCD.asm)

$include(tetris.asm)

code at 0000h
    ljmp INIT

code at 000Bh
TIMER0_INTERRUPT:
    LCALL FMG_TIMER_0
    RETI;

code
INIT: 
    MOV SP, #90h 
    LCALL LCD_INIT
    LJMP MAIN 
    
code
MAIN: 
    ;Banco 2
    SETB RS1
    CLR RS0
    MOV R1, #001h
    MOV R2, #001h
    

    MOV lcd_X, #000h
    MOV lcd_Y, #000h
    LCALL LCD_XY
    LCALL FMG_TETRIS_MAIN
END