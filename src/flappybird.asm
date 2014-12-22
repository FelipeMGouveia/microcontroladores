$include(REG52.inc)

;------------------------------------------------
; Flappy Bird - Nestor Maciel - uC eComp 2014.2
;------------------------------------------------
; Mapeamento em memoria:
;
;   Os dados necessarios para funcionamento do jogo, como
; flags de controle e variaveis de posicoes e score, sao
; mapeados a seguir:
;
EQU ntmj_score               R0   ; Placar atual
EQU ntmj_bird_y              R1   ; Posicao vert. que o passaro se encontra
EQU ntmj_pipeA_x             R2   ; Posicao hor. do primeiro cano
EQU ntmj_pipeA_y             R3   ; Posicao vert. do primeiro cano
EQU ntmj_pipeB_x             R4   ; Posicao hor. do segundo cano
EQU ntmj_pipeB_y             R5   ; Posicao vert. do segundo cano
EQU ntmj_flag_bird_fall      20h  ; Flag de controle que indica se passou o tempo para o passaro cair
EQU ntmj_flag_pipe_move      21h  ; Flag de controle que indica se passou o tempo para o cano mover
EQU ntmj_flag_bird_up        22h  ; Flag de controle que indica se o usuario pressionou o botao pra subir
EQU ntmj_flag_game_over      23h  ; Flag de controle que indica se houve colisao
EQU ntmj_flag_update_screen  24h
EQU ntmj_screen              00h  ; Posicao da tela na memoria externa
EQU ntmj_lcd_screen          0FC0h; Posicao da tela na memoria externa com a representacao do LCD
EQU ntmj_bird_time_counter   32h  ; Contador utilizado para temporizacao do passaro
EQU ntmj_bird_time           33h  ; Limite da contagem do contador anterior
EQU ntmj_pipe_timer_counter  34h  ; Contador utilizado para temporizacao dos canos
EQU ntmj_pipe_timer          35h  ; Limite da contagem do contador anterior

; Definição das portas a serrem utilizadas pelo LCD
EQU lcd_ce                   P1.6 ; Chip enabled
EQU lcd_reset                P1.5 ; Reset
EQU lcd_dc                   P1.7 ; Data Command
EQU lcd_clk                  P3.1 ; Clock
EQU lcd_din                  P3.0 ; Data in
EQU lcd_bus                  R0   ; Posição a ser utilizada pelo LCD para acesso bit-a-bit
EQU lcd_X                    R1
EQU lcd_Y                    R2

; Random
EQU rand8reg                 20h ; Numero aleatorio de 1 byte
EQU rand16reg                21h ; Numero aleatorio de 2 bytes


; Tela de game over
code
ntmj_gameover_screen_line_1: DB 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 080h, 080h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 080h, 080h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 055h, 0AAh, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h

code
ntmj_gameover_screen_line_2: DB 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 080h, 0C0h, 0C0h, 060h, 061h, 061h, 060h, 060h, 060h, 060h, 060h, 060h, 060h, 061h, 061h, 060h, 0C0h, 0C0h, 080h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 055h, 0AAh, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 080h, 040h, 040h, 040h, 040h, 000h, 080h, 040h, 040h, 040h, 080h, 000h, 080h, 040h, 040h, 040h, 080h, 000h, 0C0h, 040h, 040h, 040h, 080h, 000h, 0C0h, 040h, 040h, 040h, 040h, 000h, 000h, 000h, 000h, 000h

code
ntmj_gameover_screen_line_3: DB 000h, 000h, 000h, 000h, 000h, 000h, 000h, 080h, 040h, 040h, 040h, 080h, 000h, 000h, 080h, 040h, 040h, 040h, 080h, 000h, 000h, 0C0h, 080h, 000h, 080h, 0C0h, 000h, 000h, 0C0h, 040h, 040h, 040h, 040h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 055h, 0AAh, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 011h, 012h, 012h, 012h, 00Ch, 000h, 00Fh, 010h, 010h, 010h, 008h, 000h, 00Fh, 010h, 010h, 010h, 00Fh, 000h, 01Fh, 002h, 006h, 00Ah, 011h, 000h, 01Fh, 012h, 012h, 012h, 010h, 000h, 000h, 000h, 000h, 000h

code
ntmj_gameover_screen_line_4: DB 000h, 000h, 000h, 000h, 000h, 000h, 000h, 00Fh, 090h, 090h, 094h, 00Ch, 000h, 000h, 09Fh, 002h, 002h, 002h, 09Fh, 000h, 000h, 09Fh, 080h, 083h, 080h, 09Fh, 000h, 000h, 09Fh, 092h, 092h, 092h, 020h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 055h, 0AAh, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h

code
ntmj_gameover_screen_line_5: DB 000h, 000h, 000h, 000h, 000h, 000h, 000h, 01Fh, 020h, 020h, 020h, 01Fh, 000h, 000h, 007h, 018h, 020h, 018h, 007h, 000h, 000h, 03Fh, 024h, 024h, 024h, 020h, 000h, 000h, 03Fh, 004h, 00Ch, 014h, 023h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 055h, 0AAh, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 080h, 000h, 000h, 000h, 000h, 000h

