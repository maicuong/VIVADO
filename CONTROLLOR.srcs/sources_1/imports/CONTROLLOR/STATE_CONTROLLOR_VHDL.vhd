library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity STATE_CONTROLLOR_VHDL is
	port (
		CLK : in std_logic := '0';
		ID : in integer := 0;
		RDY_IN : in std_logic := '0';
		BYTE_TRG : out std_logic := '0';
		SET_TRG : out std_logic := '0';
		RSET_TRG : out std_logic := '0';
		OBYTE_TRG : out std_logic := '0';
		STR_TRG : out std_logic := '0';
		NANY_TRG : out std_logic := '0';
		OTHERS_TRG : out std_logic := '0';
		FAIL_TRG : out std_logic := '0');
end STATE_CONTROLLOR_VHDL;

architecture Behavioral of STATE_CONTROLLOR_VHDL is
	signal trg_array : std_logic_vector(0 to 20) := (others => '0');
	
begin
	process(CLK)
		variable next_accept : boolean := false;
	begin
		if (CLK'event and CLK = '1') then
		   if(RDY_IN = '1' ) then
				next_accept := true ;
		   end if;
		   if (next_accept) then 
               trg_array <= (others => '0');
               trg_array(id) <= '1';
               next_accept := false;
            else
               trg_array <= (others => '0');
            end if;
		end if;
	end process;

	BYTE_TRG <= trg_array(1); -- BYTE trigger
	SET_TRG <= trg_array(3); -- SET trigger
	RSET_TRG <= trg_array(14); -- RSET trigger
	FAIL_TRG <= trg_array(13); -- FAIL trigger
	OBYTE_TRG <= trg_array(17); -- OBYTE trigger
	STR_TRG <= trg_array(19); -- STR trigger
	NANY_TRG <= trg_array(16); -- NANY trigger
	OTHERS_TRG <= (trg_array(9) or trg_array(10) or trg_array(11) or trg_array(12) or trg_array(15) or trg_array(18));
		
end Behavioral;