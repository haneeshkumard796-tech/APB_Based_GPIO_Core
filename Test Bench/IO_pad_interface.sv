interface IO_pad_interface(input bit clock);

	wire [31:0] io_pad;
	logic eclk;

	clocking DRV_CB@(posedge clock);
		inout io_pad;
	endclocking	
	clocking MON_CB@(posedge clock);
		input io_pad;
	endclocking	

	modport DRV_MP(clocking DRV_CB);
	modport MON_MP(clocking MON_CB);	
endinterface