library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity OBYTE_VHDL is
	port(
		CLK : in std_logic ;
		R : in std_logic ;
		TRG_ONE : in std_logic ;
		TEXT_IN : in character := 'a';
		NEZ_IN : in character := 'a';
		COUNT_IN : in integer := 1;
		COUNT_OUT : out integer ;
		RDY_ONE : out std_logic := '0');
end OBYTE_VHDL;

architecture Behavioral of OBYTE_VHDL is

   signal count_out_reg : integer := 1;
	signal match_reg : std_logic ;
	--signal rdy_reg : std_logic := '0' ;
	
begin
	
	--match, count_out
	process (CLK)
	begin
		if(CLK'event and CLK = '1') then
			if (R = '1') then
				match_reg <= '0' ;
			elsif (TRG_ONE = '1') then
				if(TEXT_IN = NEZ_IN) then
					--count_out_reg <= COUNT_IN + 1;
				else
					--count_out_reg <= COUNT_IN ;
				end if;
				match_reg <= '1' ;
			else
				match_reg <= '0' ;
			end if;
		end if;
	end process;
	
	COUNT_OUT <= count_out_reg ;
	RDY_ONE <= match_reg ;
	
end Behavioral;
