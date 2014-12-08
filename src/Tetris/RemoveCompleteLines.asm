code
    FMG_REMOVE_COMPLETE_LINES:
        ;R7 - Contador de linhas removidas!
        MOV A, #000h
        PUSH ACC
        ; Capturar �ltima linha da tela
        MOV R0, #fmg_grid
        MOV A, #028h ; Deslocamento do come�o das linhas na mem�ria
        ADD A, R0 ; Posi��o do come�o das linhas na mem�ria
        MOV R0, A
        
        FMG_REMOVE_COMPLETE_LINES_LOOP:
            MOV A, R0
            MOV R1, A ;R1 est� na mesma posi��o que R0
            MOV R2, #00Ah ;Quantidade de colunas �teis por linha
            MOV R3, #0FFh ; M�scara para teste das linhas
            
            FMG_REMOVE_COMPLETE_LINES_LOOP_0:
                MOV A, @R1 ; Captura o elemento que est� em R1
                ANL A, R3 ; Captura quais as linhas que est�o completas
                MOV R3, A
                INC R1
                
                DJNZ R2, FMG_REMOVE_COMPLETE_LINES_LOOP_0
            ;R3 possui as linhas completas, move-lo para A para acessar cada linha
            MOV A, R3
            
            ;Se R3 for 0 ent�o n�o temos linhas a serem removidas, caso contr�rio removemos linhas
            JZ FMG_REMOVE_COMPLETE_LINES_LINE_COMPLETE
            JNZ FMG_REMOVE_COMPLETE_LINES_REMOVE_SPECIFIC
            ;Nenhuma linha a remover, logo movo para a pr�xima linha macro do jogo.
            FMG_REMOVE_COMPLETE_LINES_LINE_COMPLETE:
                MOV A, R0
                CLR C
                SUBB A, #fmg_grid
                CLR C
                SUBB A, #004h ; Verificar se R0 est� j� na posi��o 0
                JZ FMG_REMOVE_COMPLETE_LINES_END ; J� verificamos as primeiras linhas
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