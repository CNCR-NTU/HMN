Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use ieee.fixed_float_types.all;
--!ieee_proposed for fixed point
use ieee.fixed_pkg.all;
--!ieee_proposed for floating point
use ieee.float_pkg.all;

use work.expdecay.all;

entity lmm is

generic 
	(
		CONTROLBUS 	: natural := 1512;	-- Control BUS width
		RESERVEDC	: natural := 112;	-- Control BUS Reserved bits 
		SIS 		: natural := 304;	-- Synaptic inputs
		READBACKBUS	: natural := 32;	-- Control BUS width
		SYNAPSES		: natural :=20
	);

port (	clk		: IN std_logic; -- 100 MHz clock
	reset		: IN std_logic; -- sync clock
	runStep		: IN std_logic; -- N/M model
	restoreState	: IN std_logic; -- N/M model
	contBus		: IN std_logic_vector ((CONTROLBUS+RESERVEDC+SIS)-1 downto 0); -- N/M model
	readBckBus	: OUT std_logic_vector ((READBACKBUS)-1 downto 0); -- N/M model
	busy		: OUT std_logic -- N/M model
	);
end lmm;

architecture lmm_arch of lmm is
type synFloat is array (0 to SYNAPSES-1) of float32;
type synNatural is array (0 to SYNAPSES-1) of natural;
signal 	eSynMap:		std_logic_vector(39 downto 0);
signal	eSyn:			synFloat;
signal	w:				synFloat;
signal	iSyn:			synFloat;
signal	dt:			synNatural;
signal	gSyn:			synFloat;
signal	g_Syn:		synFloat;
signal 	A:				float32;
signal 	B:				float32;
signal 	C:				float32;
signal 	D:				float32;
signal 	timeStep:	float32;
signal 	v1:			float32;
signal 	v2:			float32;
signal 	v3:			float32;
signal	current:		float32;
signal 	count:		natural					:=0;
signal 	ct:		natural					:=0;
signal	compute_flag:	std_logic 				:='0';
signal	busy_aux:	std_logic 				:='0';
signal	rkAux0:		float32;
signal	rxAux1:		float32;
signal	rkAux2:		float32;
signal	rxAux3:		float32;
signal	rk22_flag:	std_logic 				:='0';
signal	currentLast: 	float32;
signal	forces	:	float32;
signal 	syn:				std_logic_vector(19 downto 0)		:= (others => '0');
signal	sflag:			std_logic 								:='0';
signal	readBckBus_aux: std_logic_vector (READBACKBUS-1 downto 0):=(others =>'0');
signal	flag:				std_logic 								:='0';
signal	stimuli:			float32;	
signal	countRK:	natural					:=0;
signal	M1A:		float32;
signal 	M1B:		float32;
signal	M1C:		float32;
signal 	M1D:		float32;
signal	M2A:		float32;
signal 	M2B:		float32;
signal	K1A:		float32;
signal 	K1B:		float32;
signal	q1A:		float32;
signal	q1B:		float32;
signal	K2A:		float32;
signal	K2B:		float32;
signal	q2A:		float32;
signal	q2B:		float32;
signal	K3A:		float32;
signal	K3B:		float32;
signal	q3A:		float32;
signal	q3B:		float32;
signal	K4A:		float32;
signal	K4B:		float32;
	

