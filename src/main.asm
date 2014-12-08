$include(REG52.inc)
;to use these pseudo-random number sequence generators, memory must be
;set aside to hold the last random number, which is used to generate the
;next one so that a randomly distributed (but predictable) sequence of
;number is generated.
rand8reg SET 0x20		;one byte
rand16reg SET 0x21		;two bytes
;generates an 8 bit pseudo-random number which is returned in Acc.
;one byte of memory must be available for rand8reg
code
RAND8:	
    mov	a, rand8reg
	jnz	rand8b
	cpl	a
	mov	rand8reg, a
	rand8b:	
    anl	a, #10111000b
	mov	c, p
	mov	a, rand8reg
	rlc	a
	mov	rand8reg, a
	ret
	;generates a 16 bit pseudo-random number which is returned in Acc (lsb) & B (msb)
;two bytes of memory must be available for rand16reg
code
RAND16:	
    mov	a, rand16reg
	jnz	rand16b
	mov	a, rand16reg+1
	jnz	rand16b
	cpl	a
	mov	rand16reg, a
	mov	rand16reg+1, a
	rand16b:
    anl	a, #11010000b
	mov	c, p
	mov	a, rand16reg
	jnb	acc.3, rand16c
	cpl	c
	rand16c:
    rlc	a
	mov	rand16reg, a
	mov	b, a
	mov	a, rand16reg+1
	rlc	a
	mov	rand16reg+1, a
	xch	a, b
	ret
	
;Defini��o das portas a serrem utilizadas pelo LCD
lcd_ce    SET P1.6 ;Chip enabled
lcd_reset SET P1.5 ;Reset
lcd_dc    SET P1.7 ;Data Comando
lcd_clk   SET P3.1 ;Clock
lcd_din   SET P3.0 ;Data in

lcd_bus   SET R0 ;Posi��o a ser utilizada pelo LCD para acesso bit-a-bit
lcd_X     SET R1 ;
lcd_Y     SET R2 ;

; O LCD utilizar� o banco de registradores 2, segundo a seguinte especifica��o:
; R0 - Byte/comando a ser escrito no LCD
; R1 - Coordenada X da fun��o LDC_XY
; R2 - Coordenada Y da fun��o LCD_XY

; R3 - Utilizado no LCD_CLEAR como contador (numero de linhas)
; R4 - Utilizado no LCD_CLEAR como contador (numero de colunas)

; R5 - utilizado internamente como contador para o delay (pode-se utilizar o timer e se livrar desse cara)
; R6 - utilizado internamente como contador para o delay (pode-se utilizar o timer e se livrar desse cara)
; R7 - utilizado internamente como contador para o envio.

code ;ROTINA para inicializa��o do LCD, deve ser chamada por um CALL
LCD_INIT:
    PUSH ACC ;Acumulador para pilha
    PUSH PSW ;Guardar a infroma��o do banco de registradores que est� sendo utilizado
    SETB RS1
    CLR RS0
    SETB lcd_reset ;RESET
    SETB lcd_ce    ;Set Chip Enabled
    ;CLR lcd_reset
    LCALL BIG_DELAY
    ;SETB lcd_reset ;RESET
    
    ;Rotina de inicializa��o
    MOV lcd_bus, #021h  
    LCALL LCD_SEND_COMMAND
    
    MOV lcd_bus, #0C2h  
    LCALL LCD_SEND_COMMAND
    
    MOV lcd_bus, #011h 
    LCALL LCD_SEND_COMMAND
    
    MOV lcd_bus, #020h 
    LCALL LCD_SEND_COMMAND
    
    MOV lcd_bus, #009h 
    LCALL LCD_SEND_COMMAND
    
    LCALL LCD_CLEAR
    
    MOV lcd_bus, #008h 
    LCALL LCD_SEND_COMMAND
    
    MOV lcd_bus, #00Ch 
    LCALL LCD_SEND_COMMAND
    
    POP PSW
    POP ACC
    ret

code ;Desenha um byte na tela
LCD_DRAW:
    LCALL LCD_SEND_DATA
    ret

code
LCD_SEND_SERIAL_DATA: ;Dados vem na posi��o R0, R7 serve como contador (utiliza pag2)
    MOV R7, #008h 
    MOV A, lcd_bus
    LCD_SEND_SERIAL_DATA_INTERNAL_LOOP:
        CLR lcd_clk ;Clock para nivel alto
        JB ACC.7, LCD_SEND_SERIAL_DATA_NOT_ZERO
            CLR lcd_din
            SJMP LCD_SERIAL_END_IF
        LCD_SEND_SERIAL_DATA_NOT_ZERO:
            SETB lcd_din
        LCD_SERIAL_END_IF:
        SETB lcd_clk 
        RL A
        DJNZ R7, LCD_SEND_SERIAL_DATA_INTERNAL_LOOP
    ret

code
LCD_SEND_COMMAND:
; Registrador R0 deve conter o comando a ser enviado
    PUSH ACC ;Acumulador para pilha
    PUSH PSW ;Guardar a infroma��o do banco de registradores que est� sendo utilizado
    SETB RS1
    CLR RS0
    CLR lcd_dc ;Modo comando
    CLR lcd_ce ;Ativa o display
    LCALL LCD_SEND_SERIAL_DATA
    SETB lcd_ce ;Desativa o display
    ;Volta os registradores PSW e ACC respectivamente
    POP PSW
    POP ACC
    ret

code
LCD_SEND_DATA:
; Registrador R0 deve conter o dado a ser enviado
    PUSH ACC ;Acumulador para pilha
    PUSH PSW ;Guardar a infroma��o do banco de registradores que est� sendo utilizado
    SETB RS1
    CLR RS0
    SETB lcd_dc ;Modo Dados
    CLR lcd_ce ;Ativa o display
    LCALL LCD_SEND_SERIAL_DATA
    SETB lcd_ce ;Ativa o display
    ;Volta os registradores PSW e ACC respectivamente
    POP PSW
    POP ACC
    ret
code
LCD_XY:
    PUSH ACC ;Acumulador para pilha
    PUSH PSW ;Guardar a infroma��o do banco de registradores que est� sendo utilizado
    SETB RS1
    CLR RS0
    ;080h X R1
    ;040h Y R2
    ;Recalcular o valor de Y (R2)
    MOV A, lcd_Y
    ORL A, #040h ;Sem garantia que o valor seja v�lido
    MOV lcd_bus, A
    LCALL LCD_SEND_COMMAND
    ;Recalcular valor de X (R1)
    MOV A, lcd_X
    ORL A, #080h ;Sem garantia que o valor seja v�lido
    MOV lcd_bus, A
    LCALL LCD_SEND_COMMAND
    POP PSW
    POP ACC
    ret

