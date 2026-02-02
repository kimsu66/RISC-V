module mem_instr
(
	input		[ 9:0]	addr,			//10bit address input
	output		[31:0]	instr			//32bit instruction output
);

	reg			[32:0]	mem	[255:0];	//32bit * 256 reg array

	initial begin
		$readmemh("memfile.dat", mem);
	end

	assign	instr	=	mem[addr[9:2]];

endmodule
