module riscv_top
(
	input			clk,
	input			reset_n
);

	wire			data_cen;
	wire	[ 9:0]	data_addr;
	wire			data_wen;
	wire	[31:0]	wdata;
	wire	[31:0]	rdata;
	
	wire	[ 9:0]	instr_addr;
	wire	[31:0]	i_instr;

	wire			reg_wen;
	wire	[ 4:0]	rs1;
	wire	[ 4:0]	rs2;
	wire	[ 4:0]	rd;
	wire	[31:0]	rd_data;
	wire	[31:0]	rs1_data;
	wire	[31:0]	rs2_data;
	
	regfile					REGFILE
	(
		.clk				( clk			),
		.reg_wen			( reg_wen		),
		.rs1				( rs1			),
		.rs2				( rs2			),
		.rd					( rd			),
		.rd_data			( rd_data		),
		.rs1_data			( rs1_data		),
		.rs2_data			( rs2_data		)
	);

	mem_instr				MEM_INSTR
	(
		.addr				( instr_addr	),
		.instr				( i_instr		)
	);

	mem_data				MEM_DATA
	(
		.clk				( clk			),
		.cen				( data_cen		),
		.addr				( data_addr		),
		.wen				( data_wen		),
		.wdata				( wdata			),
		.rdata				( rdata			)
	);

	riscv_cpu				RISCV_CPU
	(
		.clk				( clk			),
		.reset_n			( reset_n		),
		.i_instr			( i_instr		),
		.rs1_data			( rs1_data		),
		.rs2_data			( rs2_data		),
		.rdata				( rdata			),
		.pc					( instr_addr	),
		.data_addr			( data_addr		),
		.data_cen			( data_cen		),
		.data_wen			( data_wen		),
		.wdata				( wdata			),
		.reg_wen			( reg_wen		),
		.rs1				( rs1			),
		.rs2				( rs2			),
		.rd					( rd			),
		.rd_data			( rd_data		)
	);

endmodule
