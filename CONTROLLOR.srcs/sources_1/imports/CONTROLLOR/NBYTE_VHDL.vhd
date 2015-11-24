library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity NBYTE_VHDL is
	port(
		CLK : in std_logic ;
		R : in std_logic ;
		TRG_ONE : in std_logic ;
		TEXT_IN : in string(1 to 10) := "aaa1aaaaaa";
		NEZ_IN : in character := 'a';
		COUNT_IN : in integer := 4;
		RDY_ONE : out std_logic := '0');
end NBYTE_VHDL;

architecture Behavioral of NBYTE_VHDL is

   signal count_out_reg : integer := 1;
	signal match_reg : std_logic ;
	signal rdy_reg : std_logic := '0' ;
	
begin
	
	--match, count_out
	process (CLK)
		variable i : integer := 1;
	begin
		if(CLK'event and CLK = '1') then
			i := COUNT_IN ;
			if (R = '1') then
				match_reg <= '0' ;
			elsif ((TRG_ONE = '1') and (TEXT_IN(i) /= NEZ_IN)) then
				match_reg <= '1' ;
			else
				match_reg <= '0' ;
			end if;
		end if;
	end process;
	
	----------------------------------------------
	--rdy_reg
	----------------------------------------------
	process (CLK)
	begin
		if (CLK'event and CLK = '1') then
			if (R='1') then
				rdy_reg <= '0';
			elsif (match_reg = '1') then
				rdy_reg <= '1';
			else
				rdy_reg <= '0';
			end if;
		end if;
	end process;
	------------------------------------

	RDY_ONE <= rdy_reg ;
	
end Behavioral;