code
ntmj_gameover_screen_line_6: DB 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 055h, 0AAh, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h, 011h, 02Ah, 008h, 009h, 008h, 02Ah, 011h, 000h, 000h

; Fonte numeria 3x5
code
ntmj_numbers_font: DB 0F8h, 088h, 0F8h, 090h, 0F8h, 080h, 090h, 0C8h, 0B8h, 088h, 0A8h, 050h, 038h, 020h, 0F8h, 038h, 0A8h, 048h, 0F8h, 0A8h, 0D8h, 008h, 0D8h, 081h, 0F8H, 0A8H, 0F8h, 038h, 028h, 0F8h

;------------------------------------------------

; Codigo de reset pra execucao independente
code at 0
    LJMP NTMJ_START

; Definicao da rotina de tratamento de interrupcao para o Timer 0
code at 000Bh
TIMER0_INTERRUPT:
    LCALL NTMJ_TIMER_0 ; Como temos pouco espaco aqui, chama um metodo externo
    RETI

; Codigo de inicializacao
code 
NTMJ_START: ; Novo Jogo!
    MOV SP, #60h 
    LCALL NTMJ_SETUP_TIMER ; Inicializacao da temporizacao do jogo
    LCALL LCD_INIT ; Rotina de inicializacao do LCD
    LCALL LCD_CLEAR ; Limpa o LCD
    LCALL NTMJ_CLEAR_MEMORY ; Reseta os espacos de memoria que serao utilizados
    LCALL NTMJ_PLAY ; Inicia o jogo
    RET

; Inicializacao da temporizacao do jogo
code
NTMJ_SETUP_TIMER:
    MOV ntmj_bird_time, #20 ; Quantos multiplos do timer para uma contagem de atualizacao do bird
    MOV ntmj_pipe_timer, #10 ; Quantos multiplos do timer para uma contagem de atualizacao dos canos
    CLR EA
    CLR TR0
    MOV TMOD, #001h
    MOV A, #0DCh
    MOV TL0, A
    MOV A, #011h
    MOV TH0, A
    SETB ET0
    SETB TR0
    SETB EA
    RET

; Limpeza de memoria
code
NTMJ_CLEAR_MEMORY:
    MOV ntmj_score #00h ; Reseta o score
    MOV ntmj_bird_y #18 ; Reseta o passaro
    LCALL NTMJ_RANDOMIZE_PIPE_A ; Reseta o cano A
    LCALL NTMJ_RANDOMIZE_PIPE_B ; Reseta o cano B
    MOV ntmj_pipeA_x #2 ; Bota o cano A em x = 12
    MOV ntmj_pipeB_x #42 ; Bota o cano B em x = 50
    LCALL NTMJ_CLEAR_SCREEN ; Limpa a representacao da tela na memoria
    RET

; Limpa a parte da memoria externa referente a tela
code
NTMJ_CLEAR_SCREEN:
    MOV A, #000h ; Valor que vai ser escrito na memoria (0)
    MOV DPTR, #ntmj_screen ; DPTR do Endereco inicial
    MOV R6, #48 ; Quantidade de linhas da tela
    NTMJ_CLEAR_SCREEN_LINE:
        MOV R7, #84 ; Quantidade de colunas em cada linha
        NTMJ_CLEAR_SCREEN_COLUMN:
            MOVX @DPTR, A ; Escreve o A nessa posicao da memoria externa
            INC DPTR ; Vai para a proxima coluna
            DJNZ R7 NTMJ_CLEAR_SCREEN_COLUMN ; Diminui o contador de colunas e repete ate q complete
            DJNZ R6 NTMJ_CLEAR_SCREEN_LINE ; Diminui o contador de linhas e repete ate q complete
    RET

; Reseta ambas as coordenadas do cano A
code
NTMJ_RESET_PIPE_A:
    MOV ntmj_pipeA_x #83 ; Bota o cano comecando no extremo direito da tela
NTMJ_RANDOMIZE_PIPE_A:
    LCALL RAND8 ; Gera um numero aleatorio
    ANL A, #7Fh ; Remove o MSB pra permitir overflow na soma seguinte
    ADD A, #3 ; Soma 3
    ANL A, #1Fh ; Limita a 31
    MOV ntmj_pipeA_y A ; Salva no y do cano A
    RET

; Reseta ambas as coordenadas do cano B
code
NTMJ_RESET_PIPE_B:
    MOV ntmj_pipeB_x #83 ; Bota o cano comecando no extremo direito da tela
NTMJ_RANDOMIZE_PIPE_B:
    LCALL RAND8 ; Gera um numero aleatorio
    ANL A, #7Fh ; Remove o MSB pra permitir overflow na soma seguinte
    ADD A, #3 ; Soma 3
    ANL A, #1Fh ; Limita a 31
    MOV ntmj_pipeB_y A ; Salva no y do cano B
    RET

