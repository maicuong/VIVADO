library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity STR_VHDL is
	port(
		CLK : in std_logic ;
		TRG_ONE : in std_logic ;
		TEXT_IN : in string(1 to 2) ;
		NEZ_IN : in string(1 to 2) ;
		FAIL : out std_logic := '0' ;
		RDY_ONE : out std_logic := '0');
end STR_VHDL;

architecture Behavioral of STR_VHDL is

	signal match_reg : std_logic ;
	signal fail_reg : std_logic := '0' ;
	
begin
	
	--match, count_out
	process (CLK)
	begin
		if(CLK'event and CLK = '1') then
			if (TRG_ONE = '1') then
				if (TEXT_IN = NEZ_IN) then
					match_reg <= '1' ;
					--count_out_reg <= COUNT_IN + 1;
				else
					fail_reg <= '1' ;
				end if;
			else
				match_reg <= '0' ;
				fail_reg <= '0' ;
			end if;
		end if;
	end process;

	FAIL <= fail_reg ;
	RDY_ONE <= match_reg ;
	
end Behavioral;
