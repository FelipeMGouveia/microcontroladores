$include(REG52.inc) ;Utilizando reg52 para termos acesso ao terceiro timer caso necessário

$include(LCD.asm)
;Podemos dividir o códgigo de cada um em um asm separado, para evitar problema
;com nomenclatura sugiro termos esses arquivos pré-definidos.
$include (tetris.asm)

code at 0
    ljmp INIT

code
INIT: ;Inicialização das interrupções, do display e do que mais for necessário
    MOV SP, #60h ; Move o stack pointer para o endereço 60h
    LCALL TIMER_INIT
    LCALL LCD_INIT
    LJMP MAIN 
    
code ;ROTINA para inicialização do Timer, de ser chamado por um CALL
TIMER_INIT:
    ret;

code ;ROTINA para tratamento da interrupção do timer0
TIMER0_INTERRUPT:
    PUSH ACC ;Acumulador para pilha
    PUSH PSW ;Guardar a infromação do banco de registradores que está sendo utilizado    
    ;Utilizar página 1 para interrupção do timer 1 (timer do jogo)
    SETB RS0
    CLR RS1
    
    ;Volta os registradores PSW e ACC respectivamente
    POP PSW
    POP ACC
    ret;

code ;Entrada principal onde será exibido o código de menu para seleção do jogo
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
