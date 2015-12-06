library ieee;
use ieee.std_logic_1164.all;
use STD.textio.all;

entity TEXT_INPUT_VHDL is
	port(
	CLK : in std_logic ;
	TRG : in std_logic ;
	RDY : in std_logic ;
	CHAR_OUT : out character ;
	STR_OUT : buffer string(1 to 2) );
end TEXT_INPUT_VHDL;

architecture Behavioral of TEXT_INPUT_VHDL is

begin
	process(CLK)
       file text_input : text is in "C:\FPGAPrj\CONTROLLOR\text_input.txt";
       variable l:         line;
       variable c:         character;
       variable is_string: boolean;	 
    begin
	if(CLK'event and CLK = '1') then
	if(endfile(text_input)) then
		char_out <= ESC;
	else	
	   while not endfile(text_input) loop	
        readline(text_input, l);
        for i in 1 to 100 loop
           --wait until CLK = '1';
	       if (TRG = '1' or RDY = '1') then
	       --read(l, c, is_string);
	       --while c = ' ' loop
	       --read(l, c, is_string);
	       --end loop;
	       
	       
	       for i in 1 to 10 loop
             read(l, c, is_string);
	       exit when c /= ' ';
	       end loop;

           if is_string then 
		      char_out <= c;
		      STR_OUT <= STR_OUT(2) & c;
           else 
	          char_out <= LF;
	          str_out <= str_out(2)&LF;
	       exit;
           end if;
           end if;
         end loop;
		end loop;
	end if;
	end if;
end process;


end Behavioral;