; Main
code
NTMJ_PLAY:
    LCALL NTMJ_UPDATE_SCORE ; Verifica se precisa atualizar o score
    LCALL NTMJ_UPDATE_BIRD ; Atualiza a posicao do passaro
    LCALL NTMJ_UPDATE_PIPES ; Atualiza a posicao dos canos
    JNB ntmj_flag_update_screen, NTMJ_SKIP_DRAW
    CLR ntmj_flag_update_screen
    LCALL NTMJ_DRAW ; Atualiza o desenho na memoria
    LCALL NTMJ_DRAW_TO_LCD ; Transfere o desenho da memoria para o LCD
    NTMJ_SKIP_DRAW:
        LCALL NTMJ_DETECT_COLLISION ; Atualiza a flag de colisao
        JB ntmj_flag_game_over, NTMJ_GAME_OVER ; Pula pra game over se teve colisao (flag = 1)
        LJMP NTMJ_PLAY ; Repete tudo
        NTMJ_GAME_OVER:
            CLR ntmj_flag_game_over
            LCALL NTMJ_DRAW_GAME_OVER
            RET

code
NTMJ_TIMER_0:
    PUSH ACC
    PUSH PSW
    MOV A, R0
    PUSH ACC
    MOV A, R1
    PUSH ACC
    CLR TR0
    
    ; Checagem do tempo pro passaro cair
    MOV A, ntmj_bird_time_counter
    ADD A, #1
    MOV ntmj_bird_time_counter, A
    MOV R0, A
    MOV A, ntmj_bird_time
    MOV R1, A
    ANL A, R0
    SUBB A, R1
    JNZ NTMJ_SKIP_BIRD_FALL
    MOV ntmj_bird_time_counter, #0
    SETB ntmj_flag_bird_fall
    NTMJ_SKIP_BIRD_FALL:
        MOV A, ntmj_pipe_timer_counter
        ADD A, #1
        MOV ntmj_pipe_timer_counter, A
        MOV R0, A
        MOV A, ntmj_pipe_timer
        MOV R1, A
        ANL A, R0
        SUBB A, R1
        JNZ NTMJ_SKIP_PIPE_MOVE
        MOV ntmj_pipe_timer_counter, #0
        SETB ntmj_flag_pipe_move
        NTMJ_SKIP_PIPE_MOVE:
            JB P1.0, NTMJ_SKIP_UP_PRESSED
            SETB ntmj_flag_bird_up
            NTMJ_SKIP_UP_PRESSED: 
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
    RET

; Atualizacao do placar
code
NTMJ_UPDATE_SCORE:
    JNB ntmj_flag_pipe_move, NTMJ_SKIP_UPDATE_SCORE ; Se o pipe nao estiver andando, skip!
    MOV A, ntmj_pipeA_x ; Salva o y do cano A no ACC
    SUBB A, #8 ; Subtrai o limiar pra contar ponto
    JZ INCREMENT_SCORE ; Se casou, score++!
    MOV A, ntmj_pipeB_x ; Se nao casou, vamos testar com o B
    SUBB A, #8 ; Subtrai o limiar pra contar ponto
    JZ INCREMENT_SCORE ; Se casou, score++!
    RET ; Se ainda assim nao casou, nada de ponto
INCREMENT_SCORE:
    INC ntmj_score ; score++!
NTMJ_SKIP_UPDATE_SCORE:
    RET

; Atualizacao das posicoes dos canos
code
NTMJ_UPDATE_PIPES:
    PUSH ACC ; Faz backup do ACC
    JNB ntmj_flag_pipe_move, NTMJ_SKIP_UPDATE_PIPES ; Se ainda nao chegou a hora de atualizar, skip!
    CLR ntmj_flag_pipe_move ; Se ja chegou a hora de atualizar, limpa a flag e continua
    SETB ntmj_flag_update_screen
    DEC ntmj_pipeA_x ; Diminui o X do cano A
    MOV A, ntmj_pipeA_x ; Salva no ACC
    JNZ NTMJ_SKIP_RESET_PIPE_A ; Se X != 0, nao devemos resetar o cano, skip!
    LCALL NTMJ_RESET_PIPE_A ; Se o X do cano A for 0, atingiu o fim da tela e deve resetar
    NTMJ_SKIP_RESET_PIPE_A:
        DEC ntmj_pipeB_x ; Diminui o X do cano B
        MOV A, ntmj_pipeB_x ; Salva no ACC
        JNZ NTMJ_SKIP_UPDATE_PIPES ; Se X != 0, nao devemos resetar o cano, skip!
        LCALL NTMJ_RESET_PIPE_B ; Se o X do cano B for 0, atingiu o fim da tela e deve resetar
        NTMJ_SKIP_UPDATE_PIPES:
            POP ACC ; Restaura ACC
            RET