BEGIN
	muscle: process(clk, reset, v1, v2, rk22_flag)
		variable currentSum : float32;
	begin
	if clk'event and clk='1' then 
		if reset='1' then
			forces<=to_float(0.0,forces);
			count<=0;
			compute_flag<='0';
			timeStep<=to_float(0.0,timeStep);	-- 0.05
			A<=to_float(0.0,A);	-- 1.0
			B<=to_float(0.0,B);	-- 25.0
			C<=to_float(0.0,C);	-- -0.015
			D<=to_float(0.0,D);	-- 14.0
			for I in 0 to SYNAPSES-1 loop
				w(I)<=to_float(0.0,w(I));
				iSyn(I)<=to_float(0.0,iSyn(I));
				g_Syn(I)<=to_float(0.0,g_Syn(I));
				dt(I)<=0;
				gSyn(I)<=to_float(0.0,gSyn(I));
				eSyn(I)<=to_float(0.0,eSyn(I));
			end loop;
			current<=to_float(0.0,current);
			busy_aux<='0';
			current<=to_float(0.0,current);
			readBckBus<= (others => '0');
			syn<=(others => '0');
			sflag<='0';
			flag<='0';
			currentSum:=to_float(0.0,currentSum);
			stimuli<=to_float(0.0,stimuli);
			esynMap<=(others =>'0');
			ct<=10;
		else
			if restoreState='1' then
				-- 11 current max
				timeStep<=to_float(contBus(SIS+95 downto SIS+64),timeStep);
				-- (the three thetas)
				A<=to_float(contBus(RESERVEDC+31 downto RESERVEDC),A); 
				B<=to_float(contBus(RESERVEDC+63 downto RESERVEDC+32),B); 
				C<=to_float(contBus(RESERVEDC+95 downto RESERVEDC+64),C);
				D<=to_float(contBus(RESERVEDC+127 downto RESERVEDC+96),D);
				forces<=to_float(contBus(RESERVEDC+159 downto RESERVEDC+128),forces);
				stimuli<=to_float(contBus(RESERVEDC+191 downto RESERVEDC+160),stimuli);
				esynMap<=contBus(SIS+RESERVEDC+231 downto SIS+RESERVEDC+192);
				for I in 10 to SYNAPSES-1 loop
					w(I)<=to_float(contBus(SIS+RESERVEDC+263+(I*32) downto SIS+RESERVEDC+232+(I*32)),w(I));
					g_Syn(I)<=to_float(contBus(SIS+RESERVEDC+903+(I*32) downto SIS+RESERVEDC+872+(I*32)),g_Syn(I));
					iSyn(I)<=to_float(0.0,iSyn(I));
					eSyn(I)<=to_float(0.0,eSyn(I));
					dt(I)<=0;
					gSyn(I)<=to_float(0.0,gSyn(I));
				end loop;
				busy_aux<='0';
				sflag<='1';
				flag<='0';
				eSynMap<=(others => '0');
			else
				-- nothing happens
			end if;
			
			if sflag='1' then
			for I in 0 to SYNAPSES-1 loop
				if w(I)<to_float(0.0,w(I)) or w(I)>to_float(0.0,w(I))then
					syn(I)<='1';
				else
					syn(I)<='0';
				end if;
				if eSynMap(I*2+1 downto I*2) = "01" then
					eSyn(I)<=to_float(1.0,eSyn(I));
				elsif eSynMap(I*2+1 downto I*2) = "11" then
					eSyn(I)<=to_float(-1.0,eSyn(I));
				else
					eSyn(I)<=to_float(0.0,eSyn(I));
				end if;
			end loop;
			sflag<='0';
			flag<='1';
		else
			-- noting happens
		end if;
		
			if flag='1' and runStep='1' and count=0 then
				stimuli<=to_float(contBus(SIS+RESERVEDC+223 downto SIS+RESERVEDC+192),stimuli);
				currentSum:=to_float(0.0,currentSum);
				ct<=0;
				for I in 0 to SYNAPSES-1 loop
					if syn(I)='1' then
						if contBus(I)='1' then
							dt(I)<=0;
						else
							dt(I)<=dt(I)+50; 
						end if;
						
					else
						-- nothing happens
					end if;
				end loop;
				count<=count+1;
				busy_aux<='1';
			
			elsif count=1 then
				if ct<SYNAPSES then
					if syn(ct)='1' then
						gSyn(ct)<=g_syn(ct)*CONDUCTANCE(dt(ct));
						iSyn(ct)<= -eSyn(ct)*w(ct);--forces*w(ct)-eSyn(ct)*w(ct);
					else
						gSyn(ct)<=to_float(0.0,gSyn(ct));
						iSyn(ct)<=to_float(0.0,iSyn(ct));
					end if;
					ct<=ct+1;
				else
					count<=count+1;
					ct<=10;
				end if;
				
			
			elsif count=2 then
				if ct<SYNAPSES then
					iSyn(ct)<=iSyn(ct)*gSyn(ct);
					ct<=ct+1;
				else
					ct<=10;
					count<=count+1;
				end if;
			
			elsif count=3 then
				for I in 0 to SYNAPSES-1 loop
					currentSum:=currentSum+iSyn(I);
				end loop;
				count<=count+1;
			
			elsif count=4 then
				current<=currentSum+stimuli;
				compute_flag<='1';
				count<=count+1;
				
			elsif count=5 then
				compute_flag<='0';
				count<=count+1;
				
			elsif count=6 and rk22_flag='1'then 
				forces<=v1;
				busy_aux<='0';
				count<=0;
			else
			-- nothing happens
			end if;
			readBckBus(31 downto 0)<=to_slv(forces);
			busy<=busy_aux;
		end if;	
		else
			-- nothing happens
		end if;
	end process;
	
	LMM : process(clk, reset, compute_flag, A, B, C, D, timeStep, current)
	begin
	if clk'event and clk='1' then 
		if reset='1' then
			v1<=to_float(0.0,v1);
			v2<=to_float(0.0,v2);
			countRK<=0;
			rk22_flag<='0';
			K1A<=to_float(0.0,K1A);
			K1B<=to_float(0.0,K1B);
			K2A<=to_float(0.0,K2A);
			K2B<=to_float(0.0,K2B);
			K3A<=to_float(0.0,K3A);
			K3B<=to_float(0.0,K3B);
			K4A<=to_float(0.0,K4A);
			K4B<=to_float(0.0,K4B);
			q1A<=to_float(0.0,q1A);
			q1B<=to_float(0.0,q1B);
			q2A<=to_float(0.0,q2A);
			q2B<=to_float(0.0,q2B);
			q3A<=to_float(0.0,q3A);
			q3B<=to_float(0.0,q3B);
			M1A<=to_float(0.0,M1A);
			M1B<=to_float(0.0,M1B);
			M1C<=to_float(0.0,M1C);
			M1D<=to_float(0.0,M1D);
			M2A<=to_float(0.0,M2A);
			M2B<=to_float(0.0,M2B);
			rkAux0<=to_float(0.0,rkAux0);
			rxAux1<=to_float(0.0,rxAux1);
			rkAux2<=to_float(0.0,rkAux2);
			rxAux3<=to_float(0.0,rxAux3);
		else
			if countRK=0 and compute_flag='1' then
				M1A<= to_float(0.0,M1A);
				M1B<= -C;
				M1C<= -B;
				M1D<= -A;
				M2A<= to_float(0.0,M2A);
				M2B<= D;
				countRK<=countRK+1;
			
			elsif countRK=1 then
				K1A<=M1B*v2;
				K1B<=M1D*v2;
				countRK<=countRK+1;
			
			elsif countRK=2 then
				K1A<=K1A+M2A*current;
				K1B<=K1B+M2B*current;
				countRK<=countRK+1;
			
			elsif countRK=3 then
				K1A<=M1A*v1 + K1A;
				K1B<=M1C*v1 + K1B;
				q1A<=timeStep*to_float(0.5,q1A);
				q1B<=timeStep*to_float(0.5,q1B);
				countRK<=countRK+1;
			
			elsif countRK=4 then
				q1A<=v1+K1A*q1A;
				q1B<=v2+K1B*q1B;
				K2A<=M2A*current;
				K2B<=M2B*current;
				countRK<=countRK+1;
				
			elsif countRK=5 then
				K2A<=M1B*q1B+K2A;
				K2B<=M1D*q1B+K2B;
				countRK<=countRK+1;
			
			elsif countRK=6 then
				K2A<=M1A*q1A+K2A;
				K2B<=M1C*q1A+K2B;
				q2A<=timeStep*to_float(0.5,q2A);
				q2B<=timeStep*to_float(0.5,q2B);
				countRK<=countRK+1;
				
			elsif countRK=7 then
				q2A<=v1+K2A*q2A;
				q2B<=v2+K2B*q2B;
				K3A<=M2A*current;
				K3B<=M2B*current;
				countRK<=countRK+1;
				
			elsif countRK=8 then
				K3A<=M1B*q2B+K3A;
				K3B<=M1D*q2B+K3B;
				countRK<=countRK+1;
				
			elsif countRK=9 then
				K3A<=M1A*q2A + K3A;
				K3B<=M1C*q2A + K3B;
				q3A<=timeStep*to_float(0.5,q2A);
				q3B<=timeStep*to_float(0.5,q2B);
				countRK<=countRK+1;
				
			elsif countRK=10 then
				q3A<=v1+K3A*q3A;
				q3B<=v2+K3B*q3B;
				K4A<=M2A*current;
				K4B<=M2B*current;
				countRK<=countRK+1;
				
			elsif countRK=11 then
				K4A<=M1B*q3B+K4A;
				K4B<=M1D*q3B+K4B;
				countRK<=countRK+1;
			
			elsif countRK=12 then
				K4A<=M1A*q3A + K4A;
				K4B<=M1C*q3A + K4B;
				countRK<=countRK+1;
				
			elsif countRK=13 then
				rkAux0<=K1A + 2*K2A + 2*K3A + K4A;
				rxAux1<=K1B + 2*K2B + 2*K3B + K4B;
				rkAux2<=to_float(0.16666666666666666,rkAux2)*timeStep;
				rxAux3<=to_float(0.16666666666666666,rxAux3)*timeStep;
				countRK<=countRK+1;
				
			elsif countRK=14 then
				v1<=v1+rkAux0*rkAux2;
				v2<=v2+rxAux1*rxAux3;
				rk22_flag<='1';
				countRK<=countRK+1;
				
			elsif countRK=15 then
				rk22_flag<='0';
				countRK<=0;
			else
				--nothing happens
			end if;
		end if;
	else
		-- nothing happens
	end if;
	end process;

END lmm_arch;
