LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.std_logic_unsigned.all;
use work.utility_package.all;
use work.settings_package.all;
  
entity mc_tb is
end;

architecture behav_tb of mc_tb is
component mc 

port (
	clk				: IN std_logic; -- 50 MHz clock
	reset				: IN std_logic; -- sync reset
	resetBut			: IN STD_LOGIC;
	spiInReady		: IN std_logic; -- SPI
	spiIn				: IN std_logic_vector(7 downto 0);
	spiTX				: IN std_logic;
	spiOutReady		: OUT std_logic; -- SPI
	spiOut			: OUT std_logic_vector (7 downto 0); -- SPI
	resetTrigger	: OUT std_logic;
	txReq				: OUT std_logic; -- SPI
	debug				: OUT std_logic_vector (2 downto 0)
	);
end component mc;
	signal clk: 			std_logic:='0';
	signal reset: 			std_logic:='0'; -- sync reset
	signal resetBut: 			std_logic:='0'; -- async reset
	signal spiInReady:	std_logic; -- SPI
	signal spiIn:			std_logic_vector (7 downto 0); -- SPI
	signal spiTX: 			std_logic_vector(NUM_MODELS-1 downto 0);
	
	
	signal spiOutReady:	std_logic; -- SPI
	signal spiOut:			std_logic_vector (7 downto 0); -- SPI
	signal resetTrigger:	std_logic_vector(NUM_MODELS-1 downto 0);
	
	
	signal txReq:			std_logic; -- SPI
	signal debug:			std_logic_vector (2 downto 0);
	
begin
	neur: for I in 0 to NUM_MODELS-1 generate
		muscle_num: mc
		port map (
			clk   => clk,
			reset => reset,
			resetBut => resetBut,
			spiInReady => spiInReady,
			spiIn=>spiIn,
			spiTX=>spiTX(I),
			spiOutReady=>spiOutReady,
			spiOut=>spiOut,
			resetTrigger=>resetTrigger(I),
			txReq=>txReq,
			debug=>debug
		);
	end generate;
		
	clock : process
		begin
		wait for 1 ns; clk  <= not clk;
   end process clock;
 
   stimulus : process
   begin
		runStep<=(others =>'0');
		spiInReady<='0';
		spiIn	<= (others =>'0');
		spiTX<=(others =>'0');
		for i in readBckBus'range loop
			readBckBus(i)<=(others => '0');
		end loop;
		busy<=(others=>'0'); 
		wait for 5 ns; reset  <= '1';
		wait for 4 ns; reset  <= '0';
		-- test reset
		
		wait for 8 ns; spiIn<="00000000"; -- send reset to all models
		spiInReady<='1';
		report "Sending command " & natural'image(to_integer(unsigned(spiIn))) & ", reset" severity note;
		wait for 2 ns; spiInReady<='0';
		
		-- test write
		wait for 8 ns; spiIn<="11000000";  -- send write to all models
		spiInReady<='1';
		report "Sending command " & natural'image(to_integer(unsigned(spiIn))) & ", write ALL" severity note;
		wait for 2 ns; spiInReady<='0';
		-- item id x"0001"
		wait for 8 ns; spiIn<=x"00";
		spiInReady<='1';
		wait for 2 ns; spiInReady<='0';
		wait for 8 ns; spiIn<=x"01";
		spiInReady<='1';
		wait for 2 ns; spiInReady<='0';
		-- item value x"00000002"
		wait for 8 ns; spiIn<=x"00";
		spiInReady<='1';
		wait for 2 ns; spiInReady<='0';
		wait for 8 ns; spiIn<=x"00";
		spiInReady<='1';
		wait for 2 ns; spiInReady<='0';
		wait for 8 ns; spiIn<=x"00";
		spiInReady<='1';
		wait for 2 ns; spiInReady<='0';
		wait for 8 ns; spiIn<=x"02";
		spiInReady<='1';
		wait for 2 ns; spiInReady<='0';
		
		wait for 8 ns; spiIn<="11000001"; -- send write to model 1
		spiInReady<='1';
		report "Sending command " & natural'image(to_integer(unsigned(spiIn))) & ", write 1" severity note;
		wait for 2 ns; spiInReady<='0';
		-- item id x"0002"
		wait for 8 ns; spiIn<=x"00";
		spiInReady<='1';
		wait for 2 ns; spiInReady<='0';
		wait for 8 ns; spiIn<=x"02";
		spiInReady<='1';
		wait for 2 ns; spiInReady<='0';
		-- item value x"00000007"
		wait for 8 ns; spiIn<=x"00";
		spiInReady<='1';
		wait for 2 ns; spiInReady<='0';
		wait for 8 ns; spiIn<=x"00";
		spiInReady<='1';
		wait for 2 ns; spiInReady<='0';
		wait for 8 ns; spiIn<=x"00";
		spiInReady<='1';
		wait for 2 ns; spiInReady<='0';
		wait for 8 ns; spiIn<=x"07";
		spiInReady<='1';
		wait for 2 ns; spiInReady<='0';
		for i in 0 to NUM_MODELS-1 loop
			wait for 8 ns; spiIn<="10100001"; -- send define net topology to neurons
			spiInReady<='1';
			report "Sending command " & natural'image(to_integer(unsigned(spiIn))) & ", neuron " & natural'image(ID(i)) & " define network topology" severity note;
			wait for 2 ns; spiInReady<='0';
			for j in 0 to 36 loop
				wait for 8 ns; spiIn<=x"00";
				spiInReady<='1';
				wait for 2 ns; spiInReady<='0';
			end loop;
			wait for 8 ns; spiIn<=std_logic_vector(to_unsigned(ID(i),8));
			spiInReady<='1';
			wait for 2 ns; spiInReady<='0';
		end loop;

		wait;
   end process stimulus;
 
   monitor : process (clk)
   begin
     if (clk = '1' and clk'event) then
			--report "ID = " & natural'image(ID(0)) & ", LAYER = "& natural'image(LAYER(0)) severity note;
     end if;
    end process monitor;
  
 end behav_tb;