; Atualizacao da posicao do passaro
code
NTMJ_UPDATE_BIRD:
    PUSH ACC ; Faz backup do ACC
    JNB ntmj_flag_bird_up, NTMJ_SKIP_UPDATE_BIRD_UP ; Se nao houve clique para subir o passaro, skip!
    CLR ntmj_flag_bird_up ; Se houve o clique, limpa o flag
    SETB ntmj_flag_update_screen
    MOV A, ntmj_bird_y ; Pega a posicao atual do passaro
    SUBB A, #2 ; Subtrai 1
    JNB ACC.7, NTMJ_SKIP_CHECK_NEG_POSITION ; Se o valor da subtracao for <0, precisamos reseta-la. Se nao, skip!
    MOV A, #0 ; Se o valor <0, reseta pra 0
    NTMJ_SKIP_CHECK_NEG_POSITION:
        MOV ntmj_bird_y, A ; Salva o valor resultante como nova posicao do passaro
        SJMP NTMJ_SKIP_UPDATE_BIRD_FALL ; Fim do metodo, ja que nao queremos q caia ao mesmo tempo que suba
        NTMJ_SKIP_UPDATE_BIRD_UP: ; Se nao houve pressionar, entao vamos verificar se deve cair
            JNB ntmj_flag_bird_fall, NTMJ_SKIP_UPDATE_BIRD_FALL ; Se ainda nao chegou a hora de atualizar a queda, skip!
            CLR ntmj_flag_bird_fall ; Se chegou a hora, limpa o flag
            INC ntmj_bird_y ; Reduz a altura do passaro aumentando seu Y
            NTMJ_SKIP_UPDATE_BIRD_FALL:
                POP ACC ; Restaura ACC
                RET

code
NTMJ_DETECT_COLLISION:
    ; se 5 < x_A < 16 && ((y_A + 15 < y_bird) || (y_bird < y_A))
    PUSH ACC
    
    ; Colisao se o passaro estiver com Y > 43
    MOV A, ntmj_bird_y
    SUBB A, #43
    JNB ACC.7, NTMJ_COLLISION_DETECTED

    ; O cano A nao colide se o seu X > 16
    MOV A, #16
    SUBB A, ntmj_pipeA_x
    JB ACC.7, NTMJ_SKIP_CHECK_PIPE_A

    ; O cano A tambem nao colide se seu X <= 3
    MOV A, ntmj_pipeA_x
    SUBB A, #3
    JB ACC.7, NTMJ_SKIP_CHECK_PIPE_A

    ; Mas se tudo isso foi verdade e o Y do passaro for menor ou igual que o do cano, colide!
    MOV A, ntmj_pipeA_y
    DEC A
    SUBB A, ntmj_bird_y
    JB ACC.7, NTMJ_TRY_CHECK_OTHER_CONDITION_A
    JMP NTMJ_COLLISION_DETECTED

    ; Ou, por fim, ha colisao se o passaro estiver acima de 15 do y do cano
    NTMJ_TRY_CHECK_OTHER_CONDITION_A:
        MOV A, ntmj_pipeA_y
        ADD A, #15
        MOV B, A
        MOV A, ntmj_bird_y
        SUBB A, B
        JB ACC.7, NTMJ_SKIP_CHECK_PIPE_A
        JMP NTMJ_COLLISION_DETECTED
        NTMJ_SKIP_CHECK_PIPE_A:
            ; Agora faz o mesmo pra B
            MOV A, #16
            SUBB A, ntmj_pipeB_x
            JB ACC.7, NTMJ_SKIP_CHECK_PIPE_B
            MOV A, ntmj_pipeB_x
            SUBB A, #3
            JB ACC.7, NTMJ_SKIP_CHECK_PIPE_B
            MOV A, ntmj_pipeB_y
            DEC A
            SUBB A, ntmj_bird_y
            JB ACC.7, NTMJ_TRY_CHECK_OTHER_CONDITION_B
            JMP NTMJ_COLLISION_DETECTED
            NTMJ_TRY_CHECK_OTHER_CONDITION_B:
                MOV A, ntmj_pipeB_y
                ADD A, #15
                MOV B, A
                MOV A, ntmj_bird_y
                SUBB A, B
                JB ACC.7, NTMJ_SKIP_CHECK_PIPE_B
                JMP NTMJ_COLLISION_DETECTED
                NTMJ_COLLISION_DETECTED:
                    SETB ntmj_flag_game_over
                    NTMJ_SKIP_CHECK_PIPE_B:
                        POP ACC
                        RET

; Metodos de desenho em memoria:
code
NTMJ_DRAW:
    LCALL NTMJ_CLEAR_SCREEN ; Limpa a tela na memoria
    LCALL NTMJ_DRAW_BIRD ; Desenha o passaro
    LCALL NTMJ_DRAW_PIPE_A ; Desenha o cano A
    LCALL NTMJ_DRAW_PIPE_B ; Desenha o cano B
    LCALL NTMJ_LCD_CONVERT_TO_COLUMNS;
    RET

; Passaro:
; ___xxxx_
; __x____x
; __xxx__x
; __x___x_
; ___xxx__

