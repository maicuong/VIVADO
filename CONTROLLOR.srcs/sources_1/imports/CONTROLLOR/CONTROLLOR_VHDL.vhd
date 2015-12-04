library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity CONTROLLOR_VHDL is
	port (
	CLK : in std_logic ;
	--START : in std_logic := '0' ;
	PARSER_ERROR : out std_logic );
	--PARSER_OK : buffer boolean := false);
end CONTROLLOR_VHDL;

architecture Behavioral of CONTROLLOR_VHDL is

	------------------------------------------------
	--Need to fix when add new
	------------------------------------------------
	component FILE_INPUT_VHDL 
		port(
		CLK : in std_logic;
		TRG : in std_logic ;
		RDY_IN : in std_logic ;
		FAIL : in std_logic ;
		ID : out integer;
		BYTE_TEXT : out character ;
		SET_TEXT_START : out character ;
	   SET_TEXT_SECOND : out character ;
	   SET_OPTION : out integer ;
		RBYTE_TEXT : out character ;
		OBYTE_TEXT : out character ;
		NBYTE_TEXT : out character ;
		CMD_LINE_NO : out natural;
		END_FAIL : buffer boolean ;
	   PARSER_OK : buffer boolean ;
		NEXT_TEXT_RDY : out std_logic ;
		NEXT_RDY : out std_logic );
	end component;
	
	
	component TEXT_INPUT_VHDL 
	   port(
		CLK : in std_logic ;
		TRG : in std_logic ;
		RDY : in std_logic ;
		COUNT_IN : in integer;
		COUNT_OUT : out integer ;
		CHAR_OUT : out character);
	end component;
	
	
	
	------------------------------------------------
	--Need to fix when add new
	------------------------------------------------
	component STATE_CONTROLLOR_VHDL
		port (
		CLK : in std_logic;
		R : in std_logic ;
		TRG_ONE : in std_logic ;
		RDY_IN : in std_logic ;
		ID : in integer;
		BYTE_TRG : out std_logic;
		--ANY_TRG : out std_logic;
		SET_TRG : out std_logic;
		--RBYTE_TRG : out std_logic;
		--OBYTE_TRG : out std_logic;
		--POS_TRG : out std_logic;
		--BACK_TRG : out std_logic;
		--NBYTE_TRG : out std_logic;
		RSET_TRG : out std_logic;
		FAIL_TRG : out std_logic;
		OTHERS_TRG : out std_logic);
--		CALL_TRG : out std_logic := '0';
--		ALT_TRG : out std_logic := '0';
--		SKIP_TRG : out std_logic := '0';
		--CALL_TRG : out std_logic := '0';
