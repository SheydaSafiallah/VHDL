-- VHDL Final Project
-- sheyda safiallah 9820893
-- semester : fall 2021

library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
   use IEEE.NUMERIC_STD.ALL;
-- TOP Module
entity Watering is
	-- Generic data : Atmosfer Band's are 300 and 100 and converted to Digital
	-- Digital(300) = (300/500)*2^10 - 1 = 613
	-- Digital(100) = (100/500)*2^10 - 1 = 203
	generic
		(
			HIGH_HUMIDITY : std_logic_vector := "1001100101" ; -- Atmosfer = 300 ==> Digital = 613 
			Low_HUMIDITY  : std_logic_vector := "0011001011"   -- Atmosfer = 100 ==> Digital = 203   
		);
   Port 
		(
			CLK         	: in   STD_LOGIC;   -- Main CLK for all modules
         RST         	: in   STD_LOGIC;   -- Reset all Modules
         ADC_Data    	: in   STD_LOGIC_VECTOR (9 downto 0); -- ADC 10 Bit from external ADC to FPGA 
         ADC_Select  	: out  STD_LOGIC_VECTOR (1 downto 0); -- ADC Selector 2 Bit from FPGA to external ADC
         Water_Pomp0 	: out  STD_LOGIC;   -- Command from FPGA to external water pomp0 0:OFF and 1:HIGH Z:NO Change
         Water_Pomp1 	: out  STD_LOGIC;   -- Command from FPGA to external water pomp1 0:OFF and 1:HIGH Z:NO Change
         Water_Pomp2 	: out  STD_LOGIC;   -- Command from FPGA to external water pomp2 0:OFF and 1:HIGH Z:NO Change
         Water_Pomp3 	: out  STD_LOGIC    -- Command from FPGA to external water pomp3 0:OFF and 1:HIGH Z:NO Change
		);
end Watering;

architecture Behavioral of Watering is
	-- CONTROL UNIT : use this module to compare Humidity with desire Humidity(Atmosfer)
	-- AND generate command for On/OFF Water Pomp
	component CONTROL_UNIT  
		generic
			(
				HIGH_HUMIDITY   : std_logic_vector := "1001100101" ; -- Atmosfer = 300 ==> Digital = 613 
			   Low_HUMIDITY    : std_logic_vector := "0011001011"   -- Atmosfer = 100 ==> Digital = 203   
			);
		Port 
			(
				CLK             : in   STD_LOGIC;
				RST             : in   STD_LOGIC;
				ADC_Data        : in   STD_LOGIC_VECTOR (9 downto 0); -- ADC 10 Bit from external ADC to FPGA
				ADC_Data_Valid  : in   STD_LOGIC; -- This port is high when FPGA select ADC and drived by SELECT_ADC module
				Water_Pomp      : out  STD_LOGIC  -- Command from FPGA to external water pomp 0:OFF and 1:HIGH Z:NO Change
			);
	end component;

   -- SELECT_ADC : use this module to select ADC0 to ADC3
	component SELECT_ADC is
    Port 
		(
			  CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           SEL : out STD_LOGIC_VECTOR (1 downto 0); -- From FPGA to External Multiplexer ( Simulator Module as test bench module)
			  ADC_Data_Valid0 : out STD_LOGIC; -- when ADC0 selected then its data is ready to use in FPGA so This port is High for only 1 CLK
			  ADC_Data_Valid1 : out STD_LOGIC; -- when ADC1 selected then its data is ready to use in FPGA so This port is High for only 1 CLK
			  ADC_Data_Valid2 : out STD_LOGIC; -- when ADC2 selected then its data is ready to use in FPGA so This port is High for only 1 CLK
			  ADC_Data_Valid3 : out STD_LOGIC  -- when ADC3 selected then its data is ready to use in FPGA so This port is High for only 1 CLK
		);
	end component;
	
	signal ADC_Data_Valid0 :  STD_LOGIC := '0'; -- ADC Data is Ready to use. From SELECT_ADC module to CONTROL_UNIT0 
	signal ADC_Data_Valid1 :  STD_LOGIC := '0'; -- ADC Data is Ready to use. From SELECT_ADC module to CONTROL_UNIT1
	signal ADC_Data_Valid2 :  STD_LOGIC := '0'; -- ADC Data is Ready to use. From SELECT_ADC module to CONTROL_UNIT2
	signal ADC_Data_Valid3 :  STD_LOGIC := '0'; -- ADC Data is Ready to use. From SELECT_ADC module to CONTROL_UNIT3
	
