library ieee;
use ieee.std_logic_1164.all;
use STD.textio.all;
use ieee.numeric_std.all;

entity FILE_INPUT_VHDL is
        port(
        CLK : in std_logic := '0';
        READ_TRG : in std_logic := '0';
        CONTINUE : in std_logic;
        TRG : in std_logic := '0';
        RDY_IN : in std_logic := '0';
        FAIL : in std_logic := '0' ;
	    TEXT_IN : in std_logic_vector(7 downto 0);
	    TEXT_INPUT_STREAM : in std_logic_vector(7 downto 0);
        ID : out integer := 0;
        BYTE_TEXT : out std_logic_vector(7 downto 0) ;
        SET_TEXT_START : out std_logic_vector(7 downto 0) ;
        SET_TEXT_SECOND : out std_logic_vector(7 downto 0) ;
        SET_OPTION : out integer := 0 ;
        STR_TEXT : out string(1 to 2) := "  " ;
        END_FAIL : buffer std_logic := '0' ;
        PARSER_OK : buffer std_logic := '0';
        NEXT_RDY : out std_logic := '0');
end FILE_INPUT_VHDL;

architecture behave of FILE_INPUT_VHDL is
 
  type cmd_record is record 
     id : integer ;
     save : integer;
     next_cmd : integer;
     char_first : std_logic_vector(7 downto 0);
     char_second : std_logic_vector(7 downto 0);
     char_first1 : character;
     char_second1 : character;
     option : integer;
   end record;
   type cmd_record_array is array(1 to 125) of cmd_record;
   signal command_array : cmd_record_array := (others => (id => 0, save => 0 , next_cmd => 0,
                                                          char_first => "00000000", char_second => "00000000",
                                                                             char_first1 => ' ', char_second1 => ' ', option => 0));
                                                                                                                                           
   type int_alt_array is array(1 to 50) of integer;
   signal alt_stack : int_alt_array := (others => 0) ;
   type int_call_array is array(1 to 30) of integer;
   signal call_stack : int_call_array := (others => 0);
   
   --attribute mark_debug : string;
   --attribute mark_debug of id : signal is "true";
   --attribute mark_debug of NEXT_RDY : signal is "true";
  
  --convert character to integer
  function character_to_integer(char:character) return integer is
		variable int : integer;
		begin
			case char is
				when '1' => int := 1;
				when '2' => int := 2;
				when '3' => int := 3;
				when '4' => int := 4;
				when '5' => int := 5;
				when '6' => int := 6;
				when '7' => int := 7;
				when '8' => int := 8;
				when '9' => int := 9;
				when others => int := 0;
			end case;
			return int;
	end character_to_integer;
	
	        --convert string to integer
            function string2_to_integer(str:string(1 to 2)) return integer is
                variable int : integer;
                variable int_1, int_10 : integer;
                begin
                    int_10 := character_to_integer(str(1));
                    int_1 := character_to_integer(str(2));
                    int := 10*int_10 + int_1 ;
                    return int;
            end string2_to_integer;
            
            --convert string to integer
            function string3_to_integer(str:string(1 to 3)) return integer is
                variable int : integer;
                variable int_1, int_10 ,int_100: integer;
                begin
                    int_100 := character_to_integer(str(1));
                    int_10 := character_to_integer(str(2));
                    int_1 := character_to_integer(str(3));
                    int := 100*int_100 + 10*int_10 + int_1 ;
                    return int;
            end string3_to_integer;
	
	--next_rdy_function
	function next_rdy_function(n:std_logic_vector) return std_logic is
		variable i : integer;
		variable rdy : std_logic ;
		begin
			rdy := n(1);
			for i in n'range loop
				rdy := (rdy or n(i));
			end loop;
			return rdy;
	end next_rdy_function;

	signal call_top : natural := 1;
	signal fail_sig : boolean := false;
	signal parser_ok_sig : boolean := false;
	signal cmd_read_no : natural := 1 ;
    signal rdy_array : std_logic_vector(1 to 20) := (others => '0');
	signal next_accept : boolean := false;
	signal alt_top : natural := 1;
	
	signal continue_sig : std_logic := '0';
	
