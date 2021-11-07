module decrypt_message
	(
		input logic clk, reset,
		input logic start,
		input logic [7:0] s_read_data,
		input logic [7:0] rom_read_data,
		output logic s_write,
		output logic ram_write,
		output logic [7:0] s_address,
		output logic [4:0] ram_address,
		output logic [4:0] rom_address,
		output logic [7:0] s_write_data,
		output logic [7:0] ram_write_data,
		output logic finish
	);

	parameter WAITING        = 15'b00000_0000000000;
	parameter INCREMENT_I    = 15'b00001_0000000000;
	parameter READ_I         = 15'b00010_0010001000;
	parameter READ_I_WAIT    = 15'b00011_0010001000;
	parameter COMPUTE_J      = 15'b00100_0000000000;
	parameter READ_J         = 15'b00101_0100010000;
	parameter READ_J_WAIT    = 15'b00110_0100010000;
	parameter WRITE_J        = 15'b00111_0010000001;
	parameter WRITE_J_WAIT   = 15'b01000_0010000001;
	parameter WRITE_I        = 15'b01001_0100000001;
	parameter WRITE_I_WAIT   = 15'b01010_0100000001;
	parameter COMPUTE_SUM    = 15'b01011_0000000000;
	parameter READ_SUM       = 15'b01100_1000100000;
	parameter READ_SUM_WAIT  = 15'b01101_1000100000;
	parameter READ_K         = 15'b01110_0001000000;
	parameter READ_K_WAIT    = 15'b01111_0001000000;
	parameter COMPUTE_OUTPUT = 15'b10000_0000000000;
	parameter WRITE_OUTPUT   = 15'b10001_0000000010;
	parameter INCREMENT_K    = 15'b10010_0000000000;
	parameter DECRYPTED      = 15'b10011_0000000100;

	reg [14:0] state = WAITING;

	reg [7:0] i = 8'b0;
	reg [7:0] j = 8'b0;
	reg [4:0] k = 5'b0;

	reg [7:0] f = 8'b0;
	reg [7:0] si = 8'b0;
	reg [7:0] sj = 8'b0;
	reg [7:0] romk = 8'b0;

	logic en_si, en_sj, en_f, en_k;

	always_ff@(posedge clk)
	begin
		case (state)
			WAITING:
			begin
				if (reset) begin
					i <= 8'b0;
					j <= 8'b0;
					k <= 5'b0;
				end
				else if (start)
					state <= INCREMENT_I;
			end
			INCREMENT_I:
			begin
				i <= i + 8'b1;
				state <= READ_I;
			end
			READ_I:
			begin
				state <= READ_I_WAIT;
			end
			READ_I_WAIT:
			begin
				state <= COMPUTE_J;
			end
			COMPUTE_J:
			begin
				j <= j + si;
				state <= READ_J;
			end
			READ_J:
			begin
				state <= READ_J_WAIT;
			end
			READ_J_WAIT:
			begin
				state <= WRITE_J;
			end
			WRITE_J:
			begin
				s_write_data <= sj;
				state <= WRITE_J_WAIT;
			end
			WRITE_J_WAIT:
			begin
				state <= WRITE_I;
			end
			WRITE_I:
			begin
				s_write_data <= si;
				state <= WRITE_I_WAIT;
			end
			WRITE_I_WAIT:
			begin
				state <= COMPUTE_SUM;
			end
			COMPUTE_SUM:
			begin
				state <= READ_SUM;
			end
			READ_SUM:
			begin
				state <= READ_SUM_WAIT;
			end
			READ_SUM_WAIT:
			begin
				state <= READ_K;
			end
			READ_K:
			begin
				state <= READ_K_WAIT;
			end
			READ_K_WAIT:
			begin
				state <= COMPUTE_OUTPUT;
			end
			COMPUTE_OUTPUT:
			begin
				ram_write_data <= f ^ romk;
				state <= WRITE_OUTPUT;
			end
			WRITE_OUTPUT:
			begin
				state <= INCREMENT_K;
			end
			INCREMENT_K:
			begin
				if (k == 5'd31)
					state <= DECRYPTED;
				else
				begin
					k <= k + 5'b1;
					state <= INCREMENT_I;
				end
			end
			DECRYPTED:
			begin
				state <= WAITING;
			end
		endcase
	end

	always_ff@(posedge clk)
	begin
		if (en_si)
			si <= s_read_data;
	end

	always_ff@(posedge clk)
	begin
		if (en_sj)
			sj <= s_read_data;
	end

	always_ff@(posedge clk)
	begin
		if (en_f)
			f <= s_read_data;
	end

	always_ff@(posedge clk)
	begin
		if (en_k)
			romk <= rom_read_data;
	end

	assign ram_address = k;
	assign rom_address = k;

	logic [7:0] addr_i, addr_j, addr_sum;

	assign s_address = addr_i
		? i
		: addr_j
			? j
			: si + sj;

	assign s_write = state[0];
	assign ram_write = state[1];
	assign finish = state[2];
	assign en_si = state[3];
	assign en_sj = state[4];
	assign en_f = state[5];
	assign en_k = state[6];
	assign addr_i = state[7];
	assign addr_j = state[8];
	assign addr_sum = state[9];
endmodule