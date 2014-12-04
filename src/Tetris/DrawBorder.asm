code
FMG_DRAW_BORDER:
    PUSH PSW
    SETB RS1
    CLR RS0
    
    MOV lcd_X, #020h
    MOV lcd_Y, #000h
    LCALL LCD_XY
    
    MOV R3, #005h
    FMG_DRAW_BORDER_LOOP_EXTERNAL:
        MOV R4, #016h
        FMG_DRAW_BORDER_LOOP:
            MOV lcd_bus, #0FFh
            LCALL LCD_DRAW
            DJNZ R4, FMG_DRAW_BORDER_LOOP
        MOV lcd_X, #020h
        MOV A, lcd_Y
        ADD A, #001h
        MOV lcd_y, A
        LCALL LCD_XY
    DJNZ R3, FMG_DRAW_BORDER_LOOP_EXTERNAL
    
    MOV lcd_X, #020h
    MOV lcd_Y, #005h
    LCALL LCD_XY
    
    MOV R3, #016h
    FMG_DRAW_BORDER_LOOP_BOTTOM:
        MOV lcd_bus, #001h
        LCALL LCD_DRAW
        DJNZ R3, FMG_DRAW_BORDER_LOOP_BOTTOM
    POP PSW
    ret