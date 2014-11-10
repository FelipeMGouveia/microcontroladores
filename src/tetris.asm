;Posi��o da pe�a na tela (Canto superior esquerdo da mesma).
fmg_piece_x SET 0x23
fmg_piece_y SET 0x24 ;Y(0) implica em -4 na tela, s� a partir de Y(4) que com certeza a pe�a estar� na tela
;Representar as pe�as por 3 bytes, onde os 2 primeiros s�o o endere�o da pe�a na mem�ria, e o terceiro
;seria o valor atual da pe�a em fun��o da rota��o.

;Informa��es com rela��o a pe�a que est� na espera.
fmg_piece_id_H SET 0x25
fmg_piece_id_L SET 0x26
fmg_piece_id_R SET 0x27 ; Cada pe�a na mem�ria possui na posi��o 0 a quantidade de rota��es que a mesma possui
fmg_piece_id_0 SET 0x28
fmg_piece_id_1 SET 0x29

;Informa��es com rela��o a pe�a que est� em uso.
fmg_piece_H SET 0x2A
fmg_piece_L SET 0x2B
fmg_piece_R SET 0x2C
fmg_piece_0 SET 0x2D
fmg_piece_1 SET 0x2E

;Posi��o de mem�ria base para a grade
fmg_grid SET 0x40

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

code
;Main tetris
code
FMG_TETRIS_MAIN:
    LCALL LCD_CLEAR
    
    ;Inicialia��o de um novo jogo!    
    LCALL FMG_CLEAR_MEMORY ;Limpar mem�ria
    LCALL FMG_DRAW_BORDER  ;Desenhar borda do tabuleiro
    LCALL FMG_DRAW_SCREEN  ;Desenhar estado do tabuleiro
    
    ;Selecionar pr�xima pe�a
    LCALL FMG_SELECT_NEW_PIECE  ; Selecionar nova pe�a
    LCALL FMG_FROM_WAIT_TO_GAME ; Coloca a pe�a da espera no jogo.
    LCALL FMG_SELECT_NEW_PIECE  ; Seleciona a pe�a que ficar� na espera
    
    ;Move a pe�a para a posi��o central no topo
    MOV fmg_piece_x, #028h
    MOV fmg_piece_y, #000h
    
    LCALL FMG_DRAW_NEXT_PIECE ; Desenha a pe�a que est� na espera
    
    ;Loop de um jogo corrente.
    RET

code 
    FMG_DRAW_NEXT_PIECE:
    PUSH PSW
    SETB RS1
    CLR RS0
    MOV lcd_X, #017h
    MOV lcd_Y, #000h
    LCALL LCD_XY
    MOV lcd_bus, #003h
    LCALL LCD_DRAW
    
    MOV R4, #00Ah
    FMG_DRAW_NEXT_PIECE_TOP:
        MOV lcd_bus, #002h
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_NEXT_PIECE_TOP
        
    MOV lcd_bus, #003h
    LCALL LCD_DRAW
    
    MOV R3, fmg_piece_id_0
    MOV R4, #002h
    
    MOV lcd_X, #017h
    MOV lcd_Y, #001h
    LCALL LCD_XY
    
    MOV lcd_bus, #0FFh
    LCALL LCD_DRAW
    MOV lcd_bus, #000h
    LCALL LCD_DRAW
    
    FMG_DRAW_NEXT_PIECE_INTERNAL:
        MOV A, R3 ; Desenha a pr�xima pe�a
        MOV R1, A
        MOV ACC, @R1
            
        MOV C, ACC.3
        MOV ACC.7, C
        MOV ACC.6, C
        MOV C, ACC.2
        MOV ACC.5, C
        MOV ACC.4, C
        MOV C, ACC.1
        MOV ACC.3, C
        MOV ACC.2, C
        MOV C, ACC.0
        MOV ACC.1, C

        MOV lcd_bus, ACC; primeiro draw
        LCALL LCD_DRAW
        MOV lcd_bus, ACC; segundo draw
        LCALL LCD_DRAW

        MOV A, R3; Desenha bytes inferiores
        MOV R1, A
        MOV ACC, @R1
        
        MOV C, ACC.4
        MOV ACC.0, C
        MOV ACC.1, C
        MOV C, ACC.5
        MOV ACC.2, C
        MOV ACC.3, C
        MOV C, ACC.6
        MOV ACC.4, C
        MOV ACC.5, C
        MOV C, ACC.7
        MOV ACC.6, C

        MOV lcd_bus, ACC; primeiro draw
        LCALL LCD_DRAW
        MOV lcd_bus, ACC; segundo draw
        LCALL LCD_DRAW
        
        MOV R3, fmg_piece_id_1
        DJNZ R4, FMG_DRAW_NEXT_PIECE_INTERNAL
    
    MOV lcd_bus, #000h
    LCALL LCD_DRAW
    MOV lcd_bus, #0FFh
    LCALL LCD_DRAW
    
    MOV lcd_X, #017h
    MOV lcd_Y, #002h
    LCALL LCD_XY
    MOV lcd_bus, #0C0h
    LCALL LCD_DRAW
    
    MOV R4, #00Ah
    FMG_DRAW_NEXT_PIECE_BOTTOM:
        MOV lcd_bus, #040h
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_NEXT_PIECE_BOTTOM
    MOV lcd_bus, #0C0h
    LCALL LCD_DRAW    
    RET

