$include(REG52.inc)
$include(Random.asm)
$include(LCD.asm)

SNAKE_MAX_SIZE SET 0x09
SNAKE_MAX_SIZE_ADDRESS SET 0x50

SNAKE_SCREEN_WIDTH SET 0x54
SNAKE_SCREEN_WIDTH_ADDRESS SET 0x51

SNAKE_SCREEN_HEIGHT SET 0x30
SNAKE_SCREEN_HEIGHT_ADDRESS SET 0x52

SNAKE_X_ARRAY_START_ADDRESS SET 0xA0
SNAKE_Y_ARRAY_START_ADDRESS SET 0xA8

SNAKE_ADD_X_ADDRESS SET 0x53
SNAKE_ADD_Y_ADDRESS SET 0x54

SNAKE_SIZE_ADDRESS SET 0x55

x_temp SET 0x56
y_temp SET 0x57

SNAKE_PRE_SCREEN_Y_START_ADDRESS SET 0x00

code at 0
    MOV SP, #078h
    ljmp SNAKE_MAIN

SNAKE_MAIN:
    LCALL SNAKE_CLEAR_MEMORY ; limpa a regi�o de mem�ria da Snake
    LCALL SNAKE_INIT ; configura o estado inicial da Snake
    SNAKE_MAIN_LOOP:
        LCALL SNAKE_CONVERT_MEMORY ; l� a mem�ria da Snake e converte para informa��o pr�-tela
        ;LCALL LCD_CLEAR ; limpa a tela
        ;LCALL SNAKE_DRAW_SCREEN ; l� e regi�o de mem�ria que armazena as informa��es da Snake e imprime na tela
        LCALL SNAKE_READ_BUTTONS ; l� os bot�es e atualiza a mem�ria
        LCALL SNAKE_UPDATE ; atualiza a regi�o de mem�ria da Snake
        SJMP SNAKE_MAIN_LOOP
    RET

