$include(REG52.inc) ;Utilizando reg52 para termos acesso ao terceiro timer caso necess�rio

;Podemos dividir o c�dgigo de cada um em um asm separado, para evitar problema
;com nomenclatura sugiro termos esses arquivos pr�-definidos.
$include (tetris.asm)

code at 0
    ljmp INIT

code
INIT: ;Inicializa��o das interrup��es, do display e do que mais for necess�rio
    lcall TIMER_INIT
    lcall LCD_INIT
    ljmp MAIN 
    
code ;ROTINA para inicializa��o do LCD, deve ser chamada por um CALL
LCD_INIT:
    ret;

code ;Desenha um byte na tela
LCD_DRAW:
    ret;

code ;ROTINA para inicializa��o do Timer, de ser chamado por um CALL
TIMER_INIT:
    ret;

code ;Entrada principal onde ser� exibido o c�digo de menu para sele��o do jogo
MAIN: 
    lcall FMG_TETRIS_MAIN
    END