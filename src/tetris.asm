;Posição da peça na tela (Canto superior esquerdo da mesma).
fmg_piece_x SET 0x23
fmg_piece_y SET 0x24 ;Y(0) implica em -4 na tela, só a partir de Y(4) que com certeza a peça estará na tela
;Representar as peças por 3 bytes, onde os 2 primeiros são o endereço da peça na memória, e o terceiro
;seria o valor atual da peça em função da rotação.

;Informações com relação a peça que está na espera.
fmg_piece_id_H SET 0x25 ;Enderços da peça
fmg_piece_id_L SET 0x26
fmg_piece_id_R SET 0x27 ; Cada peça na memória possui na posição 0 a quantidade de rotações que a mesma possui
fmg_piece_id_0 SET 0x28
fmg_piece_id_1 SET 0x29

;Informações com relação a peça que está em uso.
fmg_piece_H SET 0x2A
fmg_piece_L SET 0x2B
fmg_piece_R SET 0x2C
fmg_piece_0 SET 0x2D
fmg_piece_1 SET 0x2E

fmg_state SET 0x2F ;Estado corrente do jogo
fmg_control SET 0x30 ; Estado de controles do jogo, deve ser utilizado para os botões
fmg_control_old SET 0x31 ;Estado anterior, utilizado para não ter repetição de comandos
    ;0 - Nada a fazer
    ;1 - Mover para esquerda
    ;2 - Mover para direita
    ;3 - Rotacionar
    ;4 - Cair

;Posição de memória base para a grade
fmg_grid SET 0x40

code
    ;Fonte numérica 3x5
    FMG_NUMBERS_FONT: DB 01Fh, 011h, 01Fh, 009h, 01Fh, 001h, 009h, 013h, 01Dh, 011h, 015h, 00Ah, 01Ch, 004h, 01Fh, 01Ch, 015h, 012h, 01Fh, 015h, 017h, 010h, 017h, 018h, 01FH, 015H, 01Fh, 01Ch, 014h, 01Fh

    ;Cada peça é definida por um par de bytes onde os bits mais significativos representam 
    ;a coluna impares(3 e 1), e os menos significativos representam as colunas pares (2 e 0)
    ;As peças são centralziadas, quando não for possível serão alinhadas a esquerda e abaixo.
    ;Ordem das peças:
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

; A grade será todo o espaço localizado na posição de memória definido entre X e Y (25 posições), 
; representado da seguinte maneira: 
; X00L X00H X01L X01H X02L X02H X03L X03H X04L X04H
; X05H X06H X07H X08H X09H X10H X11H X12H X13H X14H
; X05L X06L X07L X08L X09L X10L X11L X12L X13L X14L
; X15H X16H X17H X18H X19H X20H X21H X22H X23H X24H
; X15L X16L X17L X18L X19L X20L X21L X22L X23L X24L
; XNNH significa os 4 bits mais significativos do byte NN no vetor X (posição de memória base).
; XNNL significa os 4 bits menos significativos do byte NN no vetor X (posição de memória base).

code
;Main tetris
code
FMG_TETRIS_MAIN:
    LCALL LCD_CLEAR
    
    ;Inicialiação de um novo jogo!    
    LCALL FMG_CLEAR_MEMORY ;Limpar memória
    LCALL FMG_DRAW_BORDER  ;Desenhar borda do tabuleiro
    LCALL FMG_DRAW_SCREEN  ;Desenhar estado do tabuleiro
    
    ;Selecionar próxima peça
    LCALL FMG_SELECT_NEW_PIECE  ; Selecionar nova peça
    LCALL FMG_FROM_WAIT_TO_GAME ; Coloca a peça da espera no jogo.
    LCALL FMG_SELECT_NEW_PIECE  ; Seleciona a peça que ficará na espera
    
    ;Move a peça para a posição central no topo
    MOV fmg_piece_x, #028h
    MOV fmg_piece_y, #000h
    
    LCALL FMG_DRAW_NEXT_PIECE ; Desenha a peça que está na espera

    ;Loop de um jogo corrente.
    LCALL FMG_UPDATE_STATE ; Atualiza o estado atual do jogo
    LCALL FMG_DRAW_SCREEN ; Desenha o jogo atual
    
    RET

