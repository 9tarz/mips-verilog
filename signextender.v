module signextend(in , out);
	input[15:0] in;
	output[31:0] out;
	//assign out = (in[15])? {16'b0, in}:{16'b1, in};
	assign out = {16'b0, in};
	
endmodule