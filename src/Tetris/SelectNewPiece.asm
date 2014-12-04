code
FMG_SELECT_NEW_PIECE:
    LCALL RAND8
    MOV B, #007h
    DIV AB; Capturando apenas as 8 possiveis pe�as (temos 7 pe�as portanto um dos valores sera desconsiderado)
    MOV A, B
    MOV B, #003h
    MUL AB
    MOV DPTR, #FMG_SELECT_PIECE_SWITCH
    JMP @A+DPTR
    FMG_SELECT_PIECE_SWITCH:
        JMP FMG_SELECT_PIECE_I
        JMP FMG_SELECT_PIECE_O
        JMP FMG_SELECT_PIECE_S
        JMP FMG_SELECT_PIECE_Z
        JMP FMG_SELECT_PIECE_L
        JMP FMG_SELECT_PIECE_J
        JMP FMG_SELECT_PIECE_T
    FMG_SELECT_PIECE_O:
        MOV DPTR, #FMG_PIECES_O
        SJMP FMG_SELECT_NEW_PIECE_END
    FMG_SELECT_PIECE_S:
        MOV DPTR, #FMG_PIECES_S
        SJMP FMG_SELECT_NEW_PIECE_END
    FMG_SELECT_PIECE_Z:
        MOV DPTR, #FMG_PIECES_Z
        SJMP FMG_SELECT_NEW_PIECE_END
    FMG_SELECT_PIECE_L:
        MOV DPTR, #FMG_PIECES_L
        SJMP FMG_SELECT_NEW_PIECE_END
    FMG_SELECT_PIECE_J:
        MOV DPTR, #FMG_PIECES_J
        SJMP FMG_SELECT_NEW_PIECE_END
    FMG_SELECT_PIECE_T:
        MOV DPTR, #FMG_PIECES_T
        SJMP FMG_SELECT_NEW_PIECE_END
    FMG_SELECT_PIECE_I:
        ;Escolhe qual vai ser a pe�a
        MOV DPTR, #FMG_PIECES_I
        SJMP FMG_SELECT_NEW_PIECE_END
    ;Parte final da rotina, com a pe�a correta selecionada, devemos escolher qual a rota��o inidial da mesma e
    ;popular as vari�veis de ambiente com ela.
    FMG_SELECT_NEW_PIECE_END:
        ;Salva a pe�a escolhida na mem�ria
        MOV fmg_piece_id_H, DPH
        MOV fmg_piece_id_L, DPL
        MOV A, #000h
        MOVC A, @A+DPTR ; Quantidade de rota��es da pe�a
        MOV B, A ; Coloca em B a quantidade de rota��es da pe�a
        LCALL RAND8
        DIV AB
        MOV A, B ;Escolhendo a rota��o
        MOV fmg_piece_id_R, A ;Coloca a posi��o da pe�a rotacionada no id 2
        MOV B, #002h
        MUL AB ; Multiplico por 2 para ir para a pe�a correta
        ADD A, #001h ;Soma 1 j� que o primeiro valor contem a quantidade de rota��es da pe�a
        MOV R1, A
        ;Coloca em id 0 e 1 qual a pe�a selecionada
        MOVC A, @A+DPTR ;Representa��o da pe�a (primeiros bytes)
        MOV fmg_piece_id_0, A
        MOV A, R1
        ADD A, #001h ;Representa��o da pe�a (segundos bytes)
        MOVC A, @A+DPTR
        MOV fmg_piece_id_1, A
    RET