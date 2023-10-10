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

	signal cinco, blink, direction, enable, reset_cinco, reset_blink, botao, ovf_debounce  : std_logic;
	signal next_state, state, step :   integer;

begin

	-- Mudar de estado
	process(clock, reset)
	begin
		if reset = '1' then
            state <= 0;
		elsif rising_edge(clock) then
			state <= next_state;
		end if;
	end process;
	---------------------

	-- Controle dos LEDs
	process (clock, LedG, LedR)
	begin
		if rising_edge(clock) then
			if state = 0 then
				LedG <= '0';
	        	LedR <= '0';
			else
				LedG <= blink;
				LedR <= not blink;
          	end if;
		end if;
	end process;
	---------------------------

	-- Lógica para mudanca de estados
	process(sensorP, step, state, botao, cinco)
	begin
		case state is
			when 0 =>         					-- Fechado
				next_state <= 0;

				if botao = '1' then				-- 0 - pressionado (só vai funcionar quando pressionar o botão)
					next_state <= 1;
				end if;

			when 1 =>							-- Abrindo
				next_state <= 1;
	
				if botao = '1' and sensorP = '0' then
					next_state <= 3;
				else
					if step = 1024 then
            	  	next_state <= 2;
					end if;
				end if;
					
			when 2 =>							-- Aberto
				next_state <= 2;
					
				if sensorP = '0' then
					if botao = '1' or cinco = '1' then
						next_state <= 3;
					end if;
				end if;
				
			when others =>							-- Fechando
				next_state <= 3;
					
				if botao = '1' or sensorP = '1' then
           			next_state <= 1;
				else
					if step = 0 then
              			next_state <= 0;
           			end if;
				end if;

		end case;
	end process;
	-------------------------------------------
	
	-- Saídas de cada estado
	process(sensorP, step, state, botao, cinco)
	begin
		case state is

			when 0 =>         					-- Fechado
				reset_blink <= '1';
				reset_cinco <= '1';
				enable <= '0';
				direction <= '0';

			when 1 =>							-- Abrindo
				reset_blink <= '0';
				reset_cinco <= '1';
				enable <= '0';
				direction <= '0';
				
				if botao = '0' then
					if step < 1024 then
						direction <= '0';
						enable <= '1';
					end if;
				end if;
					
			when 2 =>							-- Aberto
				reset_blink <= '0';
				reset_cinco <= '0';
				enable <= '0';
				direction <= '0';
				
				if sensorP = '1' then
					reset_cinco <= '1';
	           	else
					reset_cinco <= '0';
				end if;
				
			when others =>						-- Fechando
				reset_blink <= '0';
				reset_cinco <= '1';
				enable <= '0';
				direction <= '0';
					
				if botao = '0' or sensorP = '0' then
					if step > 0 then
						enable <= '1';
               			direction <= '1';
         			else    					-- Fechou
              			enable <= '0';
           			end if;
				end if;
			
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