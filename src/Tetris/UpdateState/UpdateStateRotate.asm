; Rotaciona a pe�a para a esquerda e testa se a rota��o � poss�vel, em caso afirmativo, rotaciona a mesma.
; Rotacionar a pe�a para esquerda:
; Subtrair 1 do contador de posi��o atual em R1 (se maior que zero, sen�o colocar para o valor m�ixmo)
; Carregar a nova pe�a nos registradores R2 e R3
; fmg_piece_H,L,R,0,1
;Rotacionando
MOV A, fmg_piece_x
MOV R4, A
MOV A, fmg_piece_y
MOV R5, A
MOV A, fmg_piece_R ; Carrega a rota��o atual para A
JNZ FMG_UPDATE_STATE_LEFT_NOT_ZERO 
    ; IF(A == 0) Rotacionar para o m�ximo (A - 1 por ser 0 based)
    ; ELSE R1 = A - 1
;Atualiza��o para o caso de ser zero
MOV DPH, fmg_piece_H
MOV DPL, fmg_piece_L
MOV A, #000h
MOVC A, @A+DPTR
SUBB A, #001h; Zero based
MOV R1, A
JMP FMG_UPDATE_STATE_ROTATION_LEFT
FMG_UPDATE_STATE_LEFT_NOT_ZERO: ; Atualiza para o caso de n�o ser zero
SUBB A, 1
MOV R1, A

FMG_UPDATE_STATE_ROTATION_LEFT:
    LCALL FMG_UPDATE_STATE_CHECK_COLLISION
    JC FMG_UPDATE_STATE_ROTATION_LEFT_VALID; Posi��o v�lida
    JNC FMG_UPDATE_STATE_ROTATION_LEFT_NOT_VALID; Posi��o inv�lida
FMG_UPDATE_STATE_ROTATION_LEFT_VALID:
    ;Rota��o v�lida
    MOV A, R1
    MOV fmg_piece_R, A; Atualiza a rota��o
    MOV DPH, fmg_piece_H
    MOV DPL, fmg_piece_L
    
    MOV A, fmg_piece_R
    MOV B, #002h
    MUL AB
    ADD A, #001h
    MOV R1, A
    ;Coloca em id 0 e 1 qual a pe�a selecionada
    MOVC A, @A+DPTR ;Representa��o da pe�a (primeiros bytes)
    MOV fmg_piece_id_0, A
    MOV A, R1
    ADD A, #001h ;Representa��o da pe�a (segundos bytes)
    MOVC A, @A+DPTR
    MOV fmg_piece_id_1, A
    
FMG_UPDATE_STATE_ROTATION_LEFT_NOT_VALID:
    LJMP FMG_UPDATE_STATE_END
    
;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ROTACAO PARA DIREITA ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

; Rotaciona a pe�a para a direita e testa se a rota��o � poss�vel, em caso afirmativo, rotaciona a mesma.
; Rotacionar a pe�a para direita:
; Adiciona 1 do contador de posi��o atual em R1 (se menor que m�ximo, sen�o colocar para zero)
; Carregar a nova pe�a nos registradores R2 e R3
; fmg_piece_H,L,R,0,1

;Rotacionando
;MOV A, fmg_piece_x
;MOV R4, A
;MOV A, fmg_piece_y
;MOV R5, A
;MOV DPH, fmg_piece_H
;MOV DPL, fmg_piece_L
;MOV A, #000h
;MOVC A, @A+DPTR;  ;Rota��o m�xima
;MOV R0, A ; Rota��o m�xima est� em R0
;MOV A, fmg_piece_R ; Carrega a rota��o atual para A
;ADD A, #001h ;Rotaciona A
;
;MOV B, A
;SUBB A, R0 ; Verifica se R0 � igual a A
;JNZ FMG_UPDATE_STATE_RIGHT_NOT_MAX ;Se A == B, ent�o resete A, sen�o continue
;    ;IF (A == B) R1 = 0 
;    ;ELSE R1 = A
;    MOV R1, #000h ; Coloca 0 em R1.
;    JMP FMG_UPDATE_STATE_ROTATION_RIGHT
;
;    FMG_UPDATE_STATE_RIGHT_NOT_MAX:
;    MOV A, B
;    MOV R1, A; Coloca a nova rota��o em R1.
;
;FMG_UPDATE_STATE_ROTATION_RIGHT:
;    LCALL FMG_UPDATE_STATE_CHECK_COLLISION
;    JC FMG_UPDATE_STATE_ROTATION_RIGHT_VALID; Posi��o v�lida
;    JNC FMG_UPDATE_STATE_ROTATION_RIGHT_NOT_VALID; Posi��o inv�lida
;FMG_UPDATE_STATE_ROTATION_RIGHT_VALID:
;    ;Rota��o v�lida
;    MOV A, R1
;    MOV fmg_piece_R, A; Atualiza a rota��o
;FMG_UPDATE_STATE_ROTATION_RIGHT_NOT_VALID:
;    LJMP FMG_UPDATE_STATE_END