code
LCD_CLEAR:
    PUSH ACC 
    PUSH PSW 
    SETB RS1
    CLR RS0
    MOV lcd_X, #000h
    MOV lcd_Y, #000h
    ; 0-83 x 0-5
    
    MOV R3, #006h
    LCD_CLEAR_INTERNAL_LOOP_LINE:
        MOV R2, #054h
        LCD_CLEAR_INTERNAL_LOOP_COLUMN:
            MOV lcd_bus, #000h
            LCALL LCD_SEND_DATA
            DJNZ R2, LCD_CLEAR_INTERNAL_LOOP_COLUMN
            DJNZ R3, LCD_CLEAR_INTERNAL_LOOP_LINE
    POP PSW
    POP ACC
    ret

code
BIG_DELAY:
        MOV R5, #10d
    INIT_DELAY_3:
        MOV R6, #255d
    INIT_DELAY_2:
        MOV R7, #255d
    INIT_DELAY:    
        DJNZ R7, INIT_DELAY
        DJNZ R6, INIT_DELAY_2
        DJNZ R5, INIT_DELAY_3
    ret

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
    fmg_numbers_font: DB 0F8h, 088h, 0F8h, 090h, 0F8h, 080h, 090h, 0C8h, 0B8h, 088h, 0A8h, 050h, 038h, 020h, 0F8h, 038h, 0A8h, 048h, 0F8h, 0A8h, 0D8h, 008h, 0D8h, 081h, 0F8H, 0A8H, 0F8h, 038h, 028h, 0F8h

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
FMG_TETRIS_MAIN:
    ;Configura��o do timer_0
    MOV A, #00Fh
    MOV fmg_time_to_fall, A
    MOV fmg_score_0, #000h
    MOV fmg_score_1, #000h

    
    CLR EA ;Desabilita interrup��o at� configurar o(s) timer(s)
    CLR TR0 ; Para o timer 0

    MOV TMOD, #001h
    
    MOV A, #0DCh
    MOV TL0, A
    
    MOV A, #011h
    MOV TH0, A
    
    SETB ET0 ;Ativa a interrup��o do timer 0
    SETB TR0 ;Ativa o timer 0
    SETB EA ;Ativa interrup��o
    
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
    MOV fmg_piece_x, #007h
    MOV fmg_piece_y, #000h
    
    LCALL FMG_DRAW_NEXT_PIECE ; Desenha a pe�a que est� na espera

    ;Loop de um jogo corrente.
    ;LCALL FMG_UPDATE_STATE ; Atualiza o estado atual do jogo
    ;LCALL FMG_DRAW_SCREEN ; Desenha o jogo atual
    FMG_WAIT_ETERNAL:
        LCALL FMG_DRAW_NEXT_PIECE ; Desenha a pe�a que est� na espera
        LCALL FMG_UPDATE_STATE ;Movimenta a pe�a atual.
        LCALL FMG_VALIDATE_COLLISION ; Valida se ocorreu uma colis�o

        LCALL FMG_REMOVE_COMPLETE_LINES; Remove as linhas completas 
        ;R7 Est� com a quantidade de linhas removidas
        LCALL FMG_UPDATE_SCORE
        
        LCALL FMG_DRAW_SCORE
        
        LCALL FMG_TEST_END
        MOV A, fmg_state
        CLR C
        SUBB A, #002h
        JZ FMG_END_GAME
       
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
        
        LCALL FMG_DRAW_SCREEN
        
        MOV R4, fmg_piece_x
        MOV R5, fmg_piece_y
        LCALL FMG_GET_REGION
        MOV R2, fmg_piece_0
        MOV R3, fmg_piece_1
        MOV A, R6
        SUBB A, R2
        MOV R6, A
        
        MOV A, R7
        SUBB A, R3
        MOV R7, A
        MOV R4, fmg_piece_x
        MOV R5, fmg_piece_y
        LCALL FMG_SET_REGION
    LJMP FMG_WAIT_ETERNAL
    
    FMG_END_GAME:
        LCALL FMG_DRAW_END
    RET
code 
    FMG_UPDATE_STATE:
    ;Verificar no controle se tem alguma tecla prescionada
    ;Caso tenha, fazer a rotina correspondente
    MOV A, fmg_control ;Coloca o controle no acumulador
    MOV B, fmg_control_old ;Coloca a vers�o antiga do controle no acumulador B
    ; Se controle for cair(normal), ent�o caia :D
    MOV R0, A; Guarda o controle em R0
    MOV R1, B; Guarda o controle antigo em R1
    
    SUBB A, R1 ; Se for 0 ent�o n�o ocorreu altera��o de controle
    JZ FMG_UPDATE_STATE_END_WORKAROUND
    ;Atualiza o controle antigo para ser o valor atualmente em controle.
    MOV A, fmg_control
    MOV fmg_control_old, A
    MOV A, R0 ;Caso contr�rio restaura fmg_control
    
    MOV B, #003h
    MUL AB
    
    MOV DPTR, #FMG_UPDATE_STATE_SWITCH_CONTROL
    JMP @A+DPTR
    
    FMG_UPDATE_STATE_END_WORKAROUND:
        LJMP FMG_UPDATE_STATE_END
        
    FMG_UPDATE_STATE_SWITCH_CONTROL:
        JMP FMG_UPDATE_STATE_SWITCH_STATE_NOTHING
        JMP FMG_UPDATE_STATE_SWITCH_STATE_LEFT
        JMP FMG_UPDATE_STATE_SWITCH_STATE_RIGHT
        JMP FMG_UPDATE_STATE_SWITCH_STATE_ROTATE
        JMP FMG_UPDATE_STATE_SWITCH_STATE_FALL
    FMG_UPDATE_STATE_SWITCH_STATE_LEFT:
        ;Carrega a posi��o X e Y para R4 e R5
MOV A, fmg_piece_x
DEC A
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
    DEC A
    MOV fmg_piece_x, A; Atualiza a posi��o
FMG_UPDATE_STATE_LEFT_NOT_VALID:
    LJMP FMG_UPDATE_STATE_END
    FMG_UPDATE_STATE_SWITCH_STATE_RIGHT:
        ;Carrega a posi��o X e Y para R4 e R5
MOV A, fmg_piece_x
INC A
MOV R4, A
MOV A, fmg_piece_y
MOV R5, A

;Carrega a rota��o para R1
MOV A, fmg_piece_R
MOV R1, A

FMG_UPDATE_STATE_RIGHT:
    LCALL FMG_UPDATE_STATE_CHECK_COLLISION
    JC FMG_UPDATE_STATE_RIGHT_VALID; Posi��o v�lida
    JNC FMG_UPDATE_STATE_RIGHT_NOT_VALID; Posi��o inv�lida
