code 
    FMG_DRAW_NEXT_PIECE:
    PUSH PSW
    SETB RS1
    CLR RS0
    MOV lcd_X, #012h
    MOV lcd_Y, #000h
    LCALL LCD_XY
    MOV lcd_bus, #0C0h
    LCALL LCD_DRAW
    
    MOV R4, #00Ah
    FMG_DRAW_NEXT_PIECE_TOP:
        MOV lcd_bus, #040h
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_NEXT_PIECE_TOP
        
    MOV lcd_bus, #0C0h
    LCALL LCD_DRAW
    
    MOV R3, #fmg_piece_id_0
    MOV R4, #0C0h
    
    MOV lcd_X, #012h
    MOV lcd_Y, #001h
    LCALL LCD_XY
    
    MOV lcd_bus, #0FFh
    LCALL LCD_DRAW
    MOV lcd_bus, #000h
    LCALL LCD_DRAW
    
    MOV R4, #002h
    FMG_DRAW_NEXT_PIECE_INTERNAL:
        MOV A, R3 ; Desenha a pr�xima pe�a
        MOV R1, A
        MOV ACC, @R1
        
        MOV C, ACC.4
        MOV ACC.0, C
        MOV ACC.1, C
        MOV C, ACC.5
        MOV ACC.2, C
        MOV ACC.3, C
        MOV C, ACC.6
        MOV ACC.4, C
        MOV ACC.5, C
        MOV C, ACC.7
        MOV ACC.6, C

        MOV lcd_bus, ACC; primeiro draw
        LCALL LCD_DRAW
        MOV lcd_bus, ACC; segundo draw
        LCALL LCD_DRAW

        MOV A, R3; Desenha bytes inferiores
        MOV R1, A
        MOV ACC, @R1
        
        MOV C, ACC.3
        MOV ACC.7, C
        MOV ACC.6, C
        MOV C, ACC.2
        MOV ACC.5, C
        MOV ACC.4, C
        MOV C, ACC.1
        MOV ACC.3, C
        MOV ACC.2, C
        MOV C, ACC.0
        MOV ACC.1, C

        MOV lcd_bus, ACC; primeiro draw
        LCALL LCD_DRAW
        MOV lcd_bus, ACC; segundo draw
        LCALL LCD_DRAW
        
        MOV R3, #fmg_piece_id_1
        DJNZ R4, FMG_DRAW_NEXT_PIECE_INTERNAL
    
    MOV lcd_bus, #000h
    LCALL LCD_DRAW
    MOV lcd_bus, #0FFh
    LCALL LCD_DRAW
    
    MOV lcd_X, #012h
    MOV lcd_Y, #002h
    LCALL LCD_XY
    MOV lcd_bus, #003h
    LCALL LCD_DRAW
    
    MOV R4, #00Ah
    FMG_DRAW_NEXT_PIECE_BOTTOM:
        MOV lcd_bus, #002h
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_NEXT_PIECE_BOTTOM
    MOV lcd_bus, #003h
    LCALL LCD_DRAW    
    POP PSW
    RET