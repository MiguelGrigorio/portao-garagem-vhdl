library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
	port (
		clock    : in std_logic;
		reset    : in std_logic;
		trigger  : in std_logic;
		period   : in integer;
		BCD      : out std_logic_vector(3 downto 0);
		overflow : out std_logic
	);
end counter;

architecture behavioral of counter is

	signal count, NextCount : integer;

begin

	NextCount <= 0 when count = period else
		count + 1;

	process (clock, reset)
	begin
		if reset = '1' then
			count <= 0;
		elsif rising_edge(clock) then
			if trigger = '1' then
				count <= NextCount;
			end if;
		end if;
	end process;

	overflow <= '1' when count = period and trigger = '1' else
		'0';

	BCD <= std_logic_vector(to_unsigned(count, 4));

end behavioral;