FMG_UPDATE_STATE_RIGHT_VALID:
    ;Rota��o v�lida
    MOV A, fmg_piece_x
    INC A
    MOV fmg_piece_x, A; Atualiza a posi��o
FMG_UPDATE_STATE_RIGHT_NOT_VALID:
    LJMP FMG_UPDATE_STATE_END
    FMG_UPDATE_STATE_SWITCH_STATE_ROTATE:
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
DEC A; Zero based
MOV R1, A
JMP FMG_UPDATE_STATE_ROTATION_LEFT
FMG_UPDATE_STATE_LEFT_NOT_ZERO: ; Atualiza para o caso de n�o ser zero
DEC A
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
    MOV fmg_piece_0, A
    MOV A, R1
    ADD A, #001h ;Representa��o da pe�a (segundos bytes)
    MOVC A, @A+DPTR
    MOV fmg_piece_1, A
    
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
    FMG_UPDATE_STATE_SWITCH_STATE_FALL:
        ;Carrega a posi��o X e Y para R4 e R5
MOV A, fmg_piece_x
MOV R4, A
MOV A, fmg_piece_y
ADD A, #001h ;Cair!!!
MOV R5, A

;Carrega a rota��o para R1
MOV A, fmg_piece_R
MOV R1, A

FMG_UPDATE_STATE_FALL:
    LCALL FMG_UPDATE_STATE_CHECK_COLLISION
    JC FMG_UPDATE_STATE_FALL_VALID; Posi��o v�lida
    JNC FMG_UPDATE_STATE_FALL_NOT_VALID; Posi��o inv�lida
FMG_UPDATE_STATE_FALL_VALID:
    ;Queda v�lida
    MOV A, fmg_piece_y
    ADD A, #001h ;Cair!!!
    MOV fmg_piece_y, A; Atualiza a posi��o
    LJMP FMG_UPDATE_STATE_END
FMG_UPDATE_STATE_FALL_NOT_VALID:
    MOV fmg_state, #001h
    LJMP FMG_UPDATE_STATE_END
    FMG_UPDATE_STATE_SWITCH_STATE_NOTHING: ; N�o faz nada
    FMG_UPDATE_STATE_END: ;Fim do fluxo de atualiza��o de estado
    RET
code
    ;GETa os valores de uma determinada regi�o da mem�ria
    ; R4 contem a posi��o x,
    ; R5 contem a posi��o y
    ; R6 contem a regi�o ser desenhada (esquerda)
    ; R7 contem a regi�o ser desenhada (direita)
    
    FMG_GET_REGION:
    MOV A, R0
    PUSH ACC
    MOV A, R1
    PUSH ACC
    MOV A, R2
    PUSH ACC
    MOV A, R3
    PUSH ACC
    
    MOV A, R5
    PUSH ACC
    MOV R2, #004h
    FMG_GET_REGION_LOOP_X:
        POP ACC
        MOV R5, ACC
        PUSH ACC
        MOV R3, #004h
        FMG_GET_REGION_LOOP_Y:
            ;C�lculo do byte
            MOV A, R5
            MOV B, #008h
            DIV AB
            MOV R1, B 
            INC R1; R1 contem o bit que quero modificar (+1 por causa do 0 based)
            
            MOV B, #012h ; Byte = 18 * A + R4
            MUL AB
            ADD A, R4
            MOV R0, A 
            MOV A, #fmg_grid
            ADD A, R0
            MOV R0, A ; R0 contem a posi��o do byte que estou querendo
            
            ;Definir se R6 ou R7 e ent�o chamar o FMG_FIND_BIT
            MOV A, R2
            DEC A
            MOV B, #002h
            DIV AB

            MOV B, #003h
            MUL AB
            MOV DPTR, #FMG_GET_REGION_SWITCH_1_R6_R7
            JMP @A+DPTR
            FMG_GET_REGION_SWITCH_1_R6_R7:
                JMP FMG_GET_REGION_SWITCH_1_R7 ;Como o contador est� invertido temos o R7 em 0
                JMP FMG_GET_REGION_SWITCH_1_R6
                FMG_GET_REGION_SWITCH_1_R6:
                    ;Rotacionar R1 vezes o byte escolhido (RLC)
                    MOV A, R1
                    PUSH ACC
                    MOV A, @R0
                    
                    FMG_GET_REGION_SMALL_ROTATE_R6:
                        RLC A
                        DJNZ R1, FMG_GET_REGION_SMALL_ROTATE_R6
                    
                    POP ACC
                    MOV R1, A
                    MOV A, R6
                    RLC A
                    MOV R6, A ; Carry contem o bit a ser introduzido no sistema
                    
                    JMP FMG_GET_REGION_LOOP_END
                FMG_GET_REGION_SWITCH_1_R7:
                    ;Rotacionar R1 vezes o byte escolhido (RLC)
                    MOV A, R1
                    PUSH ACC
                    MOV A, @R0
                    
                    FMG_GET_REGION_SMALL_ROTATE_R7:
                        RLC A
                        DJNZ R1, FMG_GET_REGION_SMALL_ROTATE_R7
                    
                    POP ACC
                    MOV R1, A
                    MOV A, R7
                    RLC A
                    MOV R7, A ; Carry contem o bit a ser introduzido no sistema
                    
                    JMP FMG_GET_REGION_LOOP_END
            FMG_GET_REGION_LOOP_END:
                INC R5
                DJNZ R3, FMG_GET_REGION_LOOP_Y_WORKAROUND
                INC R4
            DJNZ R2, FMG_GET_REGION_LOOP_X_WORKAROUND
            JMP FMG_GET_REGION_END
            FMG_GET_REGION_LOOP_Y_WORKAROUND:
                LJMP FMG_GET_REGION_LOOP_Y
            FMG_GET_REGION_LOOP_X_WORKAROUND:
                LJMP FMG_GET_REGION_LOOP_X
    FMG_GET_REGION_END:
    POP ACC
    POP ACC
    MOV R3, A
    POP ACC
    MOV R2, A
    POP ACC
    MOV R1, A
    POP ACC
    MOV R0, A
    RET
