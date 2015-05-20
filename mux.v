module mux32(in1,in2,select,out);
	input[31:0] in1,in2;
	input select;
	output reg  [31:0] out;

	//assign out = (select)? in2:in1;
	always @(*)
	begin
		if (select) begin
			out <= in1;
		end
		else if (select == 0) begin
			out <= in2;
		end
	end
endmodule

module mux5(in1,in2,select,out);
	input[4:0] in1,in2;
	input select;
	output reg [4:0] out;


	//assign out = (select)? in2:in1;
	always @(*)
	begin
		if (select) begin
			out <= in1;
		end
		else if (select == 0) begin
			out <= in2;
		end
	end
endmodule