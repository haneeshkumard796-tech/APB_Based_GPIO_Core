interface IO_pad_interface(input bit clock);

	wire [31:0] io_pad;
	logic eclk;

	initial begin
		eclk = 1'b0;
		forever #40 eclk = ~eclk;
	end
	
	clocking DRV_CB@(posedge clock);
		inout io_pad;
		input eclk;
	endclocking	
	clocking MON_CB@(posedge clock);
		input io_pad;
	endclocking

	modport DRV_MP(clocking DRV_CB);
	modport MON_MP(clocking MON_CB);	
endinterface
