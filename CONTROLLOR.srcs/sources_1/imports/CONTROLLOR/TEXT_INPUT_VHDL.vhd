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
	constant STRING_WIDTH : integer := 30;
	constant LINE_NUMBER : integer := 12;
	type string_array is array(1 to LINE_NUMBER) of string(1 to STRING_WIDTH);
	signal res_string_array : string_array := (('{',LF,' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '),
	                                           ('"','I','m','a','g','e','"',':','{',LF,' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '),
	                                           ('"','W','i','t','h','"',':','8','0','0',',',LF,' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '),
	                                           ('"','H','e','i','g','h','t','"',':','6','0','0',',',LF,' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '),
	                                           ('"','T','i','t','l','e','"',':','"','V','i','e','w','f','r','o','m','1','5','t','h','F','l','o','o','r','"',',',LF,' '),
	                                           ('"','T','h','u','m','b','n','a','i','l','"',':','{',LF,' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '),
	                                           ('"','H','e','i','g','h','t','"',':','1','2','5',',',LF,' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '),
	                                           ('"','W','i','t','h','"',':','1','0','0',LF,' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '),
	                                           ('}',',',LF,' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '),
	                                           ('"','A','n','i','m','a','t','e','d','"',':','f','a','l','s','e',LF,' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '),
	                                           ('}',LF,' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '),
	                                           ('}',LF,' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '));
    --signal str_line_no_var,char_no_var : integer := 1;
    --signal next_sig:         boolean := false;

begin
        process (CLK)
           --file text_input : text is in "C:\FPGAPrj\CONTROLLOR\text_input.txt";
           --variable l:         line;
           variable c,c_read:         character;
           --variable is_string: boolean;
           --variable str : string(1 to 100) := (others => ' ');     
           variable next_sig : std_logic := '0';
           variable j,n:         natural := 1;
           variable end_sig : boolean := false;
        begin
        if(CLK'event and CLK = '1') then
          --if not endfile(text_input) then    
                        --if(TRG = '1' or RDY = '1') then
                        --if(TRG = '1' or next_sig = '1') then
                      --readline(text_input, l);
                            --j := 1;
                            --for i in str'range loop
                                --str(i) := ' ';
                           --end loop;  
                              --for i in str'range loop
                            --read(l, c, is_string);
                            --if is_string then 
                                --if(c /= ' ') then
                                --str(j) := c;
                                --j := j + 1;
                                --end if;
                                --test(i) <= c;
                                --test <= str(256);
                            --else 
                            --str(j) := LF;
                            --exit;
                            --end if;
                        
                        --end loop;
                      
                      --next_sig := '0';
                      --n := 1;
                      --end if;
                      --else
                        --for i in str'range loop
                            --    str(i) := ' ';
                           --end loop;
                        --str(1) := ESC;
                        --next_sig := '0';
                      --n := 1;
                      --end_sig := true;
                      --end if;
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
                        if(n > 0 and n <STRING_WIDTH) then
                        --if(not(c_read = LF and end_sig)) then 
                        c_read :=res_string_array(j)(n);
                        --end if;
                        n := n + 1;
                        end if;
                        
                        --if(c_read = LF)
                        
                       --exit when (c_read /= ' ');
                     --if(c = ' ') then next;
                     --else
                     --next_sig := false;
                     
                     --end if;
                     --end loop;
                     
                        if(c_read = LF) then
                            if(j > 0 and j < LINE_NUMBER) then
                                j := j + 1;
                            end if;
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
                       -- end if;
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


