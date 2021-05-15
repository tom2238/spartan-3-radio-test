library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity test2 is
    Port ( clk : in  STD_LOGIC;
           leds : out STD_LOGIC_VECTOR (7 downto 0);
           ant : out  STD_LOGIC_VECTOR (6 downto 0);
           sound : out  STD_LOGIC_VECTOR (7 downto 0)
         );
end test2;

architecture Behavioral of test2 is
    signal carrier : std_logic_vector(6 downto 0);
    signal phase : std_logic_vector(23 downto 0);
    signal counter : std_logic_vector(7 downto 0);
    signal clock_tone, rtty_dat : std_logic;

begin
    DDS_CORE: entity work.dds_compiler_v4_0
    port map (
        clk => clk,
        we => '1',
        data => phase,
        sine => carrier
    );
    
    RTTY_MEM: entity work.rttymem
    port map (
        clk => clk,
        addr => counter,
        output_data => rtty_dat
    );
 
    -- delicka z 50 MHz
	 CLK_DIVIDER_TONE: entity work.clock_divider
     generic map (
        COUNT_TO => 500000    
     )
	 port map (
	    clk_in => clk,
        clk_out => clock_tone
	 );
    
    leds <= "000000" & rtty_dat & not rtty_dat;
    sound <= carrier & '0';
     
    process(clock_tone) begin
        if(rising_edge(clock_tone)) then
            counter <= std_logic_vector(unsigned(counter) + 1);
        end if;
    end process;    
 
    -- AM carriers
    -- 7 775 878,906 Hz
    --phase <= X"27CFFF"; 
    -- 6 770 000,XXX Hz
    --phase <= X"22A993"; 
    -- 3 582 982,XXX Hz
    --phase <= X"12584F";
    -- 1 485 000,XXX Hz
    --phase <= X"079A6B";
    -- 1 269 000,XXX Hz
    --phase <= X"067F4D";
    -- 1 215 000,XXX Hz
    --phase <= X"063886";
    -- 0 460 000,XXX Hz
    --phase <= X"025AEE";
       
    process(clk) begin
        if(rising_edge(clk)) then
            phase(23 downto 8) <= "0000001001011010";
            phase(7) <= rtty_dat;
            phase(6 downto 0) <= "1101110";
            ant <= carrier;
        end if;
    end process;
 
end Behavioral;