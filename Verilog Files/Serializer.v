module Serializer (P_Data,Data_Valid,Ser_En,clk,rst,Ser_Done,Ser_Data) ;
	
	input [7:0] P_Data;
	input Data_Valid;
	input Ser_En;
	input clk,rst;

		//note output should be registerd also 
	output reg Ser_Done;
	output reg Ser_Data;

	reg [7:0] LSR; //shift register
	reg [2:0] Counter;

	always @ (posedge clk or negedge rst) begin
		if(!rst) begin
			LSR<=0;
			Ser_Data<=0;
			Counter<=0;
			Ser_Done<=0;
		end
		else begin
			if(Data_Valid)
				LSR <= P_Data;
			else if (Ser_En && ! Ser_Done) begin
				
				{LSR[6:0],Ser_Data}<=LSR;
				LSR[7]<=1'b0;
				Counter<=Counter+1'b1;

				if (Counter == 'd7)
					Ser_Done<=1'b1; // it will be high at clk no 8 and for just 1 clk
			end
			else begin
				Counter<=0;
				Ser_Done<=0;
			end	
		end


	end


endmodule