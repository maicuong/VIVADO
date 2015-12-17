library ieee;
use ieee.std_logic_1164.all;
use STD.textio.all;

entity TEXT_INPUT_VHDL is
	port(
	CLK : in std_logic := '0';
	READ_TRG : in std_logic ;
	TRG : in std_logic := '0';
	RDY : in std_logic := '0';
	CHAR_OUT : out character := ' ';
	STR_OUT : buffer string(1 to 2) := "  " );
end TEXT_INPUT_VHDL;

architecture Behavioral of TEXT_INPUT_VHDL is
	signal string_line_no : natural := 1;
	--signal char_no : natural := 1;
	--signal text_in_reg : character := ' ' ;
	--signal count_out_reg : integer := 1;
	--file in_file : text;
	constant STRING_WIDTH : integer := 50;
	constant LINE_NUMBER : integer := 15;
	type string_array is array(1 to LINE_NUMBER) of string(1 to STRING_WIDTH);
	signal res_string_array : string_array := (others => (others => ' '));
    signal str_line_no_var,char_no_var : integer := 1;
    signal next_sig:         boolean := false;

begin

	process(READ_TRG)
       file text_input : text is in "C:\FPGAPrj\CONTROLLOR\text_input.txt";
       variable l:         line;
       variable c:         character;
       variable is_string: boolean;
		 variable j,n:         natural := 1;

		 
		--type string_array is array(1 to LINE_NUMBER) of string(1 to STRING_WIDTH);
	    --variable text_string_array : string_array := (others => (others => ' '));
       
   begin
	
	--wait until (TRG = '1') ;
	--file_open(in_file, "text_input.txt",  read_mode);
      
    if(READ_TRG'event and READ_TRG = '1') then 	  
			  
	--if (READ_TRG = '1') then
     while not endfile(text_input) loop		
     readline(text_input, l);
	  n := 1 ;
     -- read all characters of the line, up to the length  
     -- of the results string
     for i in res_string_array(j)'range loop

    read(l, c, is_string);
                        if is_string then 
                            if(c /= ' ') then
                            --text_string_array(j)(n) := c;
									 res_string_array(j)(n) <= c;
                            n := n + 1;
                            end if;
                            --test(i) <= c;
                            --test <= str(256);
                        else 
                        --text_string_array(j)(n) := LF;
								res_string_array(j)(n) <= LF;
                        exit;
                        end if;
   
     end loop;
		
		if(j < LINE_NUMBER) then
		j := j+1;
		end if;
		end loop;
		
	   --text_string_array(j-1)(n) := ESC;
		res_string_array(j-1)(n) <= ESC;
		
	--end if;
		--if(text_string_array(1)(1) = ' ') then
		
		--while COUNT_IN < 30 loop
		--wait until CLK = '1' ;
		
    end if;
  end process;
  
  process(CLK)
  variable c_read : character := ' ';
 begin
    if(CLK'event and CLK = '1') then	
		if (TRG = '1' or RDY = '1') then
				if(char_no_var > 0 and char_no_var < STRING_WIDTH) then
				c_read := res_string_array(str_line_no_var)(char_no_var);
				--c_read := res_string_array(str_line_no_var)(char_no_var);
				--char_no_var <= char_no_var + 1;
				end if;
				
				if(c_read = LF) then
				next_sig <= true;
				char_no_var <= 1;
				else
				next_sig <= false;
				char_no_var <= char_no_var + 1; 
				end if;
				
				
				char_out <= c_read;
                STR_OUT <= STR_OUT(2) & c_read;
				
		end if;
        end if;      
end process;



process(CLK)
    variable accept_sig : boolean := true;
begin
    if(CLK'event and CLK = '1') then
        if(next_sig and accept_sig) then
          if(str_line_no_var > 0 and str_line_no_var < LINE_NUMBER) then
            str_line_no_var <= str_line_no_var + 1;
          end if;
          accept_sig := false;
        end if;
        if(TRG = '1' or RDY = '1') then
          accept_sig := true;
        end if;     
   end if;
 end process;            


end Behavioral;
