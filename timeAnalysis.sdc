create_clock -period 50MHz  [get_ports CLK50]
create_clock -period 0.1152MHZ [get_clocks clock_115_2kHz]
derive_pll_clocks
derive_clock_uncertainty