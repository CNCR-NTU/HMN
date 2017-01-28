library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity id is
    port (
			clk	: IN std_logic; -- 50 MHz clock
			ID1	: OUT std_logic_vector (3 downto 0);
			ID2	: OUT std_logic_vector (3 downto 0);
			ID3	: OUT std_logic_vector (3 downto 0);
			ID4	: OUT std_logic_vector (3 downto 0);
			ID5	: OUT std_logic_vector (3 downto 0)
    );
end id;

architecture id_arch of id is
	
begin
	identifier : process(clk)  begin
		if rising_edge(clk) then
			ID1<="0001";
			ID2<="0010";
			ID3<="0011";
			ID4<="0100";
			ID5<="0101";
		else
			-- nothing happens
		end if;
	end process;

end id_arch;