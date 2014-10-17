$include(REG52.inc) ;Utilizando reg52 para termos acesso ao terceiro timer caso necessário

;Podemos dividir o códgigo de cada um em um asm separado, para evitar problema
;com nomenclatura sugiro termos esses arquivos pré-definidos.
$include (tetris.asm)

code at 0
    ljmp INIT

code
INIT: ;Inicialização das interrupções, do display e do que mais for necessário
    lcall TIMER_INIT
    lcall LCD_INIT
    ljmp MAIN 
    
code ;ROTINA para inicialização do LCD, deve ser chamada por um CALL
LCD_INIT:
    ret;

code ;Desenha um byte na tela
LCD_DRAW:
    ret;

code ;ROTINA para inicialização do Timer, de ser chamado por um CALL
TIMER_INIT:
    ret;

code ;Entrada principal onde será exibido o código de menu para seleção do jogo
MAIN: 
    lcall FMG_TETRIS_MAIN
    END