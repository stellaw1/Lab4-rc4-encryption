module array_shuffle
	(
		input logic clk,
		input logic start,
		input logic [7:0] data_in,
		input logic [23:0] secret,
		output logic finish,
		output logic mem_write,
		output logic [7:0] addr_out,
		output logic [7:0] data_out
	);

	// FSM states
	parameter WAITING = 10'b0000_000_000;
	parameter COUNTING = 10'b0001_000_000;
	parameter READI = 10'b0010_000_010;
	parameter READI_WAIT = 10'b1010_000_010;
	parameter CALCJ = 10'b0011_000_100;
	parameter READJ = 10'b0100_001_001;
	parameter READJ_WAIT = 10'b1100_001_001;
	parameter WRITEJ = 10'b0101_011_000;
	parameter WRITEI = 10'b0110_010_000;
	parameter FINISH = 10'b0111_100_000;
	
	reg [9:0] state = WAITING;

	// variables
	reg [7:0] counter = 8'b0;
	reg [7:0] j = 8'b0;
	reg [7:0] si, sj;
	reg [7:0] secret_key [2:0];
	reg [1:0] secret_key_index;
	logic en_j, en_si, en_sj, addr_j;
	
	// FSM
	always_ff @(posedge clk)
	begin
		case (state)
			WAITING:
			begin
				if (start)
					state <= READI;
				else
					state <= WAITING;
			end
			COUNTING:
			begin
				counter <= counter + 8'b1;
				state <= READI;
			end
			READI:
				state <= READI_WAIT;
			READI_WAIT:
				state <= CALCJ;
			CALCJ:
				state <= READJ;
			READJ:
				state <= READJ_WAIT;
			READJ_WAIT:
				state <= WRITEJ;
			WRITEJ:
				state <= WRITEI;
			WRITEI:
			begin
				if (counter >= 8'b1111_1111)
					state <= FINISH;
				else 
					state <= COUNTING;
			end
			FINISH:
				state <= WAITING;
			default:
				state <= FINISH;
		endcase
	end

	// DFF storing j value
	always_ff @(posedge clk)
	begin
		if (en_j) j <= j + si + secret_key[secret_key_index];
		else j <= j;
	end

	// DFF storing s[i] value
	always_ff @(posedge clk)
	begin
		if (en_si) si <= data_in;
		else si <= si;
	end

	// DFF storing s[j] value
	always_ff @(posedge clk)
	begin
		if (en_sj) sj <= data_in;
		else sj <= sj;
	end

	assign addr_out = addr_j ? j : counter;
	assign data_out = addr_j ? si : sj;

	// FSM outputs
	assign finish = state[5];
	assign mem_write = state[4];
	assign addr_j = state[3];

	assign en_j = state[2];
	assign en_si = state[1];
	assign en_sj = state[0];


	// init secret_key array
	assign secret_key[0] = secret[23:16];
	assign secret_key[1] = secret[15:8];
	assign secret_key[2] = secret[7:0];
	assign secret_key_index = counter % 3;
endmodule