code
SNAKE_CLEAR_MEMORY:
    ; limpando regi�o X
    MOV R1, #SNAKE_MAX_SIZE
    MOV R0, #SNAKE_X_ARRAY_START_ADDRESS
    SNAKE_CLEAR_X_MEMORY_LOOP_START:
        MOV @R0, #001h
        INC R0
        DJNZ R1, SNAKE_CLEAR_X_MEMORY_LOOP_START
    
    ; limpando regi�o Y
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
    
    ; a snake come�a com duas partes
    MOV R0, #SNAKE_SIZE_ADDRESS
    MOV @R0, #02h

    LCALL RAND8 ; gera um n�mero aleat�rio no acumulador
    MOV R0, #SNAKE_X_ARRAY_START_ADDRESS
    MOV @R0, A ; seta posi��o X inicial da comida ; x[0] = rand
    INC R0
    MOV @R0, #01h ; x[1] = 1
    INC R0
    MOV @R0 #01h ; x[2] = 1
    
    LCALL RAND8 ; gera um n�mero aleat�rio no acumulador
    MOV R0, #SNAKE_Y_ARRAY_START_ADDRESS
    MOV @R0, A ; seta posi��o Y inicial da comida ; y[0] = rand
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
        ; R0 guarda a resposta final, d� um rotate de cara
        MOV A, R0
        RR A
        MOV R0, A
        
        ; R6 guarda a nova posi��o, d� um rotate nela (pra mandar 000..1 para 100..0, eg)
        MOV A, R6
        MOV R1, A
        MOV A, @R1
        RR A
        
        ; faz um ou de r0 com r6
        ORL A, R0
        MOV R0, A
        
        ; busca outro byte
        MOV A, R6
        ADD A, #SNAKE_SCREEN_WIDTH
        MOV R6, A
        DJNZ R7, SNAKE_START_BUILD_BYTE
        
    ; R0 t� com o byte a ser impresso
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
    MOV    R5,#000H
    SNAKE_CONVERT_MEMORY_LOOP_CLEAN_MEMORY_I:
        MOV    A,R5
        CJNE   A,#SNAKE_SCREEN_HEIGHT,SNAKE_CONVERT_MEMORY_LOOP_SHIFT_I
        SNAKE_CONVERT_MEMORY_LOOP_SHIFT_I:
        JNC    SNAKE_CONVERT_MEMORY_LOOP_CLEAN_END_I

        MOV    R6,#000H
        SNAKE_CONVERT_MEMORY_LOOP_CLEAN_MEMORY_J:
            MOV    A,R6
            CJNE   A,#SNAKE_SCREEN_WIDTH,SNAKE_CONVERT_MEMORY_LOOP_SHIFT_J
            SNAKE_CONVERT_MEMORY_LOOP_SHIFT_J:
            JNC    SNAKE_CONVERT_MEMORY_LOOP_CLEAN_END_J

            MOV    A,R5
            MOV    B,#054H
            MUL    AB
            ADD    A,#LOW (SNAKE_PRE_SCREEN_Y_START_ADDRESS)
            MOV    DPL,A
            MOV    A,B
            ADDC   A,#HIGH (SNAKE_PRE_SCREEN_Y_START_ADDRESS)
            MOV    DPH,A
            MOV    A,R6
            ADD    A,DPL
            MOV    DPL,A
            CLR    A
            ADDC   A,DPH
            MOV    DPH,A
            CLR    A
            MOVX   @DPTR,A

            INC    R6
            SJMP   SNAKE_CONVERT_MEMORY_LOOP_CLEAN_MEMORY_J
        SNAKE_CONVERT_MEMORY_LOOP_CLEAN_END_J:

        INC    R5
        SJMP   SNAKE_CONVERT_MEMORY_LOOP_CLEAN_MEMORY_I
    SNAKE_CONVERT_MEMORY_LOOP_CLEAN_END_I:
            
        ; faz a convers�o
        MOV    R4,#001H
        SNAKE_CONVERT_MEMORY_LOOP:
              MOV    A,#SNAKE_MAX_SIZE
              ADD    A,#001H
              MOV    R0,A
              CLR    A
              RLC    A
              MOV    R3,AR0
              MOV    B,A
              CPL    B.7
              MOV    A,#080H
              CJNE   A,B,SNAKE_CONVERT_MEMORY_SHIFT
              MOV    A,R4


              CJNE   A,AR3,SNAKE_CONVERT_MEMORY_SHIFT
              SNAKE_CONVERT_MEMORY_SHIFT:
              JC     $ + 5
              LJMP   SNAKE_CONVERT_MEMORY_LOOP_END

              MOV    A,R4
              ADD    A,#SNAKE_X_ARRAY_START_ADDRESS
              MOV    R0,A
              MOV    A,@R0
              ADD    A,ACC
              MOV    x_temp,A

              MOV    A,R4
              ADD    A,#SNAKE_Y_ARRAY_START_ADDRESS
              MOV    R0,A
              MOV    A,@R0
              ADD    A,ACC

              MOV    R3,A

              MOV    y_temp,A

              MOV    A,x_temp
              MOV    B,#054H
              MUL    AB
              ADD    A,#LOW (SNAKE_PRE_SCREEN_Y_START_ADDRESS)
              MOV    DPL,A
              MOV    A,B
              ADDC   A,#HIGH (SNAKE_PRE_SCREEN_Y_START_ADDRESS)
              MOV    DPH,A
              MOV    A,R3
              ADD    A,DPL
              MOV    DPL,A
              CLR    A
              ADDC   A,DPH
              MOV    DPH,A
              MOV    A,#001H
              MOVX   @DPTR,A

              MOV    A,x_temp
              MOV    B,#054H
              MUL    AB
              ADD    A,#LOW (SNAKE_PRE_SCREEN_Y_START_ADDRESS + 054H)
              MOV    DPL,A
              MOV    A,B
              ADDC   A,#HIGH (SNAKE_PRE_SCREEN_Y_START_ADDRESS + 054H)
              MOV    DPH,A
              MOV    A,R3
              ADD    A,DPL
              MOV    DPL,A
              CLR    A
              ADDC   A,DPH
              MOV    DPH,A
              MOV    A,#001H
              MOVX   @DPTR,A

              MOV    A,x_temp
              MOV    B,#054H

               
              MUL    AB
              ADD    A,#LOW (SNAKE_PRE_SCREEN_Y_START_ADDRESS + 01H)
              MOV    DPL,A
              MOV    A,B
              ADDC   A,#HIGH (SNAKE_PRE_SCREEN_Y_START_ADDRESS + 01H)
              MOV    DPH,A
              MOV    A,R3
              ADD    A,DPL
              MOV    DPL,A
              CLR    A
              ADDC   A,DPH
              MOV    DPH,A
              MOV    A,#001H
              MOVX   @DPTR,A

              MOV    A,x_temp
              MOV    B,#054H
              MUL    AB
              ADD    A,#LOW (SNAKE_PRE_SCREEN_Y_START_ADDRESS + 055H)
              MOV    DPL,A
              MOV    A,B
              ADDC   A,#HIGH (SNAKE_PRE_SCREEN_Y_START_ADDRESS + 055H)
              MOV    DPH,A
              MOV    A,R3
              ADD    A,DPL
              MOV    DPL,A
              CLR    A
              ADDC   A,DPH
              MOV    DPH,A
              MOV    A,#001H
              MOVX   @DPTR,A

              INC    R4
              LJMP   SNAKE_CONVERT_MEMORY_LOOP
        SNAKE_CONVERT_MEMORY_LOOP_END:
        RET     


    
END