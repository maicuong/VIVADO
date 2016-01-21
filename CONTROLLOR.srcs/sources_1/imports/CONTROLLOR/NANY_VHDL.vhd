library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity NANY_VHDL is
	port(
		CLK : in std_logic := '0';
		TRG_ONE : in std_logic := '0';
		TEXT_IN : in std_logic_vector(7 downto 0);
		FAIL : out std_logic := '0' ;
		RDY_ONE : out std_logic := '0');
end NANY_VHDL;

architecture Behavioral of NANY_VHDL is
	signal match_reg : std_logic := '0' ;
	signal fail_reg : std_logic := '0' ;
	
begin
	process (CLK)
	begin
		if(CLK'event and CLK = '1') then
			if (TRG_ONE = '1') then
				if (TEXT_IN = "00000011") then
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

	FAIL <= fail_reg ;
	RDY_ONE <= match_reg ;
	
end Behavioral;
