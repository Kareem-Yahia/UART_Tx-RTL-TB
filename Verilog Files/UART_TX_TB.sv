`timescale 1us/10ns
module UART_TX_TB ();

	typedef enum {IDLE,START,DATA,PARITY,STOP} state_e;
	state_e cs,ns;

	/////////////// parameters //////////////////////////////////////	
	parameter clk_period=8; //paramter can't take float by this defination
	parameter ODD_PARITY=1;
	parameter EVEN_PARITY=0;
	integer i;
	integer end_count=0;

	integer correct_count=0;
	integer error_count=0;
	integer correct_count_Parity=0;
	integer error_count_Parity=0;
	////////////////////////////////////////////////////////////////////////////////////

	reg [7:0] P_DATA;
	reg Data_Valid;
	reg clk,rst;
	reg PAR_TYP,PAR_EN;
	wire  TX_OUT,busy;

	//just array for verification
	reg [10:0] Frame_Collected=0;
	reg Parity_Ex=0;

	UART_TX  UART(P_DATA,Data_Valid,PAR_TYP,PAR_EN,TX_OUT,busy,clk,rst);

	assign cs=state_e'(UART.Controller_TX.cs);
	assign ns=state_e'(UART.Controller_TX.ns);

	//////////////////////////////////////////////////////////////////////////////////
	initial begin
		clk=0;
		forever
		#(8.68/2) clk=~clk;
	end

	///////////////////////////////////////////////////////////////////////////////////////


	task do_operation (input PAR_EN_T,input PAR_TYP_T ,input [7:0] P_DATA_T,input P_Data_change=0);
		begin
			PAR_TYP=PAR_TYP_T;
			PAR_EN= PAR_EN_T;
			Data_Valid=1'b1;
			P_DATA=P_DATA_T;
			@(negedge clk) Data_Valid=1'b0;

			Self_Checking_Algorithm(P_Data_change);

		end
	endtask


	task Self_Checking_Algorithm(input P_Data_change);
		begin
			if (PAR_TYP== EVEN_PARITY)
				Parity_Ex=^(P_DATA);
			else
				Parity_Ex=~(^(P_DATA));

			if (PAR_EN)
				end_count=11;
			else
				end_count=10;

			//Here We Collect Frame

			Frame_Collected=0;
			Frame_Collected[0]=TX_OUT;

			for(i=1;i<end_count;i=i+1) begin
				@(negedge clk)
				Frame_Collected[i]=TX_OUT;

				if (P_Data_change)
					P_DATA=$random;

			end

		end
	endtask

	task check_result (input [7:0] P_DATA_T);

		begin
			if(Frame_Collected[8:1] != P_DATA_T) begin
				$display("ERROR_Data: time=%0t PAR_EN=%b P_DATA=%d ---> Frame_Collected = %0b , Data=%d \n",$time ,PAR_EN,P_DATA_T,Frame_Collected,Frame_Collected[8:1]);
				error_count=error_count+1;
			end
			else begin
				$display("Done_Data: time=%0t PAR_EN=%b P_DATA=%d ---> Frame_Collected = %0b , Data=%d \n",$time ,PAR_EN,P_DATA_T,Frame_Collected,Frame_Collected[8:1]);
				correct_count=correct_count+1;
			end


			if (PAR_EN) begin
				check_Parity();
			end

		end
	endtask

	task check_Parity();
		begin
			if(Frame_Collected[9] != Parity_Ex) begin
				$display("ERROR_Parity: time=%0t ---> Parity=%b but ----> Parity_Ex=%b \n ",$time ,Frame_Collected[9],Parity_Ex);
				error_count_Parity=error_count_Parity+1;
			end
			else begin
				$display("Done_Parity: time=%0t ---> Parity=%b Also ----> Parity_Ex=%b \n ",$time ,Frame_Collected[9],Parity_Ex);
				correct_count_Parity=correct_count_Parity+1;
			end
		end	
	endtask

	task initialize ();
		P_DATA=0;
		Data_Valid=0;
		PAR_TYP=0;
		PAR_EN=0;
	endtask

	task reset();
		rst=0;
		@(negedge clk) rst=1;
	endtask

	//We will run different Test Cases
	initial begin
		initialize();
		reset();

		do_operation(1,EVEN_PARITY,'d10);
		check_result('d10);

		// delay 2 cycles to come back to IDLE 
		repeat(2) @(negedge clk);

		do_operation(0,ODD_PARITY,'d8);
		check_result('d8);

		// delay 2 cycles to come back to IDLE 
		repeat(2) @(negedge clk);

		do_operation(1,EVEN_PARITY,'d5);
		check_result('d5);

		// delay 2 cycles to come back to IDLE 
		repeat(2) @(negedge clk);

		do_operation(1,ODD_PARITY,'d22);
		check_result('d22);

		// delay 2 cycles to come back to IDLE 
		repeat(2) @(negedge clk);

		do_operation(0,EVEN_PARITY,'d11);
		check_result('d11);

		repeat(2) @(negedge clk);

		do_operation(1,EVEN_PARITY,'d9);
		check_result('d9);

		// delay 2 cycles to come back to IDLE 
		repeat(2) @(negedge clk);

		do_operation(1,ODD_PARITY,'d15);
		check_result('d15);


		// here we will make consecutive 2 frame_Collecteds
		do_operation(0,EVEN_PARITY,'d100);
		check_result('d100);


		// last case i want to check changing P_Data while operation

		repeat(2) @(negedge clk);

		do_operation(1,ODD_PARITY,'d23,1);
		check_result('d23);

		repeat(2) @(negedge clk);

		do_operation(1,EVEN_PARITY,'d12,1);
		check_result('d12);

		#2 $display("No of correct_count=%d -----> error_count=%d \n  correct_count_Parity=%d ---> error_count_Parity=%d",
			correct_count,error_count,correct_count_Parity,error_count_Parity);
		#2 $stop;
	end

endmodule