interface AUX_interface(input bit clock);
	logic [31:0]AUX_IN;

	clocking DRV_CB@(posedge clock);
		output AUX_IN;
	endclocking
	clocking MON_CB@(posedge clock);
		input AUX_IN;
	endclocking

	modport DRV_MP(clocking DRV_CB);
	modport MON_MP(clocking MON_CB);	
endinterface