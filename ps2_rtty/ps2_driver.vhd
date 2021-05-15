library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ps2_driver is
    Port ( clk : in  STD_LOGIC;
           ps2_data : in  STD_LOGIC;
           ps2_clock : in  STD_LOGIC;
           segment_data : out  STD_LOGIC_VECTOR (6 downto 0);
           segment_pozice : out  STD_LOGIC_VECTOR (3 downto 0);
           scan_code : out STD_LOGIC_VECTOR (7 downto 0);
           scan_code_en : out STD_LOGIC
           );
end ps2_driver;

architecture Behavioral of ps2_driver is
    -- PS2 a segmenty
    signal clock_disp : std_logic;
    signal ps2_clock_debounced, ps2_CE : std_logic;
    signal ps2_data_received : std_logic_vector(7 downto 0);
    signal ps2_data_enabled : std_logic;
    signal kb_scan_code : std_logic_vector(7 downto 0);

begin
    
    -- delicka z 50 MHz na 250 Hz
	 CLK_DIVIDER_DISP: entity work.clock_divider
     generic map (
        COUNT_TO => 100000       
     )
	 port map (
	    clk_in => clk,
        clk_out => clock_disp
	 );
     
     -- Debouncer PS2 clock signalu
     DEBOUNCER_PS2C: entity work.debouncer_2
     port map (
        clk => clk,
        pulse => ps2_clock,
        debounced => ps2_clock_debounced
     ); 
     
     -- Enabler PS2 clock, sestupna hrana
     ENABLER_PS2C: entity work.enabler
     port map (
        vstup_in => ps2_clock_debounced,
        vystup_out => ps2_CE,
        clk => clk
     );
     
     -- PS2 Packet receiver
     PS2_PACKET: entity work.ps2_packet_top
     port map(
        clk => clk,
        rst => '0',
        ps2_CE => ps2_CE,
        ps2d => ps2_data,
        ce_out => ps2_data_enabled,
        code_out => ps2_data_received
     );
     
     KB_CODE: entity work.kb_code
     port map(
        clk => clk,
        ps2_data => ps2_data_received,
        ps2_data_en => ps2_data_enabled,
        scan_code => kb_scan_code,
        scan_code_en => scan_code_en
     );
     scan_code <= kb_scan_code;
          
     -- Dekoder na 7segment
     KEY2SEG7_DISP: entity work.key2seg7
     port map(
        scan_code => kb_scan_code,
        segment_data => segment_data,
        segment_pozice => segment_pozice,
        clk => clock_disp
     );


end Behavioral;

