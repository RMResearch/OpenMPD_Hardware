# Clock
create_clock -name clk -period 20.000 [get_ports {clk}]
derive_pll_clocks
derive_clock_uncertainty

# False Path
set_false_path -from [get_clocks {clk}] -to [get_clocks {inst_Masterclock|altpll_component|auto_generated|pll1|clk[0]}]
set_false_path -from [get_clocks {inst_Masterclock|altpll_component|auto_generated|pll1|clk[0]}] -to [get_clocks {clk}]
