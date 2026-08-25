module top();
import uvm_pkg::*;
`include "uvm_macros.svh"
import test_pkg::*;

bit clock;
initial begin
	clock = 1'b0;
	forever #10 clock = ~clock;
end

APB_interface apb_intrf(clock);
AUX_interface aux_intrf(clock);
IO_pad_interface io_intrf(clock);

GPIO_core dut(.PCLK(apb_intrf.PCLK), .PRESETn(apb_intrf.PRESETn), .PWRITE(apb_intrf.PWRITE), .PADDR(apb_intrf.PADDR), .PWDATA(apb_intrf.PWDATA), .PSEL(apb_intrf.PSEL), .PENABLE(apb_intrf.PENABLE), .PRDATA(apb_intrf.PRDATA), .PREADY(apb_intrf.PREADY), .IRQ(apb_intrf.IRQ), .aux_in(aux_intrf.AUX_IN), .io_pad(io_intrf.io_pad), .ext_clk_pad_i(io_intrf.eclk));

initial begin
	uvm_config_db #(virtual APB_interface) ::set(null,"uvm_test_top","APB_interface",apb_intrf);
	uvm_config_db #(virtual AUX_interface) ::set(null,"uvm_test_top","AUX_interface",aux_intrf);
	uvm_config_db #(virtual IO_pad_interface) ::set(null,"uvm_test_top","IO_pad_interface",io_intrf);
	run_test();
end
endmodule