--		FIRST_TRG : out std_logic := '0';
--		RET_TRG : out std_logic := '0');
	end component;
	
	component BYTE_VHDL 
		port(
		CLK : in std_logic ;
		R : in std_logic := '0';
		TRG_ONE : in std_logic ;
		TEXT_IN : in character ;
		NEZ_IN : in character ;
		COUNT_IN : in integer ;
		COUNT_OUT : out integer ;
		FAIL : out std_logic ;
		RDY_ONE : out std_logic);
	end component;
	
	
	component SET_VHDL
		port(
		CLK : in std_logic ;
		R : in std_logic ;
		TRG_ONE : in std_logic ;
		NEZ_IN_START : in character ;
		NEZ_IN_END : in character ;
		OPTION : in integer ;
		TEXT_IN : in character;
		COUNT_IN : in integer;
		COUNT_OUT : out integer;
		FAIL : out std_logic ;
		RDY_ONE : out std_logic);
	end component;
	
	
	
	component RSET_VHDL 
		port(
		CLK : in std_logic ;
		R : in std_logic ;
		TRG_ONE : in std_logic ;
		CONTINUE_TRG : in std_logic ;
		NEZ_IN_START : in character := 'a';
		NEZ_IN_END : in character := 'z';
		OPTION : in integer ;
		TEXT_IN : in character ;
		COUNT_IN : in integer := 4;
		COUNT_OUT : out integer ;
		--FAIL : out std_logic := '0' ;
		CONTINUE_RDY : out std_logic ;
		RDY_ONE : out std_logic := '0');
	end component;
	
		component OBYTE_VHDL
        port(
        CLK : in std_logic ;
        R : in std_logic ;
        TRG_ONE : in std_logic ;
        TEXT_IN : in character := 'a';
        NEZ_IN : in character := 'a';
        COUNT_IN : in integer := 1;
        COUNT_OUT : out integer ;
        RDY_ONE : out std_logic := '0');
    end component;
    
    	component STR_VHDL
        port(
        CLK : in std_logic ;
        R : in std_logic ;
        TRG_ONE : in std_logic ;
        TEXT_IN : in string(1 to 2);
        NEZ_IN : in string(1 to 2);
        COUNT_IN : in integer := 1;
        COUNT_OUT : out integer ;
        FAIL : out std_logic := '0' ;
        RDY_ONE : out std_logic := '0');
    end component;
    
    	component NANY_VHDL 
        port(
        CLK : in std_logic ;
        R : in std_logic ;
        TRG_ONE : in std_logic ;
        TEXT_IN : in character := '1';
        COUNT_IN : in integer := 1;
        COUNT_OUT : out integer ;
        FAIL : out std_logic := '0' ;
        RDY_ONE : out std_logic := '0');
    end component;
	
	
	signal PARSER_OK :  boolean := false ;
	signal count_start : integer := 0;
	
		
	------------------------------------------------
	--Need to fix when add new
	------------------------------------------------
	constant ARRAY_WIDTH : natural := 20 ;
	signal byte_text_reg : character ;
	signal set_text_start_sig, set_text_end_sig : character;
	signal set_option_sig : integer ;
	signal rbyte_text_reg : character;	
	signal obyte_text_reg : character;
	signal nbyte_text_reg : character;
	signal pos_reg : integer := 0 ;
		
	--subtype digit is integer range 1 to 10 ;
	signal count : integer := 1;
	type count_all is array (0 to ARRAY_WIDTH) of integer;
	signal count_array : count_all := (others => 1) ;
	
	signal text_in_reg : character := ' ' ;
	signal next_rdy_array : std_logic_vector(ARRAY_WIDTH downto 0) := (others => '0') ;
	signal next_rdy : std_logic := '0';
	signal id_reg : integer := 0 ;
	signal trg_reg_array : std_logic_vector(ARRAY_WIDTH downto 1) := (others => '0') ;
	signal fail_reg_array : std_logic_vector(ARRAY_WIDTH downto 0) := (others => '0') ;
	signal fail_reg : std_logic := '0' ;

	signal cmd_line : natural := 1;
	
	signal nosignal_rdy : std_logic := '0' ;
	
	signal continue_sig : std_logic := '0' ;
	
	type string_array is array(1 to 3) of string(1 to 10);
	signal res_string_array : string_array := (others => (others => ' '));

	
	signal next_trg : std_logic := '0' ;
	signal next_text_rdy_reg : std_logic := '0' ;
	
	signal start : std_logic := '0' ;
	
	signal string_text_reg, string_nez_reg : string(1 to 2) := "  ";

	
	--MAX function
	function max_count(c:count_all) return integer is
		variable i : integer ;
		variable max : integer ;
		begin
		max := c(0);
		for i in c'range loop
			if (c(i) > max) then
				max := c(i) ;
			end if;
		end loop;
		return max;
	end max_count;
	
	--next_rdy_function
	function next_rdy_function(n:std_logic_vector) return std_logic is
		variable i : integer;
		variable rdy : std_logic ;
		begin
			rdy := n(0);
			for i in n'range loop
				rdy := (rdy or n(i));
			end loop;
			return rdy;
	end next_rdy_function;
	
	
	signal end_fail : boolean := false ;
	signal end_parser_ok : boolean := false ;
					
