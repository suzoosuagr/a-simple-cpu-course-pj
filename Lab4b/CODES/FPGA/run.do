delete wave sim:/testbench/CLK
delete wave sim:/testbench/reset
delete wave sim:/testbench/top/hwdatas
delete wave sim:/testbench/top/haddrs
delete wave sim:/testbench/top/hwrites
delete wave sim:/testbench/top/hreadys
delete wave sim:/testbench/top/uAHBTIMER/value
delete wave sim:/testbench/top/uAHBTIMER/HADDR
delete wave sim:/testbench/top/uAHBTIMER/timer_irq
delete wave sim:/testbench/top/irq
delete wave -position end sim:/testbench/top/uAHBUART/uart_irq

add wave -position end  sim:/testbench/CLK
add wave -position end  sim:/testbench/reset
add wave -position end  sim:/testbench/top/haddrs
add wave -position end  sim:/testbench/top/hwdatas
add wave -position end  sim:/testbench/top/hwrites
add wave -position end  sim:/testbench/top/hreadys
add wave -position end  sim:/testbench/top/uAHBTIMER/value
add wave -position end  sim:/testbench/top/uAHBTIMER/HADDR
add wave -position end  sim:/testbench/top/uAHBTIMER/timer_irq
add wave -position end  sim:/testbench/top/irq
add wave -position end sim:/testbench/top/uAHBUART/uart_irq




restart
force -deposit top.clk_div 0
force -deposit testbench.top.uAHBTIMER.uprescaler16.counter 0
run 90us
force -deposit testbench.top.uAHBUART.uUART_RX.rx_done 1
run 70us
