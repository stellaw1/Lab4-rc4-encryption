module array_fill 
	(
		input logic clk,
		input logic start,
		output logic finish,
		output logic [7:0] data
	);

	parameter waiting = 2'b00;
	parameter counting = 2'b01;
	parameter finished = 2'b10;

	reg [7:0] counter = 8'b0;
	reg [1:0] state = waiting;
	
	always_ff@(posedge clk)
	begin
		case (state)
			waiting:
			begin
				if (start)
					state <= counting;
			end
			counting:
			begin
				if (counter == 8'd255)
					state <= finished;
				else
					counter <= counter + 8'b1;
			end
			finished:
				state <= finished;
			default:
				state <= finished;
		endcase
	end

	assign finish = state[1];
	assign data = counter;
endmodule