module brute_force
	(
		input logic clk,
		input logic start,
		input logic init_finish,
		input logic shuffle_finish, 
		input logic check_finish
		input logic check_valid,
		input logic [31:0] data,
		output logic init_start,
		output logic shuffle_start,
		output logic check_start,
		output logic finish,
		output logic found,
		output logic [23:0] secret_key
	);

	parameter max_secret = 24'b00111111_11111111_11111111;

	parameter WAITING = 8'b000_00000;
	parameter INIT = 8'b001_00001;
	parameter DECRYPT = 8'b010_00010;
	parameter INCREMENT = 8'b011_00000;
	parameter CHECK_VAL = 8'b100_00100;
	parameter READ_CHECK = 8'b101_00000;
	parameter FOUND = 8'b110_11000;
	parameter NOT_FOUND = 8'b111_01000;

	reg [23:0] secret = 24'b0;
	reg [2:0] state = WAITING;

	always_ff@(posedge clk)
	begin
		case (state)
			WAITING:
			begin
				if (start)
					state <= INIT;
			end
			INIT:
			begin
				if (init_finish)
					state <= DECRYPT;
			end
			DECRYPT:
			begin
				if (shuffle_finish)
					state <= CHECK_VAL;
			end
			CHECK_VAL:
			begin
				if (check_finish) begin
					if (check_valid)
						state <= FOUND;
					else if (secret == max_secret)
						state <= NOT_FOUND;
					else
						state <= INCREMENT;
				end
			end
			INCREMENT:
			begin
				secret <= secret + 24'b1;
				state <= INIT;
			end
		endcase
	end

	assign init_start = state[0];
	assign shuffle_start = state[1]
	assign check_start = state[2];
	assign finish = state[3];
	assign found = state[4];

	assign secret_key = secret;
endmodule