code
FMG_FROM_WAIT_TO_GAME:
    MOV A, fmg_piece_id_H
    MOV R0, #fmg_piece_H
    MOV @R0, A
    
    MOV A, fmg_piece_id_L
    MOV R0, #fmg_piece_L
    MOV @R0, A
    
    MOV A, fmg_piece_id_R
    MOV R0, #fmg_piece_R
    MOV @R0, A
    
    MOV A, fmg_piece_id_0
    MOV R0, #fmg_piece_0
    MOV @R0, A
    
    MOV A, fmg_piece_id_1
    MOV R0, #fmg_piece_1
    MOV @R0, A
    RET