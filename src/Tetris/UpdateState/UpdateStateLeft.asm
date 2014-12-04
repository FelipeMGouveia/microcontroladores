;Carrega a posi��o X e Y para R4 e R5
MOV A, fmg_piece_x
SUBB A, #001h
MOV R4, A
MOV A, fmg_piece_y
MOV R5, A

;Carrega a rota��o para R1
MOV A, fmg_piece_R
MOV R1, A

FMG_UPDATE_STATE_LEFT:
    LCALL FMG_UPDATE_STATE_CHECK_COLLISION
    JC FMG_UPDATE_STATE_LEFT_VALID; Posi��o v�lida
    JNC FMG_UPDATE_STATE_LEFT_NOT_VALID; Posi��o inv�lida
FMG_UPDATE_STATE_LEFT_VALID:
    ;Rota��o v�lida
    MOV A, fmg_piece_x
    SUBB A, #001h
    MOV fmg_piece_x, A; Atualiza a posi��o
FMG_UPDATE_STATE_LEFT_NOT_VALID:
    LJMP FMG_UPDATE_STATE_END