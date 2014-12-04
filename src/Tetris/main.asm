code
FMG_TETRIS_MAIN:
    ;Configuração do timer_0
    MOV A, #00Fh
    MOV fmg_time_to_fall, A
    
    CLR EA ;Desabilita interrupção até configurar o(s) timer(s)
    CLR TR0 ; Para o timer 0

    MOV TMOD, #001h
    
    MOV A, #0DCh
    MOV TL0, A
    
    MOV A, #011h
    MOV TH0, A
    
    SETB ET0 ;Ativa a interrupção do timer 0
    SETB TR0 ;Ativa o timer 0
    SETB EA ;Ativa interrupção
    
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
    MOV fmg_piece_x, #007h
    MOV fmg_piece_y, #00Ah
    
    LCALL FMG_DRAW_NEXT_PIECE ; Desenha a peça que está na espera

    ;Loop de um jogo corrente.
    ;LCALL FMG_UPDATE_STATE ; Atualiza o estado atual do jogo
    ;LCALL FMG_DRAW_SCREEN ; Desenha o jogo atual
    FMG_WAIT_ETERNAL:
        LCALL FMG_DRAW_NEXT_PIECE ; Desenha a peça que está na espera
        LCALL FMG_UPDATE_STATE ;Movimenta a peça atual.
        LCALL FMG_VALIDATE_COLLISION ; Valida se ocorreu uma colisão
        
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
    RET