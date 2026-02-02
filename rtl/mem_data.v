module mem_data
(
	input				clk,			//clock input
	input				cen,			//chip enable input
	input		[ 9:0]	addr,			//10bit address input
	input				wen,			//write enable input
	input		[31:0]	wdata,			//32bit write data input
	
	output		[31:0]	rdata			//32bit read data output
);
	
	reg			[31:0]	mem	[0:255];	//32bit * 256 reg array
	
	always @ (posedge clk) begin
		if (!cen) begin
			if (!wen) begin
				mem[addr[9:2]] <= wdata;
			end
		end
		else;
	end

	assign	rdata = (!cen) ? mem[addr[9:2]] : 32'hz;

endmodule
