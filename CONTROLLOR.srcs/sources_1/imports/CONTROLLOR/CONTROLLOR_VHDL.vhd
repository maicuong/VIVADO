library ieee;
use ieee.std_logic_1164.all;
use STD.textio.all;

entity CONTROLLOR_VHDL is
	port (
	CLK : in std_logic := '0';
	PARSER_OK : out std_logic := '0';
	PARSER_ERROR : out std_logic := '0');
end CONTROLLOR_VHDL;

architecture Behavioral of CONTROLLOR_VHDL is

    -----------------------------------------
    -- Loading command
    -----------------------------------------
	component FILE_INPUT_VHDL 
		port(
		CLK : in std_logic;
		READ_TRG : in std_logic := '0';
		TRG : in std_logic ;
		RDY_IN : in std_logic ;
		FAIL : in std_logic ;
		TEXT_IN : in character := ' ';
		ID : out integer;
		BYTE_TEXT : out character ;
		SET_TEXT_START : out character ;
	    SET_TEXT_SECOND : out character ;
	    SET_OPTION : out integer ;
		STR_TEXT : out string(1 to 2);
		END_FAIL : buffer std_logic ;
	    PARSER_OK : buffer std_logic ;
		NEXT_RDY : out std_logic );
	end component;
	
	-------------------------------------------
	-- Loading text
	-------------------------------------------
	component TEXT_INPUT_VHDL 
	   port(
		CLK : in std_logic ;
	    READ_TRG : in std_logic ;
		TRG : in std_logic ;
		RDY : in std_logic ;
		CHAR_OUT : out character ;
		STR_OUT : buffer string(1 to 2));
	end component;
	
	------------------------------------------------
	-- Make trigger signal to each command'IP core 
	------------------------------------------------
	component STATE_CONTROLLOR_VHDL
		port (
		CLK : in std_logic;
		RDY_IN : in std_logic ;
		ID : in integer;
		BYTE_TRG : out std_logic;
		SET_TRG : out std_logic;
		RSET_TRG : out std_logic;
		OBYTE_TRG : out std_logic ;
		STR_TRG : out std_logic;
		NANY_TRG : out std_logic;
		FAIL_TRG : out std_logic;
		OTHERS_TRG : out std_logic);
	end component;
	
	-------------------------------------------------
	-- Command'IP core : BYTE
	-------------------------------------------------
	component BYTE_VHDL 
		port(
		CLK : in std_logic ;
		TRG_ONE : in std_logic ;
		TEXT_IN : in character ;
		NEZ_IN : in character ;
		FAIL : out std_logic ;
		RDY_ONE : out std_logic);
	end component;
	
	--------------------------------------------------
	-- Command'IP core : SET
	--------------------------------------------------
	component SET_VHDL
		port(
		CLK : in std_logic ;
		TRG_ONE : in std_logic ;
		NEZ_IN_START : in character ;
		NEZ_IN_END : in character ;
		OPTION : in integer ;
		TEXT_IN : in character;
		FAIL : out std_logic ;
		RDY_ONE : out std_logic);
	end component;
	
	----------------------------------------------------
	-- Command'IP core : RSET
	----------------------------------------------------
	component RSET_VHDL 
		port(
		CLK : in std_logic ;
		--R : in std_logic ;
		TRG_ONE : in std_logic ;
		NEZ_IN_START : in character := 'a';
		NEZ_IN_END : in character := 'z';
		OPTION : in integer ;
		TEXT_IN : in character ;
		CONTINUE_RDY : out std_logic ;
		RDY_ONE : out std_logic := '0');
	end component;
	
	-----------------------------------------------------
	-- Command's IP core : OBYTE
	-----------------------------------------------------
	component OBYTE_VHDL
		port(
		CLK : in std_logic ;
		TRG_ONE : in std_logic ;
		TEXT_IN : in character := 'a';
		NEZ_IN : in character := 'a';
		RDY_ONE : out std_logic := '0');
	end component;
	
	------------------------------------------------------
	-- Command's IP core : SRT
	------------------------------------------------------
	component STR_VHDL
		port(
		CLK : in std_logic ;
		TRG_ONE : in std_logic ;
		TEXT_IN : in string(1 to 2);
		NEZ_IN : in string(1 to 2);
		FAIL : out std_logic := '0' ;
		RDY_ONE : out std_logic := '0');
	end component;
	
    -------------------------------------------------------
    -- Command's IP core : NANY
    -------------------------------------------------------
	component NANY_VHDL 
		port(
		CLK : in std_logic ;
		TRG_ONE : in std_logic ;
		TEXT_IN : in character := '1';
		FAIL : out std_logic := '0' ;
		RDY_ONE : out std_logic := '0');
	end component;
	
	signal count_start : integer := 0;

	constant ARRAY_WIDTH : natural := 20 ;
	signal byte_text_reg : character := ' ' ;
	signal set_text_start_sig, set_text_end_sig : character := ' ';
	signal set_option_sig : integer := 0;	
	signal obyte_text_reg : character := ' ';

	signal text_in_reg : character := ' ' ;
	signal next_rdy_array : std_logic_vector(ARRAY_WIDTH downto 0) := (others => '0') ;
	signal next_rdy : std_logic := '0';
	signal id_reg : integer := 0 ;
	signal trg_reg_array : std_logic_vector(ARRAY_WIDTH downto 1) := (others => '0') ;
	signal fail_reg_array : std_logic_vector(ARRAY_WIDTH downto 0) := (others => '0') ;
	signal fail_reg : std_logic := '0' ;
	signal nosignal_rdy : std_logic := '0' ;
	signal continue_sig : std_logic := '0' ;
	signal next_trg : std_logic := '0' ;
	signal next_text_rdy_reg : std_logic := '0' ;	
	signal start,start1,start2 : std_logic := '0' ;
		
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
	
	signal end_fail : std_logic := '0' ;
	signal end_parser_ok : std_logic := '0' ;
	signal string_text_reg, string_nez_reg : string(1 to 2) := "  ";
	signal state_next : std_logic := '0';
	--signal clk_sig : std_logic := '0';
	
	--attribute mark_debug : string;
    --attribute mark_debug of end_parser_ok: signal is "true";
	--attribute mark_debug of end_fail : signal is "true";
	--attribute mark_debug of next_rdy : signal is "true";
	--attribute mark_debug of fail_reg : signal is "true";
	--attribute mark_debug of nosignal_rdy : signal is "true";
	--attribute mark_debug of continue_sig : signal is "true";
	--attribute mark_debug of next_trg : signal is "true";
	--attribute mark_debug of next_text_rdy_reg : signal is "true";
	--attribute mark_debug of id_reg : signal is "true";
	--attribute mark_debug of CLK_sig : signal is "true";
	--attribute mark_debug of start : signal is "true";	
    --attribute mark_debug of start1 : signal is "true";	

