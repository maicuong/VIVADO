library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity FILE_INPUT_VHDL is
	port(
	CLK : in std_logic := '0';
	TRG : in std_logic := '0';
	RDY_IN : in std_logic := '0';
	FAIL : in std_logic := '0' ;
	ID : out integer;
	BYTE_TEXT : out character := ' ' ;
	SET_TEXT_START : out character := ' ' ;
	SET_TEXT_SECOND : out character := ' ' ;
	SET_OPTION : out integer := 0 ;
	RBYTE_TEXT : out character := ' ' ;
	OBYTE_TEXT : out character := ' ' ;
	NBYTE_TEXT : out character := ' ' ;
	CMD_LINE_NO : out natural := 1;
	END_FAIL : buffer boolean := false ;
	PARSER_OK : buffer boolean := false;
	NEXT_TEXT_RDY : out std_logic := '0';
	NEXT_RDY : out std_logic := '0');
end FILE_INPUT_VHDL;

architecture behave of FILE_INPUT_VHDL is

  signal trg_sig : std_logic ;
 
  type cmd_record is record 
	id : integer ;
	save : integer;
	next_cmd : integer;
	char_first : character;
	char_second : character;
	option : integer;
  end record;
  type cmd_record_array is array(1 to 30) of cmd_record;
  signal command_array : cmd_record_array := (others => (id => 0, save => 0 , next_cmd => 0,
                                                         char_first => ' ', char_second => ' ', option => 0));
																			
  type int_array is array(1 to 10) of integer;
  signal call_stack : int_array := (others => 0);
  signal alt_stack : int_array := (others => 0) ;
  signal first_stack : int_array := (0,16,25,17,0,0,0,0,0,0) ;
  
  signal test : character := ' ';
  
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
	function string_to_integer(str:string(1 to 2)) return integer is
		variable int : integer;
		variable int_1, int_10 : integer;
		begin
			int_10 := character_to_integer(str(1));
			int_1 := character_to_integer(str(2));
			int := 10*int_10 + int_1 ;
			return int;
	end string_to_integer;
	
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


	signal call_top, alt_top : natural := 1;
	signal first_top : natural := 4;
	
	signal fail_sig : boolean := false;
	signal parser_ok_sig : boolean := false;
	
	signal CMD_LINE : natural := 1;
	
	
	--signal clk_accept : boolean := false;
	
