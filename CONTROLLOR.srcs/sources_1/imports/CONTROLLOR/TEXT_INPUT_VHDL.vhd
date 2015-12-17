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

      signal str : string(1 to 100) := (others => ' ');

begin
	process (CLK)
       file text_input : text is in "C:\FPGAPrj\CONTROLLOR\text_input.txt";
       variable l:         line;
       variable c,c_read:         character;
       variable is_string: boolean;
       --variable str : string(1 to 100) := (others => ' ');	 
       variable next_sig : std_logic := '0';
       variable j,n:         natural := 1;
       variable end_sig : boolean := false;
    begin
	if(CLK'event and CLK = '1') then
      if not end_sig then	
                    --if(TRG = '1' or RDY = '1') then
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
                            --test(i) <= c;
                            --test <= str(256);
                        else 
                        str(j) <= LF;
                        exit;
                        end if;
                    
                    end loop;
                  
                  next_sig := '0';
                  --n := 1;
                  end if;
						
						end if;
                  --else
                    --for i in str'range loop
                        --    str(i) := ' ';
                       --end loop;
                    --str(1) := ESC;
                    --next_sig := '0';
                  --n := 1;
						if endfile(text_input) then
                  end_sig := true;
                  end if;
                 -- clear the contents of the result string
                 --for i in text_string_array(j)'range loop
                     --text_string_array(j)(i) := ' ';
                 --end loop;   
                 -- read all characters of the line, up to the length  
                 -- of the results string
                  --wait until CLK = '1'; 
                  --next_sig := true;
                  --while next_sig ;
                 --for i in text_string_array(j)'range loop
                    --wait until CLK = '1';
                  --if(next_sig = '1') then
                    --next_sig <= '0';
                  --end if;
                    
                if((TRG = '1' or RDY = '1')) then
                --trg_sig <= next_sig or CLK;
                
                --if (TRG = '1' or RDY = '1') then
                 --while(c = ' ') loop
                 --if (next_sig) then
                 
                 --wait until (TRG = '1' or RDY = '1') ;
                 
                 --for i in 1 to 100 loop
                --read(l, c_read, is_string);
                   --num <= i ;
                    if(n > 0 and n <100) then
                    --if(not(c_read = LF and end_sig)) then 
                    c_read := str(n);
                    --end if;
                    n := n + 1;
                    end if;
                   --exit when (c_read /= ' ');
                 --if(c = ' ') then next;
                 --else
                 --next_sig := false;
                 
                 --end if;
                 --end loop;
                 
                    if(c_read = LF) then
                        next_sig := '1';
								n := 1;
                    end if;
                 
                 --n := i ;
                --if is_string then 
                    --text_string_array(j)(i) := c;
                    --res_string_array(j)(i) <= c;
                    --if(c_read = LF and end_sig) then
                    --char_out <= ESC;
                    --else
                    char_out <= c_read;
                    --end if;
                    --str_out_sig(1) := str_out_sig(2);
                    --str_out_sig(2) := c;
                    STR_OUT <= STR_OUT(2) & c_read;
                    --RDY <= '0';
                    --CONTINUE <= '0';
                    --next_sig <= '0';
                --else 
                 --next_sig <= '1';
                 --char_out <= LF;
                 --str_out <= str_out(2)&LF;
                 --next_sig := '1';
                --end if;
               --end if;
                    
                    
                --end if;
                 --end loop;
                    
                    --if(j < LINE_NUMBER) then
                    --j := j+1;
                    end if;
	end if;
end process;


end Behavioral;
