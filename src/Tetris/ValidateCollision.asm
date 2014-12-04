;Valida o estado atual do jogo, este momento ocorre após a detecção de colisões, e deve:
;   Sortear próxima peça
;   Remover linhas completas
;   Verificar condição de derrota
code
    FMG_VALIDATE_COLLISION:
        MOV DPTR, #FMG_VALIDATE_COLLISION_SWITCH
        MOV A, fmg_state
        MOV B, #003h
        MUL AB
        JMP @A+DPTR
        FMG_VALIDATE_COLLISION_SWITCH:
            JMP FMG_VALIDATE_COLLISION_SWITCH_CONTINUE
            JMP FMG_VALIDATE_COLLISION_SWITCH_COLLISION
        
        FMG_VALIDATE_COLLISION_SWITCH_COLLISION:
            MOV R4, fmg_piece_x
            MOV R5, fmg_piece_y
            LCALL FMG_GET_REGION
            MOV R2, fmg_piece_0
            MOV R3, fmg_piece_1
            MOV A, R2
            XRL A, R6
            MOV R6, A
            
            MOV A, R3
            XRL A, R7
            MOV R7, A
            MOV R4, fmg_piece_x
            MOV R5, fmg_piece_y
            LCALL FMG_SET_REGION
            
            ;Sortear próxima peça
            LCALL FMG_FROM_WAIT_TO_GAME ; Coloca a peça da espera no jogo.
            LCALL FMG_SELECT_NEW_PIECE  ; Seleciona a peça que ficará na espera
            
            MOV fmg_piece_x, #007h
            MOV fmg_piece_y, #000h
            MOV fmg_state, #000h
            ;Remover linhas completas
            ;LCALL FMG_REMOVE_COMPLETE_LINES
        
        FMG_VALIDATE_COLLISION_SWITCH_CONTINUE:
    RET