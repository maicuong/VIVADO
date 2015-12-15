library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity OBYTE_VHDL is
	port(
		CLK : in std_logic ;
		TRG_ONE : in std_logic ;
		TEXT_IN : in character ;
		NEZ_IN : in character ;
		RDY_ONE : out std_logic := '0');
end OBYTE_VHDL;

architecture Behavioral of OBYTE_VHDL is

	signal match_reg : std_logic ;

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
