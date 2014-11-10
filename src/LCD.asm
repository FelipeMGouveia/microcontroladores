;Definição das portas a serrem utilizadas pelo LCD
lcd_ce    SET P1.6 ;Chip enabled
lcd_reset SET P1.5 ;Reset
lcd_dc    SET P1.7 ;Data Comando
lcd_clk   SET P3.1 ;Clock
lcd_din   SET P3.0 ;Data in

lcd_bus   SET R0 ;Posição a ser utilizada pelo LCD para acesso bit-a-bit
lcd_X     SET R1 ;
lcd_Y     SET R2 ;

; O LCD utilizará o banco de registradores 2, segundo a seguinte especificação:
; R0 - Byte/comando a ser escrito no LCD
; R1 - Coordenada X da função LDC_XY
; R2 - Coordenada Y da função LCD_XY

; R3 - Utilizado no LCD_CLEAR como contador (numero de linhas)
; R4 - Utilizado no LCD_CLEAR como contador (numero de colunas)

; R5 - utilizado internamente como contador para o delay (pode-se utilizar o timer e se livrar desse cara)
; R6 - utilizado internamente como contador para o delay (pode-se utilizar o timer e se livrar desse cara)
; R7 - utilizado internamente como contador para o envio.

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