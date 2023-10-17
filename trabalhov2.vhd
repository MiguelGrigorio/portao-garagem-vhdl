library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity trabalho is
    port (
        clock   : in std_logic;                      -- 	Tic Tac
        reset   : in std_logic;                      -- 	Chave para reiniciar
        sensorP : in std_logic;                      --		Chave sensor de presenca
        botaoB  : in std_logic;                      --		Botao para abrir e fechar o portao
        wires   : out std_logic_vector (3 downto 0); -- 	Bobinas motor
        LedR    : out std_logic;                     -- 	Led vermelho
        LedG    : out std_logic                      -- 	Led verde
    );
end trabalho;

architecture behavioral of trabalho is

    type state_t is (Fechado, Abrindo, Aberto, TimerCinco, Fechando);
    signal next_state, state : state_t;

    signal cinco, blink, direction, enable, reset_cinco, reset_blink, botao, LG, LR, step_complete : std_logic;

begin

    -- Mudar de estado
    process (clock, reset)
    begin
        if reset = '1' then
            state <= Fechado;
        elsif rising_edge(clock) then
            state <= next_state;
        end if;
    end process;
    ----------------------

    -- Controle dos LEDs
    LG   <= '0' when reset_blink = '1' or (blink = '1' and LR = '0') else '1';
    LedG <= LG;
    LR   <= '0' when reset_blink = '1' or (blink = '1' and LR = '1') else '1';
    LedR <= LR;
    ------------------------------------------------------------------------

    -- Lógica para mudanca de estados
    next_state <=
        Fechado when state = Fechando and step_complete = '1' else
        Abrindo when (state = Fechado and botao = '1') or (state = Fechando and (botao = '1' or sensorP = '1')) else
        Aberto when (state = Abrindo and step_complete = '1') or (state = TimerCinco and sensorP = '1') else
        TimerCinco when state = Aberto and sensorP = '0' else
        Fechando when (state = Abrindo and (botao = '1' and sensorP = '0')) or (state = TimerCinco and (botao = '1' or cinco = '1')) else
        state;
    -------------------------------------------

    -- Saídas de cada estado
    reset_blink <= '1' when state = Fechado else '0';
    reset_cinco <= '0' when state = TimerCinco else '1';
    enable      <= '1' when state = Abrindo or state = Fechando else '0';
    direction   <= '1' when state = Fechando else '0';
    -------------------------------------------

    -- Controle do motor
    Motor : entity work.motor port map (
        clock     => clock,
        reset     => reset,
        direction => direction,
        enable    => enable,
        wires     => wires,
        angulo    => 1024,
        overflow  => step_complete
        );
    -----------------------------------

    -- Temporizador de 5 segundos
    Timer : entity work.timer port map (
        clock    => clock,
        reset    => reset_cinco,
        period   => 249_999_999, -- 5 segundos
        overflow => cinco
        );
    -----------------------------------

    -- Piscar a cada 0.5 segundos
    Piscar : entity work.timer port map (
        clock    => clock,
        reset    => reset_blink,
        period   => 24_999_999, -- 0.5 segundos
        overflow => blink
        );
    ------------------------------------

    -- Debounce para verificar botao
    Debounce : entity work.debounce port map (
        clock  => clock,
        reset  => reset,
        switch => botaoB,
        fall   => botao
        );
    --------------------------------------------

end behavioral;