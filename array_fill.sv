module array_fill 
	(
		input logic clk,
		input logic start,
		output logic finish,
		output logic [7:0] data
	);

	parameter WAITING  = 2'b00;
	parameter COUNTING = 2'b01;
	parameter FINISHED = 2'b10;

	reg [7:0] counter = 8'b0;
	reg [1:0] state = WAITING;
	
	always_ff@(posedge clk)
	begin
		case (state)
			WAITING:
			begin
				if (start)
					state <= COUNTING;
			end
			COUNTING:
			begin
				if (counter == 8'd255)
					state <= FINISHED;
				else
					counter <= counter + 8'b1;
			end
			FINISHED:
				state <= FINISHED;
			default:
				state <= FINISHED;
		endcase
	end

	assign finish = state[1];
	assign data = counter;
endmodule