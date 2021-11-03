module ksa (
    CLOCK_50,
    KEY,
    SW, 
    LEDR, 
    HEX0,
    HEX1,
    HEX2,
    HEX3,
    HEX4,
    HEX5
);

	//=======================================================
	//  PORT declarations
	//=======================================================
	input                       CLOCK_50;
	input            [3:0]      KEY;
	input            [9:0]      SW;
	output           [9:0]      LEDR;

	//////////// SEG7 //////////
	output           [6:0]      HEX0;
	output           [6:0]      HEX1;
	output           [6:0]      HEX2;
	output           [6:0]      HEX3;
	output           [6:0]      HEX4;
	output           [6:0]      HEX5;


	logic clk, reset_n;

	assign clk = CLOCK_50;
	assign reset_n = KEY[3];

	logic [6:0] ssOut;
	logic [3:0] nIn;

	SevenSegmentDisplayDecoder ssdd (
		.ssOut(ssOut),
		.nIn(nIn)
	);

	logic mem_write;
	logic [7:0] mem_addr;
	logic [7:0] mem_data_in;
	logic [7:0] mem_data_out;

	logic init_start, init_finish; 
	logic [7:0] init_data_out;

	array_fill init_s_array (
		.clk(clk),
		.start(init_start),
		.finish(init_finish),
		.data(init_data_out)
	);

	logic shuffle_start, shuffle_finish, shuffle_wren;
	logic [7:0] shuffle_data_out, shuffle_addr_out;

	array_shuffle shuffle_s_array (
		.clk(clk),
		.start(shuffle_start),
		.data_in(mem_data_out),
		.secret(secret),
		.finish(shuffle_finish),
		.mem_write(shuffle_wren),
		.addr_out(shuffle_addr_out),
		.data_out(shuffle_data_out)
	);

	assign mem_write = init_start
		? 1'b1 
		: shuffle_start
			? shuffle_wren
			: 1'b0;
	assign mem_addr = init_start
		? init_data_out 
		: shuffle_start 
			? shuffle_addr_out
			: check_addr;
	assign mem_data_in = init_start
		? init_data_out,
		: shuffle_start
			? shuffle_data_out
			: 8'b0;

	s_memory mem (
		.address(mem_addr),
		.clock(clk),
		.data(mem_data_in),
		.wren(mem_write),
		.q(mem_data_out)
	);

	logic [23:0] secret;
	logic decrypt_finish, check_start, check_finish, message_found, check_valid;
	logic [31:0] encrypted_message;
	logic [7:0] check_addr;

	check_message test_decrypt (
		.clk(clk),
		.start(check_start),
		.read_character(mem_data_out),
		.finish(check_finish),
		.valid(check_valid),
		.address(check_addr)
	);

	brute_force decrypt (
		.clk(clk),
		.start(reset_n),
		.init_finish(init_finish),
		.shuffle_finish(shuffle_finish),
		.check_finish(check_finish),
		.check_valid(check_valid),
		.data(encrypted_message),
		.init_start(init_start),
		.shuffle_start(shuffle_start),
		.check_start(check_start),
		.finish(decrypt_finish),
		.found(message_found),
		.secret_key(secret)
	);


endmodule
