library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 
use work.all; 

entity lab04_tb is 
end lab04_tb; 

architecture arch of lab04_tb is 
    signal CLK100MHZ : std_logic := '0'; -- 100 MHz System Clock    
    signal SW0 : std_logic := '0'; -- Reset Switch 

    -- Push Buttons    
    signal BTNU : std_logic := '0';  
    signal BTND : std_logic := '0';  
    signal BTNL : std_logic := '0'; 
    signal BTNR : std_logic := '0'; 

    -- VGA Signals  
    signal VGA_R : std_logic_vector (3 downto 0); 
    signal VGA_G : std_logic_vector (3 downto 0); 
    signal VGA_B : std_logic_vector (3 downto 0); 
    signal VGA_HS : std_logic; 
    signal VGA_VS : std_logic; 

    -- 7-Segment Display  
    signal SEG7_CATH : std_logic_vector (7 downto 0); 
    signal AN : std_logic_vector (7 downto 0) 

    -- clock period definition 
    constant clk_period : time := 10ns; 

begin  

    CLK100MHZ <= not CLK100MHZ after clk_period/2; -- Generate clock 

    process 
    begin 
        -- Test reset 
        SW0 <= '0'; wait for 0 ns; 
        SW0 <= '1'; wait for 500 ns; 
        SW0 <= '0'; 


        ----------------------- 
        --- Verify VS signal -- 
        ----------------------- 
        -- Driven low between approx. 0-15.6603 ms 
        -- Driven high between approx. 15.6604-15.72432 ms 
        -- Driven low between approx. 15.72433-16.6192 ms 

        ------------------------------ 
        --- Test red square control -- 
        ------------------------------ 
        -- Verifying ...  
        -- (1) Button debouncing 
        -- (2) Red square wraps around display 
        -- (3) Seven-segment display shows square location 
        -------- Red square should wrap around screen in each case 
         
        BTNU <= '1'; wait for 100 ms; 
        BTNU <= '0'; wait for 5 s; 
        -------- Seven-segment display shows (000E) 
        BTND <= '1'; wait for 100 ms; 
        BTND <= '0'; wait for 5 s; 
        -------- Seven-segment display shows (0000) 
        BTNL <= '1'; wait for 100 ms; 
        BTNL <= '0'; wait for 5 s; 
        -------- Seven-segment display shows (1300) 
        BTNR <= '1'; wait for 100 ms; 
        BTNR <= '0'; wait for 5 s; 
        -------- Seven-segment display shows (0000) 

        -------- Red square position should remain unchanged  
        BTND <= '1'; wait for 99 ms; 
        BTND <= '0'; 

 
        --------------------------------------------------------------------------------------------------------------------- 
        -- TESTCASE 1: BUTTON DEBOUNCE 
        -- Simulate button bounce for BTNU  
        BTNU <= '1';  
        wait for 5 ns;  
        BTNU <= '0';  
        wait for 5 ns;  
        BTNU <= '1';  
        wait for 5 ns;  
        BTNU <= '0';  
        wait for 5 ns;  
        BTNU <= '1';  
        wait for 100 ms;  
        -- Check if only one movement occurs 

        -- Simulate button bounce for BTND 
        BTND <= '1';  
        wait for 5 ns;  
        BTND <= '0';  
        wait for 5 ns;  
        BTND <= '1';  
        wait for 5 ns;  
        BTND <= '0';  
        wait for 5 ns;  
        BTND <= '1';  
        wait for 100 ms;  
        -- Check if only one movement occurs 
        --------------------------------------------------------------------------------------------------------------------- 

    

        --------------------------------------------------------------------------------------------------------------------- 
        -- TESTCASE 2: WRAP-AROUND VERIFICATION 
            -- move red square down 16 times and verify it wraps back around to 0,0 
        BTND <= '1'; wait for 100 ms; BTND <='0'; wait for 100 ms; --1 
        BTND <= '1'; wait for 100 ms; BTND <='0'; wait for 100 ms; --2 
        BTND <= '1'; wait for 100 ms; BTND <='0'; wait for 100 ms; --3
        BTND <= '1'; wait for 100 ms; BTND <='0'; wait for 100 ms; --4 
        BTND <= '1'; wait for 100 ms; BTND <='0'; wait for 100 ms; --5 
        BTND <= '1'; wait for 100 ms; BTND <='0'; wait for 100 ms; --6 
        BTND <= '1'; wait for 100 ms; BTND <='0'; wait for 100 ms; --7 
        BTND <= '1'; wait for 100 ms; BTND <='0'; wait for 100 ms; --8 
        BTND <= '1'; wait for 100 ms; BTND <='0'; wait for 100 ms; --9 
        BTND <= '1'; wait for 100 ms; BTND <='0'; wait for 100 ms; --10 
        BTND <= '1'; wait for 100 ms; BTND <='0'; wait for 100 ms; --11
        BTND <= '1'; wait for 100 ms; BTND <='0'; wait for 100 ms; --12
        BTND <= '1'; wait for 100 ms; BTND <='0'; wait for 100 ms; --13
        BTND <= '1'; wait for 100 ms; BTND <='0'; wait for 100 ms; --14
        BTND <= '1'; wait for 100 ms; BTND <='0'; wait for 100 ms; --15
        BTND <= '1'; wait for 100 ms; BTND <='0'; wait for 100 ms; --16
        --------------------------------------------------------------------------------------------------------------------- 
    
    end process; 

    ----------------------- 
    --- Verify HS signal -- 
    ----------------------- 
    -- Driven high between approx. 0-26239 ns 
    -- Driven low between approx. 26240-30080 ns 
    -- Driven high between approx. 30080-31960 ns 

    -- sync-verification process 
    sync_ver: process 
    begin  
        -- reset  
        SW0 <= '0'; wait for 0 ns; 
        SW0 <= '1'; wait for 500 ns; 
        SW0 <= '0'; 
        -- check hsync 
        wait for 26240 ns;  
        assert (VGA_HS = '0') report "HS signal not low as expected between 26240-30080 ns" severity error; 	
        wait for 30080 ns;  
        assert (VGA_HS = '1') report "HS signal not high as expected between 30080-31960 ns" severity error; 	
        wait for 31960 ns; 
     end process 

     
    -- Lab 4 top-level instantiation 
    lab04_top_inst: entity lab04_top 
    port map( 
        CLK100MHZ,  
        SW0, 
        BTNU,  
        BTND,  
        BTNL,  
        BTNR,  
        VGA_R, 
        VGA_G, 
        VGA_B, 
        VGA_HS, 
        VGA_VS, 
        SEG7_CATH, 
        AN
    ); 


end arch; 