`timescale 1ns / 1ps

`include "adder.v"
`include "inst_rom.v"
`include "controller.v"
`include "mux.v"
`include "signextender.v"
`include "register.v"
`include "alu.v"
`include "data_memory.v"
`include "async_memory.v"
`include "serial_buf.v"


module processor
(
	input clock,
	input reset,
	input [7:0] serial_in,
	input serial_valid_in,
	input serial_ready_in,

	output serial_rden_out,
	output [7:0] serial_out,
	output serial_wren_out
);

    reg [31:0]  pc;
    wire [31:0]  pc_out;

    parameter INIT_PC = 32'h003FFFFC;

    initial pc = INIT_PC;

    adder pc_adder(.in(pc), .out(pc_out));


    always @(negedge clock or posedge reset) begin
        if (reset) begin
            pc <= INIT_PC;
        end
        else if (inst_out==32'h00000000) begin
            $finish;
        end
        else begin
            pc <= pc_out ;
        end
    end

    wire [31:0] inst_out;

    inst_rom get_inst(
        .clock(clock), 
        .reset(reset), 
        .addr_in(pc), 
        .data_out(inst_out)
     );

    wire  RegDst, MemRead, MemtoReg, MemWrite, ALUsrc, RegWrite;
    wire [5:0] ALUctrl_in;

    controller control
	(
		.opcode(inst_out[31:26]),
		.funct(inst_out[5:0]),
		.RegDst(RegDst), 
        .MemRead(MemRead), 
        .MemtoReg(MemtoReg), 
        .ALUop(ALUctrl_in), 
        .MemWrite(MemWrite),
        .ALUsrc(ALUsrc), 
        .RegWrite(RegWrite)
	);

	wire [4:0] WriteReg;

    mux5 mux_inst( 
    	.in2(inst_out[20:16]),
    	.in1(inst_out[15:11]),
    	.select(RegDst),
    	.out(WriteReg)

   	);


   	wire [31:0] ReadData1, ReadData2, WriteData;

    register regis_mod
	(
		.reg1(inst_out[25:21]),
		.reg2(inst_out[20:16]),
		.write_reg(WriteReg),
		.write_data(WriteData),
		.write(RegWrite),
		.clk(clock),
		.read_data1(ReadData1),
		.read_data2(ReadData2)
	);


	wire [31:0] extended;
	signextend extend (
        .in(inst_out[15:0]),
        .out(extended)
     );

	wire [31:0] RegtoALU;
    mux32 mux_alu(
     	.in2(ReadData2),
    	.in1(extended),
    	.select(ALUsrc),
    	.out(RegtoALU)
   	);

    wire [31:0]  ALU_out;
    wire  branch, jump; 
    alu alu_mod (
        .Func_in(ALUctrl_in), 
        .A_in(ReadData1), 
        .B_in(RegtoALU),
        .O_out(ALU_out),
        .Branch_out(branch), 
        .Jump_out(jump)
        );

    wire  [31:0]  MEM_out; 

	data_memory data_mem(

        .clock(clock),
        .reset(reset),
        .addr_in(ALU_out),
        .writedata_in(ReadData2),
        .re_in(MemRead),
        .we_in(MemWrite),
        .size_in(2'b11),
        .readdata_out(MEM_out),
        .serial_in(serial_in),
        .serial_ready_in(serial_ready_in),
        .serial_valid_in(serial_valid_in),
        .serial_out(serial_out),
        .serial_rden_out(serial_rden_out),
        .serial_wren_out(serial_wren_out)
	);

	mux32 wb(
     	.in2(ALU_out),
    	.in1(MEM_out),
    	.select(MemtoReg),
    	.out(WriteData)
   	);

endmodule