;Carrega a posição X e Y para R4 e R5
MOV A, fmg_piece_x
MOV R4, A
MOV A, fmg_piece_y
ADD A, #001h ;Cair!!!
MOV R5, A

;Carrega a rotação para R1
MOV A, fmg_piece_R
MOV R1, A

FMG_UPDATE_STATE_FALL:
    LCALL FMG_UPDATE_STATE_CHECK_COLLISION
    JC FMG_UPDATE_STATE_FALL_VALID; Posição válida
    JNC FMG_UPDATE_STATE_FALL_NOT_VALID; Posição inválida
FMG_UPDATE_STATE_FALL_VALID:
    ;Queda válida
    MOV A, fmg_piece_y
    ADD A, #001h ;Cair!!!
    MOV fmg_piece_y, A; Atualiza a posição
    LJMP FMG_UPDATE_STATE_END
FMG_UPDATE_STATE_FALL_NOT_VALID:
    MOV fmg_state, #001h
    LJMP FMG_UPDATE_STATE_END