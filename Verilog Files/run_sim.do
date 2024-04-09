vlib work
vlog Controller_TX.v Parity_Calc.v Serializer.v UART_Mux.v UART_TX.v UART_TX_TB.sv +cover
vsim -voptargs=+acc work.UART_TX_TB -cover
add wave *
add wave -position insertpoint  \
sim:/UART_TX_TB/UART/Serializer/Ser_En \
sim:/UART_TX_TB/UART/Serializer/Ser_Data \
sim:/UART_TX_TB/UART/Serializer/LSR
add wave -position insertpoint  \
sim:/UART_TX_TB/UART/Serializer/Ser_Done

add wave -position insertpoint  \
sim:/UART_TX_TB/UART/Parity_Calc/Par_bit

run -all
#quit -sim


 