code
NTMJ_DRAW_BIRD:
    MOV DPTR, #0
    ; TODO Validacao de se estoura os limites da tela
    MOV B, ntmj_bird_y ; Numero da linha
    LCALL NTMJ_DRAW_GOTO_LINE

    MOV A, #1 ; O que vai ser desenhado nos pixels (00000001b)

    ; ___xxxx_
    MOV B, #11
    LCALL NTMJ_ADD_DPTR
    MOVX @DPTR, A
    INC DPTR
    MOVX @DPTR, A
    INC DPTR
    MOVX @DPTR, A
    INC DPTR
    MOVX @DPTR, A

    ; __x____x
    MOV B, #80 
    LCALL NTMJ_ADD_DPTR
    MOVX @DPTR, A
    MOV B, #5
    LCALL NTMJ_ADD_DPTR
    MOVX @DPTR, A

    ; __xxx__x
    MOV B, #79
    LCALL NTMJ_ADD_DPTR
    MOVX @DPTR, A
    INC DPTR
    MOVX @DPTR, A
    INC DPTR
    MOVX @DPTR, A
    MOV B, #3
    LCALL NTMJ_ADD_DPTR
    MOVX @DPTR, A

    ; __x___x_
    MOV B, #79
    LCALL NTMJ_ADD_DPTR
    MOVX @DPTR, A
    MOV B, #4
    LCALL NTMJ_ADD_DPTR
    MOVX @DPTR, A

    ; ___xxx__
    MOV B, #81
    LCALL NTMJ_ADD_DPTR
    MOVX @DPTR, A
    INC DPTR
    MOVX @DPTR, A
    INC DPTR
    MOVX @DPTR, A

    RET

code
NTMJ_DRAW_GOTO_LINE:
    PUSH ACC
    MOV A, #84 ; Quantidade de bytes pra deslocar por linha
    MUL AB ; Multiplica os valores anteriores, achando onde exatamente comeca
    MOV DPH, B
    MOV DPL, A
    POP ACC
    RET

code
NTMJ_GOTO_NEXT_LINE:
    PUSH ACC
    MOV A, DPL ; Pega o DPL pra ACC
    ADD A, #84 ; Soma 11 (quantidade de bytes em uma linha)
    MOV DPL, A ; Salva no DPL o ACC
    MOV A, DPH ; Pega o DPH pro ACC
    ADDC A, #00h ; Adiciona o carry da operacao anterior
    MOV DPH, A ; Salva no DPH o ACC
    POP ACC
    RET

code
NTMJ_ADD_DPTR:
    PUSH ACC
    MOV A, DPL ; Pega o DPL pra ACC
    ADD A, B ; Soma B (pula um byte)
    MOV DPL, A ; Salva no DPL o ACC
    MOV A, DPH ; Pega o DPH pro ACC
    ADDC A, #00h ; Adiciona o carry da operacao anterior
    MOV DPH, A ; Salva no DPH o ACC
    POP ACC
    RET

