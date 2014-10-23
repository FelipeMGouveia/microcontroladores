microcontroladores
==================

Projeto para a disciplina de microcontroladores 2014.2

LCD
---
Para utilização do LCD são necessárias as seguintes configurações:  
Pinos em que o LCD será conectado:  
* P1.6 - Chip Enabled (ativo em zero);
* P1.5 - Chip Reset (ativo em zero);
* P1.7 - Seletor para Dados (um)/ Comando (zero);
* P3.1 - Clock (deve ser controlado manualmente);
* P3.0 - Canal de dados (datain);

O LCD utilizará o banco de registradores 2 para sua comunicação, com os
seguintes registradores tendo maior importância:
* lcd_bus - Dado/Comando a ser enviado para o LCD;
* lcd_X - Posição X onde deverá ocorrer a próxima escrita (utilizado pela função LCD_XY);
* lcd_Y - Posição Y onde deverá ocorrer a próxima escrita (utilizado pela função LCD_XY);

Em termos de funções as seguintes devem ser utilizadas:  
* LCD_INIT - Inicialização do módulo de LCD, deve ser chamada no começo do programa;
* LCD_XY - Move o cursor do LCD para a posição (X,Y) definida nos registradores lcd_X e lcd_Y;
* LCD_DRAW - Desenha o byte contido em lcd_bus no LCD, após cada esccrita na tela o cursor se move para a próxima posição;
* LCD_CLEAR - Limpa totalmente a tela do LCD;

Obs: O LCD aparentemente avalia o canal de dados na borda de subida.