begin
  process(CLK)
     file in_file : text is in "C:\FPGAPrj\VIVADO\VIVADO\CONTROLLOR.srcs\constrs_1\new\json.txt";
	 variable l:         line;
     variable c:         character := ' ';
     variable is_string: boolean := false;
	 variable cmd_no:         natural := 1;
	 variable str : string(1 to 100) := (others => ' ');  
	 
  begin 
	if(CLK'event and CLK = '1') then
	   if(TRG = '1') then
	   --Loading command from text file
	       while not endfile(in_file) loop
		      readline(in_file, l);
		   for i in str'range loop
				str(i) := ' ';
		   end loop;   
		   for i in str'range loop
			 read(l, c, is_string);
			 if is_string then 
				str(i) := c;
			 else exit;
			 end if;
		   end loop;
	 	
	 	-- Saving command
		if(str(2) /= 'F') then
                cmd_no := string3_to_integer(str(2)&str(3)&str(4));
                command_array(cmd_no).id <= string2_to_integer(str(6)&str(7));
                command_array(cmd_no).save <= string3_to_integer(str(9)&str(10)&str(11));
                command_array(cmd_no).next_cmd <= string3_to_integer(str(13)&str(14)&str(15));
                if(str(18)&str(19) = "HT") then
                command_array(cmd_no).char_first <= "00001001";
                elsif (str(18)&str(19) = "LF") then
                command_array(cmd_no).char_first <= "00001010";
                else
                command_array(cmd_no).char_first <= std_logic_vector(to_unsigned(natural(character'pos(str(18))),8));
                end if;
                if(str(22)&str(23) = "HT") then
                command_array(cmd_no).char_second <= "00001001";
                elsif (str(22)&str(23) = "LF") then
                command_array(cmd_no).char_second <= "00001010";
                else
                command_array(cmd_no).char_second <= std_logic_vector(to_unsigned(natural(character'pos(str(22))),8));
                end if;
                if(str(26)&str(27) = "HT") then
                command_array(cmd_no).char_first1 <= HT;
                elsif (str(26)&str(27) = "LF") then
                command_array(cmd_no).char_first1 <= LF;
                else
                command_array(cmd_no).char_first1 <= str(26);
                end if;
                if(str(30)&str(31) = "HT") then
                command_array(cmd_no).char_second1 <= HT;
                elsif (str(30)&str(31) = "LF") then
                command_array(cmd_no).char_second1 <= LF;
                else
                command_array(cmd_no).char_second1 <= str(30);
                end if;
                command_array(cmd_no).option <= character_to_integer(str(33));
                end if;            
	       end loop;	
	       file_close(in_file);   
	   end if;
	  end if;
	end process;
    
    -- Make trigger signal to STATE_CONTROLLOR           
    process(CLK)
    begin
       if(CLK'event and CLK = '1') then
         if(text_input_stream = "01000000") then
            next_accept <= false;
            rdy_array <= (others => '0');
         else
          if(TRG = '1' or RDY_IN = '1' or FAIL = '1') then
            next_accept <= true ;
          end if;
          if (next_accept and (not fail_sig) and (not parser_ok_sig)) then
             rdy_array <= (others => '0');
             rdy_array( command_array(cmd_read_no).id) <= '1';
             next_accept <= false;
           else
             rdy_array <= (others => '0');
           end if;
          end if;
        end if;
     end process;
    
    -- Command ALT
    process(CLK)
    begin
       if(CLK'event and CLK = '1') then
         if(text_input_stream = "01000000") then
            fail_sig <= false;
            alt_top <= 1;
            alt_stack <= (others => 0);
         else
           if (FAIL = '1') then 
                    if(alt_stack(1) = 0) then 
                        fail_sig <= true;
                    else                                                        
                        alt_stack(alt_top-1) <= 0;
                        alt_top <= alt_top - 1;
                    end if;
           elsif ((RDY_IN = '1' or TRG = '1') and  command_array(cmd_read_no).id = 10 ) then    
            alt_stack(alt_top) <= command_array(cmd_read_no).save;
            alt_top <= alt_top + 1;
           end if;
         end if;
     end if;
   end process;
     
     -- Next command 
     process(CLK) 
     begin
        if(CLK'event and CLK = '1') then
           if(text_input_stream = "01000000") then
              cmd_read_no <= 1;
              call_top <= 1;
              parser_ok_sig <= false;
              call_stack <= (others => 0);
           else
               
           if (FAIL = '1' and alt_stack(1) /= 0) then                                                        
                  cmd_read_no <= alt_stack(alt_top-1);
           elsif (RDY_IN = '1' or TRG = '1' ) then
              case command_array(cmd_read_no).id is
                   when 9 =>  call_stack(call_top) <= command_array(cmd_read_no).save;
                              if(command_array(cmd_read_no).next_cmd /= 0) then
                                cmd_read_no <= command_array(cmd_read_no).next_cmd;
                              else
                                cmd_read_no <= cmd_read_no + 1;
                              end if;
                              call_top <= call_top + 1;                                                                     
                    when 12 => if(cmd_read_no = 7) then
                                            case text_in is
                                                 when "01110100" => cmd_read_no <= 81; --t
                                                 when "01100110" => cmd_read_no <= 70; --f
                                                 when "01111011" => cmd_read_no <= 86;
                                                 when "00100010" => cmd_read_no <= 9;
                                                 when "01011011" => cmd_read_no <= 58;
                                                 when "01101110" => cmd_read_no <= 76;   
                                                 when "01001111" => cmd_read_no <= 86;
                                                 when others => if(text_in >= "00110000" and text_in <= "00111001") then
                                                                   cmd_read_no <= 11;
                                                                else 
                                                                    cmd_read_no <= 8;
                                                                 end if;
                                             end case;
                                           elsif (cmd_read_no = 12) then
                                                case text_in is
                                                     when "00110100" => cmd_read_no <= 33;
                                                     when "00110101" => cmd_read_no <= 35;
                                                     when "00110110" => cmd_read_no <= 37;
                                                     when "00110111" => cmd_read_no <= 39;
                                                     when "00111000" => cmd_read_no <= 41;
                                                     when "00110001" => cmd_read_no <= 27;   
                                                     when "00111001" => cmd_read_no <= 43;
                                                     when "00110000" => cmd_read_no <= 13;
                                                     when "00110010" => cmd_read_no <= 29;   
                                                     when "00110011" => cmd_read_no <= 31;
                                                     when others => cmd_read_no <= 8;
                                                 end case;
                                             elsif (cmd_read_no = 14) then
                                                  case text_in is
                                                      when "00101110" => cmd_read_no <= 16;   
                                                      when "00000100" => cmd_read_no <= 8;
                                                      when others => cmd_read_no <= 15; 
                                                  end case;
                                              elsif(cmd_read_no = 101) then
                                                   case text_in is
                                                       when "00100010" => cmd_read_no <= 8;
                                                       when "00101111" => cmd_read_no <= 104;
                                                       when others => cmd_read_no <= 102;
                                                   end case;
                                               end if;         
                                                                                    
                        when 15 => if(call_stack(1) = 0) then 
                                       parser_ok_sig <= true;
                                   else
                                       cmd_read_no <= call_stack(call_top-1);
                                       call_stack(call_top-1) <= 0;
                                       call_top <= call_top - 1;
                                   end if;
                         when others =>                                                                                     
                                   if(command_array(cmd_read_no).next_cmd /= 0) then
                                        cmd_read_no <= command_array(cmd_read_no).next_cmd;
                                   else
                                        cmd_read_no <= cmd_read_no + 1;
                                   end if;   
                  end case;                                                       
            end if;
          end if;
         end if;
      end process;
          
   -- Output Text    
   process(CLK) 
     begin
       if(CLK'event and CLK = '1') then  
          case command_array(cmd_read_no).id is
              when 1 =>  BYTE_TEXT <= command_array(cmd_read_no).char_first;
              when 3 =>  SET_TEXT_START <= command_array(cmd_read_no).char_first;
                         SET_TEXT_SECOND <= command_array(cmd_read_no).char_second;
                         SET_OPTION <= command_array(cmd_read_no).option;
              when 14 => SET_TEXT_START <= command_array(cmd_read_no).char_first;
                         SET_TEXT_SECOND <= command_array(cmd_read_no).char_second;
                         SET_OPTION <= command_array(cmd_read_no).option;
              when 17 => BYTE_TEXT <= command_array(cmd_read_no).char_first;
              --when 19 => STR_TEXT <= command_array(cmd_read_no).char_first&command_array(cmd_read_no).char_second;
              when others =>   null;                                                                                                                                              
           end case;
        end if;
    end process;
    
    
    process(CLK)
    begin
        if(CLK'event and CLK='1') then
            continue_sig <= CONTINUE;
        end if;
    end process;
        
          
    ID <= command_array(cmd_read_no).id;
    NEXT_RDY <= next_rdy_function(rdy_array) or continue_sig;
    PARSER_OK <= '1' when parser_ok_sig else '0';
    END_FAIL <= '1' when fail_sig else '0';
  
  -- Parser result            
  process(CLK)
     variable buf_out : LINE ;
     variable end_sig : boolean := true;
  begin
     if(CLK'event and CLK = '0') then  
        if(fail_sig and end_sig) then
             write(buf_out,string'("PARSER ERROR"));
             writeline(output,buf_out);
             end_sig := false;
     elsif(parser_ok_sig and end_sig) then
             write(buf_out,string'("PARSER OK"));
             writeline(output,buf_out);
             end_sig := false;
     end if;     
  end if;
end process;

end behave;