code
    ;Coloca no carry o bit definido por R0, que se encontra em R1
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
        
    MOV lcd_bus, #0C0h
    LCALL LCD_DRAW
    
    MOV R3, #fmg_piece_id_0
    MOV R4, #0C0h
    
    MOV lcd_X, #012h
    MOV lcd_Y, #001h
    LCALL LCD_XY
    
    MOV lcd_bus, #0FFh
    LCALL LCD_DRAW
    MOV lcd_bus, #000h
    LCALL LCD_DRAW
    
    MOV R4, #002h
    FMG_DRAW_NEXT_PIECE_INTERNAL:
        MOV A, R3 ; Desenha a pr�xima pe�a
        MOV R1, A
        MOV ACC, @R1
        
        MOV C, ACC.7
        MOV ACC.0, C
        MOV ACC.1, C
        MOV C, ACC.6
        MOV ACC.2, C
        MOV ACC.3, C
        MOV C, ACC.4
        MOV ACC.6, C
        MOV ACC.7, C
        MOV C, ACC.5
        MOV ACC.5, C
        MOV ACC.4, C

        MOV lcd_bus, ACC; primeiro draw
        LCALL LCD_DRAW
        MOV lcd_bus, ACC; segundo draw
        LCALL LCD_DRAW

        MOV A, R3; Desenha bytes inferiores
        MOV R1, A
        MOV ACC, @R1
        
        MOV C, ACC.0
        MOV ACC.7, C
        MOV ACC.6, C
        MOV C, ACC.1
        MOV ACC.5, C
        MOV ACC.4, C
        MOV C, ACC.3
        MOV ACC.1, C
        MOV ACC.0, C
        MOV C, ACC.2
        MOV ACC.2, C
        MOV ACC.3, C

        MOV lcd_bus, ACC; primeiro draw
        LCALL LCD_DRAW
        MOV lcd_bus, ACC; segundo draw
        LCALL LCD_DRAW
        
        MOV R3, #fmg_piece_id_1
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
    POP PSW
    RET
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
code
FMG_SELECT_NEW_PIECE:
    LCALL RAND8
    MOV B, #007h
    DIV AB; Capturando apenas as 8 possiveis pe�as (temos 7 pe�as portanto um dos valores sera desconsiderado)
    MOV A, B
    MOV B, #003h
    MUL AB
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
        MOV A, #000h
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
    MOV R1, #04Ch
    MOV R0, #fmg_grid
    
    MOV R3, #003h
    
    FMG_CLEAR_MEMORY_MAIN_LOOP:
        MOV R2, #004h
        FMG_CLEAR_MEMORY_LOOP_BORDER_LEFT:
            MOV @R0, #0FFh
            INC R0
            DJNZ R2, FMG_CLEAR_MEMORY_LOOP_BORDER_LEFT
        MOV R1, #00Ah
        FMG_CLEAR_MEMORY_LOOP_MIDDLE:
            MOV @R0, #000h
            INC R0
            DJNZ R1, FMG_CLEAR_MEMORY_LOOP_MIDDLE
        MOV R2, #004h
        FMG_CLEAR_MEMORY_LOOP_BORDER_RIGHT:
            MOV @R0, #0FFh
            INC R0
            DJNZ R2, FMG_CLEAR_MEMORY_LOOP_BORDER_RIGHT
        DJNZ R3, FMG_CLEAR_MEMORY_MAIN_LOOP
    MOV R2, #012h
    FMG_CLEAR_MEMORY_LOOP_BORDER_FLOOR:
        MOV @R0, #0FFh
        INC R0
        DJNZ R2, FMG_CLEAR_MEMORY_LOOP_BORDER_FLOOR
    RET
;Desenha o grade na tela
code
FMG_DRAW_SCREEN:
    ;Desenhar na tela significa pegar os bytes definidos no grade e passar para a tela.
    ;lembrando que ser� usado um fator de 2x.
    PUSH PSW
    SETB RS1
    CLR RS0
    MOV lcd_X, #021h
    MOV lcd_Y, #000h
    LCALL LCD_XY
    MOV R5, #021h
    MOV R4, #00Ah
    MOV R3, #fmg_grid
    INC R3
    INC R3
    INC R3
    INC R3 ; Grid + 4
    FMG_LOOP_LINHA_SUPERIOR:
        MOV A, R3; Move o conte�do de R1 para o acumulador
        MOV R1, A
        MOV ACC, @R1
        
        MOV C, ACC.0
        MOV ACC.7, C
        MOV ACC.6, C
        MOV C, ACC.1
        MOV ACC.5, C
        MOV ACC.4, C
        MOV C, ACC.3
        MOV ACC.1, C
        MOV ACC.0, C
        MOV C, ACC.2
        MOV ACC.2, C
        MOV ACC.3, C

        MOV lcd_bus, ACC; primeiro draw
        LCALL LCD_DRAW
        MOV lcd_bus, ACC; segundo draw
        LCALL LCD_DRAW
        
        INC R3
        INC R5
        DJNZ R4, FMG_LOOP_LINHA_SUPERIOR
    MOV lcd_X, #021h
    MOV lcd_Y, #001h
    LCALL LCD_XY
    MOV R6, #002h
    FMG_LOOP_LINHA_3:
    MOV A, R3
    ADD A, #008h
    MOV R3, A ;Deslocamento das paredes
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
        
        MOV C, ACC.7
        MOV ACC.0, C
        MOV ACC.1, C
        MOV C, ACC.6
        MOV ACC.2, C
        MOV ACC.3, C
        MOV C, ACC.4
        MOV ACC.6, C
        MOV ACC.7, C
        MOV C, ACC.5
        MOV ACC.5, C
        MOV ACC.4, C
        
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
        
        MOV C, ACC.0
        MOV ACC.7, C
        MOV ACC.6, C
        MOV C, ACC.1
        MOV ACC.5, C
        MOV ACC.4, C
        MOV C, ACC.3
        MOV ACC.1, C
        MOV ACC.0, C
        MOV C, ACC.2
        MOV ACC.2, C
        MOV ACC.3, C

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
;Rotina para tratamento de interrup��o de tempo principal.
;Deve: 
;   Atualizar o status do fmg_control e fmg_control_old, de acordo com os bot�es
;   Deve atualizar e checar o valor da flag fmg_time_to_fall_0 e fmg_time_to_fall_1
code
    FMG_TIMER_0:
        PUSH ACC ;Acumulador para pilha
        PUSH PSW ;Guardar a infroma��o do banco de registradores que est� sendo utilizado
        MOV A, R0
        PUSH ACC
        MOV A, R1
        PUSH ACC
        
        CLR TR0
        
        ;Atualiza��o do tempo
        MOV A, fmg_time_to_fall_0
        ADD A, #001h
        MOV fmg_time_to_fall_0, A
        
        ;Checagem do tempo
        MOV R0, A
        MOV A, fmg_time_to_fall
        MOV R1, A
        ANL A, R0
        SUBB A, R1
        JZ FMG_TIMER_0_FALL ;Se for para a pe�a cair, ent�o caia!
        
        ;Ignorando o teste dos bot�es!
        ;MOV A, #000h
        ;JMP FMG_TIMER_0_END
        
        ;Adimitindo que: B1(P1.0) == Up, B2(P1.1) == Down, B3(P1.2) == Left, B4(P1.3) == Right, B5(P1.4) == Not Used
        JNB P1.0, FMG_TIMER_0_ROTATE
        JNB P1.1, FMG_TIMER_0_FALL
        JNB P1.2, FMG_TIMER_0_LEFT
        JNB P1.3, FMG_TIMER_0_RIGHT
        MOV A, #000h
        JMP FMG_TIMER_0_END

        FMG_TIMER_0_LEFT:
            MOV A, #001h
            JMP FMG_TIMER_0_END
        FMG_TIMER_0_RIGHT:
            MOV A, #002h
            JMP FMG_TIMER_0_END
        FMG_TIMER_0_ROTATE:
            MOV A, #003h
            JMP FMG_TIMER_0_END
        FMG_TIMER_0_FALL:
            MOV A, #000h
            MOV fmg_time_to_fall_0, A
            MOV fmg_control_old, A ;Atualiza o controle antigo
            MOV A, #004h
            JMP FMG_TIMER_0_END
            
        FMG_TIMER_0_END:
            MOV fmg_control, A ;Atualiza o controle atual
       
        MOV A, #0DCh
        MOV TL0, A
        
        MOV A, #011h
        MOV TH0, A
        SETB TR0
        
        POP ACC
        MOV R1, A
        POP ACC
        MOV R0, A
        POP PSW
        POP ACC
    RETI