code
NTMJ_DRAW_PIPE:
    SETB RS0 ; Muda a pagina
    MOV R6, A ; Salva o argumento X em R6
    MOV R7, B ; Salva o argumento Y em R7

    MOV A, R7 ; Calculo da quantidade de bordas superiores (y - 2)
    SUBB A, #2 ; Subtrai 2 de Y
    MOV R4, A ; Salva em R4
    MOV A, #48 ; Calculo da quantidade de bordas inferiores (48 - y - 18)
    SUBB A, #15
    SUBB A, R7
    MOV R5, A ; Salva em R5
    MOV A, R6 ; Salva X em ACC
    MOV DPTR, #0
    MOV DPL, A ; O desenho vai comecar em X + 1

    NTMJ_PIPE_TOP_LOOP:
        INC DPTR ; O desenho vai comecar em X + 1
        MOV A, #1 ; Desenha a lateral esquerda do cano #00100010b
        MOVX @DPTR, A ; Desenha a lateral esquerda do cano #00100010b
        MOV B, #4 ; Desenha a lateral direita do cano #00100010b
        LCALL NTMJ_ADD_DPTR ; Desenha a lateral direita do cano #00100010b
        MOVX @DPTR, A ; Desenha a lateral direita do cano #00100010b
        MOV B, #79 ; Vai para a proxima linha do cano #00100010b
        LCALL NTMJ_ADD_DPTR ; Vai para a proxima linha do cano #00100010b
        DJNZ R4, NTMJ_PIPE_TOP_LOOP ; Enquanto nao completar a parte superior, refaz

    MOVX @DPTR, A ; Desenha a quina da esquerda do cano #01000001b
    MOV B, #6 ; Desenha a quina da direita do cano #01000001b
    LCALL NTMJ_ADD_DPTR ; Desenha a quina da direita do cano #01000001b
    MOVX @DPTR, A ; Desenha a quina da direita do cano #01000001b

    MOV B, #79 ; Pula pra proxima linha
    LCALL NTMJ_ADD_DPTR ; Desenha a quina da direita do cano #01000001b
    MOVX @DPTR, A ; Desenha a linha final do cano #00111110b
    INC DPTR ; Desenha a linha final do cano #00111110b
    MOVX @DPTR, A ; Desenha a linha final do cano #00111110b
    INC DPTR ; Desenha a linha final do cano #00111110b
    MOVX @DPTR, A ; Desenha a linha final do cano #00111110b
    INC DPTR ; Desenha a linha final do cano #00111110b
    MOVX @DPTR, A ; Desenha a linha final do cano #00111110b
    INC DPTR ; Desenha a linha final do cano #00111110b
    MOVX @DPTR, A ; Desenha a linha final do cano #00111110b

    MOV B, #252
    LCALL NTMJ_ADD_DPTR ; Pula a quantidade de linhas em branco necessarias
    LCALL NTMJ_ADD_DPTR ; Pula a quantidade de linhas em branco necessarias
    LCALL NTMJ_ADD_DPTR ; Pula a quantidade de linhas em branco necessarias
    LCALL NTMJ_ADD_DPTR ; Pula a quantidade de linhas em branco necessarias
    MOV B, #248 ; No ultimo pulo, fazemos -4 para ja cair na posicao certa
    LCALL NTMJ_ADD_DPTR ; Pula a quantidade de linhas em branco necessarias

    MOVX @DPTR, A ; Desenha a linha final do cano #00111110b
    INC DPTR ; Desenha a linha final do cano #00111110b
    MOVX @DPTR, A ; Desenha a linha final do cano #00111110b
    INC DPTR ; Desenha a linha final do cano #00111110b
    MOVX @DPTR, A ; Desenha a linha final do cano #00111110b
    INC DPTR ; Desenha a linha final do cano #00111110b
    MOVX @DPTR, A ; Desenha a linha final do cano #00111110b
    INC DPTR ; Desenha a linha final do cano #00111110b
    MOVX @DPTR, A ; Desenha a linha final do cano #00111110b

    MOV B, #79 ; Vai para a proxima linha do cano
    LCALL NTMJ_ADD_DPTR ; Vai para a proxima linha do cano

    MOVX @DPTR, A ; Desenha a quina da esquerda do cano #01000001b
    MOV B, #6 ; Desenha a quina da direita do cano #01000001b
    LCALL NTMJ_ADD_DPTR ; Desenha a quina da direita do cano #01000001b
    MOVX @DPTR, A ; Desenha a quina da direita do cano #01000001b

    MOV B, #79 ; Vai para a proxima linha
    LCALL NTMJ_ADD_DPTR ; Vai para a proxima linha
    NTMJ_PIPE_BOTTOM_LOOP:
        MOV A, #1 ; Desenha a lateral esquerda do cano #00100010b
        MOVX @DPTR, A ; Desenha a lateral esquerda do cano #00100010b
        MOV B, #4 ; Desenha a lateral direita do cano #00100010b
        LCALL NTMJ_ADD_DPTR ; Desenha a lateral direita do cano #00100010b
        MOVX @DPTR, A ; Desenha a lateral direita do cano #00100010b
        MOV B, #80 ; Vai para a proxima linha do cano #00100010b
        LCALL NTMJ_ADD_DPTR ; Vai para a proxima linha do cano #00100010b
        DJNZ R5, NTMJ_PIPE_BOTTOM_LOOP
    CLR RS0
    RET

code
NTMJ_DRAW_PIPE_A:
    MOV A, ntmj_pipeA_x ; Salva X em A
    MOV B, ntmj_pipeA_y ; Salva Y em B
    LCALL NTMJ_DRAW_PIPE
    RET

code
NTMJ_DRAW_PIPE_B:
    MOV A, ntmj_pipeB_x ; Salva X em A
    MOV B, ntmj_pipeB_y ; Salva Y em B
    LCALL NTMJ_DRAW_PIPE
    RET

; Metodos de desenho no LCD

code
NTMJ_LCD_CONVERT_TO_COLUMNS:
    PUSH PSW ; Salva a pagina atual
    PUSH ACC ; Salva o ACC atual
    SETB RS1 ; Vai para a pagina do LCD
    SETB RS0 ; Vai para a pagina do LCD
    MOV DPTR, #ntmj_lcd_screen
    MOV R0, DPL ; Guarda valor do DPTR para a memoria do LCD
    MOV R1, DPH ; Guarda valor do DPTR para a memoria do LCD
    MOV DPTR, #ntmj_screen ; Vai para o comeco da tela na memoria
    MOV R2, DPL ; Guarda valor do DPTR para a memoria de desenho
    MOV R3, DPH ; Guarda valor do DPTR para a memoria de desenho
    MOV R6, #6 ; Quantidade de linhas a serem andadas no display
    NTMJ_CONVERT_LCD_LINE:
        MOV R7, #84 ; Quantidade de colunas a serem andadas no display
        NTMJ_CONVERT_LCD_COLUMN:
            LCALL NTMJ_EXTRACT_LCD_COLUMN ; Salva em B o resultado do extract column
            INC DPTR ; Aponta para a proxima coluna, na memoria
            ; Salva o valor atual da memoria de desenho
            MOV R2, DPL ; Guarda valor do DPTR para a memoria de desenho
            MOV R3, DPH ; Guarda valor do DPTR para a memoria de desenho
            ; Recupera o valor da memoria de LCD
            MOV DPL, R0
            MOV DPH, R1
            MOV A, B
            MOVX @DPTR, A
            INC DPTR
            MOV R0, DPL ; Guarda valor do DPTR para a memoria do LCD
            MOV R1, DPH ; Guarda valor do DPTR para a memoria do LCD
            MOV DPL, R2 ; Recupera valor do DPTR para a memoria de desenho
            MOV DPH, R3 ; Recupera valor do DPTR para a memoria de desenho
            DJNZ R7 NTMJ_CONVERT_LCD_COLUMN ; Se ainda restam colunas a visitar, refaz
            MOV B, #252 ; Vai para a proxima linha Y
            LCALL NTMJ_ADD_DPTR ; Vai para a proxima linha Y
            MOV B, #252 ; Vai para a proxima linha Y
            LCALL NTMJ_ADD_DPTR ; Vai para a proxima linha Y
            MOV B, #84 ; Vai para a proxima linha Y
            LCALL NTMJ_ADD_DPTR ; Vai para a proxima linha Y
            DJNZ R6 NTMJ_CONVERT_LCD_LINE ; Se ainda restarem linhas a visitar, refaz
    POP ACC ; Restaura o ACC anterior
    POP PSW ; Restaura a pagina anterior
    RET

