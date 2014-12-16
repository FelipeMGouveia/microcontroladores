$include(REG52.inc)
$include(Random.asm)
$include(LCD.asm)

SNAKE_MAX_SIZE SET 0x02
SNAKE_MAX_SIZE_ADDRESS SET 0x50

SNAKE_SCREEN_WIDTH SET 0x04
SNAKE_SCREEN_WIDTH_ADDRESS SET 0x51

SNAKE_SCREEN_HEIGHT SET 0x04
SNAKE_SCREEN_HEIGHT_ADDRESS SET 0x52

SNAKE_X_ARRAY_START_ADDRESS SET 0xA0
SNAKE_Y_ARRAY_START_ADDRESS SET 0xA8

SNAKE_ADD_X_ADDRESS SET 0x53
SNAKE_ADD_Y_ADDRESS SET 0x54

SNAKE_SIZE_ADDRESS SET 0x55

SNAKE_PRE_SCREEN_Y_START_ADDRESS SET 0xB4

code at 0
    MOV SP, #078h
    ljmp SNAKE_MAIN

SNAKE_MAIN:
    LCALL SNAKE_CLEAR_MEMORY ; limpa a região de memória da Snake
    LCALL SNAKE_INIT ; configura o estado inicial da Snake
    SNAKE_MAIN_LOOP:
        LCALL SNAKE_CONVERT_MEMORY ; lê a memória da Snake e converte para informação pré-tela
        LCALL LCD_CLEAR ; limpa a tela
        LCALL SNAKE_DRAW_SCREEN ; lê e região de memória que armazena as informações da Snake e imprime na tela
        LCALL SNAKE_READ_BUTTONS ; lê os botões e atualiza a memória
        LCALL SNAKE_UPDATE ; atualiza a região de memória da Snake
        SJMP SNAKE_MAIN_LOOP
    RET

code
SNAKE_CLEAR_MEMORY:
    ; limpando região X
    MOV R1, #SNAKE_MAX_SIZE
    MOV R0, #SNAKE_X_ARRAY_START_ADDRESS
    SNAKE_CLEAR_X_MEMORY_LOOP_START:
        MOV @R0, #001h
        INC R0
        DJNZ R1, SNAKE_CLEAR_X_MEMORY_LOOP_START
    
    ; limpando região Y
    MOV R1, #SNAKE_MAX_SIZE
    MOV R0, #SNAKE_Y_ARRAY_START_ADDRESS
    SNAKE_CLEAR_Y_MEMORY_LOOP_START:
        MOV @R0, #001h
        INC R0
        DJNZ R1, SNAKE_CLEAR_Y_MEMORY_LOOP_START
    RET
    
code
SNAKE_INIT:
    MOV R0, #SNAKE_MAX_SIZE_ADDRESS
    MOV @R0, #SNAKE_MAX_SIZE
    
    MOV R0, #SNAKE_SCREEN_WIDTH_ADDRESS
    MOV @R0, #SNAKE_SCREEN_WIDTH
    
    MOV R0, #SNAKE_SCREEN_HEIGHT_ADDRESS
    MOV @R0, #SNAKE_SCREEN_HEIGHT
    
    ; a snake começa com duas partes
    MOV R0, #SNAKE_SIZE_ADDRESS
    MOV @R0, #02h

    LCALL RAND8 ; gera um número aleatório no acumulador TODO
    MOV A, #005h
    MOV R0, #SNAKE_X_ARRAY_START_ADDRESS
    MOV @R0, A ; seta posição X inicial da comida ; x[0] = rand
    INC R0
    MOV @R0, #01h ; x[1] = 1
    INC R0
    MOV @R0 #01h ; x[2] = 1
    
    LCALL RAND8 ; gera um número aleatório no acumulador TODO
    MOV A, #005h
    MOV R0, #SNAKE_Y_ARRAY_START_ADDRESS
    MOV @R0, A ; seta posição Y inicial da comida ; y[0] = rand
    INC R0
    MOV @R0, #02H ; y[1] = 2
    INC R0
    MOV @R0, #01H ; y[2] = 1
    
    MOV R0, #SNAKE_ADD_X_ADDRESS
    MOV @R0, #00H
    MOV R0, #SNAKE_ADD_Y_ADDRESS
    MOV @R0, #01H
    RET
    