;Valida o estado atual do jogo, este momento ocorre ap�s a detec��o de colis�es, e deve:
;   Sortear pr�xima pe�a
;   Remover linhas completas
;   Verificar condi��o de derrota
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
            
            ;Sortear pr�xima pe�a
            LCALL FMG_FROM_WAIT_TO_GAME ; Coloca a pe�a da espera no jogo.
            LCALL FMG_SELECT_NEW_PIECE  ; Seleciona a pe�a que ficar� na espera
            
            MOV fmg_piece_x, #007h
            MOV fmg_piece_y, #000h
            MOV fmg_state, #000h
            ;Remover linhas completas
            ;LCALL FMG_REMOVE_COMPLETE_LINES
        
        FMG_VALIDATE_COLLISION_SWITCH_CONTINUE:
    RET
code
    FMG_REMOVE_COMPLETE_LINES:
        ;R7 - Contador de linhas removidas!
        MOV A, #000h
        PUSH ACC
        ; Capturar �ltima linha da tela
        MOV R0, #fmg_grid
        MOV A, #028h ; Deslocamento do come�o das linhas na mem�ria
        ADD A, R0 ; Posi��o do come�o das linhas na mem�ria
        MOV R0, A
        
        FMG_REMOVE_COMPLETE_LINES_LOOP:
            MOV A, R0
            MOV R1, A ;R1 est� na mesma posi��o que R0
            MOV R2, #00Ah ;Quantidade de colunas �teis por linha
            MOV R3, #0FFh ; M�scara para teste das linhas
            
            FMG_REMOVE_COMPLETE_LINES_LOOP_0:
                MOV A, @R1 ; Captura o elemento que est� em R1
                ANL A, R3 ; Captura quais as linhas que est�o completas
                MOV R3, A
                INC R1
                
                DJNZ R2, FMG_REMOVE_COMPLETE_LINES_LOOP_0
            ;R3 possui as linhas completas, move-lo para A para acessar cada linha
            MOV A, R3
            
            ;Se R3 for 0 ent�o n�o temos linhas a serem removidas, caso contr�rio removemos linhas
            JZ FMG_REMOVE_COMPLETE_LINES_LINE_COMPLETE
            JNZ FMG_REMOVE_COMPLETE_LINES_REMOVE_SPECIFIC
            ;Nenhuma linha a remover, logo movo para a pr�xima linha macro do jogo.
            FMG_REMOVE_COMPLETE_LINES_LINE_COMPLETE:
                MOV A, R0
                CLR C
                SUBB A, #fmg_grid
                CLR C
                SUBB A, #004h ; Verificar se R0 est� j� na posi��o 0
                JZ FMG_REMOVE_COMPLETE_LINES_END ; J� verificamos as primeiras linhas
                ADD A, #fmg_grid
                SUBB A, #00Eh
                MOV R0, A
                MOV R1, A
                JMP FMG_REMOVE_COMPLETE_LINES_LOOP
            FMG_REMOVE_COMPLETE_LINES_REMOVE_SPECIFIC:
                LCALL FMG_REMOVE_SPECIFIC_LINE
                POP ACC
                INC A
                PUSH ACC
                JMP FMG_REMOVE_COMPLETE_LINES_LOOP
        FMG_REMOVE_COMPLETE_LINES_END:
        POP ACC
        MOV R7, A
    RET
