----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:54:02 11/12/2015 
-- Design Name: 
-- Module Name:    FILE_INPUT_TEST - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TEXT_INPUT_VHDL is
	port(
	CLK : in std_logic ;
	TRG : in std_logic ;
	RDY : in std_logic ;
	COUNT_IN : in integer := 1;
	COUNT_OUT : out integer ;
	CHAR_OUT : out character);
end TEXT_INPUT_VHDL;

architecture Behavioral of TEXT_INPUT_VHDL is
	signal string_line_no : natural := 1;
	--signal char_no : natural := 1;
	--signal text_in_reg : character := ' ' ;
	--signal count_out_reg : integer := 1;
	--file in_file : text;
	--type string_array is array(1 to 3) of string(1 to 10);
	--signal res_string_array : string_array := (others => (others => ' '));

begin

	process(CLK)
       file text_input : text is in "C:\FPGAPrj\VIVADO\CONTROLLOR\CONTROLLOR.srcs\constrs_1\imports\CONTROLLOR\text_input.txt";
       variable l:         line;
       variable c:         character;
       variable is_string: boolean;
		 variable j,n:         natural := 1;
		 variable str_line_no_var,char_no_var : integer := 1;
		 
		 type string_array is array(1 to 3) of string(1 to 10);
	    variable text_string_array : string_array := (others => (others => ' '));
       
   begin
	
	--wait until (TRG = '1') ;
	--file_open(in_file, "text_input.txt",  read_mode);
      
    if(CLK'event and CLK = '1') then 	  
			  
	if (TRG = '1') then
     while not endfile(text_input) loop		
     readline(text_input, l);
     -- clear the contents of the result string
     for i in text_string_array(j)'range loop
         text_string_array(j)(i) := ' ';
     end loop;   
     -- read all characters of the line, up to the length  
     -- of the results string
     for i in text_string_array(j)'range loop

    read(l, c, is_string);
	 n := i ;
    if is_string then 
		text_string_array(j)(i) := c;
		--res_string_array(j)(i) <= c;
    else exit;
    end if;
   
     end loop;
		
		if(j < 3) then
		j := j+1;
		end if;
		end loop;
		
		text_string_array(j-1)(n) := ESC;
		--res_string_array(j-1)(n) <= ESC;
		
	end if;
		--if(text_string_array(1)(1) = ' ') then
		
		--while COUNT_IN < 30 loop
		--wait until CLK = '1' ;
		if (TRG = '1' or RDY = '1') then
		char_no_var := COUNT_IN - 10*(string_line_no-1) ;
		--char_no <= COUNT ;
		if(text_string_array(str_line_no_var)(char_no_var) = ' ') then
		--while (text_string_array(str_line_no_var)(char_no_var) = ' ')
		for i in 1 to 10 loop
			if(char_no_var = 10) then
				--if(str_line_no_var <3) then
				str_line_no_var := str_line_no_var + 1;
				char_no_var := 1;
				exit when str_line_no_var > 3;
				--end if;
			else
				char_no_var := char_no_var + 1;
			end if;
				--i := i + 1;
			exit  when text_string_array(str_line_no_var)(char_no_var) /= ' ' ;
			--end if;
		end loop ;
		end if;
		--else
		
		CHAR_OUT <= text_string_array(str_line_no_var)(char_no_var);
		string_line_no <= str_line_no_var ;
		--char_no <= char_no_var ;
		COUNT_OUT <= char_no_var + 10*(str_line_no_var-1) + 1;
		--end if;
		end if;
		
		--end loop;
		
		--count_out_reg <= char_no_var;
           
       end if;          
end process;


end Behavioral;

