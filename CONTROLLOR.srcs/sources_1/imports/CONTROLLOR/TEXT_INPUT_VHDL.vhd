library ieee;
use ieee.std_logic_1164.all;
use STD.textio.all;
use ieee.numeric_std.all;

entity TEXT_INPUT_VHDL is
	port(
	CLK : in std_logic := '0';
	READ_TRG : in std_logic ;
	TRG : in std_logic := '0';
	RDY : in std_logic := '0';
	CHAR_OUT : out std_logic_vector(7 downto 0);
	STR_OUT : buffer std_logic_vector(15 downto 0));
end TEXT_INPUT_VHDL;

architecture Behavioral of TEXT_INPUT_VHDL is

      signal str : string(1 to 1000) := (others => ' ');
      signal next_sig : std_logic;
      
      signal next_done, next_please : std_logic;
      
begin
	process (CLK)
       file text_input : text is in "C:\FPGAPrj\benchmark1.txt";
       variable l:         line;
       variable c,c_read:         character;
       variable is_string: boolean;
       variable str_var : string(1 to 1000) := (others => ' ');	 
       --variable next_sig : std_logic := '0';
       variable j,n:         natural := 1;
       variable end_sig : boolean := false;
    begin
	if(CLK'event and CLK = '1') then
	   --next_done <= '0';
      while not endfile(text_input) loop	
          if(READ_TRG = '1' or next_sig = '1') then
             readline(text_input, l);
             j := 1;
            for i in str_var'range loop
              str_var(i) := ' ';
            end loop;  
            for i in str_var'range loop
               read(l, c, is_string);
               if is_string then 
                 if(c /= ' ' and c /= CR) then
                     str_var(j) := c;
                     j := j + 1;
                 end if;
               else 
                 str_var(j) := LF;
               exit;
               end if;
            end loop;      
            --next_done <= '1';
            str <= str_var;
           end if;
		end loop;
						
		--if endfile(text_input) then
           --end_sig := true;
        --end if;
                
    end if;
  end process;    
        
    
  
  
  process(CLK)
        variable n : integer := 1;
        variable c_read : character;
    begin
    if(CLK'event and CLK = '1') then           
        next_sig <= '0';           
        if((TRG = '1' or RDY = '1')) then
            if(n > 0 and n <100) then
               c_read := str(n);
               n := n + 1;
             end if;
                 
            if(c_read = LF) then
              next_sig <= '1';
			  n := 1;
            end if;
            char_out <= std_logic_vector(to_unsigned(natural(character'pos(c_read)),8));
            STR_OUT <= STR_OUT(15 downto 8) & std_logic_vector(to_unsigned(natural(character'pos(c_read)),8));
        end if;
	end if;
end process;


end Behavioral;