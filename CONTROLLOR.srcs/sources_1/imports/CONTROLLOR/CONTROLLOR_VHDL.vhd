library ieee;
use ieee.std_logic_1164.all;
use STD.textio.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

entity CONTROLLOR_VHDL is
	port (
	CLK : in std_logic := '0';
	--INPUT_STREAM : in std_logic_vector(7 downto 0);
	--RDEN : in std_logic;
	TIME_COUNT : out std_logic_vector(31 downto 0);
	PARSER_OK : buffer std_logic := '0');
	--PARSER_ERROR : out std_logic := '0');
end CONTROLLOR_VHDL;

architecture Behavioral of CONTROLLOR_VHDL is

    signal parser_error : std_logic;
    signal input_stream :  std_logic_vector(7 downto 0);
    signal rden : std_logic;
    
    -----------------------------------------
    -- Loading command
    -----------------------------------------
	component FILE_INPUT_VHDL 
		port(
		CLK : in std_logic;
		READ_TRG : in std_logic := '0';
		CONTINUE : in std_logic;
		TRG : in std_logic ;
		RDY_IN : in std_logic ;
		FAIL : in std_logic ;
		TEXT_IN : in std_logic_vector(7 downto 0);
	    TEXT_INPUT_STREAM : in std_logic_vector(7 downto 0);
	    IMP : in std_logic;
		ID : buffer integer;
		BYTE_TEXT : out std_logic_vector(7 downto 0) ;
		SET_TEXT_START : out std_logic_vector(7 downto 0) ;
	    SET_TEXT_SECOND : out std_logic_vector(7 downto 0);
	    SET_OPTION : out integer ;
		STR_TEXT : out std_logic_vector(15 downto 0);
		END_FAIL : buffer std_logic ;
	    PARSER_OK : buffer std_logic ;
	    NEXT_IMP : out std_logic;
	    Byte_trg : out std_logic;
        Set_trg : out std_logic;
        Rset_trg : out std_logic;
        Obyte_trg : out std_logic;
        Str_trg : out std_logic;
        Nany_trg : out std_logic;
		NEXT_RDY : out std_logic );
	end component;
	
	-------------------------------------------
	-- Loading text
	-------------------------------------------
	component TEXT_INPUT_VHDL 
	   port(
		CLK : in std_logic ;
	    STR_TRG : in std_logic ;
		TRG : in std_logic ;
		RDY : in std_logic ;
		TEXT_INPUT_STREAM : in std_logic_vector(7 downto 0);
	    RDEN : in std_logic ;
		RUN : out std_logic := '0';
		CHAR_OUT : out std_logic_vector(7 downto 0);
		STR_OUT : out std_logic_vector(15 downto 0));
	end component;
	
	------------------------------------------------
	-- Make trigger signal to each command'IP core 
	------------------------------------------------
	component STATE_CONTROLLOR_VHDL
		port (
		CLK : in std_logic;
		RDY_IN : in std_logic ;
		ID : in integer;
		--BYTE_TRG : out std_logic;
		--SET_TRG : out std_logic;
		--RSET_TRG : out std_logic;
		--OBYTE_TRG : out std_logic ;
		--STR_TRG : out std_logic;
		--NANY_TRG : out std_logic;
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
		TEXT_IN : in std_logic_vector(7 downto 0) ;
		NEZ_IN : in std_logic_vector(7 downto 0) ;
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
		NEZ_IN_START : in std_logic_vector(7 downto 0) ;
		NEZ_IN_END : in std_logic_vector(7 downto 0) ;
		OPTION : in integer ;
		TEXT_IN : in std_logic_vector(7 downto 0) ;
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
		NEZ_IN_START : in std_logic_vector(7 downto 0);
		NEZ_IN_END : in std_logic_vector(7 downto 0);
		OPTION : in integer ;
		TEXT_IN : in std_logic_vector(7 downto 0) ;
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
		TEXT_IN : in std_logic_vector(7 downto 0) ;
		NEZ_IN : in std_logic_vector(7 downto 0);
		RDY_ONE : out std_logic := '0';
		MATCH : out std_logic);
	end component;
	
	------------------------------------------------------
	-- Command's IP core : SRT
	------------------------------------------------------
	component STR_VHDL
		port(
		CLK : in std_logic ;
		TRG_ONE : in std_logic ;
		TEXT_IN : in std_logic_vector(15 downto 0);
		NEZ_IN : in std_logic_vector(15 downto 0);
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
		TEXT_IN : in std_logic_vector(7 downto 0) ;
		FAIL : out std_logic := '0' ;
		RDY_ONE : out std_logic := '0');
	end component;
	
	signal count_start : integer := 0;

	constant ARRAY_WIDTH : natural := 20 ;
	signal byte_text_reg : std_logic_vector(7 downto 0) := "00000000" ;
	signal set_text_start_sig, set_text_end_sig : std_logic_vector(7 downto 0) := "00000000";
	signal set_option_sig : integer := 0;	
	signal obyte_text_reg : std_logic_vector(7 downto 0) := "00000000";

	signal text_in_reg : std_logic_vector(7 downto 0) ;
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
	
	signal imp : std_logic := '0';
	
	--Test
    --signal text_input_stream : std_logic_vector(7 downto 0);
    constant CHAR_NUM : integer := 323;
    signal count_text_stream : integer := 1;
    signal txt_sample : string(1 to CHAR_NUM) := ('{','"','s','q','u','i','d','I','m','a','g','e','D','a','t','a','"',' ',':',' ','[','8',',',' ','7',',',' ','2','1',',',' ','2','5','5',',',' ','4','2',',',' ','3','9',',',' ','7','9',',',' ','2','5','5',',',' ','7','4',',',' ','6','4',',',' ','1','0','4',',',' ','2','5','5',
    '1',',','1',',','1',',','1',',','1',',',
    '1',',','1',',','1',',','1',',','1',',',
    '1',',','1',',','1',',','1',',','1',',',
    '1',',','1',',','1',',','1',',','1',',',
    '1',',','1',',','1',',','1',',','1',',',
    '1',',','1',',','1',',','1',',','1',',',
    '1',',','1',',','1',',','1',',','1',',',
    '1',',','1',',','1',',','1',',','1',',',
    '1',',','1',',','1',',','1',',','1',',',
    '1',',','1',',','1',',','1',',','1',',',
    '1',',','1',',','1',',','1',',','1',',',
    '1',',','1',',','1',',','1',',','1',',',
    '1',',','1',',','1',',','1',',','1',',',
    '1',',','1',',','1',',','1',',','1',',',
    '1',',','1',',','1',',','1',',','1',',',
    '1',',','1',',','1',',','1',',','1',',',
    '1',',','1',',','1',',','1',',','1',',',
    '1',',','1',',','1',',','1',',','1',',',
    '1',',','1',',','1',',','1',',','1',',',
    '1',',','1',',','1',',','1',',','1',',',
    '1',',','1',',','1',',','1',',','1',',',
    '1',',','1',',','1',',','1',',','1',',',
    '1',',','1',',','1',',','1',',','1',',',
    '1',',','1',',','1',',','1',',','1',',',
    '1',',','1',',','1',',','1',',','1',',',
    '1',']','}',' ');
    --type text_sample is array(1 to CHAR_NUM) of std_logic_vector(7 downto 0); 
    --signal txt_sample : text_sample := ("01111011","00100010","01000001","00100010","00111010","00111001","00111000","00101100","00001010","00100010","01000001","00100010","00111010","00111001","00111000","01111101","00101111","00000000");
    ------
		
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
	signal string_text_reg, string_nez_reg : std_logic_vector(15 downto 0);
	signal state_next : std_logic := '0';
	--signal clk_sig : std_logic := '0';
	signal fin : boolean := false;
	--signal rden : std_logic := '0';
	
	signal run_start : std_logic := '0';
	
	signal obyte_match : std_logic := '0';
	
	signal success_send : boolean := false;
	
	signal time_count_reg : integer := 0;
    signal time_count_true : boolean := false;
    signal time_count_start : boolean := true;
	
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
    
    signal rset_trg_sig, rset_ctn_sig : std_logic := '1';

