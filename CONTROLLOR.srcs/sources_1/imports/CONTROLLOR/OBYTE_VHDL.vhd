library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

entity OBYTE_VHDL is
	port(
		CLK : in std_logic := '0';
		TRG_ONE : in std_logic := '0';
		TEXT_IN : in std_logic_vector(7 downto 0);
		NEZ_IN : in std_logic_vector(7 downto 0);
		RDY_ONE : out std_logic := '0');
end OBYTE_VHDL;

architecture Behavioral of OBYTE_VHDL is

	signal match_reg : std_logic := '0' ;

begin
	
	process (CLK)
	begin
		if(CLK'event and CLK = '1') then
			if (TRG_ONE = '1') then
				match_reg <= '1' ;
			else
				match_reg <= '0' ;
			end if;
		end if;
	end process;

	RDY_ONE <= match_reg ;
	
end Behavioral;
