LIBRARY ieee;
	USE ieee.std_logic_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;
-- Watering Test Bench
ENTITY Watering_TB IS
	-- port ();
END Watering_TB;
 
ARCHITECTURE behavior OF Watering_TB IS 
	 -- WAtering Module
    component watering
		 generic
			(
				HIGH_HUMIDITY  : std_logic_vector(9 downto 0) := "1001100101" ;
				Low_HUMIDITY   : std_logic_vector(9 downto 0) := "0000100000"   
			);
		 port
			(
				CLK        		: in   std_logic;
				RST         	: in   std_logic;
				ADC_Data    	: in   STD_LOGIC_VECTOR(9 downto 0);
				ADC_select     : out  std_logic_vector(1 downto 0);
				Water_Pomp0    : out  std_logic;
				Water_Pomp1    : out  std_logic;
				Water_Pomp2    : out  std_logic;
				Water_Pomp3    : out  std_logic
			);
    end component;
    
   --Inputs
   signal CLK         : std_logic := '0';
   signal RST         : std_logic := '1';
   signal ADC_Data    : std_logic_vector(9 downto 0) := (others => '0');
	
 	--Outputs
   signal ADC_Select  : std_logic_vector(1 downto 0);
   signal Water_Pomp0 : std_logic;
   signal Water_Pomp1 : std_logic;
   signal Water_Pomp2 : std_logic;
   signal Water_Pomp3 : std_logic;
	--===================================================================
	-- Data Generator
	-- We use this signal to simulate ADC0 ~ ADC 3 data
	signal ADC_Data0   : std_logic_vector(9 downto 0) := (others => '0');
	signal ADC_Data1   : std_logic_vector(9 downto 0) := (others => '0');
	signal ADC_Data2   : std_logic_vector(9 downto 0) := (others => '0');
	signal ADC_Data3   : std_logic_vector(9 downto 0) := (others => '0');
	--===================================================================
	-- For Generate ADC Data we use a 13 Bit Counter.
	-- This counter increment at each CLK 
	signal COUNTER     : unsigned(12 downto 0):= "0001110000000"; -- Initial value is 896 (It's optional)
	--===================================================================
BEGIN
	--======================================================
	CLK <= NOT CLK after  5 ns ; -- CLK Generator
   RST <= '0'     after 25 ns ; -- System is reset for 25 ns;
	--======================================================
	-- Multiplexer 10 Bit for select and transfer ADC_Data(i) to FPGA(i : 0 , 1 , 2 , 3)
	ADC_Data <= ADC_Data0 when ADC_select = "00" else -- ADC0
	            ADC_Data1 when ADC_select = "01" else -- ADC1
	            ADC_Data2 when ADC_select = "10" else -- ADC2
	            ADC_Data3 ;                           -- ADC3
	--======================================================
	-- ADC_Data(i) Generator
	-- ADC_Data0 = COUNTER ( 9-0) 
	-- ADC_Data1 = COUNTER (10-1)
	-- ADC_Data2 = COUNTER (11-2)
	-- ADC_Data3 = COUNTER (12-3) 
	process (CLK)
	begin
		if (rising_edge(CLK)) then
			COUNTER   <= COUNTER + 1 ;
			ADC_Data0 <= std_logic_vector(COUNTER( 9 downto 0)); -- converrt UNSIGNED to STD_LOGIC_VECTOR 
			ADC_Data1 <= std_logic_vector(COUNTER(10 downto 1));
			ADC_Data2 <= std_logic_vector(COUNTER(11 downto 2));
			ADC_Data3 <= std_logic_vector(COUNTER(12 downto 3));
		end if;
	end process;
	--======================================================
   uut: Watering
		generic map
			(
				HIGH_HUMIDITY  => "1001100101",
				Low_HUMIDITY   => "0011001011"     
			) 
		PORT MAP 
			(
				 CLK         	=> CLK,
				 RST         	=> RST,
				 ADC_Data    	=> ADC_Data,
				 ADC_Select  	=> ADC_Select,
				 Water_Pomp0 	=> Water_Pomp0,
				 Water_Pomp1 	=> Water_Pomp1,
				 Water_Pomp2 	=> Water_Pomp2,
				 Water_Pomp3 	=> Water_Pomp3
			);

END;
