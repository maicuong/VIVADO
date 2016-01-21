library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

entity RSET_VHDL is
	port(
		CLK : in std_logic := '0';
		TRG_ONE : in std_logic := '0';
		NEZ_IN_START : in character := 'a';
		NEZ_IN_END : in character := 'z';
		OPTION : in integer := 0;
		TEXT_IN : in std_logic_vector(7 downto 0);
		CONTINUE_RDY : out std_logic := '0';
		RDY_ONE : out std_logic := '0');
end RSET_VHDL;

architecture Behavioral of RSET_VHDL is

	
begin
	process (CLK)
		variable i : integer := 1;
		variable match_reg : std_logic := '0';
		variable fail_reg : std_logic := '0';
	begin
		if(CLK'event and CLK = '1') then
			if (TRG_ONE = '1') then
				if(((OPTION = 0 or OPTION = 1) and (TEXT_IN = std_logic_vector(to_unsigned(natural(character'pos(NEZ_IN_START)),8)) or TEXT_IN = std_logic_vector(to_unsigned(natural(character'pos(NEZ_IN_END)),8)))) 
                or((OPTION = 2) and (TEXT_IN >= std_logic_vector(to_unsigned(natural(character'pos(NEZ_IN_START)),8)) and TEXT_IN <= std_logic_vector(to_unsigned(natural(character'pos(NEZ_IN_END)),8))))) then
					match_reg := '1' ;
					fail_reg := '0';
				else
					match_reg := '0' ;
					fail_reg := '1' ;
				end if;
			else
				match_reg := '0' ;
				fail_reg := '0' ;
			end if;
		end if;
		
	CONTINUE_RDY <= match_reg ;
	RDY_ONE <= fail_reg ;
	end process;
	
end Behavioral;
