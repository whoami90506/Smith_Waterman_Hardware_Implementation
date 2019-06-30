# Import Design
read_file -format verilog  src/SmithWaterman.v

current_design [get_designs SmithWaterman]
link

source -echo -verbose ./syn/syn_DC.sdc

# Compile Design
current_design [get_designs SmithWaterman]

set high_fanout_net_threshold 0

uniquify
set_fix_multiple_port_nets -all -buffer_constants [get_designs *]

compile_ultra 
#compile -map_effort compile_ultra
# Output Design
current_design [get_designs SmithWaterman]

remove_unconnected_ports -blast_buses [get_cells -hierarchical *]

set bus_inference_style {%s[%d]}
set bus_naming_style {%s[%d]}
set hdlout_internal_busses true
change_names -hierarchy -rule verilog
define_name_rules name_rule -allowed {a-z A-Z 0-9 _} -max_length 255 -type cell
define_name_rules name_rule -allowed {a-z A-Z 0-9 _[]} -max_length 255 -type net
define_name_rules name_rule -map {{"\\*cell\\*" "cell"}}
define_name_rules name_rule -case_insensitive
change_names -hierarchy -rules name_rule

write -format ddc     -hierarchy -output "syn/SmithWaterman_syn.ddc"
write -format verilog -hierarchy -output "syn/SmithWaterman_syn.v"
write_sdf -version 2.1 -context verilog syn/SmithWaterman_syn.sdf
#write_sdc core_syn.sdc
report_timing > syn/timing.report
report_area > syn/area.report
report_power > syn/power.report
report_timing

quit