code
    FMG_TEST_END:
        MOV R0, #fmg_grid
        MOV A, #004h
        ADD A, R0
        MOV R0, A
        MOV R3, #000h
        MOV R4, #00Ah
        
        FMG_TEST_END_LOOP:
            MOV A, @R0
            ORL A, R3
            MOV R3, A
            INC R0
            DJNZ R4, FMG_TEST_END_LOOP
        MOV A, R3
        ANL A, #0F0h
        JZ FMG_TEST_END_END
        JNZ FMG_TEST_END_END_GAME
        
        FMG_TEST_END_END_GAME:
            MOV fmg_state, #002h
        FMG_TEST_END_END:
    RET