library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity trabalho is
	Port (
		clock		: in std_logic;							-- 	Tic Tac
		reset		: in std_logic;							-- 	Chave para reiniciar
		sensorP		: in std_logic;							--	Chave sensor de presenca
		botaoB		: in std_logic;							--	Botao para abrir e fechar o portao
		wires		: out std_logic_vector (3 downto 0);	-- 	Bobinas motor
		LedR		: out std_logic;						-- 	Led vermelho
		LedG		: out std_logic							-- 	Led verde
	);
end trabalho;

architecture behavioral of trabalho is

	type state_t is (Fechado, Abrindo, Aberto, TimerCinco, Fechando);
	signal next_state, state	: state_t;

	signal cinco, blink, direction, enable, reset_cinco, reset_blink, botao, ovf_debounce, LG, LR  : std_logic;

	signal step :	integer;

begin

	-- Mudar de estado
	process(clock, reset)
	begin
		if reset = '1' then
            state <= Fechado;
		elsif rising_edge(clock) then
			state <= next_state;
		end if;
	end process;
	---------------------

	-- Controle dos LEDs
	process (clock)
	begin
		if rising_edge(clock) then
			if state = Fechado then
				LG <= '0';
	        	LR <= '0';
			elsif blink = '1' then
				if LR = '0' then
					LG <= '0';
					LR <= '1';
				else
					LG <= '1';
					LR <= '0';
				end if;
          	end if;
			
			LedG <= LG;
			LedR <= LR;
		end if;
	end process;
	---------------------------

	-- Lógica para mudanca de estados
	process(sensorP, step, state, botao, cinco)
	begin
		case state is
			when Fechado =>         					
				next_state <= Fechado;

				if botao = '1' then
					next_state <= Abrindo;
				end if;

			when Abrindo =>							
				next_state <= Abrindo;
	
				if botao = '1' and sensorP = '0' then
					next_state <= Fechando;
				else
					if step = 1024 then	-- 90 graus
            	  	next_state <= Aberto;
					end if;
				end if;
					
			when Aberto =>
				next_state <= Aberto;
					
				if sensorP = '0' then
					next_state <= TimerCinco;
				end if;
				
			when TimerCinco =>
				next_state <= TimerCinco;

				if sensorP = '1' then
					next_state <= Aberto;
				elsif botao = '1' or cinco = '1' then
					next_state <= Fechando;
				end if;

			when others =>	-- Fechando
				next_state <= Fechando;
					
				if botao = '1' or sensorP = '1' then
           			next_state <= Abrindo;
				else
					if step = 0 then -- 90 graus
              			next_state <= Fechado;
           			end if;
				end if;

		end case;
	end process;
	-------------------------------------------
	
	-- Saídas de cada estado
	process(state)
	begin
		case state is

			when Fechado  =>

				reset_blink <= '1';
				reset_cinco <= '1';
				enable <= '0';
				direction <= '0';

			when Abrindo  =>

				reset_blink <= '0';
				reset_cinco <= '1';
				enable <= '1';
				direction <= '0';
					
			when Aberto =>

				reset_blink <= '0';
				reset_cinco <= '1';
				enable <= '0';
				direction <= '0';
				
			when TimerCinco =>

				reset_blink <= '0';
				reset_cinco <= '0';
				enable <= '0';
				direction <= '0';

			when others =>	-- Fechando

				reset_blink <= '0';
				reset_cinco <= '1';
				enable <= '1';
				direction <= '1';
			
		end case;
	end process;
	-------------------------------------------
	
	-- Controle do motor
	motor: entity work.motor port map (
		clock => clock,
		reset => reset,
		direction => direction,
		enable => enable,
		wires => wires,
		angulo => 1024,
		step => step
	);
	-----------------------------------

	-- Temporizador de 5 segundos
	timer: entity work.timer port map (
		clock => clock,
		reset => reset_cinco,
		period => 249_999_999,				-- 5 segundos
		overflow => cinco
	);
	-----------------------------------

	-- Piscar a cada 0.5 segundos
    piscar: entity work.timer port map (
		clock => clock,
		reset => reset_blink,
		period => 24_999_999,				-- 0.5 segundos
		overflow => blink
	);
	------------------------------------

	-- Debounce para verificar botao
	timer_debounce: entity work.timer port map (
		clock => clock,
		reset => reset,
		period => 1_000,				
		overflow => ovf_debounce
	);
	debounce: entity work.debounce port map (
		clock => clock,
		reset => reset,
		switch => botaoB,
		fall => botao,
		trigger => ovf_debounce
	);
	--------------------------------------------

end behavioral;