code
    ;Remove uma linha especifica do jogo.
    ;R0 - Come�o da linha (macro 8 bits)
    ;R3 - M�scara do AND das linhas (linhas a serem removidas)
    ;Tentar n�o afetar R0!
    FMG_REMOVE_SPECIFIC_LINE:
        MOV A, R0
        PUSH ACC
        MOV A, R1
        PUSH ACC
        MOV A, R2
        PUSH ACC
        MOV A, R3
        PUSH ACC
        LCALL FMG_SELECT_LINE_TO_REMOVE
        MOV R4, #00Ah
        MOV B, #004h
        FMG_REMOVE_SPECIFIC_LINE_MAIN_LOOP:
        ;R5 Contem o bit a ser removido
        MOV A, R0
        CLR C
        SUBB A, #012h
        MOV R1, A ;Endere�o da linha superior
        MOV A, #007h
        CLR C
        SUBB A, R5 ;Gerar m�scara superior
        MOV R2, A
        ;Criar a m�scara superior em R6 e a inferiro em R7
        LCALL FMG_CREATE_SUPERIOR_MASK
        MOV A, R5
        MOV R2, A
        LCALL FMG_CREATE_INFERIOR_MASK
        
        MOV A, R0
        CLR C
        SUBB A, #fmg_grid
        CLR C
        SUBB A, B ;Subtraindo 4 de A
        JZ FMG_REMOVE_SPECIFIC_LINE_SET_NOT_CARRY ; Se R0 for a linha superior ignorar teste com linhas superiores
 
        MOV A, @R1 ; Linha superior
        JB ACC.0, FMG_REMOVE_SPECIFIC_LINE_SET_CARRY
        JNB ACC.0, FMG_REMOVE_SPECIFIC_LINE_SET_NOT_CARRY
        
        FMG_REMOVE_SPECIFIC_LINE_SET_CARRY:
            SETB C
            JMP FMG_REMOVE_SPECIFIC_LINE_SET_CARRY_END
        FMG_REMOVE_SPECIFIC_LINE_SET_NOT_CARRY:
            CLR C
            JMP FMG_REMOVE_SPECIFIC_LINE_SET_CARRY_END
        FMG_REMOVE_SPECIFIC_LINE_SET_CARRY_END:
            MOV A, @R0
            ANL A, R6
            RRC A
            MOV R6, A
            MOV A, @R0
            ANL A, R7
            XRL A, R6
            MOV @R0, A
        ;Fazer a etapa de corre��o para as linhas superiores
        MOV A, R0
        CLR C
        SUBB A, #fmg_grid
        CLR C
        SUBB A, B ;Subtraindo 4 de A
        ;Se R0 for a linha superior ent�o ok, fim
        JZ FMG_REMOVE_SPECIFIC_LINE_END
        
        ;Se n�o verificar linha superior
        MOV A, R1
        CLR C
        SUBB A, #fmg_grid
        CLR C
        SUBB A, B ;Subtraindo 4 de A
        ;Se a linha superior for a primeira linha, ent�o limpar o carry e fazer apenas o rotate
        JZ FMG_REMOVE_SPECIFIC_LINE_LEVEL_1
        JNZ FMG_REMOVE_SPECIFIC_LINE_LEVEL_2
        
        FMG_REMOVE_SPECIFIC_LINE_LEVEL_1:
            CLR C
            MOV A, @R1
            RRC A
            MOV @R1, A
            JMP FMG_REMOVE_SPECIFIC_LINE_END
        FMG_REMOVE_SPECIFIC_LINE_LEVEL_2:
            MOV A, @R1
            MOV R2, A ; Linha superior
            MOV A, R1
            SUBB A, #012h
            MOV R1, A; Linhas 2 niveis acima
            MOV A, @R1
            RRC A
            MOV A, R2
            RRC A
            MOV R2, A
            CLR C
            MOV A, @R1
            RRC A
            MOV @R1, A
            MOV A, R1
            ADD A, #012h
            MOV R1, A
            MOV A, R2
            MOV @R1, A
        FMG_REMOVE_SPECIFIC_LINE_END:
        INC R0
        INC B
        DJNZ R4, FMG_REMOVE_LINE_MAIN_LOOP_WORKAROUND
        
        JMP FMG_REMOVE_SPECIFIC_LINE_END_END
        FMG_REMOVE_LINE_MAIN_LOOP_WORKAROUND:
            LJMP FMG_REMOVE_SPECIFIC_LINE_MAIN_LOOP
        FMG_REMOVE_SPECIFIC_LINE_END_END:
    POP ACC
    MOV R3, A
    POP ACC
    MOV R2, A
    POP ACC
    MOV R1, A
    POP ACC
    MOV R0, A
    RET
    
code
    FMG_CREATE_SUPERIOR_MASK:
    MOV A, #000h
    FMG_CREATE_SUPERIOR_MASK_LOOP:
        SETB C
        RRC A
        DJNZ R2, FMG_CREATE_SUPERIOR_MASK_LOOP
    MOV R6, A
    RET
    
code
    FMG_CREATE_INFERIOR_MASK:
    MOV A, R2
    JZ FMG_CREATE_INFERIOR_MASK_END
    MOV A, #000h
    FMG_CREATE_INFERIOR_MASK_LOOP:
        SETB C
        RLC A
        DJNZ R2, FMG_CREATE_INFERIOR_MASK_LOOP
    FMG_CREATE_INFERIOR_MASK_END:
    MOV R7, A
    RET
code
    FMG_SELECT_LINE_TO_REMOVE:
    ;R3 - m�scara a ser analizada
    ; N�o alterar nem R0 nem R7
    CLR C
    MOV R1, #008h
    MOV R5, #000h
    MOV A, R3
    FMG_SELECT_LINE_TO_REMOVE_LOOP:
        RRC A
        JC FMG_SELECT_LINE_TO_REMOVE_END
        INC R5
        DJNZ R1, FMG_SELECT_LINE_TO_REMOVE_LOOP
    FMG_SELECT_LINE_TO_REMOVE_END:
    RET
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
code
    ;Seta os valores de uma determinada regi�o da mem�ria
    ; R4 contem a posi��o x,
    ; R5 contem a posi��o y
    ; R6 contem a regi�o ser desenhada (esquerda)
    ; R7 contem a regi�o ser desenhada (direita)
    
    FMG_SET_REGION:
    MOV A, R0
    PUSH ACC
    MOV A, R1
    PUSH ACC
    MOV A, R2
    PUSH ACC
    MOV A, R3
    PUSH ACC
    
    MOV A, R5
    PUSH ACC
    MOV R2, #004h
    FMG_SET_REGION_LOOP_X:
        POP ACC
        MOV R5, ACC
        PUSH ACC
        MOV R3, #004h
        FMG_SET_REGION_LOOP_Y:
            ;C�lculo do byte
            MOV A, R5
            MOV B, #008h
            DIV AB
            MOV R1, B 
            INC R1; R1 contem o bit que quero modificar (+1 por causa do 0 based)
            
            MOV B, #012h ; Byte = 18 * A + R4
            MUL AB
            ADD A, R4
            MOV R0, A 
            MOV A, #fmg_grid
            ADD A, R0
            MOV R0, A ; R0 contem a posi��o do byte que estou querendo
            
            ;Definir se R6 ou R7 e ent�o chamar o FMG_FIND_BIT
            MOV A, R2
            DEC A
            MOV B, #002h
            DIV AB
            MOV B, #003h
            MUL AB
            MOV DPTR, #FMG_SET_REGION_SWITCH_1_R6_R7
            JMP @A+DPTR
            FMG_SET_REGION_SWITCH_1_R6_R7:
                JMP FMG_SET_REGION_SWITCH_1_R7 ;Como o contador est� invertido temos o R7 em 0
                JMP FMG_SET_REGION_SWITCH_1_R6
                FMG_SET_REGION_SWITCH_1_R6:
                    ;Rotacionar R1 vezes o byte escolhido (RLC)
                    MOV A, R1
                    PUSH ACC
                    MOV A, @R0
                    
                    FMG_SET_REGION_SMALL_ROTATE_R6:
                        RLC A
                        DJNZ R1, FMG_SET_REGION_SMALL_ROTATE_R6
                    MOV @R0, A
                    
                    POP ACC
                    MOV R1, A
                    MOV A, R6
                    RLC A
                    MOV R6, A ; Carry contem o bit a ser introduzido no sistema
                    
                    MOV A, @R0
                    FMG_SET_REGION_SMALL_ROTATE_BACK_R6:
                        RRC A
                        DJNZ R1, FMG_SET_REGION_SMALL_ROTATE_BACK_R6
                    MOV @R0, A
                    JMP FMG_SET_REGION_LOOP_END
                FMG_SET_REGION_SWITCH_1_R7:
                    ;Rotacionar R1 vezes o byte escolhido (RLC)
                    MOV A, R1
                    PUSH ACC
                    MOV A, @R0
                    
                    FMG_SET_REGION_SMALL_ROTATE_R7:
                        RLC A
                        DJNZ R1, FMG_SET_REGION_SMALL_ROTATE_R7
                    MOV @R0, A
                    
                    POP ACC
                    MOV R1, A
                    MOV A, R7
                    RLC A
                    MOV R7, A ; Carry contem o bit a ser introduzido no sistema
                    
                    MOV A, @R0
                    FMG_SET_REGION_SMALL_ROTATE_BACK_R7:
                        RRC A
                        DJNZ R1, FMG_SET_REGION_SMALL_ROTATE_BACK_R7
                    MOV @R0, A
                    JMP FMG_SET_REGION_LOOP_END
            FMG_SET_REGION_LOOP_END:
                INC R5
                DJNZ R3, FMG_SET_REGION_LOOP_Y_WORKAROUND
                INC R4
            DJNZ R2, FMG_SET_REGION_LOOP_X_WORKAROUND
            JMP FMG_SET_REGION_END
            FMG_SET_REGION_LOOP_Y_WORKAROUND:
                LJMP FMG_SET_REGION_LOOP_Y
            FMG_SET_REGION_LOOP_X_WORKAROUND:
                LJMP FMG_SET_REGION_LOOP_X
    FMG_SET_REGION_END:
    POP ACC
    POP ACC
    MOV R3, A
    POP ACC
    MOV R2, A
    POP ACC
    MOV R1, A
    POP ACC
    MOV R0, A
    RET
