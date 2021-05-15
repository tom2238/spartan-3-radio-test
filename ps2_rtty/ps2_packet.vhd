library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values

use IEEE.NUMERIC_STD.ALL;

entity ps2_packet_top is
    Port ( clk, rst : in  STD_LOGIC;
           ps2_CE : in  STD_LOGIC;
           ps2d : in  STD_LOGIC;
           ce_out : out  STD_LOGIC;
           code_out : out  STD_LOGIC_VECTOR (7 downto 0));
end ps2_packet_top;

architecture Behavioral of ps2_packet_top is

	signal cnt, cnt_next : std_logic_vector(23 downto 0) := (others => '0');
	signal sr, sr_next : std_logic_vector(9 downto 0) := (others => '0');

	type state_type is (pwr, wait_line, idle, shift, stop, ce_state); 
    signal st, st_next : state_type := pwr;
	signal ce_out_next : std_logic;

begin

	code_out <= sr (8 downto 1);

	process (rst, clk) begin
		if rst = '1' then
			st <= pwr;
			cnt <= (others => '0');
			sr <= (others => '0');
			ce_out <= '0';
		elsif rising_edge(clk) then
			st <= st_next;
			cnt <= cnt_next;
			sr <= sr_next;
			ce_out <= ce_out_next;
		end if;
	end process;

   process (st, ps2_CE, ps2d, cnt, sr)
   begin
      st_next <= st;  --default is to stay in current state
      cnt_next <= cnt;
	  sr_next <= sr;
	  ce_out_next <= '0';
      case (st) is
         when pwr =>
				cnt_next <= (others => '0');
				st_next <= wait_line;
         when wait_line =>
				cnt_next <= std_logic_vector(unsigned(cnt) + 1);
                if ps2d = '0' or ps2_CE = '1' then 
					cnt_next <= (others => '0');
				end if;
				if unsigned(cnt) = 10000000 then 
					st_next <= idle;
				end if;
         when idle =>
				cnt_next <= (others => '0');
				if ps2d = '1' and ps2_CE = '1' then -- error
					st_next <= wait_line;                     
				end if;
				if ps2d = '0' and ps2_CE = '1' then -- start detected
					st_next <= shift;
				end if;
			when shift =>
				if ps2_CE = '1' then -- shifting
					sr_next <= ps2d & sr(9 downto 1);
					cnt_next <= std_logic_vector(unsigned(cnt) + 1);
					if unsigned(cnt) = 8 then
						st_next <= stop;
					end if;
				end if;
			when stop =>
				if ps2d = '1' and ps2_CE = '1' then
					st_next <= ce_state;
				end if;
				if ps2d = '0' and ps2_CE = '1' then
					st_next <= wait_line;
					cnt_next <= (others => '0');
				end if;
         when others =>	-- show CE
				ce_out_next <= '1';
				st_next <= idle;
				cnt_next <= (others => '0');
      end case;      
   end process;

end Behavioral;