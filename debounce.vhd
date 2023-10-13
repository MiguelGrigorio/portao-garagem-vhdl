library ieee;
use ieee.std_logic_1164.all;

entity debounce is
	port (
		clock  : in std_logic;
		reset  : in std_logic;
		switch : in std_logic;
		rise   : out std_logic;
		fall   : out std_logic;
		stb    : out std_logic
	);
end debounce;

architecture behavioral of debounce is

	signal ff, trigger : std_logic;
	signal sw          : std_logic_vector (1 downto 0);

begin

	--	"2" Flip flops

	process (clock, reset)
	begin
		if reset = '1' then
			sw <= "00";
		elsif rising_edge(clock) then
			if trigger = '1' then
				sw <= switch & sw(1);
			end if;
		end if;
	end process;

	process (clock, reset)

		--	Ultimo flip flop
	begin
		if reset = '1' then
			ff <= '0';
		elsif rising_edge(clock) then
			if sw = "11" or sw = "00" then
				ff <= sw(0);
			end if;
		end if;
	end process;

	stb  <= ff;
	rise <= sw(0) and not ff;
	fall <= not sw(0) and ff;

	timer_debounce : entity work.timer port map (
		clock    => clock,
		reset    => reset,
		period   => 1_000,
		overflow => trigger
		);

end behavioral;