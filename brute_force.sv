module brute_force
	(
		input logic clk,
		input logic start,
		input logic init_finish,
		input logic shuffle_finish,
		input logic decrypt_finish,
		input logic check_finish,
		input logic check_valid,
		output logic init_start,
		output logic shuffle_start,
		output logic decrypt_start,
		output logic check_start,
		output logic finish,
		output logic found,
		output logic [23:0] secret_key
	);

	parameter max_secret = 24'b00111111_11111111_11111111;

	parameter WAITING    = 10'b0000_000000;
	parameter INIT       = 10'b0001_000001;
	parameter SHUFFLE    = 10'b0010_000010;
	parameter DECRYPT    = 10'b0011_000100;
	parameter CHECK_VAL  = 10'b0100_001000;
	parameter INCREMENT  = 10'b0101_000000;
	parameter READ_CHECK = 10'b0110_000000;
	parameter FOUND      = 10'b0111_110000;
	parameter NOT_FOUND  = 10'b1000_010000;

	reg [23:0] secret = 24'b0;
	reg [9:0] state = WAITING;

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
			SHUFFLE:
			begin
				if (shuffle_finish)
					state <= DECRYPT;
			end
			DECRYPT:
			begin
				if (decrypt_finish)
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
	assign shuffle_start = state[1];
	assign decrypt_start = state[2];
	assign check_start = state[3];
	assign finish = state[4];
	assign found = state[5];

	assign secret_key = secret;
endmodule