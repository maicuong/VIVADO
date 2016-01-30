library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

entity SET_VHDL is
	port(
		CLK : in std_logic := '0';
		TRG_ONE : in std_logic := '0';
		NEZ_IN_START : in std_logic_vector(7 downto 0);
		NEZ_IN_END : in std_logic_vector(7 downto 0);
		OPTION : in integer := 2;
		TEXT_IN : in std_logic_vector(7 downto 0);
		FAIL : out std_logic := '0' ;
		RDY_ONE : out std_logic := '0');
end SET_VHDL;

architecture Behavioral of SET_VHDL is

	signal match_reg : std_logic := '0' ;
	signal fail_reg : std_logic := '0';
	
begin
	process (CLK)
	begin
		if(CLK'event and CLK = '1') then
			if (TRG_ONE = '1') then
				if(((OPTION = 0 or OPTION = 1) and (TEXT_IN = NEZ_IN_START or TEXT_IN = NEZ_IN_END)) 
                or((OPTION = 2) and (TEXT_IN >= NEZ_IN_START and TEXT_IN <= NEZ_IN_END))) then
					match_reg <= '1' ;
				else
					fail_reg <= '1' ;
				end if;
			else
				match_reg <= '0' ;
				fail_reg <= '0' ;
			end if;
		end if;
	end process;
	
	FAIL <= fail_reg;
	RDY_ONE <= match_reg ;
	
end Behavioral;