begin
	trg_sig <= TRG or RDY_IN or FAIL or CLK;
   --next_rdy_sig <= next_rdy_function(rdy_array);
	
  process(CLK)
     file in_file : text is in "C:\FPGAPrj\VIVADO\CONTROLLOR\CONTROLLOR.srcs\constrs_1\imports\CONTROLLOR\math_input.txt";
	 variable id_reg : integer := 0 ;
	 variable l:         line;
     variable c:         character;
     variable is_string: boolean;
	 variable line_no,cmd_no:         natural := 1;
	 variable cmd_read_no : natural := 1 ;
	 variable str : string(1 to 25) := (others => ' ');  
	 variable byt_no,set_no : natural := 1 ;
	 --variable call_top, alt_top : natural := 0;
	 variable clk_accept : boolean := false;
	 variable rdy_array : std_logic_vector(1 to 15) := (others => '0');
	 variable now_sig : integer := 0;
	 variable next_accept : boolean := false;
	 variable first_save : integer := 0 ;
  begin 
	 --wait until trg = '1' ;
	 --file_open(in_file, "math_copy.moz",  read_mode);
	if(CLK'event and CLK = '1') then
	
	if(TRG = '1') then
	 while not endfile(in_file) loop
	 --wait until trg = '1' ;
		readline(in_file, l);
		-- clear the contents of the result string
		for i in str'range loop
				str(i) := ' ';
		end loop;   
		-- read all characters of the line, up to the length  
		-- of the results string
		for i in str'range loop
			read(l, c, is_string);
			if is_string then 
				str(i) := c;
						--res_string_array(line_no)(i) <= c;
				--test(i) <= c;
				--test <= str(256);
			else exit;
			end if;
		
		end loop;
	 	
		if(str(2) = 'L') then
			if (str(4) = HT) then
				cmd_no := character_to_integer(str(3));
			else
				cmd_no := string_to_integer(str(3)&str(4));
			end if;
			case str(5)&str(6)&str(7)&str(8) is
				when "Byte" => command_array(cmd_no).id <= 1;
				               command_array(cmd_no).char_first <= str(11);
				when HT&"Byt" => command_array(cmd_no).id <= 1;
				                 command_array(cmd_no).char_first <= str(12);
				when "Any " => command_array(cmd_no).id <= 2;									
				when HT&"Any" => command_array(cmd_no).id <= 2;
				when "Set " => command_array(cmd_no).id <= 3;
									command_array(cmd_no).char_first <= str(10);
									if (str(11) = '-') then
										command_array(cmd_no).option <= 2;
										command_array(cmd_no).char_second <= str(12);
									elsif(str(11) = '\') then
										command_array(cmd_no).option <= 1;
										command_array(cmd_no).char_second <= str(12);
									else
										command_array(cmd_no).option <= 0;
										command_array(cmd_no).char_second <= str(11);
									end if;
				when HT&"Set" => command_array(cmd_no).id <= 3;
										command_array(cmd_no).char_first <= str(11);
									if (str(12) = '-') then
										command_array(cmd_no).option <= 2;
										command_array(cmd_no).char_second <= str(13);
									elsif(str(12) = '\') then
										command_array(cmd_no).option <= 1;
										command_array(cmd_no).char_second <= str(13);
									else
										command_array(cmd_no).option <= 0;
										command_array(cmd_no).char_second <= str(12);
									end if;
				when "RByt" => command_array(cmd_no).id <= 4;
				when HT&"RBy" => command_array(cmd_no).id <= 4;
				when "OByt" => command_array(cmd_no).id <= 5;
				when HT&"OBy" => command_array(cmd_no).id <= 5;
				when "Pos " => command_array(cmd_no).id <= 6;
				when HT&"Pos" => command_array(cmd_no).id <= 6;
				when "Back" => command_array(cmd_no).id <= 7;
				when HT&"Bac" => command_array(cmd_no).id <= 7;
				when "NByt" => command_array(cmd_no).id <= 8;
				when HT&"NBy" => command_array(cmd_no).id <= 8;
				when "Call" => command_array(cmd_no).id <= 9;
									if(str(12) = ' ' ) then
										command_array(cmd_no).save <= character_to_integer(str(11));
									else
										command_array(cmd_no).save <= string_to_integer(str(11)&str(12));
									end if;
				when HT&"Cal" => command_array(cmd_no).id <= 9;
									if(str(13) = ' ' ) then
										command_array(cmd_no).save <= character_to_integer(str(12));
									else
										command_array(cmd_no).save <= string_to_integer(str(12)&str(13));
									end if;
				when "Alt " => command_array(cmd_no).id <= 10;
									if(str(11) = ' ' ) then
										command_array(cmd_no).save <= character_to_integer(str(10));
									else
										command_array(cmd_no).save <= string_to_integer(str(10)&str(11));
									end if;
				when HT&"Alt" => command_array(cmd_no).id <= 10;
									if(str(12) = ' ' ) then
										command_array(cmd_no).save <= character_to_integer(str(11));
									else
										command_array(cmd_no).save <= string_to_integer(str(11)&str(12));
									end if;
				when "Skip" => command_array(cmd_no).id <= 11;
				when HT&"Ski" => command_array(cmd_no).id <= 11;
				when "Firs" => command_array(cmd_no).id <= 12;
									first_save := cmd_no ;
									--command_array(cmd_read_no).next_cmd <= 25;
				when HT&"Fir" => command_array(cmd_no).id <= 12;
				                 first_save := cmd_no ;
				                 --command_array(cmd_read_no).next_cmd <= 25;
				when "Fail" => command_array(cmd_no).id <= 13;
				when HT&"Fai" => command_array(cmd_no).id <= 13;
				when "RSet" => command_array(cmd_no).id <= 14;
									command_array(cmd_no).char_first <= str(11);
									if (str(12) = '-') then
										command_array(cmd_no).option <= 2;
										command_array(cmd_no).char_second <= str(13);
									elsif(str(12) = '\') then
										command_array(cmd_no).option <= 1;
										command_array(cmd_no).char_second <= str(13);
									else
										command_array(cmd_no).option <= 0;
										command_array(cmd_no).char_second <= str(12);
									end if;
				when HT&"RSe" => command_array(cmd_no).id <= 14;
									command_array(cmd_no).char_first <= str(12);
									if (str(13) = '-') then
										command_array(cmd_no).option <= 2;
										command_array(cmd_no).char_second <= str(14);
									elsif(str(13) = '\') then
										command_array(cmd_no).option <= 1;
										command_array(cmd_no).char_second <= str(14);
									else
										command_array(cmd_no).option <= 0;
										command_array(cmd_no).char_second <= str(13);
									end if;
				when "Ret " => command_array(cmd_no).id <= 15;
				when HT&"Ret" => command_array(cmd_no).id <= 15;
				when others => command_array(cmd_no).id <= 0;
			end case;
		end if;
		if(str(3)&str(4)&str(5)&str(6) = "jump") then
			if(str(10) = ' ') then
				command_array(cmd_no).next_cmd <= character_to_integer(str(9));
			else
				command_array(cmd_no).next_cmd <= string_to_integer(str(9)&str(10));
			end if;
		end if;
		
	  if (line_no<45 ) then	 
		 line_no := line_no + 1;
	  end if;
	end loop;	
	file_close(in_file);   
	----------------------------------------------------
	--Saved command_array
	----------------------------------------------------
	end if;
	
	
	--END_FAIL <= true after 10ns;
	
	--while (next_accept = false) loop
            --wait until CLK = '1' ; 
            --if (CLK'event and CLK = '1' ) then
              id_reg := command_array(cmd_read_no).id;
            
            if(TRG = '1' or RDY_IN = '1' or FAIL = '1') then
                          next_accept := true ;
                        end if;
            
              if (FAIL = '1') then 
                                      if(alt_stack(1) = 0) then 
                                          fail_sig <= true;
                                      else
                                          cmd_read_no := alt_stack(alt_top-1);
                                          alt_stack(alt_top-1) <= 0;
                                          alt_top <= alt_top - 1;
                                      end if;
                                elsif (RDY_IN = '1' or TRG = '1' ) then
                                case command_array(cmd_read_no).id is        
                                  when 9 => call_stack(call_top) <= command_array(cmd_read_no).save;
                                               if(command_array(cmd_read_no).next_cmd /= 0) then
                                               cmd_read_no := command_array(cmd_read_no).next_cmd;
                                           else
                                               cmd_read_no := cmd_read_no + 1;
                                           end if;
                                               call_top <= call_top + 1;
                      
                                  when 10 => alt_stack(alt_top) <= command_array(cmd_read_no).save;
                                             alt_top <= alt_top + 1;
                                               if(command_array(cmd_read_no).next_cmd /= 0) then
                                               cmd_read_no := command_array(cmd_read_no).next_cmd;
                                           else
                                               cmd_read_no := cmd_read_no + 1;
                                           end if;
                                  when 12 =>  alt_stack(alt_top) <= 16;
                                                  alt_stack(alt_top+1) <= 25;
                                              alt_top <= alt_top + 2;
                                                  cmd_read_no := 17;
                                  when 15 => if(call_stack(1) = 0) then 
                                                    parser_ok_sig <= true;
                                                else
                                                   cmd_read_no := call_stack(call_top-1);
                                                    call_stack(call_top-1) <= 0;
                                                    call_top <= call_top - 1;
                                                end if;
                                  when others => if(command_array(cmd_read_no).next_cmd /= 0) then
                                                          cmd_read_no := command_array(cmd_read_no).next_cmd;
                                                      else
                                                          cmd_read_no := cmd_read_no + 1;
                                                      end if;                        
                              end case;
                              end if;       
                 
                 
                 case command_array(cmd_read_no).id is
                                          when 1 =>    if (next_accept and (not fail_sig) and (not parser_ok_sig)) then
                                                              rdy_array := (others => '0');
                                                              rdy_array(1) := '1';
                                                              next_accept := false;
                                                           else
                                                              rdy_array := (others => '0');
                                                           end if;
                                                           BYTE_TEXT <= command_array(cmd_read_no).char_first;
                              
                                          when 3 => if (next_accept and (not fail_sig) and (not parser_ok_sig)) then
                                                              rdy_array := (others => '0');
                                                              rdy_array(3) := '1';
                                                              next_accept := false;
                                                           else
                                                              rdy_array := (others => '0');
                                                           end if;
                                                           SET_TEXT_START <= command_array(cmd_read_no).char_first;
                                                          SET_TEXT_SECOND <= command_array(cmd_read_no).char_second;
                                                          SET_OPTION <= command_array(cmd_read_no).option;
                              
                                          when 9 => if (next_accept and (not fail_sig) and (not parser_ok_sig)) then
                                                              rdy_array := (others => '0');
                                                              rdy_array(9) := '1';
                                                              next_accept := false;
                                                           else
                                                              rdy_array := (others => '0');
                                                           end if;
                                          when 10 =>if (next_accept and (not fail_sig) and (not parser_ok_sig)) then
                                                              rdy_array := (others => '0');
                                                              rdy_array(10) := '1';
                                                              next_accept := false;
                                                           else
                                                              rdy_array := (others => '0');
                                                           end if;
                                          when 11 =>if (next_accept and (not fail_sig) and (not parser_ok_sig)) then
                                                              rdy_array := (others => '0');
                                                              rdy_array(11) := '1';
                                                              next_accept := false;
                                                           else
                                                              rdy_array := (others => '0');
                                                           end if;
                                          when 12 => if (next_accept and (not fail_sig) and (not parser_ok_sig)) then
                                                              rdy_array := (others => '0');
                                                              rdy_array(12) := '1';
                                                              next_accept := false;
                                                           else
                                                              rdy_array := (others => '0');
                                                           end if;
                                          when 13 => if (next_accept and (not fail_sig) and (not parser_ok_sig)) then
                                                              rdy_array := (others => '0');
                                                              rdy_array(13) := '1';
                                                              next_accept := false;
                                                           else
                                                              rdy_array := (others => '0');
                                                           end if;
                                          when 14 => if (next_accept and (not fail_sig) and (not parser_ok_sig)) then
                                                              rdy_array := (others => '0');
                                                              rdy_array(14) := '1';
                                                              next_accept := false;
                                                           else
                                                              rdy_array := (others => '0');
                                                           end if;
                                                           SET_TEXT_START <= command_array(cmd_read_no).char_first;
                                                          SET_TEXT_SECOND <= command_array(cmd_read_no).char_second;
                                                          SET_OPTION <= command_array(cmd_read_no).option;
                                          when 15 => if (next_accept and (not fail_sig) and (not parser_ok_sig)) then
                                                              rdy_array := (others => '0');
                                                              rdy_array(15) := '1';
                                                              next_accept := false;
                                                           else
                                                              rdy_array := (others => '0');
                                                           end if;
                                          when others => rdy_array := (others => '0');
                                      end case;
          
            ID <= command_array(cmd_read_no).id;
            NEXT_RDY <= next_rdy_function(rdy_array);
            ----------------------------------------
            NEXT_TEXT_RDY <= (rdy_array(1) or rdy_array(3) or rdy_array(14));
            
            CMD_LINE_NO <= cmd_read_no ;
            
            END_FAIL <= fail_sig ;
            PARSER_OK <= parser_ok_sig ;
            
         end if;
        --end loop;
	
  end process;
  
end behave;