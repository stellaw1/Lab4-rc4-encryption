module array_shuffle
	(
		input logic clk,
		input logic start,
		input logic [7:0] data_in,
		input logic [9:0] sw_in,
		output logic finish,
		output logic mem_write,
		output logic [7:0] addr_out
		output logic [7:0] data_out
	);

	// FSM states
	reg [6:0] state = waiting;

	parameter WAITING = 6'b000_0000;
	parameter COUNTING = 6'b001_0000;
	parameter READI = 6'b010_0000;
	parameter CALCJ = 6'b011_0010;
	parameter READJ = 6'b100_1000;
	parameter WRITEJ = 6'b110_1001;
	parameter WRITEI = 6'b101_0001;
	parameter FINISH = 6'b111_0100;

	// variables
	reg [7:0] counter = 8'b0;
	reg [7:0] j = 8'b0;
	reg [7:0] secret_key [2:0];
	reg [1:0] secret_key_index;
	logic en_j, addr_j;
	
	// FSM
	always_ff @(posedge clk)
	begin
		case (state)
			WAITING:
			begin
				if (start)
					state <= COUNTING;
				else
					state <= WAITING;
			end
			COUNTING:
			begin
				if (counter == 8'd255)
					state <= FINISH;
				else
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
				state <= COUNTING;
			FINISH:
				state <= FINISH;
			default:
				state <= FINISH;
		endcase
	end

	// DFF storing j value
	always_ff @(posedge clk)
	begin
		if (en_j) j <= j + data_in + secret_key[secret_key_index];
		else j <= j;
	end

	assign addr_out = addr_j ? j : counter;

	// FSM outputs
	assign addr_j = state[3];
	assign finish = state[2];
	assign en_j = state[1];
	assign mem_write = state[0];

	// init secret_key array
	assign secret_key[0] = 8'b0;
	assign secret_key[1] = {6'b0, sw_in[9:8]};
	assign secret_key[2] = sw_in[7:0];
	assign secret_key_index = counter % 3;
endmodule