code 
    FMG_UPDATE_STATE:
    ;Verificar no controle se tem alguma tecla prescionada
    ;Caso tenha, fazer a rotina correspondente
    MOV A, fmg_control ;Coloca o controle no acumulador
    MOV B, fmg_control_old ;Coloca a versão antiga do controle no acumulador B
    
    MOV DPTR, #FMG_UPDATE_STATE_SWITCH_CONTROL
    FMG_UPDATE_STATE_SWITCH_CONTROL:
        JMP FMG_UPDATE_STATE_NOTHING
        JMP FMG_UPDATE_STATE_LEFT
        JMP FMG_UPDATE_STATE_RIGHT
        JMP FMG_UPDATE_STATE_ROTATE
        JMP FMG_UPDATE_STATE_FALL
    FMG_UPDATE_STATE_LEFT:
    ; Rotaciona a peça para a esquerda e testa se a rotação é possível, em caso afirmativo, rotaciona
    ; Rotacionar a peça para esquerda:
        ; Subtrair 1 do contador de posição atual em R1 (se maior que zero, senão colocar para o valor máixmo)
        ; Carregar a nova peça nos registradores R2 e R3
        ; fmg_piece_H,L,R,0,1
        MOV A, fmg_piece_R ; Carrega a rotação atual para A
        JNZ FMG_UPDATE_STATE_LEFT_NOT_ZERO
        ;Atualização para o caso de ser zero
        MOV DPH, fmg_piece_H
        MOV DPL, fmg_piece_L
        MOV A, #000h
        MOVC A, @A+DPTR
        MOV R1, A
        JMP FMG_UPDATE_STATE_LEFT_END
        FMG_UPDATE_STATE_LEFT_NOT_ZERO: ; Atualiza para o caso de não ser zero
            SUBB A, 1
            MOV R1, A
        FMG_UPDATE_STATE_LEFT_END:
            ;Carrega a peça para os registradores R2 e R3
            ; R1 contem a rotação da peça
            MOV DPH, fmg_piece_H
            MOV DPL, fmg_piece_L
            MOV A, R1
            MOVC A, @A+DPTR
            ;A está com a posição da peça na memória
            MOV R2, A
            MOV A, R1
            ADD A, #001h
            MOVC A, @A+DPTR
            MOV R3, A
            ;R2 possui os primeiros bytes (esquerda)
            ;R3 possui os outros bytes (direita)
            MOV A, fmg_piece_x
            MOV R4, A
            MOV A, fmg_piece_y
            MOV R5, A
            LCALL FMG_GET_REGION
            ;R6 e R7 contem a informação sobre a região, 
            ;só fazer o XOR e sei se a posição está ocupada (movimento inválido), ou não;
            MOV A, R2
            XRL A, R6 ; Xor entre R2 e R6
            SUBB A, R2 ; Se não ocorreu nenhuma colisão a subtração por R2 e R6 deve retornar Zero
            SUBB A, R6
            JZ FMG_UPDATE_STATE_LEFT_TEST_R7
            JMP FMG_UPDATE_STATE_LEFT_COLLISION
            FMG_UPDATE_STATE_LEFT_TEST_R7:
                MOV A, R3
                XRL A, R7;Xor entre R2 e R6
                SUBB A, R3 ; Se não ocorreu nenhuma colisão a subtração por R3 e R7 deve retornar Zero
                SUBB A, R7    
                JZ FMG_UPDATE_STATE_LEFT_NOT_COLLISION
                JMP FMG_UPDATE_STATE_LEFT_COLLISION
            FMG_UPDATE_STATE_LEFT_COLLISION: ;Se tiver colisão então vá para o fim!
            LJMP FMG_UPDATE_STATE_END
            FMG_UPDATE_STATE_LEFT_NOT_COLLISION: ; Se não tiver colisão, atualize a posição da peça!
            MOV A, fmg_piece_x
            SUBB A, #001h
            MOV fmg_piece_x, A
            LJMP FMG_UPDATE_STATE_END ; Vai para o fim
    FMG_UPDATE_STATE_RIGHT:
    FMG_UPDATE_STATE_ROTATE:
    
    FMG_UPDATE_STATE_NOTHING: ; Não faz nada
    FMG_UPDATE_STATE_FALL: ; Não faz nada, apenas altera o contador para contar n vezes mais rápido
    
    FMG_UPDATE_STATE_END: ;Fim do fluxo de atualização de estado
    RET

