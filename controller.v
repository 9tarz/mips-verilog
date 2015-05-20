module controller #(parameter W = 6)
(
	input [W-1:0] opcode,
	input [W-1:0] funct,

	output reg RegDst,
	output reg MemRead,
	output reg MemtoReg,
	output reg MemWrite,
	output reg ALUsrc,
	output reg RegWrite,

	output reg[W-1:0] ALUop
);

    parameter R_TYPE = 6'd0;
    parameter LW = 6'b100011;
	parameter SW = 6'b101011;

	parameter ADD = 6'b100000;
	parameter ADDU = 6'b100001;
	parameter SUB = 6'b100010;
	parameter SUBU = 6'b100011;
	parameter AND = 6'b100100;
	parameter OR = 6'b100101;
	parameter NOR = 6'b100111;
	parameter SLT = 6'b101010;
	parameter SLTU = 6'b101001;

	parameter ADDI = 6'b001000;
    parameter ANDI = 6'b001100;
    parameter ORI = 6'b001101;
    parameter XORI = 6'b001110;
    parameter SLTI = 6'b001010;
    parameter SLTIU = 6'b001001;

	always @ (*)
		begin
			ALUop = 0;
			ALUsrc = 0;
			MemWrite = 0;
			MemRead = 0; 
			MemtoReg = 0; 
			RegWrite = 0;
			RegDst = 0;

	if (opcode == 0) // R Type
		begin
			RegDst = 1;
			RegWrite = 1;
			ALUsrc = 0;
			MemtoReg = 0;
	        ALUop = funct;
		end

	// I Type
	else
		begin
			MemtoReg = 0;
			RegDst = 0;
			RegWrite = 1;
			ALUsrc = 1;
            MemRead     = 0; 
            MemWrite    = 0;

		case (opcode)
			ANDI:	ALUop = AND;
			ORI:	ALUop = OR;
			SLTI:	ALUop = SLT;
			ADDI:	ALUop = ADD;
			SLTIU:	ALUop = SLTU;

			LW:	begin
						ALUop = ADD;
						MemtoReg = 1;
						MemRead = 1;

						end
			SW:  begin
						ALUop = ADD;
						MemWrite = 1;
						MemtoReg = 1;
						RegWrite = 0;
						end
		endcase
		end

	end
endmodule