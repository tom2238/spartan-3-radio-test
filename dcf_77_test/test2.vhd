library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity test2 is
    Port ( clk : in  STD_LOGIC;
           freq : in  STD_LOGIC_VECTOR (7 downto 0);
           leds : out STD_LOGIC_VECTOR (7 downto 0);
           ant : out  STD_LOGIC_VECTOR (6 downto 0);
           uart_rx : in  STD_LOGIC;
           sound : out  STD_LOGIC_VECTOR (7 downto 0);
           rst : in STD_LOGIC;
           hsync_dcf : in STD_LOGIC
         );
end test2;

architecture Behavioral of test2 is
    -- clock
    signal clk_100M : std_logic;
    signal carrier : std_logic_vector(6 downto 0);
    signal phase : std_logic_vector(23 downto 0);
    signal counter : std_logic_vector(7 downto 0);
    signal clock_tone, rx_done : std_logic;
    signal rx_out, rx_out_int : std_logic_vector(7 downto 0);
    signal ant_am : std_logic_vector(14 downto 0);
    signal sel_mode : std_logic_vector(1 downto 0);
    signal input : std_logic;
    signal hsync_dcf_int : std_logic;
    -- numeric
    signal carrier_n : unsigned(6 downto 0); 
    signal msg_n : unsigned(7 downto 0);  
    signal ant_am_n : unsigned(14 downto 0); 
    -- signal DDS
    signal dds_reg_sel : std_logic;
    signal dds_we : std_logic;
    signal dds_phase_inc : std_logic_vector(23 downto 0);
    signal dds_phase_ofs : std_logic_vector(23 downto 0);
    -- LFSR
    signal data_lfsr : std_logic_vector(3 downto 0);
begin
--    DDS_CORE_OLD: entity work.dds_compiler_v4_0
--    port map (
--        clk => clk_100M,
--        we => dds_we,
--        data => phase,
--        sine => carrier
--    );
    
    DDS_CORE: entity work.dds_compiler_2comp
    port map (
        reg_select => dds_reg_sel,
        clk => clk_100M,
        we => dds_we,
        data => phase,
        sine => carrier
    );
    
    -- LFSR random generator
    RANDOM_GEN: entity work.lfsr_gen
    PORT MAP(
		 clk => clk_100M,
         cell_data => data_lfsr,
         rst => rst
	);
    
    --dds_phase_ofs(20) <= data_lfsr(0);
    dds_phase_ofs(20 downto 0) <= (others => '0');
    dds_phase_ofs(23) <= '0';    
    dds_phase_ofs(22 downto 21) <= data_lfsr(1 downto 0) when (hsync_dcf_int ='0') else "11";

    phase <= dds_phase_inc when (freq(2) ='0') else dds_phase_ofs;
    dds_reg_sel <= '0' when (freq(2) ='0') else '1';
    --dds_reg_sel <= '0';
    dds_we <= '1';
    
    clk_100M <= clk; -- 50 MHz
    input <= ((freq(2) or freq(2)) or (freq(3) and freq(4))) or ((freq(5) and freq(6)) xor freq(7));
    
--	 DCM_100M: entity work.dcm_100m
--	 port map (
--	    CLKIN_IN => clk,
--        RST_IN => '0',
--        CLKIN_IBUFG_OUT => open,
--        CLK0_OUT => clk_100M,
--        LOCKED_OUT => open
--	 );

     process(clk_100M) begin
        if(rising_edge(clk_100M)) then
            if(rx_done = '1') then
                rx_out <= rx_out_int;
            end if;
            sel_mode(0) <= freq(0);
            sel_mode(1) <= freq(1);
            hsync_dcf_int <= hsync_dcf;
        end if;
     end process;
     
     leds <= data_lfsr & "0000";
     
     c_RX : entity work.UART_RX 
     port map (clk => clk_100M,
			 rst => '0',
			 RX_data_in => uart_rx,		
			 RX_data_out => open,--rx_out_int,
             RX_finish => open--rx_done
    );
    rx_done <= '1';
    rx_out_int <= "00" & data_lfsr & "00";
          
    -- AM carriers
    -- 7 775 878,906 Hz
    --dds_phase_inc(23 downto 0) <= X"27CFFF"; 
    -- 6 770 000,XXX Hz
    --dds_phase_inc(23 downto 0) <= X"22A993"; 
    -- 3 582 982,XXX Hz
    --dds_phase_inc(23 downto 0) <= X"12584F";
    -- 1 485 000,XXX Hz
    --dds_phase_inc(23 downto 0) <= X"079A6B";
    -- 1 269 000,XXX Hz
    --dds_phase_inc(23 downto 0) <= X"067F4D";
    -- 1 215 000,XXX Hz
    --dds_phase_inc(23 downto 0) <= X"063886";
       
    process(clk_100M) begin
        if(rising_edge(clk_100M)) then
            -- AM mode, modulation
            carrier_n <= unsigned(carrier);
            msg_n <= unsigned(rx_out);
            ant_am <= std_logic_vector(ant_am_n);
            ant_am_n <= carrier_n * msg_n;
            ant <= ant_am(14 downto 8);
            if(sel_mode = "00") then 
                -- AM mode
                -- 06 770 000,XXX Hz X"22A993"
                -- 16 660 000,XXX Hz X"554C98"
                -- 01 215 000,XXX Hz X"063886"
                dds_phase_inc(23 downto 0) <= X"063886";
                sound <= ant_am(14 downto 7);                           
            elsif (sel_mode = "11") then
                -- DCF 77 mode
                if(hsync_dcf_int ='0') then
                    sound <= carrier & '0';
                else
                    sound <= "000" & carrier(6 downto 3) & '0';
                end if;               
                dds_phase_inc(23 downto 0) <= X"006594"; -- DCF 77.5 kHz
            else
                -- FM modulation
                -- FM dev ?
                -- BIN carrier 6.77 MHz: 0010 0010 1010 1001 1001 0011
                -- BIN carrier 16.66 MHz : 0101 0101 0100 1100 1001 1000
                -- BIN carrier 1.215 MHz : 0000 0110 0011 1000 1000 0110
                dds_phase_inc(23 downto 14) <= "0000011000";
                dds_phase_inc(13 downto 6) <= rx_out;
                dds_phase_inc(5 downto 0) <= "000110";
                sound <= carrier & '0';
            end if; 
        end if;
    end process;
end Behavioral;