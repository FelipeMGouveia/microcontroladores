;Checa se uma determinada posição de peça é válida.
; in R1 = Rotação da peça a ser checada
; in R4 = Posição X a ser checada
; in R5 = Posição Y a ser checada
; out C | 0 Posição/Rotação inválida
;       | 1 Posição/Rotação válida
code
    FMG_UPDATE_STATE_CHECK_COLLISION:
    ;Carrega a peça para os registradores R2 e R3
    ; R1 contem a rotação da peça
    MOV DPH, fmg_piece_H
    MOV DPL, fmg_piece_L
    MOV A, R1
    MOV B, #002h ;Cada peça é representada por 2 bytes
    MUL AB
    ADD A, #001h ;Retira o contador de peças
    MOVC A, @A+DPTR
    ;A está com a posição da peça na memória
    MOV R2, A
    MOV A, R1
    MOV B, #002h ; Cada peça é representada por 2 bytes
    MUL AB
    ADD A, #002h ; 1 para o contador e 1 para pegar o segundo byte da peça
    MOVC A, @A+DPTR
    MOV R3, A
    ;R2 possui os primeiros bytes (esquerda)
    ;R3 possui os outros bytes (direita)
    LCALL FMG_GET_REGION
    ;R6 e R7 contem a informação sobre a região, 
    ;só fazer o XOR e sei se a posição está ocupada (movimento inválido), ou não;
    MOV A, R2
    XRL A, R6 ; Xor entre R2 e R6
    SUBB A, R2 ; Se não ocorreu nenhuma colisão a subtração por R2 e R6 deve retornar Zero
    SUBB A, R6
    JZ FMG_UPDATE_STATE_CHECK_COLLISION_TEST_R7
    JMP FMG_UPDATE_STATE_CHECK_COLLISION_COLLISION
    FMG_UPDATE_STATE_CHECK_COLLISION_TEST_R7:
        MOV A, R3
        XRL A, R7;Xor entre R2 e R6
        SUBB A, R3 ; Se não ocorreu nenhuma colisão a subtração por R3 e R7 deve retornar Zero
        SUBB A, R7    
        JZ FMG_UPDATE_STATE_CHECK_COLLISION_NOT_COLLISION
        JMP FMG_UPDATE_STATE_CHECK_COLLISION_COLLISION
        FMG_UPDATE_STATE_CHECK_COLLISION_COLLISION: ;Se tiver colisão então vá para o fim!
            CLR C
            JMP FMG_UPDATE_STATE_CHECK_COLLISION_END
        FMG_UPDATE_STATE_CHECK_COLLISION_NOT_COLLISION: ; Se não tiver colisão, atualize a posição da peça!
            SETB C
            JMP FMG_UPDATE_STATE_CHECK_COLLISION_END
        FMG_UPDATE_STATE_CHECK_COLLISION_END:
    RET