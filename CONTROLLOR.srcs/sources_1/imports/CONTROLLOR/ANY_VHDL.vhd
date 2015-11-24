library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ANY_VHDL is
	port(
		CLK : in std_logic ;
		R : in std_logic ;
		TRG_ONE : in std_logic ;
		COUNT_IN : in integer := 1;
		COUNT_OUT : out integer ;
		RDY_ONE : out std_logic := '0');
end ANY_VHDL;

architecture Behavioral of ANY_VHDL is

	signal trg_one_reg : std_logic ;
	signal count_out_reg : integer := 1 ;
	signal rdy_reg : std_logic := '0';
	signal match_reg : std_logic := '0' ;
	
begin

	trg_one_reg <= TRG_ONE ;
	
	process(CLK)
	begin
		if (CLK'event and CLK = '1') then
			if (R = '1') then
				match_reg <= '0' ;
			elsif (TRG_ONE = '1') then
			count_out_reg <= COUNT_IN + 1 ;
			match_reg <= '1' ;
			else
			match_reg <= '0' ;
			end if;
		end if;
	end process;
	
	--rdy_one_reg	
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
	------------------
	
	COUNT_OUT <= count_out_reg ;
	RDY_ONE <= rdy_reg ;

end Behavioral;

