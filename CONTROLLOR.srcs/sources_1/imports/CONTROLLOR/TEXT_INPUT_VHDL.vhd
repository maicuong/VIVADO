library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use STD.textio.all;
use ieee.std_logic_textio.all;
LIBRARY UNISIM;
USE UNISIM.Vcomponents.ALL;

entity TEXT_INPUT_VHDL is
	port(
	CLK : in std_logic ;
	STR_TRG : in std_logic ;
	TRG : in std_logic ;
	RDY : in std_logic ;
	TEXT_INPUT_STREAM : in std_logic_vector(7 downto 0);
	RDEN : in std_logic;
	RUN : out std_logic := '0';
	CHAR_OUT : out std_logic_vector(7 downto 0) ;
	STR_OUT : out std_logic_vector(15 downto 0));
end TEXT_INPUT_VHDL;

architecture Behavioral of TEXT_INPUT_VHDL is
	signal run_sig : std_logic := '0';
	signal start_done: boolean := false;
	signal count_text_stream : integer := 0;
	
	component MEMORY_VHDL
	    port (
		 CLK : in std_logic;
		 DIN : in std_logic_vector(7 downto 0); 
         DOUT1 : out std_logic_vector(7 downto 0);
         DOUT2 : out std_logic_vector(7 downto 0);
         WR : in std_logic;
         DOEN : in std_logic;
         ADDR_IN_WR : in std_logic_vector(8 downto 0);
		 ADDR_IN_RD1 : in std_logic_vector(8 downto 0);
		 ADDR_IN_RD2 : in std_logic_vector(8 downto 0));
	end component;
	
	signal addr_in_rd1,addr_in_rd2, addr_in_wr : std_logic_vector(8 downto 0);
	signal out_num:         natural := 0;
	
	
	signal ram_we_sig : std_logic := '1';
	signal ram_doen_sig : std_logic := '0';
	signal start_to_parse : boolean := false;
	signal dout1,dout2 : std_logic_vector(7 downto 0);
	
	signal rden_sig : std_logic := '0';
	
	type char_arr is array(2047 downto 0) of std_logic_vector(7 downto 0);
    signal sample : char_arr ;
begin
		RUN <= run_sig;

		
        process (CLK)
        begin
        if(CLK'event and CLK = '1') then
            if(text_input_stream = "01000000") then
                out_num <= 0;
            elsif(STR_TRG = '1') then
                CHAR_OUT <= sample(out_num);
                STR_OUT <= sample(out_num) & sample(out_num + 1);
                if(out_num >= 0 and out_num < (count_text_stream+1)) then
                out_num <= out_num + 2;
                end if;                
            elsif ((TRG = '1' or RDY = '1')) then
                CHAR_OUT <= sample(out_num);
                STR_OUT <= sample(out_num) & sample(out_num + 1);
                if(out_num >= 0 and out_num < (count_text_stream+1)) then
                    out_num <= out_num + 1;
                end if;
            end if;
        end if;
    end process;
	 
	 --addr_in <= CONV_std_logic_vector(out_num,9);
	 MEMORY : MEMORY_VHDL
	    port map(
		 CLK => CLK,
		 DIN => text_input_stream,
         DOUT1 => dout1,
         DOUT2 => dout2,
         WR => rden_sig,
         DOEN => ram_doen_sig,
         ADDR_IN_WR => addr_in_wr,
		 ADDR_IN_RD1 => addr_in_rd1,
		 ADDR_IN_RD2 => addr_in_rd2);
		 
    rden_sig <= '1' when (RDEN = '1' and text_input_stream /= "00100000" and text_input_stream /= "00001010" ) else '0';
		
	
	process(CLK)
	begin
		if(CLK'event and CLK = '1') then
		  if(text_input_stream = "01000000") then
		      start_to_parse <= false;
		  elsif (RDEN = '1' and text_input_stream /= "00100000" and text_input_stream /= "00001010") then
				start_to_parse <= true;
		  end if;
		end if;
	end process;

	process(CLK)
	begin
		if(CLK'event and CLK = '0') then
		   if(text_input_stream = "01000000") then
             ram_doen_sig <= '0';
           elsif(start_to_parse) then
			 ram_doen_sig <= '1';
		   end if;
		end if;
	end process;
	
    --process(CLK)
    --begin
        --if(CLK'event and CLK = '0') then
            --if(input_finish) then
                --ram_we_sig <= '0';
            --end if;
        --end if;
    --end process;
    
	--ram_doen_sig <= '1' when input_finish else '0';
	--ram_we_sig <= '0' when input_finish else '1';
	
	process(CLK)
	begin
		if(CLK'event and CLK = '0') then
				addr_in_rd1 <= CONV_std_logic_vector(out_num,9);
				addr_in_rd2 <= CONV_std_logic_vector((out_num+1),9);
		end if;
	end process;
	
	process(CLK)
	begin
		if(CLK'event and CLK = '0') then
			addr_in_wr <= CONV_std_logic_vector((count_text_stream+1),9);
		end if;
	end process;
	
	process(CLK) 
	begin
		if(CLK'event and CLK = '1') then
		  if(text_input_stream = "01000000") then
		      count_text_stream <= 0;
		  elsif(RDEN = '1'and text_input_stream /= "00100000" and text_input_stream /= "00001010") then
		      if(count_text_stream >= 0 and count_text_stream <= 2047) then
		          sample(count_text_stream) <= text_input_stream;
			     count_text_stream <= count_text_stream + 1;
			  end if;
		  end if;
		end if;
	end process;
	
	--process(CLK)
	--begin
		--if(CLK'event and CLK = '1') then
			--if(text_input_stream /= dout) then	
				--count_text_stream <= count_text_stream + 1;
			--end if;
		--end if;
	--end process;
	
	process(CLK)
	begin
		if(CLK'event and CLK = '1') then
		  if(text_input_stream = "01000000") then
		     start_done <= false;
		     run_sig <= '0';
		  else		  
			if(start_to_parse and not start_done) then	
				run_sig <= '1';
				start_done <= true;
			else 
				run_sig <= '0';
			end if;
		  end if;
		end if;
	end process;
    
end Behavioral;