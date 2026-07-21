module GPIO_core(PCLK,PRESETn,PWRITE,PADDR,PWDATA,PSEL,PENABLE,aux_in,
		 PRDATA,PREADY,IRQ,io_pad,ext_clk_pad_i);

	 input PCLK,PRESETn,PWRITE,PSEL,PENABLE;
	 input [31:0]PADDR,PWDATA,aux_in;
	 output [31:0]PRDATA;
	 output PREADY,IRQ;
	 inout [31:0]io_pad;
	 input ext_clk_pad_i;
	
	 wire [31:0]gpio_addr,gpio_dat_i,gpio_dat_o,aux_i,out_pad_o,oen_padoe_o,in_pad_i;

	APB_Slave_Interface apb_slave_interface(PCLK,PRESETn,PSEL,PENABLE,PREADY,PWRITE,PADDR,PWDATA,PRDATA,IRQ,sys_clk,sys_rst,gpio_we,gpio_addr,gpio_dat_i,gpio_dat_o,gpio_inta_o);

	GPIO_registers gpio_registers(sys_clk,sys_rst,gpio_we,gpio_addr,gpio_dat_i,gpio_dat_o,gpio_inta_o,aux_in,out_pad_o,oen_padoe_o,in_pad_i,gpio_eclk);

	Auxiliary_interface auxiliary_interface(sys_clk,sys_rst,aux_in,aux_i);

	IO_interface io_interface(out_pad_o, oen_padoe_o, in_pad_i, gpio_eclk, io_pad, ext_clk_pad_i);

endmodule