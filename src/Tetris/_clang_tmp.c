code
    FMG_GET_REGION:
    MOV A, R2
    PUSH ACC
    MOV A, R3
    PUSH ACC
    
    ;Captura a regi�o de interse��o entre a posi��o descrita por R4 e R5, e retorna-a em R6 e R7 os bytes correspondentes
    MOV R6, #000h
    MOV R7, #000h
    
    MOV R2, #004h
    FMG_GET_REGION_LOOP_X:
        MOV R3, #004h
        FMG_GET_REGION_LOOP_Y:
            ;C�lculo do byte
            MOV A, R5
            MOV B, #004h
            DIV AB
            MOV DPTR, #FMG_GET_REGION_SWITCH_Y
            JMP @A+DPTR
            FMG_GET_REGION_SWITCH_Y:
                JMP FMG_GET_REGION_SWITCH_0
                JMP FMG_GET_REGION_SWITCH_1
                JMP FMG_GET_REGION_SWITCH_2
                JMP FMG_GET_REGION_SWITCH_3
                JMP FMG_GET_REGION_SWITCH_4
                JMP FMG_GET_REGION_SWITCH_5
                JMP FMG_GET_REGION_SWITCH_6
            FMG_GET_REGION_SWITCH_0:
                MOV R0, #000; Contador de ciclos
                MOV A, R4; Carrega a posi��o que desejo ir em A
                MOV R1, A; Posi��o para a qual desejo ir
                JMP FMG_GET_REGION_SWITCH_END
            FMG_GET_REGION_SWITCH_1:
                MOV R0, #004; Contador de ciclos
                MOV A, R4; Carrega a posi��o que desejo ir em A
                MOV R1, A; Posi��o para a qual desejo ir
                JMP FMG_GET_REGION_SWITCH_END
            FMG_GET_REGION_SWITCH_2:
                MOV R0, #000; Contador de ciclos
                MOV A, R4; Carrega a posi��o que desejo ir em A
                ADD A, #012h
                MOV R1, A; Posi��o para a qual desejo ir
                JMP FMG_GET_REGION_SWITCH_END
            FMG_GET_REGION_SWITCH_3:
                MOV R0, #004; Contador de ciclos
                MOV A, R4; Carrega a posi��o que desejo ir em A
                ADD A, #012h
                MOV R1, A; Posi��o para a qual desejo ir
                JMP FMG_GET_REGION_SWITCH_END
            FMG_GET_REGION_SWITCH_4:
                MOV R0, #000; Contador de ciclos
                MOV A, R4; Carrega a posi��o que desejo ir em A
                ADD A, #024h
                MOV R1, A; Posi��o para a qual desejo ir
                JMP FMG_GET_REGION_SWITCH_END
            FMG_GET_REGION_SWITCH_5:
                MOV R0, #004; Contador de ciclos
                MOV A, R4; Carrega a posi��o que desejo ir em A
                ADD A, #024h
                MOV R1, A; Posi��o para a qual desejo ir
                JMP FMG_GET_REGION_SWITCH_END
            FMG_GET_REGION_SWITCH_6:
                MOV R0, #000; Contador de ciclos
                MOV A, R4; Carrega a posi��o que desejo ir em A
                ADD A, #036h
                MOV R1, A; Posi��o para a qual desejo ir
                JMP FMG_GET_REGION_SWITCH_END
            FMG_GET_REGION_SWITCH_END:
                MOV A, R0
                ADD A, B
                MOV R0, A; Bit que preciso
                MOV A, #fmg_grid ;localiza��o da grade
                ADD A, R1 ; Move-se para a aposi��o desejada
                MOV R1, A ;Carrega o valor para R1
                MOV A, @R1 ; Pega o byte que est� na posi��o apontada por R1
                MOV R1, A; Byte para busca
                ;Definir se R6 ou R7 e ent�o chamar o FMG_FIND_BIT
                MOV A, R2
                MOV B, #002h
                DIV AB
                MOV DPTR, #FMG_GET_REGION_SWITCH_1_R6_R7
                JMP @A+DPTR
                FMG_GET_REGION_SWITCH_1_R6_R7:
                    JMP FMG_GET_REGION_SWITCH_1_R7 ;Como o contador est� invertido temos o R7 em 0
                    JMP FMG_GET_REGION_SWITCH_1_R6
                    FMG_GET_REGION_SWITCH_1_R6:
                        LCALL FMG_FIND_BIT
                        ;Carry contem o bit que preciso!
                        MOV A, R6
                        RLC A
                        MOV R6, A
                        JMP FMG_GET_REGION_LOOP_END
                    FMG_GET_REGION_SWITCH_1_R7:
                        LCALL FMG_FIND_BIT
                        ;Carry contem o bit que preciso!
                        MOV A, R7
                        RLC A
                        MOV R7, A
                        JMP FMG_GET_REGION_LOOP_END            
            FMG_GET_REGION_LOOP_END:
                MOV A, R5
                ADD A, #001h
                MOV R5, A
                DJNZ R3, FMG_GET_REGION_LOOP_Y_WORKAROUND
                MOV A, R4
                ADD A, #001h
                MOV R4, A
            DJNZ R2, FMG_GET_REGION_LOOP_X_WORKAROUND
            JMP FMG_GET_REGION_END
            FMG_GET_REGION_LOOP_Y_WORKAROUND:
                LJMP FMG_GET_REGION_LOOP_Y
            FMG_GET_REGION_LOOP_X_WORKAROUND:
                LJMP FMG_GET_REGION_LOOP_X
    FMG_GET_REGION_END:
    POP ACC
    MOV R3, A
    POP ACC
    MOV R2, A
    RET 