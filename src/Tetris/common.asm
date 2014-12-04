;Posi��o da pe�a na tela (Canto superior esquerdo da mesma).
fmg_piece_x SET 023h
fmg_piece_y SET 024h ;Y(0) implica em -4 na tela, s� a partir de Y(4) que com certeza a pe�a estar� na tela
;Representar as pe�as por 3 bytes, onde os 2 primeiros s�o o endere�o da pe�a na mem�ria, e o terceiro
;seria o valor atual da pe�a em fun��o da rota��o.

;Informa��es com rela��o a pe�a que est� na espera.
fmg_piece_id_H SET 025h ;Ender�os da pe�a
fmg_piece_id_L SET 026h
fmg_piece_id_R SET 027h; Cada pe�a na mem�ria possui na posi��o 0 a quantidade de rota��es que a mesma possui
fmg_piece_id_0 SET 028h
fmg_piece_id_1 SET 029h

;Informa��es com rela��o a pe�a que est� em uso.
fmg_piece_H SET 02Ah
fmg_piece_L SET 02Bh
fmg_piece_R SET 02Ch
fmg_piece_0 SET 02Dh
fmg_piece_1 SET 02Eh

fmg_state SET 02Fh ;Estado corrente do jogo
    ;0 - Jogo em andamento
    ;1 - Colis�o (Ocorreu uma colis�o, remover linhas, verificar se o jogo continua, sortear nova pe�a e continuar o jogo).
    ;2 - Fim do jogo
fmg_control SET 030h ; Estado de controles do jogo, deve ser utilizado para os bot�es
fmg_control_old SET 031h ;Estado anterior, utilizado para n�o ter repeti��o de comandos
    ;0  - Nada a fazer
    ;1  - Mover para esquerda
    ;2  - Mover para direita
    ;3  - Rotacionar
    ;4  - Cair

fmg_time_to_fall_0 SET 032h ;Tempo at� a pr�xima queda, menos significativo
fmg_time_to_fall SET 033h ;Tempo que o fmg_time_to_fall_0 deve atingir para ocorrer a queda

fmg_score_0 SET 034h ;Pontua��o inferior
fmg_score_1 SET 035h ;Pontua��o superior

;Posi��o de mem�ria base para a grade
fmg_grid SET 040h

code
    ;Fonte num�rica 3x5
    FMG_NUMBERS_FONT: DB 01Fh, 011h, 01Fh, 009h, 01Fh, 001h, 009h, 013h, 01Dh, 011h, 015h, 00Ah, 01Ch, 004h, 01Fh, 01Ch, 015h, 012h, 01Fh, 015h, 017h, 010h, 017h, 018h, 01FH, 015H, 01Fh, 01Ch, 014h, 01Fh

    ;Cada pe�a � definida por um par de bytes onde os bits mais significativos representam 
    ;a coluna impares(3 e 1), e os menos significativos representam as colunas pares (2 e 0)
    ;As pe�as s�o centralziadas, quando n�o for poss�vel ser�o alinhadas a esquerda e abaixo.
    ;Ordem das pe�as:
    ;  I, O, S, Z, L, J, T
    ;  I:  1  2
    ;  O:  3
    ;  S:  4  5
    ;  Z:  6  7
    ;  L:  8  9 10 11
    ;  J: 12 13 14 15
    ;  T: 16 17 18 19
    code
    FMG_PIECES_I: DB 002h, 00Fh, 000h, 022h, 022h
    code
    FMG_PIECES_O: DB 001h, 006h, 060h
    code
    FMG_PIECES_S: DB 002h, 026h, 040h, 006h, 030h
    code
    FMG_PIECES_Z: DB 002h, 046h, 020h, 003h, 060h
    code
    FMG_PIECES_L: DB 004h, 00Eh, 020h, 006h, 044h, 008h, 0E0h, 022h, 060h
    code
    FMG_PIECES_J: DB 004h, 002h, 0E0h, 062h, 020h, 00Eh, 080h, 044h, 060h
    code
    FMG_PIECES_T: DB 004h, 026h, 020h, 007h, 020h, 023h, 020h, 002h, 070h

; A grade ser� todo o espa�o localizado na posi��o de mem�ria definido entre X e Y (25 posi��es), 
; representado da seguinte maneira: 
; X00L X00H X01L X01H X02L X02H X03L X03H X04L X04H
; X05H X06H X07H X08H X09H X10H X11H X12H X13H X14H
; X05L X06L X07L X08L X09L X10L X11L X12L X13L X14L
; X15H X16H X17H X18H X19H X20H X21H X22H X23H X24H
; X15L X16L X17L X18L X19L X20L X21L X22L X23L X24L
; XNNH significa os 4 bits mais significativos do byte NN no vetor X (posi��o de mem�ria base).
; XNNL significa os 4 bits menos significativos do byte NN no vetor X (posi��o de mem�ria base).