code
    FMG_GET_REGION:
    MOV A, R2
    PUSH ACC
    MOV A, R3
    PUSH ACC
    
    ;Captura a região de interseção entre a posição descrita por R4 e R5, e retorna-a em R6 e R7 os bytes correspondentes
    MOV R6, #000h
    MOV R7, #000h
    
    MOV R2, #004h
    FMG_GET_REGION_LOOP_X:
        MOV R3, #004h
        FMG_GET_REGION_LOOP_Y:
            ;Cálculo do byte
            MOV A, R5
            MOV B, #004h
            DIV AB
            MOV DPTR, #FMG_GET_REGION_SWITCH_Y
            JMP @A+DPTR
            FMG_GET_REGION_SWITCH_Y:
                JMP FMG_GET_REGION_SWITCH_0
                JMP FMG_GET_REGION_SWITCH_1
                JMP FMG_GET_REGION_SWITCH_2
                JMP FMG_GET_REGION_SWITCH_3
                JMP FMG_GET_REGION_SWITCH_4
                JMP FMG_GET_REGION_SWITCH_5
                JMP FMG_GET_REGION_SWITCH_6
            FMG_GET_REGION_SWITCH_0:
                MOV R0, #000; Contador de ciclos
                MOV A, R4; Carrega a posição que desejo ir em A
                MOV R1, A; Posição para a qual desejo ir
                JMP FMG_GET_REGION_SWITCH_END
            FMG_GET_REGION_SWITCH_1:
                MOV R0, #004; Contador de ciclos
                MOV A, R4; Carrega a posição que desejo ir em A
                MOV R1, A; Posição para a qual desejo ir
                JMP FMG_GET_REGION_SWITCH_END
            FMG_GET_REGION_SWITCH_2:
                MOV R0, #000; Contador de ciclos
                MOV A, R4; Carrega a posição que desejo ir em A
                ADD A, #012h
                MOV R1, A; Posição para a qual desejo ir
                JMP FMG_GET_REGION_SWITCH_END
            FMG_GET_REGION_SWITCH_3:
                MOV R0, #004; Contador de ciclos
                MOV A, R4; Carrega a posição que desejo ir em A
                ADD A, #012h
                MOV R1, A; Posição para a qual desejo ir
                JMP FMG_GET_REGION_SWITCH_END
            FMG_GET_REGION_SWITCH_4:
                MOV R0, #000; Contador de ciclos
                MOV A, R4; Carrega a posição que desejo ir em A
                ADD A, #024h
                MOV R1, A; Posição para a qual desejo ir
                JMP FMG_GET_REGION_SWITCH_END
            FMG_GET_REGION_SWITCH_5:
                MOV R0, #004; Contador de ciclos
                MOV A, R4; Carrega a posição que desejo ir em A
                ADD A, #024h
                MOV R1, A; Posição para a qual desejo ir
                JMP FMG_GET_REGION_SWITCH_END
            FMG_GET_REGION_SWITCH_6:
                MOV R0, #000; Contador de ciclos
                MOV A, R4; Carrega a posição que desejo ir em A
                ADD A, #036h
                MOV R1, A; Posição para a qual desejo ir
                JMP FMG_GET_REGION_SWITCH_END
            FMG_GET_REGION_SWITCH_END:
                MOV A, R0
                ADD A, B
                MOV R0, A; Bit que preciso
                MOV A, #fmg_grid ;localização da grade
                ADD A, R1 ; Move-se para a aposição desejada
                MOV R1, A ;Carrega o valor para R1
                MOV A, @R1 ; Pega o byte que está na posição apontada por R1
                MOV R1, A; Byte para busca
                ;Definir se R6 ou R7 e então chamar o FMG_FIND_BIT
                MOV A, R2
                MOV B, #002h
                DIV AB
                MOV DPTR, #FMG_GET_REGION_SWITCH_1_R6_R7
                JMP @A+DPTR
                FMG_GET_REGION_SWITCH_1_R6_R7:
                    JMP FMG_GET_REGION_SWITCH_1_R7 ;Como o contador está invertido temos o R7 em 0
                    JMP FMG_GET_REGION_SWITCH_1_R6
                    FMG_GET_REGION_SWITCH_1_R6:
                        LCALL FMG_FIND_BIT
                        ;Carry contem o bit que preciso!
                        MOV A, R6
                        RLC A
                        MOV R6, A
                        JMP FMG_GET_REGION_LOOP_END
                    FMG_GET_REGION_SWITCH_1_R7:
                        LCALL FMG_FIND_BIT
                        ;Carry contem o bit que preciso!
                        MOV A, R7
                        RLC A
                        MOV R7, A
                        JMP FMG_GET_REGION_LOOP_END            
            FMG_GET_REGION_LOOP_END:
                MOV A, R5
                ADD A, #001h
                MOV R5, A
                DJNZ R3, FMG_GET_REGION_LOOP_Y_WORKAROUND
                MOV A, R4
                ADD A, #001h
                MOV R4, A
            DJNZ R2, FMG_GET_REGION_LOOP_X_WORKAROUND
            JMP FMG_GET_REGION_END
            FMG_GET_REGION_LOOP_Y_WORKAROUND:
                LJMP FMG_GET_REGION_LOOP_Y
            FMG_GET_REGION_LOOP_X_WORKAROUND:
                LJMP FMG_GET_REGION_LOOP_X
    FMG_GET_REGION_END:
    POP ACC
    MOV R3, A
    POP ACC
    MOV R2, A
    RET
    