code
FMG_FROM_WAIT_TO_GAME:
    MOV A, fmg_piece_id_H
    MOV fmg_piece_H, A
    
    MOV A, fmg_piece_id_L
    MOV fmg_piece_L, A
    
    MOV A, fmg_piece_id_R
    MOV fmg_piece_R, A
    
    MOV A, fmg_piece_id_0
    MOV fmg_piece_0, A
    
    MOV A, fmg_piece_id_1
    MOV fmg_piece_1, A
    RET

code
FMG_SELECT_NEW_PIECE:
    LCALL RAND8
    MOV B, #007h
    DIV AB; Capturando apenas as 8 possiveis pe�as (temos 7 pe�as portanto um dos valores sera desconsiderado)
    MOV A, B
    MOV DPTR, #FMG_SELECT_PIECE_SWITCH
    JMP @A+DPTR
    FMG_SELECT_PIECE_SWITCH:
        JMP FMG_SELECT_PIECE_I
        JMP FMG_SELECT_PIECE_O
        JMP FMG_SELECT_PIECE_S
        JMP FMG_SELECT_PIECE_Z
        JMP FMG_SELECT_PIECE_L
        JMP FMG_SELECT_PIECE_J
        JMP FMG_SELECT_PIECE_T
    FMG_SELECT_PIECE_O:
        MOV DPTR, #FMG_PIECES_O
        SJMP FMG_SELECT_NEW_PIECE_END
    FMG_SELECT_PIECE_S:
        MOV DPTR, #FMG_PIECES_S
        SJMP FMG_SELECT_NEW_PIECE_END
    FMG_SELECT_PIECE_Z:
        MOV DPTR, #FMG_PIECES_Z
        SJMP FMG_SELECT_NEW_PIECE_END
    FMG_SELECT_PIECE_L:
        MOV DPTR, #FMG_PIECES_L
        SJMP FMG_SELECT_NEW_PIECE_END
    FMG_SELECT_PIECE_J:
        MOV DPTR, #FMG_PIECES_J
        SJMP FMG_SELECT_NEW_PIECE_END
    FMG_SELECT_PIECE_T:
        MOV DPTR, #FMG_PIECES_T
        SJMP FMG_SELECT_NEW_PIECE_END
    FMG_SELECT_PIECE_I:
        ;Escolhe qual vai ser a pe�a
        MOV DPTR, #FMG_PIECES_I
        SJMP FMG_SELECT_NEW_PIECE_END
    ;Parte final da rotina, com a pe�a correta selecionada, devemos escolher qual a rota��o inidial da mesma e
    ;popular as vari�veis de ambiente com ela.
    FMG_SELECT_NEW_PIECE_END:
        ;Salva a pe�a escolhida na mem�ria
        MOV fmg_piece_id_H, DPH
        MOV fmg_piece_id_L, DPL
        MOVC A, @A+DPTR ; Quantidade de rota��es da pe�a
        MOV B, A ; Coloca em B a quantidade de rota��es da pe�a
        LCALL RAND8
        DIV AB
        MOV A, B ;Escolhendo a rota��o
        MOV fmg_piece_id_R, A ;Coloca a posi��o da pe�a rotacionada no id 2
        MOV B, #002h
        MUL AB ; Multiplico por 2 para ir para a pe�a correta
        ADD A, #001h ;Soma 1 j� que o primeiro valor contem a quantidade de rota��es da pe�a
        MOV R1, A
        ;Coloca em id 0 e 1 qual a pe�a selecionada
        MOVC A, @A+DPTR ;Representa��o da pe�a (primeiros bytes)
        MOV fmg_piece_id_0, A
        MOV A, R1
        ADD A, #001h ;Representa��o da pe�a (segundos bytes)
        MOVC A, @A+DPTR
        MOV fmg_piece_id_1, A
    RET

code
FMG_CLEAR_MEMORY:
    MOV R1, #024h
    MOV R0, fmg_grid
    FMG_CLEAR_MEMORY_LOOP:
        MOV @R0, #000h
        MOV A, R0
        ADD A, #001h
        MOV R0, A
        DJNZ R1, FMG_CLEAR_MEMORY_LOOP
    ret

