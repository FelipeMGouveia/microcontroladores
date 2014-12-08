code
    FMG_DRAW_END:
    PUSH PSW
    
    LCALL LCD_CLEAR

    ;;;;;;;;;
    ;; THE ;;
    ;;;;;;;;;
    MOV lcd_X, #004h
    MOV lcd_Y, #001h
    LCALL LCD_XY    
    
    MOV R4, #00Eh
    FMG_DRAW_END_T_TOP:
        MOV lcd_bus, #0FFh
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_END_T_TOP
    
    MOV R3, #005h
    FMG_DRAW_END_T_H_TOP:
        MOV lcd_bus, #000h
        LCALL LCD_DRAW
        DJNZ R3, FMG_DRAW_END_T_H_TOP
        
    MOV R4, #005h
    FMG_DRAW_END_H1_TOP:
        MOV lcd_bus, #0FFh
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_END_H1_TOP
    MOV R4, #005h
    FMG_DRAW_END_H2_TOP:
        MOV lcd_bus, #0F0h
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_END_H2_TOP
    MOV R4, #005h
    FMG_DRAW_END_H3_TOP:
        MOV lcd_bus, #0FFh
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_END_H3_TOP
    
    MOV R3, #005h
    FMG_DRAW_END_H_E_TOP:
        MOV lcd_bus, #000h
        LCALL LCD_DRAW
        DJNZ R3, FMG_DRAW_END_H_E_TOP
    
    MOV R4, #005h
    FMG_DRAW_END_E_TOP:
        MOV lcd_bus, #0FFh
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_END_E_TOP
    MOV R4, #005h
    FMG_DRAW_END_E2_TOP:
        MOV lcd_bus, #0CFh
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_END_E2_TOP
    MOV R4, #005h
    FMG_DRAW_END_E3_TOP:
        MOV lcd_bus, #00Fh
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_END_E3_TOP
    
    ;Linha 2
    MOV lcd_X, #008h
    MOV lcd_Y, #002h
    LCALL LCD_XY
    
    MOV R4, #005h
    FMG_DRAW_END_T_MIDDLE:
        MOV lcd_bus, #0FFh
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_END_T_MIDDLE
    
    MOV R3, #00Ah
    FMG_DRAW_END_T_H_MIDDLE:
        MOV lcd_bus, #000h
        LCALL LCD_DRAW
        DJNZ R3, FMG_DRAW_END_T_H_MIDDLE
    
    MOV R4, #005h
    FMG_DRAW_END_H1_MIDDLE:
        MOV lcd_bus, #0FFh
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_END_H1_MIDDLE

    MOV R4, #005h
    FMG_DRAW_END_H2_MIDDLE:
        MOV lcd_bus, #00Fh
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_END_H2_MIDDLE
    
    MOV R4, #005h
    FMG_DRAW_END_H3_MIDDLE:
        MOV lcd_bus, #0FFh
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_END_H3_MIDDLE
    
    MOV R3, #005h
    FMG_DRAW_END_H_E_MIDDLE:
        MOV lcd_bus, #000h
        LCALL LCD_DRAW
        DJNZ R3, FMG_DRAW_END_H_E_MIDDLE
        
    MOV R4, #005h
    FMG_DRAW_END_E_BOTTOM:
        MOV lcd_bus, #0FFh
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_END_E_BOTTOM
    MOV R4, #005h
    FMG_DRAW_END_E2_BOTTOM:
        MOV lcd_bus, #0F3h
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_END_E2_BOTTOM
    MOV R4, #005h
    FMG_DRAW_END_E3_BOTTOM:
        MOV lcd_bus, #0F0h
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_END_E3_BOTTOM
    
    FMG_DRAW_END_ETERNAL:
        JMP FMG_DRAW_END_ETERNAL
    POP PSW
    RET