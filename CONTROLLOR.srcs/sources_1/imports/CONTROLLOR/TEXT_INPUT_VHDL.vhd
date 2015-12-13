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
    signal str : string(1 to 100) := (others => ' ');	
    signal next_sig, stop_sig : std_logic := '0';
    signal end_sig : boolean := false;
    signal char_reset : boolean := false;
    signal char_no : natural := 1;
begin
	process (CLK)
       file text_input : text is in "C:\FPGAPrj\CONTROLLOR\text_input.txt";
       variable l:         line;
       variable c,c_read:         character;
       variable is_string: boolean;
       variable j:         natural := 1;
    begin
	if(CLK'event and CLK = '1') then
	  stop_sig <= '0';
	  char_reset <= false;
      if not endfile(text_input) then	
          if(READ_TRG = '1' or next_sig = '1') then
              readline(text_input, l);
              j := 1;
              for i in str'range loop
                  str(i) <= ' ';
              end loop;  
              for i in str'range loop
                   read(l, c, is_string);
                   if is_string then 
                      if(c /= ' ') then
                         str(j) <= c;
                         j := j + 1;
                      end if;
                    else 
                      str(j) <= LF;
                      exit;
                    end if;            
                end loop;
                stop_sig <= '1';
                char_reset <= true;
            end if;
        else
           end_sig <= true;
        end if;
     end if;
   end process;
        
        
 process(CLK) 
	variable c_read : character := ' ';
 begin
    if(CLK'event and CLK = '1') then                   
       if((FIRST_TRG = '1' or RDY = '1')) then
          if(char_reset) then
             char_no <= 1;
          elsif(char_no > 0 and char_no <100) then
             if(not(c_read = LF and end_sig)) then 
                c_read := str(char_no);
             end if;
             char_no <= char_no + 1;
          end if;
			 if(c_read = LF and end_sig) then
             char_out <= ESC;
          else
             char_out <= c_read;
          end if;
          STR_OUT <= STR_OUT(2) & c_read;
			 
       end if;
    end if;
 end process;
 
 process(CLK)
 begin
    if(CLK'event and CLK = '1') then 
       if(stop_sig = '1') then
          next_sig <= '0';               
       elsif((FIRST_TRG = '1' or RDY = '1') and CHAR_OUT = LF) then
          next_sig <= '1';
		 else
			 next_sig <= '0';
       end if;
    end if;
 end process;

end Behavioral;