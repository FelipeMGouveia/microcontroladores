code
    ;Seta os valores de uma determinada região da memória
    ; R4 contem a posição x,
    ; R5 contem a posição y
    ; R6 contem a região ser desenhada (esquerda)
    ; R7 contem a região ser desenhada (direita)
    
    FMG_SET_REGION:
    MOV A, R0
    PUSH ACC
    MOV A, R1
    PUSH ACC
    MOV A, R2
    PUSH ACC
    MOV A, R3
    PUSH ACC
    
    MOV A, R5
    PUSH ACC
    MOV R2, #004h
    FMG_SET_REGION_LOOP_X:
        POP ACC
        MOV R5, ACC
        PUSH ACC
        MOV R3, #004h
        FMG_SET_REGION_LOOP_Y:
            ;Cálculo do byte
            MOV A, R5
            MOV B, #008h
            DIV AB
            MOV R1, B 
            INC R1; R1 contem o bit que quero modificar (+1 por causa do 0 based)
            
            MOV B, #012h ; Byte = 18 * A + R4
            MUL AB
            ADD A, R4
            MOV R0, A 
            MOV A, #fmg_grid
            ADD A, R0
            MOV R0, A ; R0 contem a posição do byte que estou querendo
            
            ;Definir se R6 ou R7 e então chamar o FMG_FIND_BIT
            MOV A, R2
            DEC A
            MOV B, #002h
            DIV AB
            MOV B, #003h
            MUL AB
            MOV DPTR, #FMG_SET_REGION_SWITCH_1_R6_R7
            JMP @A+DPTR
            FMG_SET_REGION_SWITCH_1_R6_R7:
                JMP FMG_SET_REGION_SWITCH_1_R7 ;Como o contador está invertido temos o R7 em 0
                JMP FMG_SET_REGION_SWITCH_1_R6
                FMG_SET_REGION_SWITCH_1_R6:
                    ;Rotacionar R1 vezes o byte escolhido (RLC)
                    MOV A, R1
                    PUSH ACC
                    MOV A, @R0
                    
                    FMG_SET_REGION_SMALL_ROTATE_R6:
                        RLC A
                        DJNZ R1, FMG_SET_REGION_SMALL_ROTATE_R6
                    MOV @R0, A
                    
                    POP ACC
                    MOV R1, A
                    MOV A, R6
                    RLC A
                    MOV R6, A ; Carry contem o bit a ser introduzido no sistema
                    
                    MOV A, @R0
                    FMG_SET_REGION_SMALL_ROTATE_BACK_R6:
                        RRC A
                        DJNZ R1, FMG_SET_REGION_SMALL_ROTATE_BACK_R6
                    MOV @R0, A
                    JMP FMG_SET_REGION_LOOP_END
                FMG_SET_REGION_SWITCH_1_R7:
                    ;Rotacionar R1 vezes o byte escolhido (RLC)
                    MOV A, R1
                    PUSH ACC
                    MOV A, @R0
                    
                    FMG_SET_REGION_SMALL_ROTATE_R7:
                        RLC A
                        DJNZ R1, FMG_SET_REGION_SMALL_ROTATE_R7
                    MOV @R0, A
                    
                    POP ACC
                    MOV R1, A
                    MOV A, R7
                    RLC A
                    MOV R7, A ; Carry contem o bit a ser introduzido no sistema
                    
                    MOV A, @R0
                    FMG_SET_REGION_SMALL_ROTATE_BACK_R7:
                        RRC A
                        DJNZ R1, FMG_SET_REGION_SMALL_ROTATE_BACK_R7
                    MOV @R0, A
                    JMP FMG_SET_REGION_LOOP_END
            FMG_SET_REGION_LOOP_END:
                INC R5
                DJNZ R3, FMG_SET_REGION_LOOP_Y_WORKAROUND
                INC R4
            DJNZ R2, FMG_SET_REGION_LOOP_X_WORKAROUND
            JMP FMG_SET_REGION_END
            FMG_SET_REGION_LOOP_Y_WORKAROUND:
                LJMP FMG_SET_REGION_LOOP_Y
            FMG_SET_REGION_LOOP_X_WORKAROUND:
                LJMP FMG_SET_REGION_LOOP_X
    FMG_SET_REGION_END:
    POP ACC
    POP ACC
    MOV R3, A
    POP ACC
    MOV R2, A
    POP ACC
    MOV R1, A
    POP ACC
    MOV R0, A
    RET