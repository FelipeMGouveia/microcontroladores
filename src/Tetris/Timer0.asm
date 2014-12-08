;Rotina para tratamento de interrupção de tempo principal.
;Deve: 
;   Atualizar o status do fmg_control e fmg_control_old, de acordo com os botões
;   Deve atualizar e checar o valor da flag fmg_time_to_fall_0 e fmg_time_to_fall_1
code
    FMG_TIMER_0:
        PUSH ACC ;Acumulador para pilha
        PUSH PSW ;Guardar a infromação do banco de registradores que está sendo utilizado
        MOV A, R0
        PUSH ACC
        MOV A, R1
        PUSH ACC
        
        CLR TR0
        
        ;Atualização do tempo
        MOV A, fmg_time_to_fall_0
        ADD A, #001h
        MOV fmg_time_to_fall_0, A
        
        ;Checagem do tempo
        MOV R0, A
        MOV A, fmg_time_to_fall
        MOV R1, A
        ANL A, R0
        SUBB A, R1
        JZ FMG_TIMER_0_FALL ;Se for para a peça cair, então caia!
        
        ;Ignorando o teste dos botões!
        ;MOV A, #000h
        ;JMP FMG_TIMER_0_END
        
        ;Adimitindo que: B1(P1.0) == Up, B2(P1.1) == Down, B3(P1.2) == Left, B4(P1.3) == Right, B5(P1.4) == Not Used
        JNB P1.0, FMG_TIMER_0_ROTATE
        JNB P1.1, FMG_TIMER_0_FALL
        JNB P1.2, FMG_TIMER_0_LEFT
        JNB P1.3, FMG_TIMER_0_RIGHT
        MOV A, #000h
        JMP FMG_TIMER_0_END

        FMG_TIMER_0_LEFT:
            MOV A, #001h
            JMP FMG_TIMER_0_END
        FMG_TIMER_0_RIGHT:
            MOV A, #002h
            JMP FMG_TIMER_0_END
        FMG_TIMER_0_ROTATE:
            MOV A, #003h
            JMP FMG_TIMER_0_END
        FMG_TIMER_0_FALL:
            MOV A, #000h
            MOV fmg_time_to_fall_0, A
            MOV fmg_control_old, A ;Atualiza o controle antigo
            MOV A, #004h
            JMP FMG_TIMER_0_END
            
        FMG_TIMER_0_END:
            MOV fmg_control, A ;Atualiza o controle atual
       
        MOV A, #0DCh
        MOV TL0, A
        
        MOV A, #011h
        MOV TH0, A
        SETB TR0
        
        POP ACC
        MOV R1, A
        POP ACC
        MOV R0, A
        POP PSW
        POP ACC
    RET