begin
	
	count <= max_count(count_array) ;
	next_rdy <= (next_rdy_function(next_rdy_array));
	fail_reg <= next_rdy_function(fail_reg_array) ;
	--PARSER_ERROR <= end_fail or (end_parser_ok and text_in_reg /= ESC) ;
	PARSER_OK <= (end_parser_ok and text_in_reg = ESC) ;
	
	------------------------------------------------
	--Need to fix when add new
	------------------------------------------------
	FILE_INPUT : FILE_INPUT_VHDL
	port map(	
	   CLK => CLK,
		TRG => START,
		RDY_IN => next_rdy,
		FAIL => fail_reg,
		ID => id_reg,
		BYTE_TEXT => byte_text_reg,
		SET_TEXT_START => set_text_start_sig,
	   SET_TEXT_SECOND => set_text_end_sig,
	   SET_OPTION => set_option_sig,
		RBYTE_TEXT => rbyte_text_reg,
		OBYTE_TEXT => obyte_text_reg,
		NBYTE_TEXT => nbyte_text_reg,
		CMD_LINE_NO => cmd_line,
		END_FAIL => end_fail,
		PARSER_OK => end_parser_ok,
		NEXT_TEXT_RDY => next_text_rdy_reg,
		NEXT_RDY => nosignal_rdy);


	TEXT_INPUT : TEXT_INPUT_VHDL
	port map(
		CLK => CLK,
		TRG => START,
		RDY => next_text_rdy_reg,
		COUNT_IN => count,
		COUNT_OUT => count_array(0),
		CHAR_OUT => text_in_reg);



	------------------------------------------------
	--Need to fix when add new
	------------------------------------------------
	STATE_CONTROLLOR : STATE_CONTROLLOR_VHDL 
	port map (
		CLK => CLK ,
		ID => id_reg ,
		R => '0' ,
		TRG_ONE => '0' ,
		RDY_IN => nosignal_rdy ,
		BYTE_TRG => trg_reg_array(1) ,
		--ANY_TRG => trg_reg_array(2),
		SET_TRG => trg_reg_array(3),
		--RBYTE_TRG => trg_reg_array(4),
		--OBYTE_TRG => trg_reg_array(5),
		--POS_TRG => trg_reg_array(6),
		--BACK_TRG => trg_reg_array(7),
		--NBYTE_TRG => trg_reg_array(8),
		RSET_TRG => trg_reg_array(14),
		FAIL_TRG => fail_reg_array(13),
		OTHERS_TRG => next_rdy_array(0));

	BYTE : BYTE_VHDL port map (
		CLK => CLK ,
		R => '0' ,
		TRG_ONE => trg_reg_array(1),
		TEXT_IN => text_in_reg,
		NEZ_IN => byte_text_reg,
		COUNT_IN => count,
		COUNT_OUT => count_array(1),
		FAIL => fail_reg_array(1),
		RDY_ONE => next_rdy_array(1));

		
	SET : SET_VHDL port map (
		CLK => CLK,
		R => '0',
		TRG_ONE => trg_reg_array(3),
		NEZ_IN_START => set_text_start_sig,
		NEZ_IN_END => set_text_end_sig,
		OPTION => set_option_sig,
		TEXT_IN => text_in_reg,
		COUNT_IN => count,
		COUNT_OUT => count_array(3),
		FAIL => fail_reg_array(3),
		RDY_ONE => next_rdy_array(3));
				
	RSET : RSET_VHDL port map (
		CLK => CLK,
		R => '0',
		TRG_ONE => trg_reg_array(14),
		CONTINUE_TRG => continue_sig,
		NEZ_IN_START => set_text_start_sig,
		NEZ_IN_END => set_text_end_sig,
		OPTION => set_option_sig,
		TEXT_IN => text_in_reg,
		COUNT_IN => count,
		COUNT_OUT => count_array(14),
		--FAIL : out std_logic := '0' ;
		CONTINUE_RDY => continue_sig,
		RDY_ONE => next_rdy_array(14));
		
			OBYTE : OBYTE_VHDL port map (
            CLK => CLK,
            R => '0',
            TRG_ONE => trg_reg_array(17),
            TEXT_IN => text_in_reg,
            NEZ_IN => byte_text_reg,
            COUNT_IN => count,
            COUNT_OUT => count_array(17),
            RDY_ONE => next_rdy_array(17));
            
               STR : STR_VHDL port map (
                 CLK => CLK,
                 R => '0',
                 TRG_ONE => trg_reg_array(19),
                 TEXT_IN => string_text_reg,
                 NEZ_IN => string_nez_reg,
                 COUNT_IN => count,
                 COUNT_OUT => count_array(19),
                 FAIL => fail_reg_array(19),
                 RDY_ONE => next_rdy_array(19));
                 
         	NANY : NANY_VHDL port map (
                     CLK => CLK,
                     R => '0',
                     TRG_ONE => trg_reg_array(16),
                     TEXT_IN => text_in_reg,
                     COUNT_IN => count,
                     COUNT_OUT => count_array(16),
                     FAIL => fail_reg_array(16),
                     RDY_ONE => next_rdy_array(16));

	process(CLK)
	begin
	   if(CLK'event and CLK = '0') then	
	       if(end_fail or (end_parser_ok and text_in_reg /= ESC)) then
	       PARSER_ERROR <= '1' ;
	       else
	       PARSER_ERROR <= '0' ;
	       end if;
	       
	       if(count_start <4) then
	       count_start <= count_start + 1;
	       end if;
	       
	       if(count_start = 2) then
	           start <= '1';
	       else
	           start <= '0';
	       end if;
           
		end if;
	end process;

end Behavioral;