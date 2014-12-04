;Desenha o grade na tela
code
FMG_DRAW_SCREEN:
    ;Desenhar na tela significa pegar os bytes definidos no grade e passar para a tela.
    ;lembrando que será usado um fator de 2x.
    PUSH PSW
    SETB RS1
    CLR RS0
    MOV lcd_X, #021h
    MOV lcd_Y, #000h
    LCALL LCD_XY
    MOV R5, #021h
    MOV R4, #00Ah
    MOV R3, #fmg_grid
    INC R3
    INC R3
    INC R3
    INC R3 ; Grid + 4
    FMG_LOOP_LINHA_SUPERIOR:
        MOV A, R3; Move o conteúdo de R1 para o acumulador
        MOV R1, A
        MOV ACC, @R1
        
        MOV C, ACC.0
        MOV ACC.7, C
        MOV ACC.6, C
        MOV C, ACC.1
        MOV ACC.5, C
        MOV ACC.4, C
        MOV C, ACC.3
        MOV ACC.1, C
        MOV ACC.0, C
        MOV C, ACC.2
        MOV ACC.2, C
        MOV ACC.3, C

        MOV lcd_bus, ACC; primeiro draw
        LCALL LCD_DRAW
        MOV lcd_bus, ACC; segundo draw
        LCALL LCD_DRAW
        
        INC R3
        INC R5
        DJNZ R4, FMG_LOOP_LINHA_SUPERIOR
    MOV lcd_X, #021h
    MOV lcd_Y, #001h
    LCALL LCD_XY
    MOV R6, #002h
    FMG_LOOP_LINHA_3:
    MOV A, R3
    ADD A, #008h
    MOV R3, A ;Deslocamento das paredes
    MOV R4, #00Ah
    MOV R5, #021h
    FMG_LOOP_LINHA_2:
        MOV A, R5
        MOV lcd_X, A
        ;MOV lcd_Y, A
        LCALL LCD_XY

        MOV A, R3; Move o conteúdo de R1 para o acumulador
        MOV R1, A
        MOV ACC, @R1
        
        MOV C, ACC.7
        MOV ACC.0, C
        MOV ACC.1, C
        MOV C, ACC.6
        MOV ACC.2, C
        MOV ACC.3, C
        MOV C, ACC.4
        MOV ACC.6, C
        MOV ACC.7, C
        MOV C, ACC.5
        MOV ACC.5, C
        MOV ACC.4, C
        
        MOV lcd_bus, ACC; primeiro draw
        LCALL LCD_DRAW

        MOV lcd_bus, ACC; segundo draw
        LCALL LCD_DRAW
        
        MOV A, R5
        MOV lcd_X, A
        
        MOV A, lcd_Y
        ADD A, #001h
        MOV lcd_Y, A
        LCALL LCD_XY
        
        MOV A, R3; Move o conteúdo de R1 para o acumulador
        MOV R1, A
        MOV ACC, @R1
        
        MOV C, ACC.0
        MOV ACC.7, C
        MOV ACC.6, C
        MOV C, ACC.1
        MOV ACC.5, C
        MOV ACC.4, C
        MOV C, ACC.3
        MOV ACC.1, C
        MOV ACC.0, C
        MOV C, ACC.2
        MOV ACC.2, C
        MOV ACC.3, C

        MOV lcd_bus, ACC; primeiro draw
        LCALL LCD_DRAW
        MOV lcd_bus, ACC; segundo draw
        LCALL LCD_DRAW
        
        MOV A, R3
        ADD A, #001h
        MOV R3, A
        
        MOV A, R5
        ADD A, #002h
        MOV R5, A
        
        MOV A, lcd_Y
        SUBB A, #001h
        MOV lcd_Y, A
        
        DJNZ R4, FMG_LOOP_LINHA_2
        MOV lcd_Y, #003h
        DJNZ R6, FMG_LOOP_LINHA_3
        POP PSW
    ret