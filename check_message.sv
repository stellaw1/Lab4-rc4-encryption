module check_message
	(
		input logic clk, start,
		input logic [7:0] read_character,
		output logic finish, valid,
		output logic [4:0] address
	);

	parameter WAITING    = 5'b000_00;
	parameter CHECK_READ = 5'b001_00;
	parameter READ_WAIT  = 5'b010_00;
	parameter READ_NEXT  = 5'b011_00;
	parameter VALID      = 5'b100_11;
	parameter INVALID    = 5'b101_01;

	reg [4:0] state = WAITING;

	reg [4:0] addr = 5'b0;
	always_ff@(posedge clk)
	begin
		case (state)
			WAITING:
			begin
				if (start)
					addr <= 5'b0;
					state <= READ_WAIT;
			end
			READ_WAIT:
			begin
				state <= CHECK_READ;
			end
			CHECK_READ:
			begin
				if ((read_character < 8'd97 || read_character > 8'd122) && read_character != 8'd32)
					state <= INVALID;
				else
					state <= READ_NEXT;
			end
			READ_NEXT:
			begin
				if (addr == 5'b11111)
					state <= VALID;
				else begin
					addr <= addr + 5'b1;
					state <= READ_WAIT;
				end
			end
			VALID:
			begin
				state <= WAITING;
			end
			INVALID:
			begin
				state <= WAITING;
			end
		endcase
	end

	assign finish = state[0];
	assign valid = state[1];

	assign address = addr;
endmodule