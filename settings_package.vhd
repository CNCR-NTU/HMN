library ieee;
use ieee.std_logic_1164.all;
use work.utility_package.all;
use ieee.fixed_float_types.all;
--!ieee_proposed for fixed point
use ieee.fixed_pkg.all;
--!ieee_proposed for floating point
use ieee.float_pkg.all;

package settings_package is
	constant NUM_NEURONS:	natural 			:=5; -- number of neurons
	constant ID: 				natural_array 	:=(1,2,3,4,5); -- neuron ID
	constant MAX_NEURONS:	natural			:=304;
	constant SPKWIDTH:		natural			:= 32; -- multiples of 32 bits
	constant DELAY:			natural			:=8;
	constant CONTROLBUS:		natural 			:=32;
	constant ITEMID_SIZE:	natural 			:=16;
	constant TXDELAY:			natural 			:=32;
	constant READBACKBUS:	natural			:= 32;
	constant LAYER:			natural_array 	:=(1,2,1,2,3); -- Layer number
	constant NUM_SYN: 		natural 			:=1; -- number of synapses per neuron
	constant NET_TOPOLOGY_NUM: 	integer_array 	:=(2,1,2,2,3); -- number of connections
	constant VTH: 				natural_array 	:= (255, 255, 260, 100, 300);
	constant REF_PERIOD: 	natural_array 	:= (5,10,5,8,4); -- refractory period
	constant VRES:				natural_array 	:= (0, 0, 0, 0, 0);
	type nettop_t is array (NUM_NEURONS-1 downto 0) of std_logic_vector(SPKWIDTH-1 downto 0);
	type float_std_array is array (NUM_SYN-1 downto 0) of std_logic_vector(31 downto 0);
	constant NETTOPOLOGY: 		nettop_t	:= -- map of connections
	("00000000000000000000000000000110",
	"00000000000000000000000000000011",
	"00000000000000000000000000010010",
	"00000000000000000000000000001010",
	"00000000000000000000000000000101");
	constant g_syn: float_matrix :=
	((to_float(3.75036324546192,8,23),to_float(8.99944573605419,8,23),to_float(4.12968710706716,8,23)),
	(to_float(0.1,8,23),to_float(0.1,8,23),to_float(0.1,8,23)),
	(to_float(0.1,8,23),to_float(0.1,8,23),to_float(0.1,8,23)),
	(to_float(0.1,8,23),to_float(0.1,8,23),to_float(0.1,8,23)),
	(to_float(0.1,8,23),to_float(0.1,8,23),to_float(0.1,8,23)));
	constant eSyn: integer_matrix :=
	((1,1,1),
	(1,1,-1),
	(1,-1,1),
	(1,-1,-1),
	(-1,1,1));
	
	constant WEIGHTS: 		integer_matrix := -- weight of each connection (positive value acts as an excitatory synapse and negative acts as an inhibitory synapse
	((30,10,0),
	(20,10,0),
	(15,16,0),
	(11,21,0),
	(10,39,5));
end settings_package;

package body settings_package is
end settings_package;
