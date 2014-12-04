code
    ;Coloca no carry o bit definido por R0, que se encontra em R1
    FMG_FIND_BIT:
        MOV A, R1
        FMG_FIND_BIT_LOOP:
            RRC A
            DJNZ R0, FMG_FIND_BIT_LOOP
    RET