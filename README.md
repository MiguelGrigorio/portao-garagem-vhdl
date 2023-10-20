# Portão de Garagem em VHDL

O objetivo do trabalho é implementar o sistema de controle de um portão de garagem. O sistema de portão automático para garagens permite que o motorista não precise descer do carro para abrir a passagem para a garagem, além de poupar tempo neste processo. Para abrir ou fechar o portão, envia-se um comando por meio de um controle remoto.

![](https://alvserralheria.com.br/wp-content/uploads/2016/07/modelo-de-portao-automatico-deslizante.jpg)

## Funcionamento do Sistema

Neste trabalho, você deverá projetar em VHDL o **circuito que controlará um portão de garagem, sendo o motor representado por um motor de passo.**

![](https://github.com/MiguelGrigorio/portao-garagem-vhdl/blob/0cad2ba9728ce3e19cb5541bfbe7c82aa29923bf/imagem_2023-10-20_074059087.png)

- O usuário deve utilizar um **botão B** para simular um comando de abrir/fechar vindo do controle remoto. Quando isso acontecer, o portão deverá se abrir (em 90°), caso esteja fechado ou fechando, ou se fechar (em 0°), caso esteja aberto ou abrindo.
- Quando o portão mudar para o estado "aberto", ele deverá se manter assim por 5 segundos e depois deverá se fechar. Entretanto, caso alguém ative o **sensor de presença P** (representado por uma chave), o portão deverá voltar para o (ou, se manter no) estado aberto, até que a pessoa saia do sensor. Após desativado o sensor, o portão deve iniciar novamente a contagem de 5 segundos para iniciar o processo de fechamento. Caso o botão B seja apertado antes de completar os 5 segundos, o portão deverá ser fechado.
- Uma vez fechado, o portão deve permanecer assim até que seja enviado um novo comando do botão B.
- Lembre-se que o botão B, sempre que for apertado, deverá mudar o estado do portão.
- Para sinalizar para quem passa perto do portão que há algum carro entrando ou saindo da garagem, deverão ser utilizados **dois leds, LR (vermelho) e LG (verde)**, que ficarão alternando quem está ligado a cada meio segundo. Quando o portão estiver fechado, os leds devem ficar desligados.

Além disso, o sistema deverá ter um **botão R** de reset, para resetar o sistema inteiro. Considere a nova posição do motor como sendo o 0°.

## Resumo das Entradas e Saídas

Para realizar esse projeto, o sistema deverá apresentar minimamente as seguintes entradas e saídas:
- 1 chave para indicar o sensor de presença;
- 2 botões: um para resetar o sistema e um representar o comando de abrir/fechar o portão;
- O clock;
- Os 4 wires para controlar o motor de passo;
- 2 leds, um verde e um vermelho para o sinalizador.

**O trabalho deverá ser feito em no máximo 3 pessoas. Entretanto, a avaliação será parte em grupo, parte individual.
No momento das perguntas, o professor poderá direcionar o questionamento para algum aluno específico, sendo permitido apenas esse aluno responder. Caso alguém responda em seu lugar, sem autorização, a nota do aluno questionado será diminuída.
Deverá ser implementado o sistema digital em VHDL e apresentado para o professor o seu funcionamento e um desenho do circuito implementado.**
