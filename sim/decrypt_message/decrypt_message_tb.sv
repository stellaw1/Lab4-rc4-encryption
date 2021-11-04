module decrypt_message_tb();
	logic clk, start;
	logic [7:0] s_read_data, rom_read_data;
	logic s_write, ram_write;
	logic [7:0] s_address;
	logic [4:0] ram_address, rom_address;
	logic [7:0] s_write_data, ram_write_data;
	logic finish;

	decrypt_message dut (
		.clk(clk),
		.start(start),
		.s_read_data(s_read_data),
		.rom_read_data(rom_read_data),
		.s_write(s_write),
		.ram_write(ram_write),
		.s_address(s_address),
		.ram_address(ram_address),
		.rom_address(rom_address),
		.s_write_data(s_write_data),
		.ram_write_data(ram_write_data),
		.finish(finish)
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
		start = 1'b1;
		s_read_data = 8'b10101010;
		rom_read_data = 8'b01010101;
		#400;
	end
endmodule