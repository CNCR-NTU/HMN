library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sequentiator is
	generic (
				muscles : natural := 5
				);
    port (
			clk 				: in  STD_LOGIC;
			reset  			: in  STD_LOGIC;
			txreqa			: in  std_logic;
			txreqb			: in  std_logic;
			txreqc			: in  std_logic;
			txreqd			: in  std_logic;
			txreqe			: in  std_logic;
			spiBusy			: IN STD_LOGIC;
			spiInReadya		: IN std_logic;
			spiInReadyb		: IN std_logic;
			spiInReadyc		: IN std_logic;
			spiInReadyd		: IN std_logic;
			spiInReadye		: IN std_logic;
			spiIna			: IN std_logic_vector (7 downto 0);
			spiInb			: IN std_logic_vector (7 downto 0);
			spiInc			: IN std_logic_vector (7 downto 0);
			spiInd			: IN std_logic_vector (7 downto 0); 
			spiIne			: IN std_logic_vector (7 downto 0); 
			spiTXa			: out std_logic;
			spiTXb			: out std_logic;
			spiTXc			: out std_logic;
			spiTXd			: out std_logic;
			spiTXe			: out std_logic;
			spiOutReady		: OUT std_logic; -- SPI
			spiOut			: OUT std_logic_vector (7 downto 0) -- SPI
    );
end sequentiator;

architecture sequentiator_arch of sequentiator is
	signal count		 	: natural :=0;
	signal buff				: std_logic_vector (7 downto 0):=(others =>'0');
	signal spiOutReady_aux: std_logic :='0';
	signal spiTXa_aux		: std_logic;
	signal spiTXb_aux		: std_logic;
	signal spiTXc_aux		: std_logic;
	signal spiTXd_aux		: std_logic;
	signal spiTXe_aux		: std_logic;
begin
	sequentiator : process (clk, reset, spiBusy, spiOutReady_aux) begin
		if rising_edge(clk) then
			if reset='1' then
				buff<=(others => '0');
				count<=0;
				spiTXa_aux<='0';
				spiTXb_aux<='0';
				spiTXc_aux<='0';
				spiTXd_aux<='0';
				spiTXe_aux<='0';
			else
				if count=0 and spiBusy='0' then
					if txreqa='1' and spiTXa_aux='0' then
						spiTXa_aux<='1';
						count<=count+1;
					elsif txreqb='1' and spiTXb_aux='0' then
						spiTXb_aux<='1';
						count<=count+1;
					elsif txreqc='1' and spiTXc_aux='0' then
						spiTXc_aux<='1';
						count<=count+1;
					elsif txreqd='1' and spiTXd_aux='0' then
						spiTXd_aux<='1';
						count<=count+1;
					elsif txreqe='1' and spiTXe_aux='0' then
						spiTXe_aux<='1';
						count<=count+1;
					elsif txreqa='0' and spiTXa_aux='1' then
						spiTXa_aux<='0';
					elsif txreqb='0' and spiTXb_aux='1' then
						spiTXb_aux<='0';
					elsif txreqc='0' and spiTXc_aux='1' then
						spiTXc_aux<='0';
					elsif txreqd='0' and spiTXd_aux='1' then
						spiTXd_aux<='0';
					elsif txreqe='0' and spiTXe_aux='1' then
						spiTXe_aux<='0';
					else
						-- nothing happens
					end if;
					
				elsif count>0 then
					if spiInReadya='1' then
						buff<=spiIna;
						spiOutReady_aux<='1';
						count<=0;
						spiTXa_aux<='0';
					elsif spiInReadyb='1' then
						buff<=spiInb;
						spiOutReady_aux<='1';
						count<=0;
						spiTXb_aux<='0';
					elsif spiInReadyc='1' then
						buff<=spiInc;
						spiOutReady_aux<='1';
						count<=0;
						spiTXc_aux<='0';
					elsif spiInReadyd='1' then
						buff<=spiInd;
						spiOutReady_aux<='1';
						count<=0;
						spiTXd_aux<='0';
					elsif spiInReadye='1' then
						buff<=spiIne;
						spiOutReady_aux<='1';
						count<=0;
						spiTXe_aux<='0';
					else
						-- nothing happens
					end if;
				else
					-- nothing happens
				end if;
				
				if spiOutReady_aux='1' then
					spiOutReady_aux<='0';
				else
					-- nothing happens
				end if;
				-- port assignements
				spiOutReady<=spiOutReady_aux;
				spiOut<=buff;
				spiTXa<=spiTXa_aux;
				spiTXb<=spiTXb_aux;
				spiTXc<=spiTXc_aux;
				spiTXd<=spiTXd_aux;
				spiTXe<=spiTXe_aux;
			end if;
		else
			-- nothing happens
		end if;
	end process;

end sequentiator_arch;