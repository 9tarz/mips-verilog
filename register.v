module register(reg1,reg2,write_reg,write_data,write,clk,read_data1,read_data2);
	input[4:0] reg1,reg2,write_reg;
	input[31:0] write_data;
	input clk,write;
	output[31:0] read_data1,read_data2;
	reg signed[31:0] r [0:31];
	reg [5:0]i;
	
	assign read_data1 = r[reg1];
	assign read_data2 = r[reg2];

	initial 
	begin
		for(i = 0 ; i < 32 ; i = i+1)
		begin
			r[i] = 32'b0;
		end
	end

	always@(posedge clk)
	begin
		if (write)
			r[write_reg] <= write_data;
	end

endmodule