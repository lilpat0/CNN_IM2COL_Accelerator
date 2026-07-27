# ==============================================================================
# Synopsys Design Constraints (SDC) for CNN Accelerator Top Module
# Target PDK: SkyWater 130nm (sky130_fd_sc_hd)
# Target Frequency: 100 MHz (10.0 ns Period)
# ==============================================================================

# 1. Primary Clock Definition
create_clock -name clk -period 10.000 [get_ports clk]

# 2. Clock Uncertainty, Jitter & Transition
# Accounts for clock distribution skew, jitter, and edge transition speed
set_clock_uncertainty 0.250 [get_clocks clk]
set_clock_transition 0.150 [get_clocks clk]

# 3. Input Delays
# Assume external driving logic uses ~20% of the clock period (2.0ns)
set_input_delay -clock clk 2.000 [all_inputs -no_clocks]

# 4. Output Delays
# Budget ~20% of the clock period (2.0ns) for downstream setup constraints
set_output_delay -clock clk 2.000 [all_outputs]

# 5. Driving Cell Definition
# Standard high-density buffer to model input drive strength for synthesis
set_driving_cell -lib_cell sky130_fd_sc_hd__buf_2 [all_inputs -no_clocks]

# 6. Output Load Definition
# Standard external capacitive load (33 fF) on all output pins
set_load 0.033 [all_outputs]

# 7. Asynchronous Reset Constraints
# Treat 'rst' as a critical path input with minimal arrival delay
set_input_delay -clock clk 1.000 [get_ports rst]