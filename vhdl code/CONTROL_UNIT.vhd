library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;

	-- CONTROL UNIT : this module to compare Humidity with desire Humidity(Atmosfer)
	--                AND generate command for ON/OFF Water Pomp
entity CONTROL_UNIT is
	generic
		(
			HIGH_HUMIDITY : std_logic_vector := "1001100101" ; -- Atmosfer = 300 ==> Digital = 613 
			Low_HUMIDITY  : std_logic_vector := "0011001011"   -- Atmosfer = 100 ==> Digital = 203   
		);
	Port 
		(
			CLK             : in   STD_LOGIC;
         RST             : in   STD_LOGIC;
         ADC_Data        : in   STD_LOGIC_VECTOR (9 downto 0);-- ADC 10 Bit from external ADC to FPGA
			ADC_Data_Valid  : in   STD_LOGIC; -- This port is high when FPGA select ADC and drived by SELECT_ADC module
			Water_Pomp      : out  STD_LOGIC  -- Command from FPGA to external water pomp 0:OFF and 1:HIGH Z:NO Change
		);
end CONTROL_UNIT;

architecture Behavioral of CONTROL_UNIT is

	--==================================================================
	-- Define State_Machine States:
	-- 		Waiting     		 : Wait for ADC_DATA_VALID = '1' (Data is valid for processing and Compare)
	-- 		WATER_POMP_CONTROL : if   Humidity is less than Low_HUMIDITY then Turn-On Water pomp else
   --  								 : if   Humidity is greater then High_Humidity_Band then Turn-Off	Water pomp
	type states is (WAITING , WATER_POMP_CONTROL ); 
	signal state : states := WAITING ; -- Initial Value For State Machine
	--==================================================================
	-- Register ADC_ Data and then compare ( For avoid LOSE data)
	signal ADC_DATA_REGISTER : std_logic_vector (9 downto 0):=(others => '0');
	--==================================================================
	
begin
	--==================================================================
	-- Main Process for State Machine
	STATE_MACHINE :
		process (CLK)
		begin
			if (rising_edge(CLK)) then
				if (RST = '1') then
					state      <= WAITING ; -- If Reset is High then Machine return to WAITING state
					WATER_POMP <= '0' ;     -- and TURN_OFF water pomp
				else
					case state is 
						when WAITING     	         => state <= WAITING; -- Wait for new ADC_Data ( when  ADC_Data_Valid = '1' )
																if ( ADC_Data_Valid = '1' ) then   -- New ADC_Data is ready
																	ADC_DATA_REGISTER <= ADC_Data;  -- Register New ADC_Data
																	state <= WATER_POMP_CONTROL;    -- Change State to WATER_POMP_CONTROL (For Compare and send Command to water pomp)
																end if;
						when WATER_POMP_CONTROL 	=> state <= WAITING; -- Next State is Waiting ( this state is only 1 CLK)
																if ( ADC_DATA_REGISTER    < Low_HUMIDITY  ) then -- if ADC_Data is Less than Low_Humidity_Band (100) then 
																	Water_Pomp <= '1' ;                           -- Turn-On Water Pomp
																elsif ( ADC_DATA_REGISTER > HIGH_HUMIDITY ) then -- else if ADC_Data is Greater than High_Humidity_Band (300) then 
																	Water_Pomp <= '0' ;                           -- Turn-off Water Pomp
																end if;    
						when others  => NULL ;  -- Do Nothing
					end case;
				end if;
			end if;
		end process STATE_MACHINE;
	--==================================================================
end Behavioral;

