module array_fill_tb();
	logic clk, start, finish;
	logic [7:0] data;

	array_fill dut(.clk(clk), .start(start), .finish(finish), .data(data));

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
		#20;
		start = 1'b0;
		#5100;
	end
endmodule