code
    FMG_FIND_BIT:
        MOV A, R1
        FMG_FIND_BIT_LOOP:
            RRC A
            DJNZ R0, FMG_FIND_BIT_LOOP
    RET
code 
    FMG_DRAW_NEXT_PIECE:
    PUSH PSW
    SETB RS1
    CLR RS0
    MOV lcd_X, #012h
    MOV lcd_Y, #000h
    LCALL LCD_XY
    MOV lcd_bus, #0C0h
    LCALL LCD_DRAW
    
    MOV R4, #00Ah
    FMG_DRAW_NEXT_PIECE_TOP:
        MOV lcd_bus, #040h
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_NEXT_PIECE_TOP
        
    MOV lcd_bus, #040h
    LCALL LCD_DRAW
    
    MOV R3, fmg_piece_id_0
    MOV R4, #0C0h
    
    MOV lcd_X, #012h
    MOV lcd_Y, #001h
    LCALL LCD_XY
    
    MOV lcd_bus, #0FFh
    LCALL LCD_DRAW
    MOV lcd_bus, #000h
    LCALL LCD_DRAW
    
    FMG_DRAW_NEXT_PIECE_INTERNAL:
        MOV A, R3 ; Desenha a próxima peça
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
    
    MOV lcd_X, #012h
    MOV lcd_Y, #002h
    LCALL LCD_XY
    MOV lcd_bus, #003h
    LCALL LCD_DRAW
    
    MOV R4, #00Ah
    FMG_DRAW_NEXT_PIECE_BOTTOM:
        MOV lcd_bus, #002h
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_NEXT_PIECE_BOTTOM
    MOV lcd_bus, #003h
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
    DIV AB; Capturando apenas as 8 possiveis peças (temos 7 peças portanto um dos valores sera desconsiderado)
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
        ;Escolhe qual vai ser a peça
        MOV DPTR, #FMG_PIECES_I
        SJMP FMG_SELECT_NEW_PIECE_END
    ;Parte final da rotina, com a peça correta selecionada, devemos escolher qual a rotação inidial da mesma e
    ;popular as variáveis de ambiente com ela.
    FMG_SELECT_NEW_PIECE_END:
        ;Salva a peça escolhida na memória
        MOV fmg_piece_id_H, DPH
        MOV fmg_piece_id_L, DPL
        MOVC A, @A+DPTR ; Quantidade de rotações da peça
        MOV B, A ; Coloca em B a quantidade de rotações da peça
        LCALL RAND8
        DIV AB
        MOV A, B ;Escolhendo a rotação
        MOV fmg_piece_id_R, A ;Coloca a posição da peça rotacionada no id 2
        MOV B, #002h
        MUL AB ; Multiplico por 2 para ir para a peça correta
        ADD A, #001h ;Soma 1 já que o primeiro valor contem a quantidade de rotações da peça
        MOV R1, A
        ;Coloca em id 0 e 1 qual a peça selecionada
        MOVC A, @A+DPTR ;Representação da peça (primeiros bytes)
        MOV fmg_piece_id_0, A
        MOV A, R1
        ADD A, #001h ;Representação da peça (segundos bytes)
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
    ;Desenhar na tela significa pegar os bytes definidos no grade e passar para a tela, lembrando que será usado um fator de 2x.
    PUSH PSW
    SETB RS1
    CLR RS0
    MOV lcd_X, #021h
    MOV lcd_Y, #000h
    LCALL LCD_XY
    MOV R4, #005h
    MOV R3, #fmg_grid
    FMG_LOOP_LINHA_SUPERIOR:
        MOV A, R3; Move o conteúdo de R1 para o acumulador
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

        MOV A, R3; Move o conteúdo de R1 para o acumulador
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

        MOV A, R3; Move o conteúdo de R1 para o acumulador
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
        
        MOV A, R3; Move o conteúdo de R1 para o acumulador
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