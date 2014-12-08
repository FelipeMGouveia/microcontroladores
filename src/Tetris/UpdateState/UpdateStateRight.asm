;Carrega a posição X e Y para R4 e R5
MOV A, fmg_piece_x
INC A
MOV R4, A
MOV A, fmg_piece_y
MOV R5, A

;Carrega a rotação para R1
MOV A, fmg_piece_R
MOV R1, A

FMG_UPDATE_STATE_RIGHT:
    LCALL FMG_UPDATE_STATE_CHECK_COLLISION
    JC FMG_UPDATE_STATE_RIGHT_VALID; Posição válida
    JNC FMG_UPDATE_STATE_RIGHT_NOT_VALID; Posição inválida
FMG_UPDATE_STATE_RIGHT_VALID:
    ;Rotação válida
    MOV A, fmg_piece_x
    INC A
    MOV fmg_piece_x, A; Atualiza a posição
FMG_UPDATE_STATE_RIGHT_NOT_VALID:
    LJMP FMG_UPDATE_STATE_END