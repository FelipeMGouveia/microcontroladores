code 
    FMG_UPDATE_STATE:
    ;Verificar no controle se tem alguma tecla prescionada
    ;Caso tenha, fazer a rotina correspondente
    MOV A, fmg_control ;Coloca o controle no acumulador
    MOV B, fmg_control_old ;Coloca a versão antiga do controle no acumulador B
    ; Se controle for cair(normal), então caia :D
    MOV R0, A; Guarda o controle em R0
    MOV R1, B; Guarda o controle antigo em R1
    
    SUBB A, R1 ; Se for 0 então não ocorreu alteração de controle
    JZ FMG_UPDATE_STATE_END_WORKAROUND
    ;Atualiza o controle antigo para ser o valor atualmente em controle.
    MOV A, fmg_control
    MOV fmg_control_old, A
    MOV A, R0 ;Caso contrário restaura fmg_control
    
    MOV B, #003h
    MUL AB
    
    MOV DPTR, #FMG_UPDATE_STATE_SWITCH_CONTROL
    JMP @A+DPTR
    
    FMG_UPDATE_STATE_END_WORKAROUND:
        LJMP FMG_UPDATE_STATE_END
        
    FMG_UPDATE_STATE_SWITCH_CONTROL:
        JMP FMG_UPDATE_STATE_SWITCH_STATE_NOTHING
        JMP FMG_UPDATE_STATE_SWITCH_STATE_LEFT
        JMP FMG_UPDATE_STATE_SWITCH_STATE_RIGHT
        JMP FMG_UPDATE_STATE_SWITCH_STATE_ROTATE
        JMP FMG_UPDATE_STATE_SWITCH_STATE_FALL
    FMG_UPDATE_STATE_SWITCH_STATE_LEFT:
        $include(Tetris/UpdateState/UpdateStateLeft.asm)
    FMG_UPDATE_STATE_SWITCH_STATE_RIGHT:
        $include(Tetris/UpdateState/UpdateStateRight.asm)
    FMG_UPDATE_STATE_SWITCH_STATE_ROTATE:
        $include(Tetris/UpdateState/UpdateStateRotate.asm)
    FMG_UPDATE_STATE_SWITCH_STATE_FALL:
        $include(Tetris/UpdateState/UpdateStateFall.asm)
    FMG_UPDATE_STATE_SWITCH_STATE_NOTHING: ; Não faz nada
    FMG_UPDATE_STATE_END: ;Fim do fluxo de atualização de estado
    RET