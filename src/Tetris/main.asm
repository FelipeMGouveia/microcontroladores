code
FMG_TETRIS_MAIN:
    ;Configura��o do timer_0
    MOV A, #00Fh
    MOV fmg_time_to_fall, A
    
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
    MOV fmg_piece_y, #00Ah
    
    LCALL FMG_DRAW_NEXT_PIECE ; Desenha a pe�a que est� na espera

    ;Loop de um jogo corrente.
    ;LCALL FMG_UPDATE_STATE ; Atualiza o estado atual do jogo
    ;LCALL FMG_DRAW_SCREEN ; Desenha o jogo atual
    FMG_WAIT_ETERNAL:
        LCALL FMG_DRAW_NEXT_PIECE ; Desenha a pe�a que est� na espera
        LCALL FMG_UPDATE_STATE ;Movimenta a pe�a atual.
        LCALL FMG_VALIDATE_COLLISION ; Valida se ocorreu uma colis�o
        
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