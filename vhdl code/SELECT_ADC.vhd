library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;
-- SELECT_ADC : use this module to select ADC0 to ADC3
entity SELECT_ADC is
    Port 
		(
			  CLK : in  STD_LOGIC; -- FPGA main CLK
           RST : in  STD_LOGIC; -- Reset
           SEL : out STD_LOGIC_VECTOR (1 downto 0); -- From FPGA to External Multiplexer for select ADC0 ~ ADC3 ( Simulator Module as test bench module)
			  ADC_Data_Valid0 : out STD_LOGIC; -- when ADC0 selected then its data is ready to use in FPGA so This port is High for only 1 CLK
			  ADC_Data_Valid1 : out STD_LOGIC; -- when ADC1 selected then its data is ready to use in FPGA so This port is High for only 1 CLK
			  ADC_Data_Valid2 : out STD_LOGIC; -- when ADC2 selected then its data is ready to use in FPGA so This port is High for only 1 CLK
			  ADC_Data_Valid3 : out STD_LOGIC  -- when ADC3 selected then its data is ready to use in FPGA so This port is High for only 1 CLK
		);
end SELECT_ADC;

architecture Behavioral of SELECT_ADC is
	-- Define State_Machine States:
	-- Delay : Wait for 256*CLK_Period and then Select ADC Data
	-- SELECT_ADC0 : To Send Command SEL = 00 for select ADC0 , only 1 CLK
	-- SELECT_ADC1 : To Send Command SEL = 01 for select ADC0 , only 1 CLK
	-- SELECT_ADC2 : To Send Command SEL = 10 for select ADC0 , only 1 CLK
	-- SELECT_ADC3 : To Send Command SEL = 11 for select ADC0 , only 1 CLK
	type states is (DELAY , SELECT_ADC0 , SELECT_ADC1 ,SELECT_ADC2 ,SELECT_ADC3 );
	signal state : states := DELAY ;  -- Initial Value For State Machine.
	signal COUNTER : unsigned (7 downto 0) := X"00"; -- Delay between Select ADC. (Sampling Time : 256*CLK)
begin
	--======================================================================
	-- Main Process for State Machine
	STATE_MACHINE :
		process (CLK)
		begin
			if (rising_edge(CLK)) then
				if (RST = '1') then
					state   <= DELAY; -- If Reset is High Machine return to DELAY state
					COUNTER <= X"00"; -- Reset Delay COUNTER Reset
				else
					COUNTER <= COUNTER + 1; -- Increment Counter
					case state is           -- State_Machine Change States
						when DELAY        => state <= DELAY; -- Remain in Delay State Untill Counter = 255 
											      if ( COUNTER = "11111111" ) then -- Counter = 255 , Delay Time = 256 * CLK_Period
													   state <= SELECT_ADC0; -- Change State to SELECT_ADC0
											      end if;
						when SELECT_ADC0 	=> state <= SELECT_ADC1; -- Remain in SELECT_ADC0 state only for 1 CLK
						when SELECT_ADC1 	=> state <= SELECT_ADC2; -- Remain in SELECT_ADC1 state only for 1 CLK
						when SELECT_ADC2 	=> state <= SELECT_ADC3; -- Remain in SELECT_ADC2 state only for 1 CLK
						when SELECT_ADC3 	=> state <= DELAY      ; -- Return to DELAY       state and wait for Delay time.
																
						when others  => NULL ; -- Do Nothing
					end case;
				end if; -- RST
			end if; -- CLK
		end process STATE_MACHINE;
	--======================================================================
	-- Select one of external ADC0 ~ ADC3 with SEL Signal and ADC_Data_Valid 0 ~ 3 .	
		ADC_DATA_VALID_GENERATOR :
			process (state)   -- This process is sensitive to State
			begin	
				SEL <= "ZZ";  -- Select Nothing .
				ADC_Data_Valid0 <= '0'; -- ADC_Data0 isn't valid .
				ADC_Data_Valid1 <= '0'; -- ADC_Data1 isn't valid .
				ADC_Data_Valid2 <= '0'; -- ADC_Data2 isn't valid .
				ADC_Data_Valid3 <= '0'; -- ADC_Data3 isn't valid .
				
				if    (state = SELECT_ADC0) then -- when ADC0 selected
					SEL <= "00";
					ADC_Data_Valid0 <= '1';
				elsif (state = SELECT_ADC1) then -- when ADC1 selected
					SEL <= "01";
					ADC_Data_Valid1 <= '1';
				elsif (state = SELECT_ADC2) then -- when ADC2 selected 
					SEL <= "10";
					ADC_Data_Valid2 <= '1';
				elsif (state = SELECT_ADC3) then -- when ADC3 selected
					SEL <= "11";
					ADC_Data_Valid3 <= '1';
				end if;
				
			end process ADC_DATA_VALID_GENERATOR;
		
end Behavioral;

