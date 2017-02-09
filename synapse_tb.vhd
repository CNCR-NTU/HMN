LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.utility_package.all;
use work.settings_package.all;
use ieee.fixed_float_types.all;
--!ieee_proposed for fixed point
use ieee.fixed_pkg.all;
--!ieee_proposed for floating point
use ieee.float_pkg.all;
  
entity synapse_tb is
end synapse_tb;

architecture behav_tb of synapse_tb is
	component synapse
		generic 
			(
				ID: 		natural;	-- neuron ID
				SYN_ID:	natural
			);		
		port 
			(
				clk: 		IN std_logic; -- 100 MHz clock
				reset: 	IN std_logic; -- sync clock
				inBus:	IN std_logic; -- "10"+x"XX" change weight| 11X"+x"XX"
				outBus:	OUT std_logic
			);
	end component synapse;
	
	signal   clk:			std_logic := '0';
	signal   reset: 		std_logic := '0';
	signal	inBus:		std_logic_vector(NUM_SYN-1 downto 0);
	signal	spike:		std_logic_vector(NUM_SYN-1 downto 0);
	signal   V:				float_array (NUM_SYN-1 downto 0);
	signal   iSyn:			float_array(NUM_SYN-1 downto 0); 
	signal   outBus: 		std_logic_vector(NUM_SYN-1 downto 0);
	signal	ct:			natural;
	signal	count:		natural;
	signal 	bitNum:		integer range 8 downto -23;
	signal 	bitNum1:		integer range 8 downto -23;
	signal	rflag:			std_logic:= '0';
	
begin
syna: for I in 0 to NUM_SYN-1 generate
	synapse_num: synapse
		generic map 
			(
				ID => ID(0),
				SYN_ID =>0
			)
		port map 
			(
				clk   => clk,
				reset => reset,
				inBus => inBus(I),
				outBus =>  outBus(I)			
			);
	end generate;
		
clock : process
	begin
		wait for 1 ns; clk  <= not clk;
   end process clock;
 
stimulus : process
   begin
		spike<=(others =>'0');
		ct<=0;
		bitNum1<=-23;
		inBus<=(others=>'0');
		for I in NUM_SYN-1 downto 0 loop
			V(I)<=(others =>'0');
		end loop;
		wait for 6 ns;reset  <= '1';
		wait for 4 ns; reset  <= '0';
		for K in 0 to 100 loop
			wait for 100 ns; 
			if ct=6 then
				spike<=(others=>'1');
				ct<=0;
			else
				spike<=(others=>'0');
				ct<=ct+1;
			end if;
			wait for 2 ns;
			inBus<=(others=>'1'); -- b1=1
			wait for 2 ns;
			inBus<=(others=>'1'); -- b2=1
			wait for 2 ns;	
			for I in NUM_SYN-1 downto 0 loop
				V(I)<=to_float(K+1,8,23);
				inBus(I)<=spike(I); -- b3=spike
			end loop;
			for J in 0 to 31 loop
				for I in NUM_SYN-1 downto 0 loop
					wait for 2 ns; 
					inBus(I)<=V(I)(bitNum1);
					report "Tx: "&std_logic'image(V(I)(bitNum1))&" index "& integer'image(bitNum1) severity note;
				end loop;
				if bitNum1<8 then
					bitNum1<=bitNum1+1;
				else
					bitnum1<=-23;
				end if;
			end loop;	
		end loop;
		wait;
   end process stimulus;
	
monitor: process(clk,reset)
	begin
		if  rising_edge(clk) then
			if reset='1' then
				bitNum<=-23;
				rflag<='0';
				count<=0;
				for I in NUM_SYN-1 downto 0 loop
					iSyn(I)<=(others =>'0');
				end loop;
			else
				if to_integer(unsigned(outBus))>0 and count=0 then
					count<=count+1;
					rflag<='0';
				elsif count>0 then
					if bitNum<9 then
						for I in NUM_SYN-1 downto 0 loop
							iSyn(I)(bitNum)<=outBus(I);
						end loop;
						if bitNum<8 then
							bitNum<=bitNum+1;
						else
							bitNum<=-23;
							count<=0;
							rflag<='1';
							for I in NUM_SYN-1 downto 0 loop
								report "Synapse #"& natural'image(I)&" ,value: "&natural'image(to_integer(unsigned(iSyn(I)))) severity note;
							end loop;
						end if;
					else
						--nothing happens
					end if;
				else
					--nothing happens
				end if;
			end if;
		else
			-- nothing happens
		end if;
	end process monitor;
		
 end behav_tb;