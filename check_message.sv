module check_message
	(
		input logic clk, start,
		input logic [7:0] read_character,
		output logic finish, valid,
		output logic [4:0] address
	);

	parameter WAITING    = 5'b000_00;
	parameter CHECK_READ = 5'b001_00;
	parameter READ_NEXT  = 5'b010_00;
	parameter VALID      = 5'b011_11;
	parameter INVALID    = 5'b100_10;

	reg [4:0] addr = 5'b0;
	always_ff@(posedge clk)
	begin
		case (state)
			WAITING:
				if (start)
					state <= CHECK_READ;
			CHECK_READ:
				if ((read_character < 8'd97 || read_character > 8'd122) && read_character != 8'd32)
					state <= INVALID;
				else
					state <= READ_NEXT;
			READ_NEXT:
				if (addr == 4'b1111)
					state <= VALID;
				else
					addr <= addr + 5'b1;
					state <= CHECK_READ;
			VALID:
				state <= WAITING;
			INVALID:
				state <= WAITING;
		endcase
	end

	assign finish = state[0];
	assign valid = state[1];

endmodule