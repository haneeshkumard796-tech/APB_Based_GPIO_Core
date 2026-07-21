module IO_interface(out_pad_o, oen_padoe_o, in_pad_i, gpio_eclk, io_pad, ext_clk_pad_i);
	input [31:0]out_pad_o,oen_padoe_o;
	output [31:0]in_pad_i;
	output gpio_eclk;
	inout [31:0]io_pad;
	input ext_clk_pad_i;	
	
	assign in_pad_i = io_pad;
	assign gpio_eclk = ext_clk_pad_i;

	genvar i;
	generate
		for(i=0;i<=31;i=i+1) begin
			assign io_pad[i] = oen_padoe_o[i] ? out_pad_o[i] : 1'hz;
		end
	endgenerate
endmodule