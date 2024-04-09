module Controller_TX (Data_Valid,PAR_EN,Ser_Done,Mux_sel,Ser_En,busy,clk,rst);
	
	//here we will do FSM of UART

	localparam IDLE=3'b000;
	localparam START=3'b001;
	localparam DATA=3'b010;
	localparam PARITY=3'b011;
	localparam STOP=3'b100;

	input Data_Valid,Ser_Done;
	input PAR_EN;
	input clk,rst;
	output reg [2:0] Mux_sel;
	output reg Ser_En,busy;

	reg [2:0] cs,ns;

	 


	///////////////////// First FSM //////////////////////////////////////////////////////////

	//ns logic
	always @ (*) begin
		case (cs)
			IDLE: begin
				if(Data_Valid)
					ns=START;
				else
					ns=IDLE;	
			end
			START: begin
				ns=DATA;
			end
			DATA: begin
				if(Ser_Done && PAR_EN)
					ns=PARITY;
				else if (Ser_Done && ! PAR_EN )
					ns=STOP;
				else
					ns=DATA;	
			end
			PARITY: begin
				ns=STOP;
			end 
			STOP: begin
				if (Data_Valid)
					ns=START; //constraint that i can send two frames
				else 
					ns=IDLE; 	
			end
			default: begin
				ns=IDLE;
			end
		endcase  
	end

	//////// state memory

	always @ (posedge clk or negedge rst) begin
		if (! rst)
			cs<=IDLE;
		else
			cs<=ns;	
	end

	//////////// output logic
	always @ (*) begin

		Mux_sel=0;
		Ser_En=0;
		busy=0; //to avoid latch

		case (cs)
			IDLE: begin
				Mux_sel='d4; // to make Tx_out=1 always
				Ser_En=0;
				busy=0;
			end
			START: begin
				Mux_sel='d0;
				Ser_En=1;
				busy=1;
			end
			DATA: begin
				Mux_sel='d2;
				Ser_En=1;
				busy=1;

			end
			PARITY: begin
				Mux_sel='d3;
				Ser_En=0;
				busy=1;
			end 
			STOP: begin
				Mux_sel='d1;
				Ser_En=0;
				busy=1;
			end
			default: begin
				Mux_sel=0;
				Ser_En=0;
				busy=0;
			end
		endcase  
	end

endmodule