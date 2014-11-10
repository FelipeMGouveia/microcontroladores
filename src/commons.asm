$include(REG52.inc)

$include(Random.asm)
$include(LCD.asm)

$include (tetris.asm)

code at 0
    ljmp INIT
    
code
INIT: 
    MOV SP, #60h 
    LCALL TIMER_INIT
    LCALL LCD_INIT
    LJMP MAIN 
    
code
TIMER_INIT:
    ret;

code
TIMER0_INTERRUPT:
    PUSH ACC 
    PUSH PSW 
    
    SETB RS0
    CLR RS1
    
    
    POP PSW
    POP ACC
    ret;

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