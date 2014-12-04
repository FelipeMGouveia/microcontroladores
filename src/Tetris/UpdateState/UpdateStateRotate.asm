; Rotaciona a peça para a esquerda e testa se a rotação é possível, em caso afirmativo, rotaciona a mesma.
; Rotacionar a peça para esquerda:
; Subtrair 1 do contador de posição atual em R1 (se maior que zero, senão colocar para o valor máixmo)
; Carregar a nova peça nos registradores R2 e R3
; fmg_piece_H,L,R,0,1
;Rotacionando
MOV A, fmg_piece_x
MOV R4, A
MOV A, fmg_piece_y
MOV R5, A
MOV A, fmg_piece_R ; Carrega a rotação atual para A
JNZ FMG_UPDATE_STATE_LEFT_NOT_ZERO 
    ; IF(A == 0) Rotacionar para o máximo (A - 1 por ser 0 based)
    ; ELSE R1 = A - 1
;Atualização para o caso de ser zero
MOV DPH, fmg_piece_H
MOV DPL, fmg_piece_L
MOV A, #000h
MOVC A, @A+DPTR
SUBB A, #001h; Zero based
MOV R1, A
JMP FMG_UPDATE_STATE_ROTATION_LEFT
FMG_UPDATE_STATE_LEFT_NOT_ZERO: ; Atualiza para o caso de não ser zero
SUBB A, 1
MOV R1, A

FMG_UPDATE_STATE_ROTATION_LEFT:
    LCALL FMG_UPDATE_STATE_CHECK_COLLISION
    JC FMG_UPDATE_STATE_ROTATION_LEFT_VALID; Posição válida
    JNC FMG_UPDATE_STATE_ROTATION_LEFT_NOT_VALID; Posição inválida
FMG_UPDATE_STATE_ROTATION_LEFT_VALID:
    ;Rotação válida
    MOV A, R1
    MOV fmg_piece_R, A; Atualiza a rotação
    MOV DPH, fmg_piece_H
    MOV DPL, fmg_piece_L
    
    MOV A, fmg_piece_R
    MOV B, #002h
    MUL AB
    ADD A, #001h
    MOV R1, A
    ;Coloca em id 0 e 1 qual a peça selecionada
    MOVC A, @A+DPTR ;Representação da peça (primeiros bytes)
    MOV fmg_piece_id_0, A
    MOV A, R1
    ADD A, #001h ;Representação da peça (segundos bytes)
    MOVC A, @A+DPTR
    MOV fmg_piece_id_1, A
    
FMG_UPDATE_STATE_ROTATION_LEFT_NOT_VALID:
    LJMP FMG_UPDATE_STATE_END
    
;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ROTACAO PARA DIREITA ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

; Rotaciona a peça para a direita e testa se a rotação é possível, em caso afirmativo, rotaciona a mesma.
; Rotacionar a peça para direita:
; Adiciona 1 do contador de posição atual em R1 (se menor que máximo, senão colocar para zero)
; Carregar a nova peça nos registradores R2 e R3
; fmg_piece_H,L,R,0,1

;Rotacionando
;MOV A, fmg_piece_x
;MOV R4, A
;MOV A, fmg_piece_y
;MOV R5, A
;MOV DPH, fmg_piece_H
;MOV DPL, fmg_piece_L
;MOV A, #000h
;MOVC A, @A+DPTR;  ;Rotação máxima
;MOV R0, A ; Rotação máxima está em R0
;MOV A, fmg_piece_R ; Carrega a rotação atual para A
;ADD A, #001h ;Rotaciona A
;
;MOV B, A
;SUBB A, R0 ; Verifica se R0 é igual a A
;JNZ FMG_UPDATE_STATE_RIGHT_NOT_MAX ;Se A == B, então resete A, senão continue
;    ;IF (A == B) R1 = 0 
;    ;ELSE R1 = A
;    MOV R1, #000h ; Coloca 0 em R1.
;    JMP FMG_UPDATE_STATE_ROTATION_RIGHT
;
;    FMG_UPDATE_STATE_RIGHT_NOT_MAX:
;    MOV A, B
;    MOV R1, A; Coloca a nova rotação em R1.
;
;FMG_UPDATE_STATE_ROTATION_RIGHT:
;    LCALL FMG_UPDATE_STATE_CHECK_COLLISION
;    JC FMG_UPDATE_STATE_ROTATION_RIGHT_VALID; Posição válida
;    JNC FMG_UPDATE_STATE_ROTATION_RIGHT_NOT_VALID; Posição inválida
;FMG_UPDATE_STATE_ROTATION_RIGHT_VALID:
;    ;Rotação válida
;    MOV A, R1
;    MOV fmg_piece_R, A; Atualiza a rotação
;FMG_UPDATE_STATE_ROTATION_RIGHT_NOT_VALID:
;    LJMP FMG_UPDATE_STATE_END