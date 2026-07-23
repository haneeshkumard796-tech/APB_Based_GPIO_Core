`define RGPIO_IN 32'h0
`define RGPIO_OUT 32'h4
`define RGPIO_OE 32'h8
`define RGPIO_INTE 32'hc
`define RGPIO_PTRIG 32'h10
`define RGPIO_AUX 32'h14
`define RGPIO_CTRL 32'h18
`define RGPIO_INTS 32'h1c
`define RGPIO_ECLK 32'h20
`define RGPIO_NEC 32'h24

module top;

	reg PCLK,PRESETn,PWRITE,PSEL,PENABLE;
	reg [31:0]PADDR,PWDATA,aux_in;
	wire [31:0]PRDATA;
	wire PREADY,IRQ;
	wire [31:0]io_pad;
	reg ext_clk_pad_i;
	
	//registering temporary variable for driving io_pad
	reg [31:0] io_pad_drv,io_pad_info;
	
	GPIO_core duv(PCLK,PRESETn,PWRITE,PADDR,PWDATA,PSEL,PENABLE,aux_in,
		 PRDATA,PREADY,IRQ,io_pad,ext_clk_pad_i);


	parameter CYCLE = 10; //PCLK Cycle time
	//Defining PCLK
	initial begin
	 	PCLK = 1'b0;
		forever #(CYCLE/2) PCLK = ~PCLK;
	end
	//Defining ECLK
	initial begin
	 	ext_clk_pad_i = 1'b0;
		forever #(CYCLE) ext_clk_pad_i = ~ext_clk_pad_i;
	end
	//for driving io_pad
	genvar i;
	generate
		for(i=0;i<=31;i=i+1)
		assign io_pad[i] = io_pad_info[i] ? 1'hz : io_pad_drv[i];
	endgenerate
	
	//Reset task
	task reset(); begin
		PRESETn = 1'b0;
		#15;
		PRESETn = 1'b1;
	end
	endtask

	//Select GPIO core
	task sel_core(); begin	
		@(negedge PCLK);
		PSEL = 1'b1;
	end
	endtask
	//Deselect GPIO core
	task desel_core(); begin	
		@(negedge PCLK);
		PSEL = 1'b0;
	end
	endtask
	//Configuring Writable Registers
	task config_reg(input [31:0]data,addr); begin
		if(addr == `RGPIO_OE)
			io_pad_info = data;
		@(negedge PCLK);
		PENABLE = 1'b0;
		PWRITE = 1'b1;
		PWDATA = data;
		PADDR = addr;
		@(negedge PCLK);
		PENABLE = 1'b1;
		wait(PREADY); //In Enable Phase
		wait(!PREADY); //In Setup Phase
		PENABLE = 1'b0;
		PWDATA = 32'd0;
		PADDR = 32'd0;
	end
	endtask
	//Reading GPIO Registers
	task read_GPIO(input [31:0]addr); begin	
		@(negedge PCLK);
		PENABLE = 1'b0;
		PWRITE = 1'b0;
		PADDR = addr;
		@(negedge PCLK);
		PENABLE = 1'b1;
		wait(PREADY); //In Enable Phase
		wait(!PREADY); //In Setup Phase
		PENABLE = 1'b0;
		PADDR = 32'd0;
	end
	endtask
	
	//GPIO as normal output mode
	task normal_output_mode(); begin
		//Select Core
		sel_core();
		//Configuring the registers
		config_reg(32'h00, `RGPIO_CTRL);
		config_reg(32'hfaeb_d9c8, `RGPIO_OUT);
		config_reg(32'h0, `RGPIO_AUX);	
		config_reg(32'hf0f0_f0f0, `RGPIO_OE);
		//Read the GPIO_IN Register
		read_GPIO(`RGPIO_IN);
		//Deselect Core
		desel_core();
	end		
	endtask

	//GPIO as auxiliary output mode
	task auxiliary_output_mode(); begin
		//Select Core
		sel_core();
		//Configuring the registers
		config_reg(32'h00, `RGPIO_CTRL);
		config_reg(32'h1020_3040, `RGPIO_OUT);
		//Providing auxiliary
		aux_in = 32'ha0b0_c0d0;
		//configuring for RGPIO_aux
		config_reg(32'hf0f0_0000, `RGPIO_AUX);	
		config_reg(32'hf0f0_f0f0, `RGPIO_OE);
		//Reading RGPIO_IN
		read_GPIO(`RGPIO_IN);
		//Deselect Core
		desel_core();
	end
	endtask
	
	//GPIO as polling input at sys_clk
	task polling_input_mode(); begin
		//Sel core
		sel_core();
		//configure for input without interrupt
		config_reg(32'h00, `RGPIO_CTRL);
		config_reg(32'h00, `RGPIO_INTE);
		config_reg(32'h00, `RGPIO_PTRIG);
		config_reg(32'h00, `RGPIO_ECLK);
		config_reg(32'h0000_0000, `RGPIO_OE); //Enabling all pins as input
		//drive the io pad
		io_pad_drv = 32'h0570_0a40; 
		//read the GPIO_IN
		read_GPIO(`RGPIO_IN);
		//read the GPIO_INTS for oberving no interrupts
		read_GPIO(`RGPIO_INTS);
		//desel core
		desel_core();
	end
	endtask

	//GPIO as polling input at ECLK
	task polling_input_mode_ECLK(); begin
		//Sel core
		sel_core();
		//configure for input without interrupt
		config_reg(32'h00, `RGPIO_CTRL);
		config_reg(32'h00, `RGPIO_INTE);
		config_reg(32'h00, `RGPIO_PTRIG);
		config_reg(32'h00f0_0f00, `RGPIO_ECLK);
		config_reg(32'h0000_0000, `RGPIO_NEC); //Positive edge of ECLK  
		config_reg(32'h0000_0000, `RGPIO_OE); //Enabling all pins as input
		//drive the io pad
		io_pad_drv = 32'h03c0_02b0; 
		#(CYCLE*2);
		//read the GPIO_IN
		read_GPIO(`RGPIO_IN);
		//read the GPIO_INTS for oberving no interrupts
		read_GPIO(`RGPIO_INTS);
		//desel core
		desel_core();
	end
	endtask
	
	//GPIO as input with interrupt mode at sys_clk
	task input_interrupt_mode(); begin
		//Sel core
		sel_core();
		//configure for input with interrupt
		config_reg(32'h01, `RGPIO_CTRL);
		config_reg(32'hf0ff_0f00, `RGPIO_INTE);
		config_reg(32'hf0f0_0000, `RGPIO_PTRIG);
		config_reg(32'h00, `RGPIO_ECLK);
		config_reg(32'h0000_0000, `RGPIO_OE); //Enabling all pins as input
		//drive the io pad
		io_pad_drv = 32'h000f_0fff;
	       	#(CYCLE*2);
		io_pad_drv = 32'hb570_0c80;
		//Waiting for Interrupt request
		wait(IRQ);
		//read the GPIO_IN
		read_GPIO(`RGPIO_IN);
		//read the GPIO_INTS
		read_GPIO(`RGPIO_INTS);
		//Inform the GPIO core of Interrupt pending
		config_reg(32'h2,`RGPIO_CTRL);
		//Clear the Interrupts
		config_reg(32'h0,`RGPIO_INTS);
		//waiting for no IRQ
		wait(IRQ == 1'b0);
		//Inform the GPIO core of no pending interrupts
		config_reg(32'h1,`RGPIO_CTRL);
		//Disabling INTE
		config_reg(32'h0,`RGPIO_INTE);
		//Disabling PTRIG
		config_reg(32'h0,`RGPIO_PTRIG);
		//desel core
		desel_core();
	end
	endtask
	
	//GPIO as input with interrupt mode at ECLK
	task input_interrupt_mode_ECLK(); begin
		//Sel core
		sel_core();
		//configure for input with interrupt
		config_reg(32'h01, `RGPIO_CTRL);
		config_reg(32'hf0ff_0f00, `RGPIO_INTE);
		config_reg(32'h00f0_0000, `RGPIO_PTRIG);
		config_reg(32'hffff_f0ff, `RGPIO_ECLK);
		config_reg(32'h0000_ffff, `RGPIO_NEC); //Positive edge of ECLK for 16 MSB bits and then negative edge
		config_reg(32'h0000_0000, `RGPIO_OE); //Enabling all pins as input
		//drive the io pad
		io_pad_drv = 32'hf00f_0fff;
		#(CYCLE*2);
		io_pad_drv = 32'hb320_0c50;
		#(CYCLE*2);
		//read the GPIO_IN
		read_GPIO(`RGPIO_IN);
		//read the GPIO_INTS
		read_GPIO(`RGPIO_INTS);
		//Inform the GPIO core of Interrupt pending
		config_reg(32'h2,`RGPIO_CTRL);
		//Clear the Interrupts
		config_reg(32'h0,`RGPIO_INTS);
		//Waiting for no IRQ
		wait(IRQ == 1'b0);
		//Inform the GPIO core of no pending interrupts
		config_reg(32'h1,`RGPIO_CTRL);
		//Disabling INTE
		config_reg(32'h0, `RGPIO_INTE);
		//Disabling PTRIG
		config_reg(32'h0, `RGPIO_PTRIG);
		//Disabling ECLK
		config_reg(32'h0, `RGPIO_ECLK);
		//Disabling NEC
		config_reg(32'h0, `RGPIO_NEC);
		//desel core
		desel_core();
	end
	endtask

	initial begin
		reset();
		normal_output_mode();
		reset();
		auxiliary_output_mode();
		reset();
		polling_input_mode();
		reset();
		polling_input_mode_ECLK();
		reset();
		input_interrupt_mode();
		reset();
		input_interrupt_mode_ECLK();
		reset();
		$finish();
	end
endmodule
