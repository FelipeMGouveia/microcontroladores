code
FMG_SELECT_NEW_PIECE:
    LCALL RAND8
    MOV B, #007h
    DIV AB; Capturando apenas as 8 possiveis peças (temos 7 peças portanto um dos valores sera desconsiderado)
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
        ;Escolhe qual vai ser a peça
        MOV DPTR, #FMG_PIECES_I
        SJMP FMG_SELECT_NEW_PIECE_END
    ;Parte final da rotina, com a peça correta selecionada, devemos escolher qual a rotação inidial da mesma e
    ;popular as variáveis de ambiente com ela.
    FMG_SELECT_NEW_PIECE_END:
        ;Salva a peça escolhida na memória
        MOV fmg_piece_id_H, DPH
        MOV fmg_piece_id_L, DPL
        MOV A, #000h
        MOVC A, @A+DPTR ; Quantidade de rotações da peça
        MOV B, A ; Coloca em B a quantidade de rotações da peça
        LCALL RAND8
        DIV AB
        MOV A, B ;Escolhendo a rotação
        MOV fmg_piece_id_R, A ;Coloca a posição da peça rotacionada no id 2
        MOV B, #002h
        MUL AB ; Multiplico por 2 para ir para a peça correta
        ADD A, #001h ;Soma 1 já que o primeiro valor contem a quantidade de rotações da peça
        MOV R1, A
        ;Coloca em id 0 e 1 qual a peça selecionada
        MOVC A, @A+DPTR ;Representação da peça (primeiros bytes)
        MOV fmg_piece_id_0, A
        MOV A, R1
        ADD A, #001h ;Representação da peça (segundos bytes)
        MOVC A, @A+DPTR
        MOV fmg_piece_id_1, A
    RET