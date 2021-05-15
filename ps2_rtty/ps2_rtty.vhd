library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ps2_rtty is
    Port ( clk : in  STD_LOGIC;
           leds : out STD_LOGIC_VECTOR (7 downto 0);
           ant : out  STD_LOGIC_VECTOR (6 downto 0);
           sound : out  STD_LOGIC_VECTOR (7 downto 0);
           ps2_data : in  STD_LOGIC;
           ps2_clock : in  STD_LOGIC;
           segment_data : out  STD_LOGIC_VECTOR (6 downto 0);
           segment_pozice : out  STD_LOGIC_VECTOR (3 downto 0)
         );
end ps2_rtty;

architecture Behavioral of ps2_rtty is
    -- DDS pro RTTY
    signal carrier : std_logic_vector(6 downto 0);
    signal phase : std_logic_vector(23 downto 0);
    --signal counter : std_logic_vector(7 downto 0);
    signal clock_tone, rtty_dat : std_logic;
    signal clock_tone_pulse : std_logic;
    -- PS2 code
    signal scan_code : std_logic_vector(7 downto 0);
    signal scan_code_en : std_logic;
    signal scan_code_baudot : std_logic_vector(4 downto 0);
    -- RTTY byte
    signal rtty_byte, rtty_byte_next : std_logic_vector(7 downto 0);
    signal rtty_byte_wait, rtty_byte_wait_next : std_logic_vector(4 downto 0);
    signal rtty_byte_new, rtty_byte_new_next : std_logic;
    signal rtty_byte_sended, rtty_byte_sended_next : std_logic;
    type rtty_state is (rtty_ready, rtty_sending); 
    signal rtty_fsm, rtty_fsm_next : rtty_state := rtty_ready;
    signal cnt_rtty, cnt_rtty_next : std_logic_vector(2 downto 0) := (others => '0');

begin
    -- Generator DDS nosné pro RTTY (FSK)
    DDS_CORE: entity work.dds_compiler_v4_0
    port map (
        clk => clk,
        we => '1',
        data => phase,
        sine => carrier
    );
    
    -- PS2 driver
    PS2_DRIVER: entity work.ps2_driver
    port map (
        clk => clk,
        ps2_data => ps2_data,
        ps2_clock => ps2_clock,
        segment_data => segment_data,
        segment_pozice => segment_pozice,
        scan_code => scan_code,
        scan_code_en => scan_code_en
    );
    
    RTTY_PS2LUT: entity work.rtty_lut
    port map (
        ps2_scan_code => scan_code,
        rtty_baudot => scan_code_baudot
    );
    
     -- Enabler 50 Hz clock
     ENABLER_50HZ: entity work.enabler
     port map (
        vstup_in => clock_tone,
        vystup_out => clock_tone_pulse,
        clk => clk
     );
        
--    RTTY_MEM: entity work.rttymem
--    port map (
--        clk => clk,
--        addr => counter,
--        output_data => rtty_dat
--    );
 
    -- delicka z 50 MHz na 50 Hz
	CLK_DIVIDER_TONE: entity work.clock_divider
    generic map (
       COUNT_TO => 500000    
    )
	port map (
	   clk_in => clk,
       clk_out => clock_tone
	);
    
    -- LEDs, signal
    leds(1 downto 0) <= rtty_dat & not rtty_dat;
    leds(2) <= scan_code_en;
    leds(7 downto 4) <= "0000";
    ant <= carrier;
    sound <= carrier & '0';
     
    -- RTTY byte s start/stop bits
    rtty_byte_next(0) <= '0'; -- start bit
    rtty_byte_next(6) <= '1'; -- stop bit
    rtty_byte_next(7) <= '1'; -- stop bit
    
    process(rtty_fsm,scan_code_en,clock_tone_pulse,scan_code_baudot,cnt_rtty,rtty_byte,rtty_byte_new,rtty_byte_wait) 
    begin 
        rtty_fsm_next <= rtty_fsm;
        rtty_dat <= '1';       
        rtty_byte_next(5 downto 1) <= rtty_byte(5 downto 1);
        cnt_rtty_next <= "000";
        rtty_byte_new_next <= rtty_byte_new;
        rtty_byte_wait_next <= rtty_byte_wait;
        rtty_byte_sended_next <= rtty_byte_sended;
        if(scan_code_en = '1') then
            rtty_byte_wait_next <= scan_code_baudot;
            rtty_byte_new_next <= '1';
        end if;
        case (rtty_fsm) is
            when rtty_ready =>
                leds(3) <= '0';
                rtty_dat <= '1';
                cnt_rtty_next <= "000";
                if(rtty_byte_new = '1') then
                    rtty_fsm_next <= rtty_sending;
                    rtty_byte_new_next <= '0';
                    rtty_byte_next(5 downto 1) <= scan_code_baudot;--rtty_byte_wait;
                else
                    rtty_fsm_next <= rtty_sending;
                    rtty_byte_next(5 downto 1) <= "11111";
                end if;            
            when others =>	-- rtty_sending
                leds(3) <= '1';
                if(clock_tone_pulse = '1') then
                    cnt_rtty_next <= std_logic_vector(unsigned(cnt_rtty) + 1);
                else
                    cnt_rtty_next <= cnt_rtty;
                end if;
                if(cnt_rtty = "111") then
                    rtty_dat <= '1';
                    rtty_byte_sended <= '1';
                    rtty_fsm_next <= rtty_ready;
                else
                    rtty_dat <= rtty_byte(to_integer(unsigned(cnt_rtty)));
                    rtty_fsm_next <= rtty_sending;
                end if;     
        end case;       
    end process;
     
--    process(clock_tone) begin
--        if(rising_edge(clock_tone)) then
--            counter <= std_logic_vector(unsigned(counter) + 1);
--        end if;
--    end process;    
 
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
            -- Set RTTY frequency and shift
            -- Freq: 595 000 Hz for 0, 595 200 for 1, = 200 Hz shift
            phase(23 downto 11) <= "0000001100001";
            phase(10) <= rtty_dat;
            phase(9) <= not rtty_dat;
            phase(8) <= not rtty_dat;
            phase(7) <= not rtty_dat;
            phase(6) <= not rtty_dat;
            phase(5) <= '1';
            phase(4) <= '0';
            phase(3) <= '0';
            phase(2) <= '0';
            phase(1) <= rtty_dat;
            phase(0) <= rtty_dat;
            -- Rewrite RTTY FSM
            rtty_fsm <= rtty_fsm_next;
            cnt_rtty <= cnt_rtty_next;
            rtty_byte <= rtty_byte_next;
            rtty_byte_new <= rtty_byte_new_next;
            rtty_byte_wait <= rtty_byte_wait_next;
            rtty_byte_sended <= rtty_byte_sended_next;
        end if;
    end process;


end Behavioral;