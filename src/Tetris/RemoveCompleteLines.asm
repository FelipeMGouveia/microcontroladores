code
    FMG_REMOVE_COMPLETE_LINES:
        ;R7 - Contador de linhas removidas!
        MOV A, #000h
        PUSH ACC
        ; Capturar última linha da tela
        MOV R0, #fmg_grid
        MOV A, #028h ; Deslocamento do começo das linhas na memória
        ADD A, R0 ; Posição do começo das linhas na memória
        MOV R0, A
        
        FMG_REMOVE_COMPLETE_LINES_LOOP:
            MOV A, R0
            MOV R1, A ;R1 está na mesma posição que R0
            MOV R2, #00Ah ;Quantidade de colunas úteis por linha
            MOV R3, #0FFh ; Máscara para teste das linhas
            
            FMG_REMOVE_COMPLETE_LINES_LOOP_0:
                MOV A, @R1 ; Captura o elemento que está em R1
                ANL A, R3 ; Captura quais as linhas que estão completas
                MOV R3, A
                INC R1
                
                DJNZ R2, FMG_REMOVE_COMPLETE_LINES_LOOP_0
            ;R3 possui as linhas completas, move-lo para A para acessar cada linha
            MOV A, R3
            
            ;Se R3 for 0 então não temos linhas a serem removidas, caso contrário removemos linhas
            JZ FMG_REMOVE_COMPLETE_LINES_LINE_COMPLETE
            JNZ FMG_REMOVE_COMPLETE_LINES_REMOVE_SPECIFIC
            ;Nenhuma linha a remover, logo movo para a próxima linha macro do jogo.
            FMG_REMOVE_COMPLETE_LINES_LINE_COMPLETE:
                MOV A, R0
                CLR C
                SUBB A, #fmg_grid
                CLR C
                SUBB A, #004h ; Verificar se R0 está já na posição 0
                JZ FMG_REMOVE_COMPLETE_LINES_END ; Já verificamos as primeiras linhas
                ADD A, #fmg_grid
                SUBB A, #00Eh
                MOV R0, A
                MOV R1, A
                JMP FMG_REMOVE_COMPLETE_LINES_LOOP
            FMG_REMOVE_COMPLETE_LINES_REMOVE_SPECIFIC:
                LCALL FMG_REMOVE_SPECIFIC_LINE
                POP ACC
                INC A
                PUSH ACC
                JMP FMG_REMOVE_COMPLETE_LINES_LOOP
        FMG_REMOVE_COMPLETE_LINES_END:
        POP ACC
        MOV R7, A
    RET