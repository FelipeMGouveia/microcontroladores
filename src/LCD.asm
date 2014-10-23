;Definição das portas a serrem utilizadas pelo LCD
lcd_ce    SET P1.6 ;Chip enabled
lcd_reset SET P1.5 ;Reset
lcd_dc    SET P1.7 ;Data Comando
lcd_clk   SET P3.1 ;Clock
lcd_din   SET P3.0 ;Data in

lcd_bus   SET 020h ;Posição a ser utilizada pelo LCD para acesso bit-a-bit

code ;ROTINA para inicialização do LCD, deve ser chamada por um CALL
LCD_INIT:

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
    
    MOV lcd_bus, #013h 
    LCALL LCD_SEND_COMMAND
    
    MOV lcd_bus, #020h 
    LCALL LCD_SEND_COMMAND
    
    MOV lcd_bus, #009h 
    LCALL LCD_SEND_COMMAND
    
    MOV lcd_bus, #008h 
    LCALL LCD_SEND_COMMAND
    
    MOV lcd_bus, #00Ch 
    LCALL LCD_SEND_COMMAND
    ret

code ;Desenha um byte na tela
LCD_DRAW:
    LCALL LCD_SEND_DATA
    ret

code
LCD_SEND_SERIAL_DATA: ;Dados vem na posição R0, R1 serve como contador (utiliza pag2)
    MOV R1, #008h 
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
        DJNZ R1, LCD_SEND_SERIAL_DATA_INTERNAL_LOOP
    ret

code
LCD_SEND_COMMAND:
; Registrador R0 deve conter o comando a ser enviado
    PUSH ACC ;Acumulador para pilha
    PUSH PSW ;Guardar a infromação do banco de registradores que está sendo utilizado
    CLR lcd_dc ;Modo comando
    CLR lcd_ce ;Ativa o display
    LCALL LCD_SEND_SERIAL_DATA
    SETB lcd_ce ;Desativa o display
    ;Volta os registradores PSW e ACC respectivamente
    POP PSW
    POP ACC
    ret

LCD_SEND_DATA:
; Registrador R0 deve conter o dado a ser enviado
    PUSH ACC ;Acumulador para pilha
    PUSH PSW ;Guardar a infromação do banco de registradores que está sendo utilizado
    SETB lcd_dc ;Modo Dados
    CLR lcd_ce ;Ativa o display
    LCALL LCD_SEND_SERIAL_DATA
    SETB lcd_ce ;Ativa o display
    ;Volta os registradores PSW e ACC respectivamente
    POP PSW
    POP ACC
    ret

code
BIG_DELAY:
        MOV R4, #10d
    INIT_DELAY_3:
        MOV R2, #255d
    INIT_DELAY_2:
        MOV R1, #255d
    INIT_DELAY:    
        DJNZ R1, INIT_DELAY
        DJNZ R2, INIT_DELAY_2
        DJNZ R4, INIT_DELAY_3
    ret