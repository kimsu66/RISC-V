module riscv_cpu
(
	input				clk,		//clock input
	input				reset_n,	//reset input
	input		[31:0]	i_instr,	//32bit instruction input
	input		[31:0]	rs1_data,	//32bit rs1 data input
	input		[31:0]	rs2_data,	//32bit rs2 data input
	input		[31:0]	rdata,		//32bit read data input from data memory
	
	output reg	[ 9:0]	pc,			//10bit program count output
	output		[ 9:0]	data_addr,	//10bit data memeory address output
	output				data_cen,	//data memory chip enable output
	output				data_wen,	//data memory write enable output
	output		[31:0]	wdata,		//32bit writing data output to data memory 
	output				reg_wen,	//regfile write enable output
	output		[ 4:0]	rs1,		//5bit rs1 output
	output		[ 4:0]	rs2,		//5bit rs2 output
	output		[ 4:0]	rd,			//5bit rd output
	output		[31:0]	rd_data		//32bit rd data output
);

	wire	[31:0]	instr;
	wire	[ 6:0]	opcode;
	wire	[ 6:0]	funct7;
	wire	[ 2:0]	funct3;

	wire			alu_src;

	wire	[ 4:0]	alu_ctrl;
	wire	[31:0]	alu_a;
	wire	[31:0]	alu_b;
	reg		[31:0]	alu_res;

	wire	[11:0]	imm;
	wire	[31:0]	ext_imm;
	
	wire	[1:0]	select;			// beq의 taken, jal을 판단하는 2bit wire select 추가

	//=========================================================
	//					Instruction Fetch
	//=========================================================
	always @ (posedge clk or negedge reset_n)
	begin
		if (!reset_n)	begin
			pc <= 32'd0;
		end
		else if ((select == 2'b01) || (select == 2'b10)) begin // BEQ taken, JAL
			pc <= pc + ext_imm;
		else	pc <= pc + 32'd4;
	end

	//=========================================================
	//					Instruction Decoder 
	//=========================================================
	assign instr	=	{i_instr[7:0], i_instr[15:8], i_instr[23:16], i_instr[31:24]};
	assign opcode	=	instr[ 6: 0];	
	assign funct7	=	instr[31:25];
	assign funct3	=	instr[14:12];
	assign rs1		=	instr[19:15];
	assign rs2		=	instr[24:20];
	assign rd		=	(opcode == 7'b110_0011) ? 5'dZ : // BEQ : rd is not defined
						instr[11: 7];

	assign rd_data	=	(opcode == 7'b000_0011) ? rdata : // LW
						(opcode == 7'b110_1111) ? pc + 4 : // JAL
						alu_res;

	// ALU Decoder
	assign alu_ctrl =	((opcode == 7'b011_0011) && (funct7 == 7'b000_0000) && (funct3 == 3'b000))	?	5'b0_0000 : // ADD
						((opcode == 7'b011_0011) && (funct7 == 7'b010_0000) && (funct3 == 3'b000))	?	5'b0_0001 : // SUB
						((opcode == 7'b011_0011) && (funct7 == 7'b000_0000) && (funct3 == 3'b110))	?	5'b0_0010 : // OR
						((opcode == 7'b011_0011) && (funct7 == 7'b000_0000) && (funct3 == 3'b111))	?	5'b0_0011 : // AND
						((opcode == 7'b001_0011) && (funct3 == 3'b000))  ?	5'b0_0000 : // ADDI
						((opcode == 7'b001_0011) && (funct3 == 3'b110))  ?	5'b0_0010 : // ORI
						((opcode == 7'b001_0011) && (funct3 == 3'b111))  ?	5'b0_0011 : // ANDI
						((opcode == 7'b000_0011) && (funct3 == 3'b010))  ?	5'b0_0000 : // LW
						((opcode == 7'b010_0011) && (funct3 == 3'b010))  ?	5'b0_0000 : // SW
						((opcode == 7'b110_0011) && (funct3 == 3'b000))  ?	5'b0_0100 : // BEQ
						(opcode == 7'b110_1111)  ?	5'b0_0101 : // JAL
						5'dZ;
			 			
	assign alu_a	=	rs1_data;
	assign alu_b	=	alu_src		?	ext_imm	:	rs2_data;

	// Main Decoder
	assign alu_src	=	((opcode == 7'b011_0011) || (opcode == 7'b110_0011))    ?	1'b0	:	1'b1;		//ALU result, imm calculation except for R-type
	assign reg_wen	=	((opcode == 7'b001_0011) || (opcode == 7'b000_0011) || (opcode == 7'b110_1111) || (opcode == 7'b011_0011))	?	1'b0	:	1'b1;		//RegWrite
	
	assign data_cen	=	((opcode == 7'b000_0011) || (opcode == 7'b010_0011)) ? 1'b0 : 1'b1;		//mem_data module disabled except LW, SW
	assign data_addr=	((opcode == 7'b000_0011) || (opcode == 7'b010_0011)) ? alu_res : 10'do;
	assign data_wen	=	(opcode == 7'b010_0011) ? 1'b0 : 1'bx; // data memory on -SW
	assign wdata	=	(opcode == 7'b010_0011) ? rs2_data : 32'b0;

	// Sign Extension
	assign imm		=	(opcode == 7'b010_0011) ? {instr[31:20], instr[11:7]} : // S-type SW, imm[11:0]
						(opcode == 7'b110_0001) ? {instr[31], instr[7], instr[30:25], instr[11:8]} : // B-type BEQ, imm[12:1]
						instr[31:20]; // I-type ADDI, ORI, ORI, ANDI, imm[11:0]
	assign ext_imm	=	(opcode == 7'b110_0011) ? {{19{imm[11]}}, imm, 1'b0} : // B-type BEQ
						(opcode == 7'b110_1111) ? {{10{instr[31]}}, instr[31], instr[19:12], instr[30:21], 1'b0} : // J-type JAL
						((opcode == 7'b001_0011) || (opcode == 7'b010_0011)) ? {{20{imm[11]}}, imm} : // I-type, S-type
						32'b0; // R-type

	//=========================================================
	//						Execution
	//=========================================================
	// ALU
	always @ (alu_ctrl or alu_a or alu_b) begin
		case(alu_ctrl)
			5'b0_0000	:	alu_res = alu_a + alu_b; // ADD, ADDI, LW, SW
			5'b0_0001   :   alu_res = alu_a - alu_b; // SUB
			5'b0_0010   :   alu_res = alu_a | alu_b; // OR, ORI
			5'b0_0011   :   alu_res = alu_a & alu_b; // AND, ANDI
			5'b0_0100   :   alu_res = alu_a - alu_b; // BEQ
			default		:	alu_res = 32'd0;
		endcase
	end

	assign select = ((alu_ctrl == 5'b0_0100) && (alu_res == 0)) ? 2'b01 : // BEQ taken
					(opcode == 7'b110_1111) ? 2'b10 : // JAL
					2'b00;
	

endmodule
