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

    -- Modeled Red Square XY coordinates
    signal tb_red_sqr_coord_x : integer range 0 to 14;
    signal tb_red_sqr_coord_y : integer range 0 to 19;
    signal seg7_int           : integer range 
    
    -- Hex-Encoded SEG7_CATH output
    signal seg7_hex_enc : std_logic_vector(3 downto 0);
    signal seg7_hex_x   : std_logic_vector(7 downto 0);
    signal seg7_hex_y   : std_logic_vector(7 downto 0);

begin  

    CLK100MHZ <= not CLK100MHZ after clk_period/2; -- Generate clock 

    -- Stimulus Process
    -- Drives top-level inputs of DUT
    process 
    begin 
        -- Test reset 
        SW0 <= '0'; wait for 0 ns; 
        SW0 <= '1'; wait for 500 ns; 
        SW0 <= '0'; 

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
    --- Verify VS signal -- 
    ----------------------- 
    -- Driven low between approx. 0-15.6603 ms 
    -- Driven high between approx. 15.6604-15.72432 ms 
    -- Driven low between approx. 15.72433-16.6192 ms 

    -- vertical sync-verification process 
    vsync_ver: process 
    begin  
        assert (VGA_VS = '0') report "VS signal not low as expected between 0-15.6603 ms" severity error;
        wait for 15.6603 ms;
        assert (VGA_VS = '1') report "VS signal not low as expected between 15.6604-15.72432 ms " severity error;
        wait for 0.06392 ms;
        assert (VGA_VS = '1') report "VS signal not low as expected between 15.72433-16.6192 ms" severity error;
        wait for 0.99487 ms;
    end process;


    ----------------------- 
    --- Verify HS signal -- 
    ----------------------- 
    -- Driven high between approx. 0-26239 ns 
    -- Driven low between approx. 26240-30080 ns 
    -- Driven high between approx. 30080-31960 ns 

    -- horizontal sync-verification process 
    hsync_ver: process 
    begin  
        -- reset  
        --SW0 <= '0'; wait for 0 ns; 
        --SW0 <= '1'; wait for 500 ns; 
        --SW0 <= '0'; 
        -- check hsync 
        wait for 26240 ns;  
        assert (VGA_HS = '0') report "HS signal not low as expected between 26240-30080 ns" severity error; 	
        wait for 3840 ns;  --wait for 30080 ns;  
        assert (VGA_HS = '1') report "HS signal not high as expected between 30080-31960 ns" severity error; 	
        wait for 1880 ns; -- wait for 31960 ns; 
     end process; 

    -------------------------------------------
    --- Encode Actual Red Square Coordinates -- 
    -------------------------------------------
    -- Encode raw value of SEG7_CATH outputs back into Hex format
    -- Hex encoded value of XY coordinates is then converted into an integer and compared to testbench model coordinate value
    c_encode : process(SEG7_CATH, AN)
    begin
        -- Assign default values
        seg7_hex_enc <= "10001110";
        seg7_hex_x <= (others => '0');
        seg7_hex_y <= (others => '0');

        -- Decode SEG7_CATH Output to Hex value
        with SEG7_CATH select 
            seg7_hex_enc <= 
             x"0"  when "11000000", 
             x"1"  when "11111001", 
             x"2"  when "10100100", 
             x"3"  when "10110000", 
             x"4"  when "10011001", 
             x"5"  when "10010010", 
             x"6"  when "10000010", 
             x"7"  when "11111000", 
             x"8"  when "10000000", 
             x"9"  when "10010000", 
             x"A"   when "10001000", 
             x"B"   when "10000011", 
             x"C"   when "11000110", 
             x"D"   when "10100001", 
             x"E"   when "10000110", 
             x"E"   when others;
             
        -- Check AN (anode select) to determine which display is currently using SEG7_CATH output values
        -- Y-Coordinate Anode Values:
        --      Display 0: AN = x"01"
        --      Display 1: AN = x"02"
        -- X-Coordinates Anode Values:
        --      Display 2: AN = x"04"
        --      Display 3: AN = x"08"
        case AN is
            -- X-Coordinates from SEG7_CATH outputs
            when x"01" =>
                seg7_hex_x(3 downto 0) <= seg7_hex_enc;
            when x"02" =>
                seg7_hex_x(7 downto 4) <= seg7_hex_enc;
            -- Y-Coordinates from SEG7_CATH outputs
            when x"04" =>
                seg7_hex_y(3 downto 0) <= seg7_hex_enc;
            when x"08" =>
                seg7_hex_y(7 downto 4) <= seg7_hex_enc;
            when others => null;
        end case;

    end process;

    -----------------------------------
    --- Red Square Coordinates Model -- 
    -----------------------------------
    -- Model the behavior of the red square coordinates based on button presses
    red_sqr_update: process (BTND, BTNU, BTNL, BTNR)
    begin  
        -- check button pushes and update red square modeled coordinates accordingly
        if (BTND = '1') then
            tb_red_sqr_coord_y <= tb_red_sqr_coord_y - 1;
        elsif (BTNU = '1') then
            tb_red_sqr_coord_y <= tb_red_sqr_coord_y + 1;
        elsif (BTNL = '1') then
            tb_red_sqr_coord_y <= tb_red_sqr_coord_x + 1;
        elsif (BTNR = '1') then
            tb_red_sqr_coord_y <= tb_red_sqr_coord_x - 1;
        end if;
    end process; 
  
    ------------------------------------
    --- Verify Red Square Coordinates -- 
    ------------------------------------
    -- Compare Actual vs. Modeled Red-Square Coordinates
    seg7_ver: process (seg7_hex_x, seg7_hex_y, tb_red_sqr_coord_x, tb_red_sqr_coord_y)
    begin  
        -- check actual X-coordinate output value matches testbench model value
        assert to_integer(seg7_hex_x) /= tb_red_sqr_coord_x report "Actual X-Coordinate does not match modeled value." severity error; 
         -- check actual Y-coordinate output value matches testbench model value
        assert to_integer(seg7_hex_y) /= tb_red_sqr_coord_y report "Actual Y-Coordinate does not match modeled value." severity error; 
    end process; 
     
    -- Lab 4 top-level instantiation (DUT)
    u_dut: entity lab04_top 
    port map( 
        CLK100MHZ => CLK100MHZ,  
        SW0       => SW0, 
        BTNU      => BTNU, 
        BTND      => BTND, 
        BTNL      => BTNL, 
        BTNR      => BTNR, 
        VGA_R     => VGA_R, 
        VGA_G     => VGA_G, 
        VGA_B     => VGA_B, 
        VGA_HS    => VGA_HS, 
        VGA_VS    => VGA_VS, 
        SEG7_CATH => SEG7_CATH, 
        AN        => AN
    ); 


end arch; 