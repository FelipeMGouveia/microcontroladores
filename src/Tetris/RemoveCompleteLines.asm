code
    FMG_REMOVE_COMPLETE_LINES:
        ; Capturar �ltima linha da tela
        MOV R0, #fmg_grid
        MOV A, #028 ; Deslocamento do come�o das linhas na mem�ria
        
        ADD A, R0 ; Posi��o do come�o das linhas na mem�ria
        MOV R0, A
        MOV R1, A
        MOV R2, #00Ah ;Quantidade de colunas
        
        MOV R3, #0FFh ; M�scara para teste das linhas
        
        FMG_REMOVE_COMPLETE_LINES_LOOP_0:
            MOV A, @R1 ; Captura o elemento que est� em R1
            ANL A, R3 ; Captura quais as linhas que est�o completas
            MOV R3, A
            INC R1
            
            DJNZ R2, FMG_REMOVE_COMPLETE_LINES_LOOP_0
        ;R3 possui as linhas completas, move-lo para A para acessar cada linha
        MOV A, R3
        
        MOV R4, #008h ;Quantidade de linhas a serem analizadas
        MOV R5, #000h ;Controle do n�mero da linha
        FMG_REMOVE_COMPLETE_LINES_LOOP_1:
            RRC A
            ;Carry contem a linha a ser analizada (0 ... 7)
            JNC FMG_REMOVE_COMPLETE_LINES_LOOP_1_NEXT
            LCALL FMG_REMOVE_SPECIFIC_LINE
            FMG_REMOVE_COMPLETE_LINES_LOOP_1_NEXT:
            DJNZ R4, FMG_REMOVE_COMPLETE_LINES_LOOP_1
    RET