begin
	-- SELECT_ADC module for select ADC0 to ADC3
	SELECT_ADC_INPUT : SELECT_ADC 
    Port map
		(
			  CLK => CLK ,
           RST => RST ,
           SEL => ADC_Select ,
			  ADC_Data_Valid0 => ADC_Data_Valid0, -- to Control unit0 for compare Humidity and ON/OFF Water Pomp0
			  ADC_Data_Valid1 => ADC_Data_Valid1, -- to Control unit0 for compare Humidity and ON/OFF Water Pomp1
			  ADC_Data_Valid2 => ADC_Data_Valid2, -- to Control unit0 for compare Humidity and ON/OFF Water Pomp2
			  ADC_Data_Valid3 => ADC_Data_Valid3  -- to Control unit0 for compare Humidity and ON/OFF Water Pomp3
		);
	--======================================================
	-- To compare ADC0 Data with Humidity Bands High and LOw and ON/OFF Water_Pomp0 ON/OFF
	CONTROL_UNIT0:  CONTROL_UNIT  
		generic map
			(
				HIGH_HUMIDITY   => HIGH_HUMIDITY  ,
				Low_HUMIDITY    => LOW_HUMIDITY  
			) 
		Port map
			(
				CLK             => CLK            , 
				RST             => RST            ,  
				ADC_Data        => ADC_Data       , -- ADC Data from external ADC   
				ADC_Data_Valid  => ADC_Data_Valid0, -- ADC Data Valid from  SELECT_ADC module
				Water_Pomp      => Water_Pomp0      -- 1 : Water pomp0 is ON , 0 : water pomp0 is OFF
			);
	--======================================================
	-- To compare ADC1 Data with Humidity Bands High and Low and ON/OFF Water_Pomp1 ON/OFF
	CONTROL_UNIT1:  CONTROL_UNIT  
		generic map
			(
				HIGH_HUMIDITY   => HIGH_HUMIDITY  ,
				Low_HUMIDITY    => LOW_HUMIDITY   
			) 
		Port map
			(
				CLK             => CLK            , 
				RST             => RST            ,  
				ADC_Data        => ADC_Data       ,   
				ADC_Data_Valid  => ADC_Data_Valid1,  
				Water_Pomp      => Water_Pomp1      -- 1 : Water pomp1 is ON , 0 : water pomp1 is OFF
			);
	--======================================================
	-- To compare ADC2 Data with Humidity Bands High and Low and ON/OFF Water_Pomp2 ON/OFF
	CONTROL_UNIT2:  CONTROL_UNIT  
		generic map
			(
				HIGH_HUMIDITY   => HIGH_HUMIDITY  , 
				Low_HUMIDITY    => LOW_HUMIDITY   
			) 
		Port map
			(
				CLK             => CLK            , 
				RST             => RST            ,  
				ADC_Data        => ADC_Data       ,   
				ADC_Data_Valid  => ADC_Data_Valid2,  
				Water_Pomp      => Water_Pomp2      -- 1 : Water pomp2 is ON , 0 : water pomp2 is OFF
			);
	--======================================================
	-- To compare ADC3 Data with Humidity Bands High and Low and ON/OFF Water_Pomp3 ON/OFF
	CONTROL_UNIT3:  CONTROL_UNIT  
		generic map
			(
				HIGH_HUMIDITY   => HIGH_HUMIDITY  ,
				Low_HUMIDITY    => LOW_HUMIDITY   
			) 
		Port map
			(
				CLK             => CLK            , 
				RST             => RST            ,  
				ADC_Data        => ADC_Data       ,   
				ADC_Data_Valid  => ADC_Data_Valid3,  
				Water_Pomp      => Water_Pomp3      -- 1 : Water pomp3 is ON , 0 : water pomp3 is OFF
			);
	--======================================================
end Behavioral;

