code
    FMG_DRAW_SCORE:
    PUSH PSW
    MOV A, fmg_score_1
    MOV B, #006h
    MUL AB
    MOV B, #00Ah
    DIV AB
    MOV R2, A; Estouro!
    MOV A, B; Unidades da parte High do score!
    MOV R1, A
    MOV A, fmg_score_0
    MOV B, #00Ah
    DIV AB
    MOV R7, A ;Divisão
    MOV A, B
    ADD A, R1
    MOV R1, A 
    MOV B, #00Ah
    DIV AB
    ADD A, R2
    MOV R2, A
    MOV A, B
    MOV R1, A ;Unidades!
    MOV A, R7
    ADDC A, #000h
    MOV R7, A
    
    MOV A, fmg_score_1
    MOV B, #005h
    MUL AB
    ADD A, R2
    MOV B, #00Ah
    DIV AB
    MOV R3, A;Estouro
    MOV A, B; Dezenas da parte High do score!
    MOV R2, A
    MOV A, R7
    MOV B, #00Ah
    DIV AB
    MOV R7, A ; Divisão
    MOV A, B
    ADD A, R2
    MOV R2, A ;Dezenas
    MOV B, #00Ah
    DIV AB
    ADD A, R3
    MOV R3, A
    MOV A, B
    MOV R2, A
    MOV A, R7
    ADDC A, #000h
    MOV R7, A
    
    MOV A, fmg_score_1
    MOV B, #002h
    MUL AB
    ADD A, R3
    MOV B, #00Ah
    DIV AB
    MOV R4, A;Estouro
    MOV A, B; Centenas da parte High do score!
    MOV R3, A
    MOV A, R7
    MOV B, #00Ah
    DIV AB
    MOV R7, A ; Divisão
    MOV A,B
    ADD A, R3
    MOV R3, A ;Centenas
    MOV B, #00Ah
    DIV AB
    ADD A, R4
    MOV R4, A
    MOV A, B
    MOV R3, A
    MOV A, R7
    ADDC A, #000h
    MOV R7, A
    
    MOV A, R1
    PUSH ACC
    MOV A, R2
    PUSH ACC
    MOV A, R3
    PUSH ACC
    MOV A, R4
    PUSH ACC
    
    ;;;;;;;;;;;;;
    ;; DESENHO ;;
    ;;;;;;;;;;;;;
    SETB RS1
    CLR RS0
    
    MOV DPTR, #fmg_numbers_font
    MOV R3, #000h
    ;Milhares
    POP ACC
    MOV lcd_X, #03Ch
    MOV lcd_Y, #000h
    LCALL LCD_XY
    
    MOV B, #003h
    MUL AB
    MOV R4, A
    MOVC A, @A+DPTR
    MOV lcd_bus, A    
    LCALL LCD_DRAW
    INC R4
    MOV A, R4
    MOVC A, @A+DPTR
    MOV lcd_bus, A
    LCALL LCD_DRAW
    INC R4
    MOV A, R4
    MOVC A, @A+DPTR
    MOV lcd_bus, A
    LCALL LCD_DRAW
    
    ;Centenas
    POP ACC
    MOV lcd_X, #040h
    MOV lcd_Y, #000h
    LCALL LCD_XY
    
    MOV B, #003h
    MUL AB
    MOV R4, A
    MOVC A, @A+DPTR
    MOV lcd_bus, A    
    LCALL LCD_DRAW
    INC R4
    MOV A, R4
    MOVC A, @A+DPTR
    MOV lcd_bus, A
    LCALL LCD_DRAW
    INC R4
    MOV A, R4
    MOVC A, @A+DPTR
    MOV lcd_bus, A
    LCALL LCD_DRAW
    
    ;Dezenas
    POP ACC
    MOV lcd_X, #044h
    MOV lcd_Y, #000h
    LCALL LCD_XY
    
    MOV B, #003h
    MUL AB
    MOV R4, A
    MOVC A, @A+DPTR
    MOV lcd_bus, A
    LCALL LCD_DRAW
    INC R4
    MOV A, R4
    MOVC A, @A+DPTR
    MOV lcd_bus, A
    LCALL LCD_DRAW
    INC R4
    MOV A, R4
    MOVC A, @A+DPTR
    MOV lcd_bus, A
    LCALL LCD_DRAW
    
    ;Unidades
    POP ACC
    MOV lcd_X, #048h
    MOV lcd_Y, #000h
    LCALL LCD_XY
    MOV B, #003h
    MUL AB
    MOV R4, A
    MOVC A, @A+DPTR
    MOV lcd_bus, A
    LCALL LCD_DRAW
    INC R4
    MOV A, R4
    MOVC A, @A+DPTR
    MOV lcd_bus, A
    LCALL LCD_DRAW
    INC R4
    MOV A, R4
    MOVC A, @A+DPTR
    MOV lcd_bus, A
    LCALL LCD_DRAW
    POP PSW
    RET