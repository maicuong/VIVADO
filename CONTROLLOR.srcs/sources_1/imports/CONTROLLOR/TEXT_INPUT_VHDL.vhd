library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use STD.textio.all;
use ieee.std_logic_textio.all;
LIBRARY UNISIM;
USE UNISIM.Vcomponents.ALL;

entity TEXT_INPUT_VHDL is
	port(
	CLK : in std_logic ;
	READ_TRG : in std_logic ;
	TRG : in std_logic ;
	RDY : in std_logic ;
	TEXT_INPUT_STREAM : in std_logic_vector(7 downto 0);
	COUNT_TEXT_STREAM : in natural;
	RUN : out std_logic := '0';
	CHAR_OUT : out std_logic_vector(7 downto 0)) ;
	--STR_OUT : buffer string(1 to 2) );
end TEXT_INPUT_VHDL;

architecture Behavioral of TEXT_INPUT_VHDL is
	signal string_line_no : natural := 1;
	constant ETX : std_logic_vector(7 downto 0) := "00000011";
	constant CHAR_NUM : integer := 500;
	type string_array is array(1 to CHAR_NUM) of std_logic_vector(7 downto 0);
	signal str_array : string_array := (others => "00000000");
	signal run_sig : std_logic := '0';
	--signal in_num, out_num : natural := 1;
	--signal c,c_read: std_logic_vector(7 downto 0);
	signal input_end: boolean := false;
	
	component MEMORY_VHDL
	    port (
		 CLK : in std_logic;
		DIN : in std_logic_vector(7 downto 0); 
       DOUT : out std_logic_vector(7 downto 0);
       WR : in std_logic;
       ADDR_IN : in std_logic_vector(8 downto 0));
	end component;
	
   --component RAMB4_S8
      --port (DI     : in STD_LOGIC_VECTOR (7 downto 0);
            --EN     : in STD_LOGIC;
            --WE     : in STD_LOGIC;
            --RST    : in STD_LOGIC;
            --CLK    : in STD_LOGIC;
            --ADDR   : in STD_LOGIC_VECTOR (8 downto 0);
            --DO     : out STD_LOGIC_VECTOR (7 downto 0)
      --); 
   -- end component;
	
	signal addr_in : std_logic_vector(8 downto 0);
	signal in_num, out_num:         natural := 1;
	
	
	signal ram_we_sig : std_logic := '1';
	signal ram_rst_sig : std_logic := '0';
	signal input_finish : boolean := false;
	--signal count_text_stream : natural := 1;
	signal dout : std_logic_vector(7 downto 0);
	
begin
		--char_out <= c_read;
		--count_out <= in_num;
		RUN <= run_sig;
		CHAR_OUT <= dout;
		
        process (CLK)
           --variable c,c_read: std_logic_vector(7 downto 0);     
           --variable next_sig : std_logic := '0';

           --variable end_sig : boolean := false;
			  --variable str_array : string_array := (others => "00000000");
        begin
        if(CLK'event and CLK = '1') then
				--if (TEXT_INPUT_STREAM /= ETX and TEXT_INPUT_STREAM /= "UUUUUUUU") then
					--str_array(in_num) <= TEXT_INPUT_STREAM;
					--in_num := in_num + 1;
				--elsif (TEXT_INPUT_STREAM = ETX and not input_end) then
					--str_array(in_num) <= TEXT_INPUT_STREAM;
					--run_sig <= '1';
					--input_end <= true;
				--else
					--run_sig <= '0';
				--end if;
					
                    if((TRG = '1' or RDY = '1')) then
                        if(out_num > 0 and out_num < CHAR_NUM) then
                        --c_read := str_array(out_num);
                        out_num <= out_num + 1;
                        end if;
 
                        --char_out <= c_read;
                        --STR_OUT <= STR_OUT(2) & c_read;

                    end if;
        end if;
    end process;
	 
	 --addr_in <= CONV_std_logic_vector(out_num,9);
	 MEMORY : MEMORY_VHDL
	    port map(
		 CLK => CLK,
		 DIN => text_input_stream,
         DOUT => dout,
         WR => ram_we_sig,
         ADDR_IN => addr_in );
		 
	--MEM : RAMB4_S8
		--port map(
		--ADDR => addr_in,
		--DI => text_input_stream,
		--CLK => CLK,
		--EN => '1',
		--RST => '0',
		--WE => ram_we_sig,
		--DO => dout);
		
	
	process(CLK)
	begin
		if(CLK'event and CLK = '1') then
			if(text_input_stream = "00000011") then
				input_finish <= true;
			end if;
		end if;
	end process;

	ram_rst_sig <= '0' when input_finish else '1';
	ram_we_sig <= '0' when input_finish else '1';
	
	process(CLK)
	begin
		if(CLK'event and CLK = '1') then
			if(input_finish) then
				addr_in <= CONV_std_logic_vector(out_num,9);
			else
				addr_in <= CONV_std_logic_vector((count_text_stream+1),9);
			end if;
		end if;
	end process;
	
	--process(CLK)
	--begin
		--if(CLK'event and CLK = '1') then
			--if(text_input_stream /= dout) then	
				--count_text_stream <= count_text_stream + 1;
			--end if;
		--end if;
	--end process;
	
	process(CLK)
	begin
		if(CLK'event and CLK = '1') then
			if(input_finish and not input_end) then	
				run_sig <= '1';
				input_end <= true;
			else 
				run_sig <= '0';
			end if;
		end if;
	end process;
    
end Behavioral;