;Desenha o grade na tela
code
FMG_DRAW_SCREEN:
    ;Desenhar na tela significa pegar os bytes definidos no grade e passar para a tela, lembrando que ser� usado um fator de 2x.
    PUSH PSW
    SETB RS1
    CLR RS0
    MOV lcd_X, #021h
    MOV lcd_Y, #000h
    LCALL LCD_XY
    MOV R4, #005h
    MOV R3, #fmg_grid
    FMG_LOOP_LINHA_SUPERIOR:
        MOV A, R3; Move o conte�do de R1 para o acumulador
        MOV R1, A
        MOV ACC, @R1
        
        MOV C, ACC.3
        MOV ACC.7, C
        MOV ACC.6, C
        MOV C, ACC.2
        MOV ACC.5, C
        MOV ACC.4, C
        MOV C, ACC.1
        MOV ACC.3, C
        MOV ACC.2, C
        MOV C, ACC.0
        MOV ACC.1, C

        MOV lcd_bus, ACC; primeiro draw
        LCALL LCD_DRAW
        MOV lcd_bus, ACC; segundo draw
        LCALL LCD_DRAW

        MOV A, R3; Move o conte�do de R1 para o acumulador
        MOV R1, A
        MOV ACC, @R1
        
        MOV C, ACC.4
        MOV ACC.0, C
        MOV ACC.1, C
        MOV C, ACC.5
        MOV ACC.2, C
        MOV ACC.3, C
        MOV C, ACC.6
        MOV ACC.4, C
        MOV ACC.5, C
        MOV C, ACC.7
        MOV ACC.6, C

        MOV lcd_bus, ACC; primeiro draw
        LCALL LCD_DRAW
        MOV lcd_bus, ACC; segundo draw
        LCALL LCD_DRAW
        
        MOV A, R3
        ADD A, #001h
        MOV R3, A
        DJNZ R4, FMG_LOOP_LINHA_SUPERIOR    
    ; Mover o ponteiro do LCD para o local desejado, para cada coluna desenhar a mesma 2 vezes.
    MOV lcd_X, #021h
    MOV lcd_Y, #001h
    LCALL LCD_XY
    MOV R6, #002h
    MOV lcd_Y, #001h
    FMG_LOOP_LINHA_3:
    MOV R4, #00Ah
    MOV R5, #021h
    FMG_LOOP_LINHA_2:
        MOV A, R5
        MOV lcd_X, A
        ;MOV lcd_Y, A
        LCALL LCD_XY

        MOV A, R3; Move o conte�do de R1 para o acumulador
        MOV R1, A
        MOV ACC, @R1
        
        MOV C, ACC.3
        MOV ACC.7, C
        MOV ACC.6, C
        MOV C, ACC.2
        MOV ACC.5, C
        MOV ACC.4, C
        MOV C, ACC.1
        MOV ACC.3, C
        MOV ACC.2, C
        MOV C, ACC.0
        MOV ACC.1, C
        
        MOV lcd_bus, ACC; primeiro draw
        LCALL LCD_DRAW

        MOV lcd_bus, ACC; segundo draw
        LCALL LCD_DRAW
        
        MOV A, R5
        MOV lcd_X, A
        
        MOV A, lcd_Y
        ADD A, #001h
        MOV lcd_Y, A
        LCALL LCD_XY
        
        MOV A, R3; Move o conte�do de R1 para o acumulador
        MOV R1, A
        MOV ACC, @R1
        
        MOV C, ACC.4
        MOV ACC.0, C
        MOV ACC.1, C
        MOV C, ACC.5
        MOV ACC.2, C
        MOV ACC.3, C
        MOV C, ACC.6
        MOV ACC.4, C
        MOV ACC.5, C
        MOV C, ACC.7
        MOV ACC.6, C

        MOV lcd_bus, ACC; primeiro draw
        LCALL LCD_DRAW
        MOV lcd_bus, ACC; segundo draw
        LCALL LCD_DRAW
        
        MOV A, R3
        ADD A, #001h
        MOV R3, A
        
        MOV A, R5
        ADD A, #002h
        MOV R5, A
        
        MOV A, lcd_Y
        SUBB A, #001h
        MOV lcd_Y, A
        
        DJNZ R4, FMG_LOOP_LINHA_2
        MOV lcd_Y, #003h
        DJNZ R6, FMG_LOOP_LINHA_3
        POP PSW
    ret
 
code
FMG_DRAW_BORDER:
    PUSH PSW
    SETB RS1
    CLR RS0
    
    MOV lcd_X, #020h
    MOV lcd_Y, #000h
    LCALL LCD_XY
    
    MOV R3, #005h
    FMG_DRAW_BORDER_LOOP_EXTERNAL:
        MOV R4, #016h
        FMG_DRAW_BORDER_LOOP:
            MOV lcd_bus, #0FFh
            LCALL LCD_DRAW
            DJNZ R4, FMG_DRAW_BORDER_LOOP
        MOV lcd_X, #020h
        MOV A, lcd_Y
        ADD A, #001h
        MOV lcd_y, A
        LCALL LCD_XY
    DJNZ R3, FMG_DRAW_BORDER_LOOP_EXTERNAL
    
    MOV lcd_X, #020h
    MOV lcd_Y, #005h
    LCALL LCD_XY
    
    MOV R3, #016h
    FMG_DRAW_BORDER_LOOP_BOTTOM:
        MOV lcd_bus, #001h
        LCALL LCD_DRAW
        DJNZ R3, FMG_DRAW_BORDER_LOOP_BOTTOM
    POP PSW
    ret