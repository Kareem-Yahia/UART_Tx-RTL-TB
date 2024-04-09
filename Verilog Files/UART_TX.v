module UART_TX (P_DATA,Data_Valid,PAR_TYP,PAR_EN,TX_OUT,busy,clk,rst);
	

	input [7:0] P_DATA;
	input Data_Valid;
	input clk,rst;
	input PAR_TYP,PAR_EN;
	output  TX_OUT,busy;

	wire Ser_Done,Ser_En,Ser_Data,Par_bit;
	wire [2:0] Mux_sel;

	 Controller_TX Controller_TX(.Data_Valid(Data_Valid),.PAR_EN(PAR_EN),.Ser_Done(Ser_Done)
	 	,.Mux_sel(Mux_sel),.Ser_En(Ser_En),.busy(busy),.clk(clk),.rst(rst));


	 Serializer  Serializer(.P_Data(P_DATA),.Data_Valid(Data_Valid),.Ser_En(Ser_En),
	 	.clk(clk),.rst(rst),.Ser_Done(Ser_Done),.Ser_Data(Ser_Data)) ;


	 Parity_Calc Parity_Calc(.P_DATA(P_DATA),.Data_Valid(Data_Valid)
	 	,.Par_Type(PAR_TYP),.Par_En(PAR_EN),.Par_bit(Par_bit),.clk(clk),.rst(rst));


	 UART_Mux  mux(.Mux_Sel(Mux_sel),.Start_Bit(1'b0),.Stop_Bit(1'b1),
	 	.ser_data(Ser_Data),.Par_Bit(Par_bit),.No_Trans(1'b1),.TX_OUT(TX_OUT));


	


endmodule