code
SNAKE_DRAW_SCREEN:
    MOV lcd_X, #000H
    MOV lcd_Y, #000H
    LCALL LCD_XY
    
    MOV R7, #008H ; contador inicial
    MOV R6, #SNAKE_PRE_SCREEN_Y_START_ADDRESS
    MOV R0, #000H
    SNAKE_START_BUILD_BYTE:
        MOV A, R0
        RR A
        MOV R0, A
        
        MOV A, R6
        MOV R1, A
        MOV A, @R1
        RR A
        
        ORL A, R0
        MOV R0, A
        
        MOV A, R6
        ADD A, #SNAKE_SCREEN_WIDTH
        MOV R6, A
        DJNZ R7, SNAKE_START_BUILD_BYTE
        
    ; R0 tá com o byte a ser impresso
    MOV A, R0
    MOV lcd_bus, A
    LCALL LCD_DRAW
    
    RET

code
SNAKE_UPDATE:
    MOV R0, #SNAKE_SIZE_ADDRESS
    MOV A, @R0
    MOV R3, A
    LOOP_UPDATE_BODY:
        MOV A, R3
        CJNE A, #001h, BODY
        SETB C
    BODY:
        JC AFTER_LOOP
        
        MOV    A, R3
        ADD    A, #SNAKE_X_ARRAY_START_ADDRESS + 0FFH
        MOV    R0, A
        MOV    A, R3
        ADD    A, #SNAKE_X_ARRAY_START_ADDRESS
        MOV    R1, A
        MOV    A, @R0
        MOV    @R1, A
        
        MOV    A, R3
        ADD    A, #SNAKE_Y_ARRAY_START_ADDRESS + 0FFH
        MOV    R0, A
        MOV    A, R3
        ADD    A, #SNAKE_Y_ARRAY_START_ADDRESS
        MOV    R1, A
        MOV    A, @R0
        MOV    @R1, A
        
        DEC R3
        SJMP LOOP_UPDATE_BODY
    AFTER_LOOP:
       MOV R0, #SNAKE_ADD_X_ADDRESS
       MOV A, @R0
       MOV R0, #SNAKE_X_ARRAY_START_ADDRESS + 02H
       ADD A, @R0
       MOV R0, #SNAKE_X_ARRAY_START_ADDRESS + 01H
       MOV @R0, A
       
       MOV R0, #SNAKE_ADD_Y_ADDRESS
       MOV A, @R0
       MOV R0, #SNAKE_Y_ARRAY_START_ADDRESS + 02H
       ADD A, @R0
       MOV R0, #SNAKE_Y_ARRAY_START_ADDRESS + 01H
       MOV @R0, A
    RET
    
code
SNAKE_READ_BUTTONS:
    CHECK_LEFT:
        JNB P1.2, CHECK_RIGHT
        
        ;  addy = 0;
        CLR A
        MOV SNAKE_ADD_Y_ADDRESS, A
        
        ; if (addx != 1)
        MOV A, SNAKE_ADD_X_ADDRESS
        XRL A, #001H
        JZ ELSE_CHECK_LEFT
        
        ; addx = -1;
        MOV SNAKE_ADD_X_ADDRESS, #0FFH
        SJMP CHECK_RIGHT
        
        ELSE_CHECK_LEFT:
            ; addx = 1;
            MOV SNAKE_ADD_X_ADDRESS, #001H
        
    CHECK_RIGHT:
        JNB P1.3, CHECK_DOWN
        
        ;  addy = 0;
        CLR A
        MOV SNAKE_ADD_Y_ADDRESS, A
        
        CJNE A, #0FFH, NOT_EQUAL
        MOV A, SNAKE_ADD_X_ADDRESS
        CPL A
        JZ ELSE_CHECK_RIGHT
        
        NOT_EQUAL:
            MOV SNAKE_ADD_X_ADDRESS, #001H
            SJMP CHECK_DOWN
        ELSE_CHECK_RIGHT:
             MOV SNAKE_ADD_X_ADDRESS, #0FFH
             
    CHECK_DOWN:
        JB P1.1, CHECK_UP
        CLR    A
        MOV    SNAKE_ADD_Y_ADDRESS,A
        CJNE   A,#0FFH,NOT_EQUAL_CHECK_DOWN
        MOV    A,SNAKE_ADD_Y_ADDRESS
        CPL    A
        JZ     NOT_EQUAL_CHECK_DOWN
        
        NOT_EQUAL_CHECK_DOWN:
            MOV    SNAKE_ADD_Y_ADDRESS,#001H
            SJMP   CHECK_UP
        CHECK_DOWN_ELSE:
            MOV    SNAKE_ADD_Y_ADDRESS,#0FFH
        
    CHECK_UP:
        JB     P1.0, CHECK_BUTTONS_END
        CLR    A
        MOV    SNAKE_ADD_X_ADDRESS,A
        MOV    A,SNAKE_ADD_Y_ADDRESS
        XRL    A,#001H
        JZ     CHECK_UP_ELSE
        MOV    SNAKE_ADD_Y_ADDRESS,#0FFH
        RET
        CHECK_UP_ELSE:
            MOV    SNAKE_ADD_Y_ADDRESS,#001H
        CHECK_BUTTONS_END:
    RET
    
