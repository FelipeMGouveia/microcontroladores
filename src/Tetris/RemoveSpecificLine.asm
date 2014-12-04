code
    ;Remove uma linha especifica do jogo.
    ;R0 - Começo da linha (macro)
    ;R5 - Número da linha (específica)
    ;Tentar não afetar R0, R3, R4 e R5
    FMG_REMOVE_SPECIFIC_LINE:
    PUSH ACC
    MOV A, R1
    PUSH ACC
    
        MOV A, R0
        SUBB A, #012h
        MOV A, R1 ;R1 está com a linha acima de R0
        MOV A, #007h
        CLR C
        SUBB A, R5 ;Gerar máscara superior
        MOV R2, A
        ;Criar a máscara superior em R6 e a inferiro em R7
        LCALL FMG_CREATE_SUPERIOR_MASK
        MOV A, R5
        MOV R2, A
        DEC R2
        LCALL FMG_CREATE_INFERIOR_MASK
        
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
        
    POP ACC
    MOV R1, A
    POP ACC
    RET
    
code
    FMG_CREATE_SUPERIOR_MASK:
    MOV A, #000h
    FMG_CREATE_SUPERIOR_MASK_LOOP:
        SETB C
        RLC A
        DJNZ R2, FMG_CREATE_SUPERIOR_MASK_LOOP
    MOV R6, A
    RET
    
code
    FMG_CREATE_INFERIOR_MASK:
    MOV A, #000h
    FMG_CREATE_INFERIOR_MASK_LOOP:
        SETB C
        RRC A
        DJNZ R2, FMG_CREATE_INFERIOR_MASK_LOOP
    MOV R7, A
    RET