library ieee;
use ieee.std_logic_1164.all;
use STD.textio.all;

entity TEXT_INPUT_VHDL is
	port(
	CLK : in std_logic ;
	READ_TRG : in std_logic ;
	TRG : in std_logic ;
	RDY : in std_logic ;
	TEXT_INPUT_STREAM : in std_logic_vector(7 downto 0);
	RUN : out std_logic := '0';
	CHAR_OUT : out std_logic_vector(7 downto 0)) ;
	--STR_OUT : buffer string(1 to 2) );
end TEXT_INPUT_VHDL;

architecture Behavioral of TEXT_INPUT_VHDL is
	signal string_line_no : natural := 1;
	constant ETX : std_logic_vector(7 downto 0) := "00000011";
	constant CHAR_NUM : integer := 10;
	type string_array is array(1 to CHAR_NUM) of std_logic_vector(7 downto 0);
	signal str_array : string_array := (others => "00000000");
	signal run_sig : std_logic := '0';
	--signal in_num, out_num : natural := 1;
	--signal c,c_read: std_logic_vector(7 downto 0);
	signal input_end: boolean := false;
	
	--Test
    --type text_sample is array(1 to 10) of std_logic_vector(7 downto 0); 
    --signal str_array : text_sample := ("01111011","00100010","01000001","00100010","00111010","00111001","01111101","00000011","00000000","00000000");
	
begin
		--char_out <= c_read;
		--count_out <= in_num;
		RUN <= run_sig;
        process (CLK)
          -- variable next_sig : std_logic := '0';
           variable count : natural := 1;
           variable in_num:         natural := 1;
		   --variable str_array : string_array := (others => "00000000");
        begin
        if(CLK'event and CLK = '1') then
				if (TEXT_INPUT_STREAM /= ETX and TEXT_INPUT_STREAM /= "UUUUUUUU") then
					str_array(in_num) <= TEXT_INPUT_STREAM;
					in_num := in_num + 1;
				elsif (TEXT_INPUT_STREAM = ETX) then
					str_array(in_num) <= TEXT_INPUT_STREAM;
					count := count + 1;
					if(count = 5) then
					run_sig <= '1';
					else
					run_sig <= '0';
					end if;
					input_end <= true;
				else
					run_sig <= '0';
				end if;
		 end if;
		 end process;
		 
		 process(CLK)
         variable c_read: std_logic_vector(7 downto 0);
         variable out_num:         natural := 1;  
		 begin
		  if(CLK'event and CLK = '1') then
                    if((TRG = '1' or RDY = '1')) then
                        if(out_num > 0 and out_num <=9) then
                        c_read := str_array(out_num);
                        out_num := out_num + 1;
                        end if;
 
                        char_out <= c_read;
                        --STR_OUT <= STR_OUT(2) & c_read;

                    end if;
            end if;
        end process;
    
    end Behavioral;