code
SNAKE_CONVERT_MEMORY:
    ; limpa a memoria antes de popular (sempre populo todos pixels)
    MOV R5, #000H
    SNAKE_CONVERT_MEMORY_LOOP_CLEAN_MEMORY_I:
        MOV R6, #00H
        SNAKE_CONVERT_MEMORY_LOOP_CLEAN_MEMORY_J:
            MOV A, R5
            MOV B, #SNAKE_SCREEN_HEIGHT
            MUL AB
            ADD A,#SNAKE_PRE_SCREEN_Y_START_ADDRESS
            MOV R0, A
            MOV A, R6
            ADD A, R0
            MOV R0, A
            MOV @R0, #000H
            
            INC R6
            MOV A, R6
            CJNE A, #SNAKE_SCREEN_HEIGHT, SNAKE_CONVERT_MEMORY_LOOP_CLEAN_MEMORY_J
        INC R5
        MOV A, R5
        CJNE A, #SNAKE_SCREEN_WIDTH, SNAKE_CONVERT_MEMORY_LOOP_CLEAN_MEMORY_I
            

    MOV    R6,#001H
    SNAKE_CONVERT_MEMORY_LOOP:
        MOV    A,R6
        CJNE   A, #SNAKE_MAX_SIZE + 01H, SNAKE_CONVERT_MEMORY_LOOP_CONTENT
    LJMP SNAKE_CONVERT_MEMORY_LOOP_EXIT
    
    SNAKE_CONVERT_MEMORY_LOOP_CONTENT:
        ADD    A,#SNAKE_X_ARRAY_START_ADDRESS
        MOV    R0,A
        MOV    A,@R0
        ADD    A,ACC
        MOV    R5,A

        MOV    A,R6
        ADD    A,#SNAKE_Y_ARRAY_START_ADDRESS
        MOV    R0,A
        MOV    A,@R0
        ADD    A,ACC
        MOV    R7,A

        MOV    A,R5
        MOV    B,#SNAKE_SCREEN_WIDTH
        MUL    AB
        ADD    A,#SNAKE_PRE_SCREEN_Y_START_ADDRESS
        MOV    R0,A
        MOV    A,R7
        ADD    A,R0
        MOV    R0,A
        MOV    @R0,#001H

        MOV    A,R5
        MOV    B,#SNAKE_SCREEN_WIDTH
        MUL    AB
        ADD    A, #SNAKE_PRE_SCREEN_Y_START_ADDRESS
        ADD    A, #SNAKE_SCREEN_WIDTH
        MOV    R0,A
        MOV    A,R7
        ADD    A,R0
        MOV    R0,A
        MOV    @R0,#001H

        MOV    A,R5
        MOV    B,#SNAKE_SCREEN_WIDTH
        MUL    AB
        ADD    A,#SNAKE_PRE_SCREEN_Y_START_ADDRESS+01H
        MOV    R0,A
        MOV    A,R7
        ADD    A,R0
        MOV    R0,A
        MOV    @R0,#001H

        MOV    A,R5
        MOV    B,#SNAKE_SCREEN_WIDTH
        MUL    AB
        ADD    A, #SNAKE_PRE_SCREEN_Y_START_ADDRESS
        ADD    A, #SNAKE_SCREEN_WIDTH
        ADD    A, #001h
        MOV    R0,A
        MOV    A,R7
        ADD    A,R0
        MOV    R0,A
        MOV    @R0,#001H

        INC    R6
        SJMP   SNAKE_CONVERT_MEMORY_LOOP
    SNAKE_CONVERT_MEMORY_LOOP_EXIT:
RET
    
END