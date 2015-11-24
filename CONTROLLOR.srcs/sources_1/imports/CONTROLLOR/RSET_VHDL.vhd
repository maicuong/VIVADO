library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RSET_VHDL is
	port(
		CLK : in std_logic ;
		R : in std_logic ;
		TRG_ONE : in std_logic ;
		CONTINUE_TRG : in std_logic ;
		NEZ_IN_START : in character := 'a';
		NEZ_IN_END : in character := 'z';
		OPTION : in integer ;
		TEXT_IN : in character := 'a' ;
		COUNT_IN : in integer := 4;
		COUNT_OUT : out integer ;
		--FAIL : out std_logic := '0' ;
		CONTINUE_RDY : out std_logic ;
		RDY_ONE : out std_logic := '0');
end RSET_VHDL;

architecture Behavioral of RSET_VHDL is
	
   signal count_out_reg : integer := 1;
	signal match_reg : std_logic ;
	signal fail_reg : std_logic ;
	--signal rdy_reg : std_logic := '0' ;
	
begin

	--match, count_out
	process (CLK)
		variable i : integer := 1;
	begin
		if(CLK'event and CLK = '1') then
			if (R = '1') then
				match_reg <= '0' ;
			elsif (TRG_ONE = '1' or CONTINUE_TRG = '1') then
				--i := COUNT_IN ;
				if ((((OPTION = 0 or OPTION = 1) and (TEXT_IN = NEZ_IN_START or TEXT_IN = NEZ_IN_END)) 
					or((OPTION = 2) and (TEXT_IN >= NEZ_IN_START and TEXT_IN <= NEZ_IN_END)))) then
					match_reg <= '1' ;
					count_out_reg <= COUNT_IN + 1;
				else
					fail_reg <= '1' ;
					count_out_reg <= COUNT_IN;
				end if;
			else
				match_reg <= '0' ;
				fail_reg <= '0' ;
			end if;
		end if;
	end process;
	
	----------------------------------------------
	--rdy_reg
	----------------------------------------------
	--process (CLK)
	--begin
		--if (CLK'event and CLK = '1') then
			--if (R='1') then
				--rdy_reg <= '0';
			--elsif (match_reg = '1') then
				--rdy_reg <= '1';
			--else
				--rdy_reg <= '0';
			--end if;
		--end if;
	--end process;
	------------------------------------
	
	COUNT_OUT <= count_out_reg ;
	CONTINUE_RDY <= match_reg ;
	RDY_ONE <= fail_reg ;
	
end Behavioral;
