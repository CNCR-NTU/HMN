library ieee;
use ieee.std_logic_1164.all;
use work.utility_package.all;



package settings_package is
	constant ID: 				natural_array 	:=(1,2,3,4,5);
	constant MAX_NEURONS:	natural			:=304;
	constant SPKWIDTH:		natural			:= 8;
	constant DELAY:			natural			:=8;
	constant CONTROLBUS:		natural 			:=32;
	constant ITEMID_SIZE:	natural 			:=16;
	constant TXDELAY:			natural 			:=869;
	constant READBACKBUS:	natural			:= 32;
	constant NUM_MODELS:		natural			:= 5;
end settings_package;

package body settings_package is
end settings_package;