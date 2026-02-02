module regfile
(
	input				clk,		//clock input
	input				reg_wen,	//regfile write enable input
	input		[ 4:0]	rs1,		//5bit rs1 input
	input		[ 4:0]	rs2,		//5bit rs2 input
	input		[ 4:0]	rd,			//5bit rd input
	input		[31:0]	rd_data,	//32bit rd data input
	
	output		[31:0]	rs1_data,	//32bit rs1 data output
	output		[31:0]	rs2_data	//32bit rs2 data output
);

	reg			[31:0]	rf[31:0];	//register file
	
	assign	rs1_data	=	(rs1 != 5'd0)	?	rf[rs1]	:	32'd0;
	assign	rs2_data	=	(rs2 != 5'd0)	?	rf[rs2]	:	32'd0;

	always @ (posedge clk) begin
		if (!reg_wen) begin
			rf[rd]	<=	rd_data;
		end
		else;
	end

endmodule
