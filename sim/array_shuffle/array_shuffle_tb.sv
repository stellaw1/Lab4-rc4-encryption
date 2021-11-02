module array_shuffle_tb();
	logic clk, start, finish, mem_write;
	logic [7:0] data_in, data_out, addr_out;
	logic [9:0] sw_in;

	array_shuffle dut(
		.clk(clk),
		.start(start),
		.data_in(data_in),
		.sw_in(sw_in),
		.finish(finish),
		.mem_write(mem_write),
		.addr_out(addr_out),
		.data_out(data_out)
	);

	initial begin
		forever begin
			clk = 0;
			#10;
			clk = 1;
			#10;
		end
	end

	initial begin
		start = 1'b0;
		data_in = 8'b0110_1111;
		sw_in = 10'b10_0100_1001;
		#20;

		start = 1'b1;

		#31000;
    	$stop;
	end
endmodule