begin
	next_rdy <= (next_rdy_function(next_rdy_array));
	fail_reg <= next_rdy_function(fail_reg_array) ;
	next_text_rdy_reg <= next_rdy_array(1) or next_rdy_array(3) or continue_sig;
	state_next <= nosignal_rdy or continue_sig;
	PARSER_OK <= end_parser_ok;
	--PARSER_OK <= start2;
	PARSER_ERROR <= end_fail;
	--clk_sig <= CLK;

	FILE_INPUT : FILE_INPUT_VHDL
	port map(	
	    CLK => CLK,
	    READ_TRG => start1,
	    TRG => START,
		RDY_IN => next_rdy,
		FAIL => fail_reg,
		ID => id_reg,
		TEXT_IN => text_in_reg,
		BYTE_TEXT => byte_text_reg,
		SET_TEXT_START => set_text_start_sig,
	    SET_TEXT_SECOND => set_text_end_sig,
	    SET_OPTION => set_option_sig,
		STR_TEXT => string_nez_reg,
		END_FAIL => end_fail,
		PARSER_OK => end_parser_ok,
		NEXT_RDY => nosignal_rdy);

	TEXT_INPUT : TEXT_INPUT_VHDL
	port map(
		CLK => CLK,
		READ_TRG => start1,
		TRG => START,
		RDY => next_text_rdy_reg,
		CHAR_OUT => text_in_reg,
		STR_OUT => string_text_reg);

	STATE_CONTROLLOR : STATE_CONTROLLOR_VHDL 
	port map (
		CLK => CLK ,
		ID => id_reg ,
		RDY_IN => state_next ,
		BYTE_TRG => trg_reg_array(1) ,
		SET_TRG => trg_reg_array(3),
		RSET_TRG => trg_reg_array(14),
		OBYTE_TRG => trg_reg_array(17),
		STR_TRG => trg_reg_array(19),
		NANY_TRG => trg_reg_array(16),
		FAIL_TRG => fail_reg_array(13),
		OTHERS_TRG => next_rdy_array(0));

	BYTE : BYTE_VHDL port map (
		CLK => CLK,
		TRG_ONE => trg_reg_array(1),
		TEXT_IN => text_in_reg,
		NEZ_IN => byte_text_reg,
		FAIL => fail_reg_array(1),
		RDY_ONE => next_rdy_array(1));

		
	SET : SET_VHDL port map (
		CLK => CLK,
		TRG_ONE => trg_reg_array(3),
		NEZ_IN_START => set_text_start_sig,
		NEZ_IN_END => set_text_end_sig,
		OPTION => set_option_sig,
		TEXT_IN => text_in_reg,
		FAIL => fail_reg_array(3),
		RDY_ONE => next_rdy_array(3));
				
	RSET : RSET_VHDL port map (
		CLK => CLK,
		TRG_ONE => trg_reg_array(14),
		NEZ_IN_START => set_text_start_sig,
		NEZ_IN_END => set_text_end_sig,
		OPTION => set_option_sig,
		TEXT_IN => text_in_reg,
		CONTINUE_RDY => continue_sig,
		RDY_ONE => next_rdy_array(14));
		
	OBYTE : OBYTE_VHDL port map (
		CLK => CLK,
		TRG_ONE => trg_reg_array(17),
		TEXT_IN => text_in_reg,
		NEZ_IN => byte_text_reg,
		RDY_ONE => next_rdy_array(17));
		
   STR : STR_VHDL port map (
		CLK => CLK,
		TRG_ONE => trg_reg_array(19),
		TEXT_IN => string_text_reg,
		NEZ_IN => string_nez_reg,
		FAIL => fail_reg_array(19),
		RDY_ONE => next_rdy_array(19));
		
	NANY : NANY_VHDL port map (
		CLK => CLK,
		TRG_ONE => trg_reg_array(16),
		TEXT_IN => text_in_reg,
		FAIL => fail_reg_array(16),
		RDY_ONE => next_rdy_array(16));

	process(CLK)
	begin
	   if(CLK'event and CLK = '0') then	       
	       if(count_start < 8) then
	       count_start <= count_start + 1;
	       end if;
	       
	       if(count_start = 2) then
	           start1 <= '1';
	       elsif(count_start = 4) then
	           start <= '1' ;
	       elsif(count_start = 6) then
	           start2 <= '1';
	       else
	           start1 <= '0';	       
	           start <= '0';
	       end if;
           
		end if;
	end process;

end Behavioral;