; Transfere e tela da memoria para o LCD
code
NTMJ_DRAW_TO_LCD:
    PUSH PSW ; Salva a pagina atual
    PUSH ACC ; Salva o ACC atual
    SETB RS1 ; Vai para a pagina do LCD
    SETB RS0 ; Vai para a pagina do LCD
    MOV DPTR, #ntmj_lcd_screen ; Vai para o comeco da tela na memoria
    MOV A, #0 ; Vai para o comeco da tela no LCD
    MOV B, #0 ; Vai para o comeco da tela no LCD
    LCALL LCD_ACC_XY ; Vai para o comeco da tela no LCD
    MOV R6, #6 ; Quantidade de linhas a serem andadas no display
    NTMJ_DRAW_LCD_LINE:
        MOV R7, #84 ; Quantidade de colunas a serem andadas no display
        NTMJ_DRAW_LCD_COLUMN:
            MOVX A, @DPTR
            MOV B, A
            LCALL LCD_ACC_DRAW ; Usa o B resultante anterior pra desenhar no LCD
            INC DPTR ; Aponta para a proxima coluna, na memoria
            DJNZ R7 NTMJ_DRAW_LCD_COLUMN ; Se ainda restam colunas a visitar, refaz
            DJNZ R6 NTMJ_DRAW_LCD_LINE ; Se ainda restarem linhas a visitar, refaz
    MOV A, #2
    MOV B, #0
    LCALL LCD_ACC_XY
    POP ACC ; Restaura o ACC anterior
    POP PSW ; Restaura a pagina anterior
    LCALL NTMJ_DRAW_SCORE
    RET

; Extrai um byte de coluna da representa da tela, em memoria
code
NTMJ_EXTRACT_LCD_COLUMN:
    PUSH ACC ; Guarda o acumulador atual
    MOV A, DPH ; Guarda o DPH
    PUSH ACC ; Guarda o DPH
    MOV A, DPL ; Guarda o DPL
    PUSH ACC ; Guarda o DPL
    MOV R5, #0 ; Resultado
    MOV R3, #8 ; Contador de bytes a serem utilizados
    NTMJ_EXTRACT_LCD_LOOP: 
        MOVX A, @DPTR ; Le o byte atual
        MOV R4, A ; Salva o byte atual em R4
        MOV A, R5 ; Recupera o resultado mais recente
        ORL A, R4 ; Adiciona o byte atual no resultado
        RR A ; Rotaciona o novo resultado
        MOV R5, A ; Sobrescreve o resultado antigo pelo atualizado
        MOV B, #84 ; Avanca para o endereco do proximo byte
        LCALL NTMJ_ADD_DPTR ; Avanca para o endereco do proximo byte
        DJNZ R3 NTMJ_EXTRACT_LCD_LOOP ; Se ainda nao atingiu a qtd de bytes, faz de novo
    MOV B, R5 ; Salva o resultado em B, para retorno
    POP ACC ; Recupera o DPL
    MOV DPL, A ; Recupera o DPL
    POP ACC ; Recupera o DPH
    MOV DPH, A ; Recupera o DPH
    POP ACC ; Recupera o ACC
    RET

code
NTMJ_DRAW_NUMBER:
    PUSH ACC
    MOV A, R0
    PUSH ACC
    MOV A, #3
    MUL AB
    MOV R0, A
    MOV B, #0
    LCALL LCD_ACC_DRAW
    MOV A, R0
    MOV DPTR, #ntmj_numbers_font
    MOVC A, @A+DPTR
    MOV B, A
    LCALL LCD_ACC_DRAW
    INC R0
    MOV A, R0
    MOVC A, @A+DPTR
    MOV B, A
    LCALL LCD_ACC_DRAW
    INC R0
    MOV A, R0
    MOVC A, @A+DPTR
    MOV B, A
    LCALL LCD_ACC_DRAW
    INC R0
    MOV A, R0
    MOV B, #0
    LCALL LCD_ACC_DRAW
    POP ACC
    MOV R0, A
    POP ACC
    RET

