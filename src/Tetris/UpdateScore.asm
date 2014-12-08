code
    FMG_UPDATE_SCORE:
    ;R7 Quantidade de linhas removidas
    ;fmg_score_0 - pontuação Inferior
    ;fmg_score_1 - pontuação Superior
    
    MOV A, R7
    MOV B, #003h
    MUL AB
    
    MOV DPTR, #FMG_UPDATE_SCORE_SWITCH_LINES
    JMP @A+DPTR
    
    FMG_UPDATE_SCORE_SWITCH_LINES:
        JMP FMG_UPDATE_SCORE_SWITCH_LINES_0
        JMP FMG_UPDATE_SCORE_SWITCH_LINES_1
        JMP FMG_UPDATE_SCORE_SWITCH_LINES_2
        JMP FMG_UPDATE_SCORE_SWITCH_LINES_3
        JMP FMG_UPDATE_SCORE_SWITCH_LINES_4
    FMG_UPDATE_SCORE_SWITCH_LINES_0:
        MOV R0, #000h;
        JMP FMG_UPDATE_SCORE_END
    FMG_UPDATE_SCORE_SWITCH_LINES_1:
        MOV R0, #001h;
        JMP FMG_UPDATE_SCORE_END
    FMG_UPDATE_SCORE_SWITCH_LINES_2:
        MOV R0, #003h;
        JMP FMG_UPDATE_SCORE_END
    FMG_UPDATE_SCORE_SWITCH_LINES_3:
        MOV R0, #005h;
        JMP FMG_UPDATE_SCORE_END
    FMG_UPDATE_SCORE_SWITCH_LINES_4:
        MOV R0, #008h;
        JMP FMG_UPDATE_SCORE_END
    FMG_UPDATE_SCORE_END:
        MOV A, fmg_score_0
        ADD A, R0
        MOV fmg_score_0, A
        MOV A, fmg_score_1
        ADDC A, #000h
        MOV fmg_score_1, A
    RET