module array_shuffle
	(
		input logic clk,
		input logic start,
		input logic [7:0] data_in,
		input logic [9:0] sw_in,
		output logic finish,
		output logic mem_write,
		output logic [7:0] addr_out,
		output logic [7:0] data_out
	);

	// FSM states
	parameter WAITING = 9'b000_000_000;
	parameter COUNTING = 9'b001_000_000;
	parameter READI = 9'b010_000_010;
	parameter CALCJ = 9'b011_000_100;
	parameter READJ = 9'b100_001_001;
	parameter WRITEJ = 9'b101_011_000;
	parameter WRITEI = 9'b110_010_000;
	parameter FINISH = 9'b111_100_000;
	
	reg [8:0] state = WAITING;

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
				state <= CALCJ;
			CALCJ:
				state <= READJ;
			READJ:
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
				state <= FINISH;
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
	assign secret_key[0] = 8'b0;
	assign secret_key[1] = {6'b0, sw_in[9:8]};
	assign secret_key[2] = sw_in[7:0];
	assign secret_key_index = counter % 3;
endmodule