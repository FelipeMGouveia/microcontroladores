code
    ;Remove uma linha especifica do jogo.
    ;R0 - Começo da linha (macro 8 bits)
    ;R3 - Máscara do AND das linhas (linhas a serem removidas)
    ;Tentar não afetar R0!
    FMG_REMOVE_SPECIFIC_LINE:
        MOV A, R0
        PUSH ACC
        MOV A, R1
        PUSH ACC
        MOV A, R2
        PUSH ACC
        MOV A, R3
        PUSH ACC
        LCALL FMG_SELECT_LINE_TO_REMOVE
        MOV R4, #00Ah
        MOV B, #004h
        FMG_REMOVE_SPECIFIC_LINE_MAIN_LOOP:
        ;R5 Contem o bit a ser removido
        MOV A, R0
        CLR C
        SUBB A, #012h
        MOV R1, A ;Endereço da linha superior
        MOV A, #007h
        CLR C
        SUBB A, R5 ;Gerar máscara superior
        MOV R2, A
        ;Criar a máscara superior em R6 e a inferiro em R7
        LCALL FMG_CREATE_SUPERIOR_MASK
        MOV A, R5
        MOV R2, A
        LCALL FMG_CREATE_INFERIOR_MASK
        
        MOV A, R0
        CLR C
        SUBB A, #fmg_grid
        CLR C
        SUBB A, B ;Subtraindo 4 de A
        JZ FMG_REMOVE_SPECIFIC_LINE_SET_NOT_CARRY ; Se R0 for a linha superior ignorar teste com linhas superiores
 
        MOV A, @R1 ; Linha superior
        JB ACC.0, FMG_REMOVE_SPECIFIC_LINE_SET_CARRY
        JNB ACC.0, FMG_REMOVE_SPECIFIC_LINE_SET_NOT_CARRY
        
        FMG_REMOVE_SPECIFIC_LINE_SET_CARRY:
            SETB C
            JMP FMG_REMOVE_SPECIFIC_LINE_SET_CARRY_END
        FMG_REMOVE_SPECIFIC_LINE_SET_NOT_CARRY:
            CLR C
            JMP FMG_REMOVE_SPECIFIC_LINE_SET_CARRY_END
        FMG_REMOVE_SPECIFIC_LINE_SET_CARRY_END:
            MOV A, @R0
            ANL A, R6
            RRC A
            MOV R6, A
            MOV A, @R0
            ANL A, R7
            XRL A, R6
            MOV @R0, A
        ;Fazer a etapa de correção para as linhas superiores
        MOV A, R0
        CLR C
        SUBB A, #fmg_grid
        CLR C
        SUBB A, B ;Subtraindo 4 de A
        ;Se R0 for a linha superior então ok, fim
        JZ FMG_REMOVE_SPECIFIC_LINE_END
        
        ;Se não verificar linha superior
        MOV A, R1
        CLR C
        SUBB A, #fmg_grid
        CLR C
        SUBB A, B ;Subtraindo 4 de A
        ;Se a linha superior for a primeira linha, então limpar o carry e fazer apenas o rotate
        JZ FMG_REMOVE_SPECIFIC_LINE_LEVEL_1
        JNZ FMG_REMOVE_SPECIFIC_LINE_LEVEL_2
        
        FMG_REMOVE_SPECIFIC_LINE_LEVEL_1:
            CLR C
            MOV A, @R1
            RRC A
            MOV @R1, A
            JMP FMG_REMOVE_SPECIFIC_LINE_END
        FMG_REMOVE_SPECIFIC_LINE_LEVEL_2:
            MOV A, @R1
            MOV R2, A ; Linha superior
            MOV A, R1
            SUBB A, #012h
            MOV R1, A; Linhas 2 niveis acima
            MOV A, @R1
            RRC A
            MOV A, R2
            RRC A
            MOV R2, A
            CLR C
            MOV A, @R1
            RRC A
            MOV @R1, A
            MOV A, R1
            ADD A, #012h
            MOV R1, A
            MOV A, R2
            MOV @R1, A
        FMG_REMOVE_SPECIFIC_LINE_END:
        INC R0
        INC B
        DJNZ R4, FMG_REMOVE_LINE_MAIN_LOOP_WORKAROUND
        
        JMP FMG_REMOVE_SPECIFIC_LINE_END_END
        FMG_REMOVE_LINE_MAIN_LOOP_WORKAROUND:
            LJMP FMG_REMOVE_SPECIFIC_LINE_MAIN_LOOP
        FMG_REMOVE_SPECIFIC_LINE_END_END:
    POP ACC
    MOV R3, A
    POP ACC
    MOV R2, A
    POP ACC
    MOV R1, A
    POP ACC
    MOV R0, A
    RET
    
code
    FMG_CREATE_SUPERIOR_MASK:
    MOV A, #000h
    FMG_CREATE_SUPERIOR_MASK_LOOP:
        SETB C
        RRC A
        DJNZ R2, FMG_CREATE_SUPERIOR_MASK_LOOP
    MOV R6, A
    RET
    
code
    FMG_CREATE_INFERIOR_MASK:
    MOV A, R2
    JZ FMG_CREATE_INFERIOR_MASK_END
    MOV A, #000h
    FMG_CREATE_INFERIOR_MASK_LOOP:
        SETB C
        RLC A
        DJNZ R2, FMG_CREATE_INFERIOR_MASK_LOOP
    FMG_CREATE_INFERIOR_MASK_END:
    MOV R7, A
    RET
code
    FMG_SELECT_LINE_TO_REMOVE:
    ;R3 - máscara a ser analizada
    ; Não alterar nem R0 nem R7
    CLR C
    MOV R1, #008h
    MOV R5, #000h
    MOV A, R3
    FMG_SELECT_LINE_TO_REMOVE_LOOP:
        RRC A
        JC FMG_SELECT_LINE_TO_REMOVE_END
        INC R5
        DJNZ R1, FMG_SELECT_LINE_TO_REMOVE_LOOP
    FMG_SELECT_LINE_TO_REMOVE_END:
    RET