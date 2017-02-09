library ieee ;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.utility_package.all;
use work.settings_package.all;
use ieee.fixed_float_types.all;
--!ieee_proposed for fixed point
use ieee.fixed_pkg.all;
--!ieee_proposed for floating point
use ieee.float_pkg.all;
 
entity synapse is 
	generic 
			(
				ID: 		natural :=1;	-- neuron ID
				SYN_ID:	natural :=0
			);		
	port 
		(
			clk: 		IN std_logic; -- 100 MHz clock
			reset: 	IN std_logic; -- sync clock
			inBus:	IN std_logic; -- "10"+x"XX" change weight| 11X"+x"XX"
			outBus:	OUT std_logic
		);
	end synapse;
	
architecture behaviour of synapse is
	signal gSyn:		float32;
	signal iSyn:		float32;
	signal dt:			natural;
	signal count:		natural;
	signal counter:	natural;
	signal ct:			natural;
	signal tau:			float32;
	signal w: 			float32;
	signal V:			float32;
	signal bitNum:		integer range 8 downto -23;
	signal bitNum1:	integer range 8 downto -23;
	signal spike:		std_logic;
	signal flag:		std_logic;
	signal vFlag:		std_logic;
	signal iFlag:		std_logic;
	
	
begin
deserialiser: process (clk, reset,inBus)
	begin
		if  rising_edge(clk) then
			if reset='1' then
				w<=to_float(WEIGHTS(ID-1,SYN_ID),w);
				V<=to_float(0.0,V);
				counter<=0;
				flag<='0';
				bitNum<=-23;
				vFlag<='0';
			else
				if inBus='1' and counter=0 then
					counter<=counter+1;
				elsif counter=1 then
					if inBus='1'then -- run step
						flag<='1';
					else
						flag<='0';
					end if;
					counter<=counter+1;
				elsif counter>1 then
					if flag='1' then
						if counter=2 then
							spike<=inBus;
							counter<=counter+1;
						elsif counter>2 then
							if bitNum<9 then
								V(bitNum)<=inBus;
								--report "Rx: "&std_logic'image(V(bitNum))&" index "& integer'image(bitNum) severity note;
								if bitNum<8 then
									bitNum<=bitNum+1;
								else
									vFlag<='1';
									counter<=0;
									bitNum<=-23;
								end if;
							else
								--nothing happens
							end if;
						else
							-- nothing hppens
						end if;
					else
						if bitNum<9 then
							w(bitNum)<=inBus;
							if bitNum<8 then
								bitNum<=bitNum+1;
							else
								counter<=0;
								bitNum<=-23;
							end if;
						else
							--nothing happens
						end if;
					end if;
				else
					--nothing happens
				end if;
				
				if vFlag='1' then
					vFlag<='0';
				else
					--nothing happens
				end if;
			end if;		
		else
			--nothing happens
		end if;
	end process deserialiser;
							
					
	
syn: process(clk,reset, spike, vFlag, V, w)
	begin
		if  rising_edge(clk) then
			if reset='1' then
				dt<=0;
				tau<=to_float(0.017,tau);
				count<=0;
				dt<=0;
				gSyn<=to_float(0.0,gSyn);
				iSyn<=to_float(0.0,iSyn);
				iFlag<='0';
			else
				if vFlag='1' and count=0 then
					if w>to_float(0.0,w) or w<to_float(0.0,w) then
						if spike='1' then
							dt<=0;
						else
							dt<=dt+1;
						end if;
						count<=count+1;
					else
						--nothing happens;
					end if;
				elsif count=1 then
					gSyn<=g_syn(ID-1,SYN_ID)*CONDUCTANCE(dt);
					count<= count+1;
				elsif count=2 then
					iSyn<=V*gSyn-eSyn(ID-1,SYN_ID)*gSyn;
					--report "Synapse #"& natural'image(SYN_ID)&" ,value: "&integer'image(to_integer(signed(iSyn))) severity note;
					count<=0;
					iFlag<='1';
				else
					-- nothing happens;
				end if;
				
				if iFlag='1' then
					iFlag<='0';
				else
					-- nothing happens
				end if;
			
			end if;
		else
			-- nothing happens
		end if;
	end process syn;
	
	serialiser: process (clk, reset, iFlag, iSyn)
		variable iSynBuff: float32;
	begin
		if  rising_edge(clk) then
			if reset='1' then
				ct<=0;
				bitNum1<=-23;
				iSynBuff:=to_float(0.0,iSynBuff);
				outBus<='0';
			else
				if iFlag='1' and ct=0 then
					ct<=ct+1;
					iSynBuff:=iSyn;
					outBus<='1';
				elsif ct>0 then
					if bitNum1<9 then
						outBus<=iSynBuff(bitNum1);
						if bitNum1<8 then
							bitNum1<=bitNum1+1;
						else
							ct<=0;
							bitNum1<=-23;
							outBus<='0';
						end if;
					else
						--nothing happens
					end if;
				else
					--nothing happens
				end if;
			end if;		
		else
			--nothing happens
		end if;
	end process serialiser;
end behaviour;						
	
 
 