code
    FMG_UPDATE_SCORE:
    ;R7 Quantidade de linhas removidas
    ;fmg_score_0 - pontua��o Inferior
    ;fmg_score_1 - pontua��o Superior
    
    MOV A, R7
    MOV B, #003h
    MUL AB
    
    MOV DPTR, #FMG_UPDATE_SCORE_SWITCH_LINES
    JMP @A+DPTR
    
    FMG_UPDATE_SCORE_SWITCH_LINES:
        JMP FMG_UPDATE_SCORE_SWITCH_LINES_0
        JMP FMG_UPDATE_SCORE_SWITCH_LINES_1
        JMP FMG_UPDATE_SCORE_SWITCH_LINES_2
        JMP FMG_UPDATE_SCORE_SWITCH_LINES_3
        JMP FMG_UPDATE_SCORE_SWITCH_LINES_4
    FMG_UPDATE_SCORE_SWITCH_LINES_0:
        MOV R0, #000h;
        JMP FMG_UPDATE_SCORE_END
    FMG_UPDATE_SCORE_SWITCH_LINES_1:
        MOV R0, #001h;
        JMP FMG_UPDATE_SCORE_END
    FMG_UPDATE_SCORE_SWITCH_LINES_2:
        MOV R0, #003h;
        JMP FMG_UPDATE_SCORE_END
    FMG_UPDATE_SCORE_SWITCH_LINES_3:
        MOV R0, #005h;
        JMP FMG_UPDATE_SCORE_END
    FMG_UPDATE_SCORE_SWITCH_LINES_4:
        MOV R0, #008h;
        JMP FMG_UPDATE_SCORE_END
    FMG_UPDATE_SCORE_END:
        MOV A, fmg_score_0
        ADD A, R0
        MOV fmg_score_0, A
        MOV A, fmg_score_1
        ADDC A, #000h
        MOV fmg_score_1, A
    RET
code
    FMG_DRAW_SCORE:
    PUSH PSW
    MOV A, fmg_score_1
    MOV B, #006h
    MUL AB
    MOV B, #00Ah
    DIV AB
    MOV R2, A; Estouro!
    MOV A, B; Unidades da parte High do score!
    MOV R1, A
    MOV A, fmg_score_0
    MOV B, #00Ah
    DIV AB
    MOV R7, A ;Divis�o
    MOV A, B
    ADD A, R1
    MOV R1, A 
    MOV B, #00Ah
    DIV AB
    ADD A, R2
    MOV R2, A
    MOV A, B
    MOV R1, A ;Unidades!
    MOV A, R7
    ADDC A, #000h
    MOV R7, A
    
    MOV A, fmg_score_1
    MOV B, #005h
    MUL AB
    ADD A, R2
    MOV B, #00Ah
    DIV AB
    MOV R3, A;Estouro
    MOV A, B; Dezenas da parte High do score!
    MOV R2, A
    MOV A, R7
    MOV B, #00Ah
    DIV AB
    MOV R7, A ; Divis�o
    MOV A, B
    ADD A, R2
    MOV R2, A ;Dezenas
    MOV B, #00Ah
    DIV AB
    ADD A, R3
    MOV R3, A
    MOV A, B
    MOV R2, A
    MOV A, R7
    ADDC A, #000h
    MOV R7, A
    
    MOV A, fmg_score_1
    MOV B, #002h
    MUL AB
    ADD A, R3
    MOV B, #00Ah
    DIV AB
    MOV R4, A;Estouro
    MOV A, B; Centenas da parte High do score!
    MOV R3, A
    MOV A, R7
    MOV B, #00Ah
    DIV AB
    MOV R7, A ; Divis�o
    MOV A,B
    ADD A, R3
    MOV R3, A ;Centenas
    MOV B, #00Ah
    DIV AB
    ADD A, R4
    MOV R4, A
    MOV A, B
    MOV R3, A
    MOV A, R7
    ADDC A, #000h
    MOV R7, A
    
    MOV A, R1
    PUSH ACC
    MOV A, R2
    PUSH ACC
    MOV A, R3
    PUSH ACC
    MOV A, R4
    PUSH ACC
    
    ;;;;;;;;;;;;;
    ;; DESENHO ;;
    ;;;;;;;;;;;;;
    SETB RS1
    CLR RS0
    
    MOV DPTR, #fmg_numbers_font
    MOV R3, #000h
    ;Milhares
    POP ACC
    MOV lcd_X, #03Ch
    MOV lcd_Y, #000h
    LCALL LCD_XY
    
    MOV B, #003h
    MUL AB
    MOV R4, A
    MOVC A, @A+DPTR
    MOV lcd_bus, A    
    LCALL LCD_DRAW
    INC R4
    MOV A, R4
    MOVC A, @A+DPTR
    MOV lcd_bus, A
    LCALL LCD_DRAW
    INC R4
    MOV A, R4
    MOVC A, @A+DPTR
    MOV lcd_bus, A
    LCALL LCD_DRAW
    
    ;Centenas
    POP ACC
    MOV lcd_X, #040h
    MOV lcd_Y, #000h
    LCALL LCD_XY
    
    MOV B, #003h
    MUL AB
    MOV R4, A
    MOVC A, @A+DPTR
    MOV lcd_bus, A    
    LCALL LCD_DRAW
    INC R4
    MOV A, R4
    MOVC A, @A+DPTR
    MOV lcd_bus, A
    LCALL LCD_DRAW
    INC R4
    MOV A, R4
    MOVC A, @A+DPTR
    MOV lcd_bus, A
    LCALL LCD_DRAW
    
    ;Dezenas
    POP ACC
    MOV lcd_X, #044h
    MOV lcd_Y, #000h
    LCALL LCD_XY
    
    MOV B, #003h
    MUL AB
    MOV R4, A
    MOVC A, @A+DPTR
    MOV lcd_bus, A
    LCALL LCD_DRAW
    INC R4
    MOV A, R4
    MOVC A, @A+DPTR
    MOV lcd_bus, A
    LCALL LCD_DRAW
    INC R4
    MOV A, R4
    MOVC A, @A+DPTR
    MOV lcd_bus, A
    LCALL LCD_DRAW
    
    ;Unidades
    POP ACC
    MOV lcd_X, #048h
    MOV lcd_Y, #000h
    LCALL LCD_XY
    MOV B, #003h
    MUL AB
    MOV R4, A
    MOVC A, @A+DPTR
    MOV lcd_bus, A
    LCALL LCD_DRAW
    INC R4
    MOV A, R4
    MOVC A, @A+DPTR
    MOV lcd_bus, A
    LCALL LCD_DRAW
    INC R4
    MOV A, R4
    MOVC A, @A+DPTR
    MOV lcd_bus, A
    LCALL LCD_DRAW
    POP PSW
    RET
