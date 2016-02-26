library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Positive edge-triggered with reset and latch
entity reg_pos_et_d_ff is
	port(clk, D, lat, rst : in std_logic;
			Q : out std_logic);
end reg_pos_et_d_ff;

architecture Behavioral of reg_pos_et_d_ff is

	component pos_et_d_ff
	port(CK, D : in std_logic;
			Q, Q_BAR : out std_logic);
	end component;
	
	signal S_A, S_B, S_D, S_Q, S_Q_BAR : std_logic;
	
begin

	pos_et_d_ff1 : pos_et_d_ff port map(clk, S_D, S_Q, S_Q_BAR);
	S_A <= (S_Q and (not lat) and (not rst));
	S_B <= (D and lat and (not rst));
	S_D <= S_A or S_B;
	Q <= S_Q;


end Behavioral;

