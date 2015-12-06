library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity STATE_CONTROLLOR_VHDL is
	port (
		CLK : in std_logic;
		ID : in integer;
		--TRG_ONE : in std_logic ;
		RDY_IN : in std_logic ;
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

	--signal trg_one_reg : std_logic ;
	signal trg_array : std_logic_vector(0 to 20);
	--signal now_sig : natural	:= 0;
	
begin
	--trg_one_reg <= TRG_ONE or RDY_IN ;
	
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
                                           --now_sig <= 1;
                                           next_accept := false;
                                        else
                                           trg_array <= (others => '0');
                                        end if;
		end if;
	end process;

	BYTE_TRG <= trg_array(1);
	SET_TRG <= trg_array(3);
	RSET_TRG <= trg_array(14);
	FAIL_TRG <= trg_array(13);
	OBYTE_TRG <= trg_array(17);
	STR_TRG <= trg_array(19);
	NANY_TRG <= trg_array(16);
	OTHERS_TRG <= (trg_array(9) or trg_array(10) or trg_array(11) or trg_array(12) or trg_array(15) or trg_array(18));
		
end Behavioral;