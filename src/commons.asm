$include(REG52.inc) ;Utilizando reg52 para termos acesso ao terceiro timer caso necess�rio

$include(LCD.asm)
;Podemos dividir o c�dgigo de cada um em um asm separado, para evitar problema
;com nomenclatura sugiro termos esses arquivos pr�-definidos.
$include (tetris.asm)

code at 0
    ljmp INIT

code
INIT: ;Inicializa��o das interrup��es, do display e do que mais for necess�rio
    MOV SP, #60h ; Move o stack pointer para o endere�o 60h
    LCALL TIMER_INIT
    LCALL LCD_INIT
    LJMP MAIN 
    
code ;ROTINA para inicializa��o do Timer, de ser chamado por um CALL
TIMER_INIT:
    ret;

code ;ROTINA para tratamento da interrup��o do timer0
TIMER0_INTERRUPT:
    PUSH ACC ;Acumulador para pilha
    PUSH PSW ;Guardar a infroma��o do banco de registradores que est� sendo utilizado    
    ;Utilizar p�gina 1 para interrup��o do timer 1 (timer do jogo)
    SETB RS0
    CLR RS1
    
    ;Volta os registradores PSW e ACC respectivamente
    POP PSW
    POP ACC
    ret;

code ;Entrada principal onde ser� exibido o c�digo de menu para sele��o do jogo
MAIN: 
    ;Banco 2
    SETB RS1
    CLR RS0
    MOV R1, #001h
    MOV R2, #001h
LOOP_MAIN:
    MOV A, #01010101b
    LCALL LCD_XY
    MOV lcd_bus, A
    LCALL LCD_DRAW
    SJMP LOOP_MAIN
    LCALL FMG_TETRIS_MAIN
END
