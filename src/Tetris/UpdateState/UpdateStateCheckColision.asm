;Checa se uma determinada posi��o de pe�a � v�lida.
; in R1 = Rota��o da pe�a a ser checada
; in R4 = Posi��o X a ser checada
; in R5 = Posi��o Y a ser checada
; out C | 0 Posi��o/Rota��o inv�lida
;       | 1 Posi��o/Rota��o v�lida
code
    FMG_UPDATE_STATE_CHECK_COLLISION:
    ;Carrega a pe�a para os registradores R2 e R3
    ; R1 contem a rota��o da pe�a
    MOV DPH, fmg_piece_H
    MOV DPL, fmg_piece_L
    MOV A, R1
    MOV B, #002h ;Cada pe�a � representada por 2 bytes
    MUL AB
    ADD A, #001h ;Retira o contador de pe�as
    MOVC A, @A+DPTR
    ;A est� com a posi��o da pe�a na mem�ria
    MOV R2, A
    MOV A, R1
    MOV B, #002h ; Cada pe�a � representada por 2 bytes
    MUL AB
    ADD A, #002h ; 1 para o contador e 1 para pegar o segundo byte da pe�a
    MOVC A, @A+DPTR
    MOV R3, A
    ;R2 possui os primeiros bytes (esquerda)
    ;R3 possui os outros bytes (direita)
    LCALL FMG_GET_REGION
    ;R6 e R7 contem a informa��o sobre a regi�o, 
    ;s� fazer o XOR e sei se a posi��o est� ocupada (movimento inv�lido), ou n�o;
    MOV A, R2
    XRL A, R6 ; Xor entre R2 e R6
    SUBB A, R2 ; Se n�o ocorreu nenhuma colis�o a subtra��o por R2 e R6 deve retornar Zero
    SUBB A, R6
    JZ FMG_UPDATE_STATE_CHECK_COLLISION_TEST_R7
    JMP FMG_UPDATE_STATE_CHECK_COLLISION_COLLISION
    FMG_UPDATE_STATE_CHECK_COLLISION_TEST_R7:
        MOV A, R3
        XRL A, R7;Xor entre R2 e R6
        SUBB A, R3 ; Se n�o ocorreu nenhuma colis�o a subtra��o por R3 e R7 deve retornar Zero
        SUBB A, R7    
        JZ FMG_UPDATE_STATE_CHECK_COLLISION_NOT_COLLISION
        JMP FMG_UPDATE_STATE_CHECK_COLLISION_COLLISION
        FMG_UPDATE_STATE_CHECK_COLLISION_COLLISION: ;Se tiver colis�o ent�o v� para o fim!
            CLR C
            JMP FMG_UPDATE_STATE_CHECK_COLLISION_END
        FMG_UPDATE_STATE_CHECK_COLLISION_NOT_COLLISION: ; Se n�o tiver colis�o, atualize a posi��o da pe�a!
            SETB C
            JMP FMG_UPDATE_STATE_CHECK_COLLISION_END
        FMG_UPDATE_STATE_CHECK_COLLISION_END:
    RET