code
    FMG_TEST_END:
        MOV R0, #fmg_grid
        MOV A, #004h
        ADD A, R0
        MOV R0, A
        MOV R3, #000h
        MOV R4, #00Ah
        
        FMG_TEST_END_LOOP:
            MOV A, @R0
            ORL A, R3
            MOV R3, A
            INC R0
            DJNZ R4, FMG_TEST_END_LOOP
        MOV A, R3
        ANL A, #0F0h
        JZ FMG_TEST_END_END
        JNZ FMG_TEST_END_END_GAME
        
        FMG_TEST_END_END_GAME:
            MOV fmg_state, #002h
        FMG_TEST_END_END:
    RET
code
    FMG_DRAW_END:
    PUSH PSW
    
    LCALL LCD_CLEAR

    ;;;;;;;;;
    ;; THE ;;
    ;;;;;;;;;
    MOV lcd_X, #004h
    MOV lcd_Y, #001h
    LCALL LCD_XY    
    
    MOV R4, #00Eh
    FMG_DRAW_END_T_TOP:
        MOV lcd_bus, #0FFh
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_END_T_TOP
    
    MOV R3, #005h
    FMG_DRAW_END_T_H_TOP:
        MOV lcd_bus, #000h
        LCALL LCD_DRAW
        DJNZ R3, FMG_DRAW_END_T_H_TOP
        
    MOV R4, #005h
    FMG_DRAW_END_H1_TOP:
        MOV lcd_bus, #0FFh
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_END_H1_TOP
    MOV R4, #005h
    FMG_DRAW_END_H2_TOP:
        MOV lcd_bus, #0F0h
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_END_H2_TOP
    MOV R4, #005h
    FMG_DRAW_END_H3_TOP:
        MOV lcd_bus, #0FFh
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_END_H3_TOP
    
    MOV R3, #005h
    FMG_DRAW_END_H_E_TOP:
        MOV lcd_bus, #000h
        LCALL LCD_DRAW
        DJNZ R3, FMG_DRAW_END_H_E_TOP
    
    MOV R4, #005h
    FMG_DRAW_END_E_TOP:
        MOV lcd_bus, #0FFh
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_END_E_TOP
    MOV R4, #005h
    FMG_DRAW_END_E2_TOP:
        MOV lcd_bus, #0CFh
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_END_E2_TOP
    MOV R4, #005h
    FMG_DRAW_END_E3_TOP:
        MOV lcd_bus, #00Fh
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_END_E3_TOP
    
    ;Linha 2
    MOV lcd_X, #008h
    MOV lcd_Y, #002h
    LCALL LCD_XY
    
    MOV R4, #005h
    FMG_DRAW_END_T_MIDDLE:
        MOV lcd_bus, #0FFh
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_END_T_MIDDLE
    
    MOV R3, #00Ah
    FMG_DRAW_END_T_H_MIDDLE:
        MOV lcd_bus, #000h
        LCALL LCD_DRAW
        DJNZ R3, FMG_DRAW_END_T_H_MIDDLE
    
    MOV R4, #005h
    FMG_DRAW_END_H1_MIDDLE:
        MOV lcd_bus, #0FFh
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_END_H1_MIDDLE

    MOV R4, #005h
    FMG_DRAW_END_H2_MIDDLE:
        MOV lcd_bus, #00Fh
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_END_H2_MIDDLE
    
    MOV R4, #005h
    FMG_DRAW_END_H3_MIDDLE:
        MOV lcd_bus, #0FFh
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_END_H3_MIDDLE
    
    MOV R3, #005h
    FMG_DRAW_END_H_E_MIDDLE:
        MOV lcd_bus, #000h
        LCALL LCD_DRAW
        DJNZ R3, FMG_DRAW_END_H_E_MIDDLE
        
    MOV R4, #005h
    FMG_DRAW_END_E_BOTTOM:
        MOV lcd_bus, #0FFh
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_END_E_BOTTOM
    MOV R4, #005h
    FMG_DRAW_END_E2_BOTTOM:
        MOV lcd_bus, #0F3h
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_END_E2_BOTTOM
    MOV R4, #005h
    FMG_DRAW_END_E3_BOTTOM:
        MOV lcd_bus, #0F0h
        LCALL LCD_DRAW
        DJNZ R4, FMG_DRAW_END_E3_BOTTOM
    
    FMG_DRAW_END_ETERNAL:
        JMP FMG_DRAW_END_ETERNAL
    POP PSW
    RET

code at 0
    ljmp INIT

code at 000Bh
TIMER0_INTERRUPT:
    LCALL FMG_TIMER_0
    ret;

code
INIT: 
    MOV SP, #90h 
    LCALL LCD_INIT
    LJMP MAIN 
    
code
MAIN: 
    ;Banco 2
    SETB RS1
    CLR RS0
    MOV R1, #001h
    MOV R2, #001h
    

    MOV lcd_X, #000h
    MOV lcd_Y, #000h
    LCALL LCD_XY
    LCALL FMG_TETRIS_MAIN
END