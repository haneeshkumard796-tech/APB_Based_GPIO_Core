//APB Slave Interface
module APB_Slave_Interface(PCLK,PRESETn,PSEL,PENABLE,PREADY,PWRITE,
			PADDR,PWDATA,PRDATA,IRQ,sys_clk,sys_rst,gpio_we,
			gpio_addr,gpio_dat_i,gpio_dat_o,gpio_inta_o);
	input PCLK;
	input PRESETn;
	input PSEL,PENABLE;
	output PREADY;
	input PWRITE;
        input [31:0]PADDR,PWDATA;
	output [31:0]PRDATA;
	output IRQ;
	
	output sys_clk;
	output sys_rst;
	output gpio_we;
	output [31:0] gpio_addr,gpio_dat_i;
	input [31:0]gpio_dat_o;
	input gpio_inta_o;

	parameter IDLE = 2'b00, SETUP = 2'b01, ENABLE = 2'b10;

	reg [1:0]PS,NS;

	assign sys_clk = PCLK;
	assign sys_rst = PRESETn;
	assign gpio_we = (PS==ENABLE)? PWRITE : 1'b0;

	assign gpio_addr = PADDR;
	assign gpio_dat_i = (PS==ENABLE)? PWDATA : 32'd0;

	assign PREADY = (PS==ENABLE)? 1'b1 : 1'b0;
	assign PRDATA = (PS==ENABLE)? gpio_dat_o : 32'd0;
	assign IRQ = gpio_inta_o;

	always@(posedge PCLK or negedge PRESETn) begin
		if(PRESETn == 1'b0)
			PS = IDLE;
		else
			PS <= NS;
	end

	always@(PS or PSEL or PENABLE) begin
		case(PS) 
			IDLE : if(PSEL) NS = SETUP;
			       else NS = IDLE;
			SETUP : if (PSEL && PENABLE) NS = ENABLE;
				else if(PSEL && !PENABLE) NS = SETUP;
			        else NS = IDLE;
			ENABLE : if (PSEL) NS = SETUP;
				 else NS = IDLE;
			default : NS = IDLE;
		endcase
	end
endmodule
