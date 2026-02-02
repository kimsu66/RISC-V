`timescale 1ns/1ps
module tb_riscv_top();

	reg			clk;
	reg			reset_n;

	parameter	clk_period	= 20;
  	
	riscv_top		RISCV_TOP
	(
		.clk		( clk		),
		.reset_n	( reset_n	)
	);

	always begin
		clk = 1'b1;
		forever begin
			#(clk_period / 2);
			clk = ~clk;
		end
	end

	initial begin
		reset_n = 1'b1; #13;
		reset_n = 1'b0; #(clk_period);
		reset_n = 1'b1;
	end

endmodule
