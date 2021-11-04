module decrypt_message
	(
		input logic clk,
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

	parameter WAITING        = 11'b0000_0000000;
	parameter INCREMENT_I    = 11'b0001_0000000;
	parameter READ_I         = 11'b0010_0001000;
	parameter COMPUTE_J      = 11'b0011_0000000;
	parameter READ_J         = 11'b0100_0010000;
	parameter WRITE_J        = 11'b0101_0000001;
	parameter WRITE_I        = 11'b0110_0000001;
	parameter COMPUTE_SUM    = 11'b0111_0000000;
	parameter READ_SUM       = 11'b1000_0100000;
	parameter READ_K         = 11'b1001_1000000;
	parameter COMPUTE_OUTPUT = 11'b1010_0000000;
	parameter WRITE_OUTPUT   = 11'b1011_0000010;
	parameter INCREMENT_K    = 11'b1100_0000000;
	parameter DECRYPTED      = 11'b1101_0000100;

	reg [10:0] state = WAITING;

	reg [7:0] i = 8'b0;
	reg [7:0] j = 8'b0;
	reg [4:0] k = 5'b0;

	reg [7:0] sum = 8'b0;

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
				if (start)
					state <= INCREMENT_I;
			end
			INCREMENT_I:
			begin
				i <= i + 8'b1;
				s_address <= i;
				state <= READ_I;
			end
			READ_I:
			begin
				state <= COMPUTE_J;
			end
			COMPUTE_J:
			begin
				j <= j + si;
				s_address <= j;
				state <= READ_J;
			end
			READ_J:
			begin
				s_write_data <= si;
				s_address <= j;
				state <= WRITE_J;
			end
			WRITE_J:
			begin
				s_write_data <= sj;
				s_address <= i;
				state <= WRITE_I;
			end
			WRITE_I:
			begin
				state <= COMPUTE_SUM;
			end
			COMPUTE_SUM:
			begin
				s_address <= si + sj;
				state <= READ_SUM;
			end
			READ_SUM:
			begin
				state <= READ_K;
			end
			READ_K:
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
					k <= k + 1;
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

	assign s_write = state[0];
	assign ram_write = state[1];
	assign finish = state[2];
	assign en_si = state[3];
	assign en_sj = state[4];
	assign en_f = state[5];
	assign en_k = state[6];
endmodule