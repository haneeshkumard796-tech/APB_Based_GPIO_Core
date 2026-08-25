interface APB_interface (input bit clock);
	logic PCLK;
	logic PRESETn;
	logic PSEL;
	logic PENABLE;
	logic PWRITE;
	logic [31:0]PADDR;
	logic [31:0]PWDATA;
	logic [31:0]PRDATA;
	logic PREADY;
	logic IRQ;
	
	assign PCLK = clock;

	clocking DRV_CB@(posedge PCLK);
		output PRESETn,PSEL,PENABLE,PWRITE,PADDR,PWDATA;
		input PREADY;
	endclocking
	
	clocking MON_CB@(posedge PCLK);
		input PRESETn,PSEL,PENABLE,PWRITE,PADDR,PWDATA,PRDATA;
		input PREADY,IRQ;
	endclocking

	modport DRV_MP(clocking DRV_CB);
	modport MON_MP(clocking MON_CB);
endinterface