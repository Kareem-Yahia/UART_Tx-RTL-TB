module UART_Mux (Mux_Sel,Start_Bit,Stop_Bit,ser_data,Par_Bit,No_Trans,TX_OUT);

	input [2:0] Mux_Sel;
	input Start_Bit,Stop_Bit,ser_data,Par_Bit,No_Trans;
	output reg TX_OUT;

	always @(*) begin

		case(Mux_Sel)
			3'd0: TX_OUT= Start_Bit;
			3'd1: TX_OUT= Stop_Bit;
			3'd2: TX_OUT= ser_data;
			3'd3: TX_OUT= Par_Bit;
			3'd4: TX_OUT= No_Trans;
			default: TX_OUT= 0; //I made case for No transmission and made default 0 as if it is always  1 no optimization
								//will happen to mux 
		endcase

	end
endmodule