begin
	next_rdy <= (next_rdy_function(next_rdy_array));
	fail_reg <= next_rdy_function(fail_reg_array) ;
	next_text_rdy_reg <= next_rdy_array(1) or next_rdy_array(3) or continue_sig or obyte_match;
	state_next <= nosignal_rdy;
	--PARSER_OK <= end_parser_ok;
	--PARSER_OK <= start2;
	PARSER_ERROR <= end_fail;
	--clk_sig <= CLK;

	FILE_INPUT : FILE_INPUT_VHDL
	port map(	
	    CLK => CLK,
	    READ_TRG => run_start,
	    TRG => START,
	    CONTINUE => continue_sig,
		RDY_IN => next_rdy,
		FAIL => fail_reg,
		ID => id_reg,
		TEXT_IN => text_in_reg,
	    TEXT_INPUT_STREAM => INPUT_STREAM,
	    IMP => imp,
		BYTE_TEXT => byte_text_reg,
		SET_TEXT_START => set_text_start_sig,
	    SET_TEXT_SECOND => set_text_end_sig,
	    SET_OPTION => set_option_sig,
		STR_TEXT => string_nez_reg,
		END_FAIL => end_fail,
		PARSER_OK => end_parser_ok,
		BYTE_TRG => trg_reg_array(1) ,
        SET_TRG => trg_reg_array(3),
        RSET_TRG => trg_reg_array(14),
        OBYTE_TRG => trg_reg_array(17),
        STR_TRG => trg_reg_array(19),
        NANY_TRG => trg_reg_array(16),
		NEXT_IMP => imp,
		NEXT_RDY => nosignal_rdy);
		
		--trg_reg_array(14) <= rset_trg_sig or rset_ctn_sig;

	TEXT_INPUT : TEXT_INPUT_VHDL
	port map(
		CLK => CLK,
		STR_TRG => next_rdy_array(19),
		TRG => START,
		RDY => next_text_rdy_reg,
		TEXT_INPUT_STREAM => input_stream,
		RDEN => rden,
		RUN => run_start,
		CHAR_OUT => text_in_reg,
		STR_OUT => string_text_reg
		);

	STATE_CONTROLLOR : STATE_CONTROLLOR_VHDL 
	port map (
		CLK => CLK ,
		ID => id_reg ,
		RDY_IN => state_next ,
		--RSET_TRG => rset_ctn_sig,
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
		RDY_ONE => next_rdy_array(17),
		MATCH => obyte_match);
		
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

	--process(CLK)
	--begin
	   --if(CLK'event and CLK = '0') then	       
	       --if(count_start < 8) then
	       --count_start <= count_start + 1;
	       --end if;
	       
	       --if(count_start = 2) then
	           --start1 <= '1';
	       --elsif(count_start = 4) then
	          --- start <= '1' ;
	       --elsif(count_start = 6) then
	           --start2 <= '1';
	       --else
	           --start1 <= '0';	       
	           --start <= '0';
	       --end if;
           
		--end if;
	--end process;
	
	process(CLK)
    begin
        if(CLK'event and CLK = '0') then
            if(count_text_stream >= 1 and count_text_stream <=(CHAR_NUM - 1)) then
                --if(not fin) then
                input_stream <= std_logic_vector(to_unsigned(natural(character'pos(txt_sample(count_text_stream))),8));
                rden <= '1';
                count_text_stream <= count_text_stream + 1;
                --end if;
                --count_text_stream <= count_text_stream + 1;
            else
                rden <= '0';
                --text_input_stream <= "UUUUUUUU";
            --end if;
            
            --if(count_text_stream = 9) then
                --count_text_stream <= 1;
                --fin <= true;
            end if;
        end if;
    end process;
    
    --process(CLK)
    --begin
        --if(CLK'event and CLK = '0') then
            --if(count_text_stream <= 8) then
                --count_text_stream <= count_text_stream + 1;
            --end if;
        --end if;
    --end process;
	 
    --process(CLK)
    --begin
        --if(CLK'event and CLK = '0') then
            --if(count_text_stream <= 8) then
                --rden <= '1';
				--else 
					--rden <= '0';
            --end if;
        --end if;
    --end process;
    
    --process(CLK)
    --begin
        --if(CLK'event and CLK = '1') then
            --if(input_stream = "01000000") then
               --parser_ok <= '0' ;
            --elsif(end_parser_ok = '1') then
                --parser_ok <= '1';
            --end if;
        --end if;
    --end process;
    
    process(CLK)
    begin
        if(CLK'event and CLK = '1') then
            if(input_stream = "01000000") then
               parser_ok <= '0' ;
               success_send <= false;
            elsif(end_parser_ok = '1' and not success_send) then
                parser_ok <= '1';
                success_send <= true;
            else
                parser_ok <= '0';
            end if;
        end if;
    end process;
    
    process(CLK)
    begin
        if(CLK'event and CLK = '1') then
            if(input_stream = "01000000") then
               time_count_true <= false;
               time_count_start <= true;
            elsif(parser_ok = '1') then
               time_count_true <= false;
            elsif(rden = '1' and time_count_start) then
               time_count_true <= true;
               time_count_start <= false;
            end if;
        end if;
    end process;
    
    TIME_COUNT <= CONV_std_logic_vector(time_count_reg,32) when (parser_ok = '1') else (others => '0');
    
    process(CLK)
    begin
        if(CLK'event and CLK = '1') then
            if(input_stream = "01000000") then
               time_count_reg <= 0;
            elsif(time_count_true) then
               time_count_reg <= time_count_reg + 1;
            else
               time_count_reg <= 0;
            end if;
        end if;
    end process;
    
    process(CLK)
        variable n : std_logic := '0';
        variable c : natural := 1; 
    begin
        if(CLK'event and CLK = '1') then
          if(input_stream = "01000000") then
            n := '0';
            c := 1;
         else   
            if(run_start = '1') then
                n := '1';
            end if;
            if(n= '1' and c < 10) then
                c := c + 1;
            end if;
            if(c = 7) then
                start <= '1';
            else
                start <= '0';
            end if;
          end if;
         end if;
     end process;

end Behavioral;