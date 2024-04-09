module Parity_Calc (P_DATA,Data_Valid,Par_Type,Par_En,Par_bit,clk,rst);

	input [7:0] P_DATA;
	input Data_Valid;
	input Par_Type;
	input Par_En;
	input clk,rst; 
	output reg Par_bit;

	always @ (posedge clk or negedge rst) begin
		if(! rst)
			Par_bit<=0;
		else begin
			if (Par_En) begin
				if(Data_Valid) begin
					if (Par_Type==0)
						Par_bit=^P_DATA;
					else
						Par_bit=~(^P_DATA);	
				end
			end
			else
			Par_bit=1'b0;	
		end	
	end
	
endmodule