code
NTMJ_DRAW_SCORE:
    PUSH ACC
    MOV A, R0
    PUSH ACC
    MOV A, ntmj_score
    MOV B, #10
    DIV AB
    MOV R0, B
    MOV B, A
    LCALL NTMJ_DRAW_NUMBER
    MOV B, R0
    LCALL NTMJ_DRAW_NUMBER
    POP ACC
    MOV R0, A
    POP ACC
    RET

code
NTMJ_DRAW_GAME_OVER:
    MOV A, #0
    MOV B, #0
    LCALL LCD_ACC_XY
    MOV DPTR, #ntmj_gameover_screen_line_1
    LCALL NTMJ_DRAW_GO_LINE
    MOV DPTR, #ntmj_gameover_screen_line_2
    LCALL NTMJ_DRAW_GO_LINE
    MOV DPTR, #ntmj_gameover_screen_line_3
    LCALL NTMJ_DRAW_GO_LINE
    MOV DPTR, #ntmj_gameover_screen_line_4
    LCALL NTMJ_DRAW_GO_LINE
    MOV DPTR, #ntmj_gameover_screen_line_5
    LCALL NTMJ_DRAW_GO_LINE
    MOV DPTR, #ntmj_gameover_screen_line_6
    LCALL NTMJ_DRAW_GO_LINE
    MOV A, #61
    MOV B, #3
    LCALL LCD_ACC_XY
    LCALL NTMJ_DRAW_SCORE
    JNB ntmj_flag_bird_up, $
    CLR ntmj_flag_bird_up
    RET

code
NTMJ_DRAW_GO_LINE:
    MOV R5, #84
    MOV R4, #0
    NTMJ_DRAW_GAME_OVER_INNER_LOOP:
        MOV A, R4
        INC R4
        MOVC A, @A+DPTR
        MOV B, A
        LCALL LCD_ACC_DRAW
        DJNZ R5, NTMJ_DRAW_GAME_OVER_INNER_LOOP
    RET

; -- LCD CODE
code
LCD_ACC_XY:
    PUSH ACC 
    PUSH PSW 
    SETB RS1
    CLR RS0
    MOV lcd_X, A
    MOV lcd_Y, B
    LCALL LCD_XY
    POP PSW
    POP ACC
    ret

code
LCD_ACC_DRAW:
    PUSH ACC 
    PUSH PSW 
    SETB RS1
    CLR RS0
    MOV lcd_bus, B
    LCALL LCD_DRAW
    POP PSW
    POP ACC
    ret

code ;ROTINA para inicialização do LCD, deve ser chamada por um CALL
LCD_INIT:
    PUSH ACC ;Acumulador para pilha
    PUSH PSW ;Guardar a infromação do banco de registradores que está sendo utilizado
    SETB RS1
    CLR RS0
    SETB lcd_reset ;RESET
    SETB lcd_ce    ;Set Chip Enabled
    ;CLR lcd_reset
    LCALL BIG_DELAY
    ;SETB lcd_reset ;RESET
    
    ;Rotina de inicialização
    MOV lcd_bus, #021h  
    LCALL LCD_SEND_COMMAND
    
    MOV lcd_bus, #0A0h  
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
LCD_SEND_SERIAL_DATA: ;Dados vem na posição R0, R7 serve como contador (utiliza pag2)
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
    PUSH PSW ;Guardar a infromação do banco de registradores que está sendo utilizado
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
    PUSH PSW ;Guardar a infromação do banco de registradores que está sendo utilizado
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
    PUSH PSW ;Guardar a infromação do banco de registradores que está sendo utilizado
    SETB RS1
    CLR RS0
    ;080h X R1
    ;040h Y R2
    ;Recalcular o valor de Y (R2)
    MOV A, lcd_Y
    ORL A, #040h ;Sem garantia que o valor seja válido
    MOV lcd_bus, A
    LCALL LCD_SEND_COMMAND
    ;Recalcular valor de X (R1)
    MOV A, lcd_X
    ORL A, #080h ;Sem garantia que o valor seja válido
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

; RANDOM
; generates an 8 bit pseudo-random number which is returned in Acc.
; one byte of memory must be available for rand8reg
code
RAND8:  
    mov a, rand8reg
    jnz rand8b
    cpl a
    mov rand8reg, a
rand8b: 
    anl a, #10111000b
    mov c, p
    mov a, rand8reg
    rlc a
    mov rand8reg, a
    ret

; generates a 16 bit pseudo-random number which is returned in Acc (lsb) & B (msb)
; two bytes of memory must be available for rand16reg
code
RAND16: 
    mov a, rand16reg
    jnz rand16b
    mov a, rand16reg+1
    jnz rand16b
    cpl a
    mov rand16reg, a
    mov rand16reg+1, a
rand16b:
    anl a, #11010000b
    mov c, p
    mov a, rand16reg
    jnb acc.3, rand16c
    cpl c
rand16c:
    rlc a
    mov rand16reg, a
    mov b, a
    mov a, rand16reg+1
    rlc a
    mov rand16reg+1, a
    xch a, b
    ret
