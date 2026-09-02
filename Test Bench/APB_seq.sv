class base_apb_seq extends uvm_sequence #(APB_txn);
	`uvm_object_utils(base_apb_seq)

	//APB_txn req;

	function new(string name="base_apb_seq");
		super.new(name);
	endfunction

	bit eclk_enb = 1'b0;
	extern task body();
endclass

task base_apb_seq::body();	
	if(!uvm_config_db #(bit) ::get(null,get_full_name(),"eclk_enb",eclk_enb))
		`uvm_fatal(get_type_name(),"Getting eclk enable signal failed")
endtask

class reset_seq extends base_apb_seq;
	`uvm_object_utils(reset_seq)

	function new(string name="reset_seq");
		super.new(name);
	endfunction

	extern task body();
endclass

task reset_seq::body();
	super.body();
	req = APB_txn::type_id::create("req");

	start_item(req);
	req.randomize() with {PRESETn==1'b0;};
	finish_item(req);

endtask

class read_seq extends base_apb_seq;
	`uvm_object_utils(read_seq)

	function new(string name="read_seq");
		super.new(name);
	endfunction

	extern task body();
endclass

task read_seq::body();
	super.body();
	req = APB_txn::type_id::create("req");

	// 1. Read RGPIO_IN (32'h0)
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b0; PADDR==32'h0;};
	finish_item(req);

	// 2. Read RGPIO_OUT (32'h4)
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b0; PADDR==32'h4;};
	finish_item(req);

	// 3. Read RGPIO_OE (32'h8)
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b0; PADDR==32'h8;};
	finish_item(req);

	// 4. Read RGPIO_INTE (32'hc)
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b0; PADDR==32'hc;};
	finish_item(req);

	// 5. Read RGPIO_PTRIG (32'h10)
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b0; PADDR==32'h10;};
	finish_item(req);

	// 6. Read RGPIO_AUX (32'h14)
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b0; PADDR==32'h14;};
	finish_item(req);

	// 7. Read RGPIO_CTRL (32'h18)
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b0; PADDR==32'h18;};
	finish_item(req);

	// 8. Read RGPIO_INTS (32'h1c)
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b0; PADDR==32'h1c;};
	finish_item(req);

	// 9. Read RGPIO_ECLK (32'h20)
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b0; PADDR==32'h20;};
	finish_item(req);

	// 10. Read RGPIO_NEC (32'h24)
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b0; PADDR==32'h24;};
	finish_item(req);
endtask

class output_seq extends base_apb_seq;
	`uvm_object_utils(output_seq)
	
	function new(string name="output_seq");
		super.new(name);
	endfunction

	extern task body();	
endclass

	task output_seq::body();
		super.body();
		req = APB_txn::type_id::create("req");
		
		start_item(req); //RGPIO_CTRL
		req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'h18; PWDATA==32'h0;};
		finish_item(req);
		
		start_item(req); //RGPIO_OUT
		req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'h4;};
		finish_item(req);
		
		start_item(req); //RGPIO_AUX
		req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'h14; PWDATA==32'h0;};
		finish_item(req);
		
		start_item(req); //RGPIO_OE
		req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'h8; PWDATA==32'hffff;};
		finish_item(req);
			
	endtask

class aux_output_seq extends base_apb_seq;
	`uvm_object_utils(aux_output_seq)

	function new(string name="aux_output_seq");
		super.new(name);
	endfunction

	extern task body();
endclass

task aux_output_seq::body();
	super.body();
	req = APB_txn::type_id::create("req");

	start_item(req); //RGPIO_CTRL
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'h18; PWDATA==32'h0;};
	finish_item(req);
	
	start_item(req); // RGPIO_AUX
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'h14;};
	finish_item(req);

	start_item(req); //RGPIO_OE
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'h8; PWDATA == 32'hffff_ffff;};
	finish_item(req);
	
endtask

class poll_input_seq extends base_apb_seq;
	`uvm_object_utils(poll_input_seq)

	function new(string name="poll_input_seq");
		super.new(name);
	endfunction

	extern task body();
endclass

task poll_input_seq::body();
	super.body();
	req = APB_txn::type_id::create("req");

	// 1. Configure RGPIO_CTRL: Disable interrupts (32'h0)
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'h18; PWDATA==32'h0;};
	finish_item(req);

	// 2. Configure RGPIO_ECLK: Set all to PCLK, 32'h0)
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'h20; PWDATA==32'h0;};
	finish_item(req);
	
	// 3. Configure RGPIO_OE: Set all pins as inputs (LOW -> 32'h0)
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'h8; PWDATA==32'h0;};
	finish_item(req);

endtask

class input_interrupt_seq extends base_apb_seq;
	`uvm_object_utils(input_interrupt_seq)

	function new(string name="input_interrupt_seq");
		super.new(name);
	endfunction

	extern task body();
endclass

task input_interrupt_seq::body();
	super.body();
	req = APB_txn::type_id::create("req");

	// 1. Configure RGPIO_CTRL: Enable Global Interrupts (32'h1)
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'h18; PWDATA==32'h1;};
	finish_item(req);

	// 2. Configure RGPIO_ECLK: Set External Clock to 0
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'h20; PWDATA==32'h0;};
	finish_item(req);

	// 3. Configure RGPIO_NEC: Set Active Edge configuration to 0
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'h24; PWDATA==32'h0;};
	finish_item(req);

	// 4. Configure RGPIO_PTRIG: Alternating High and Low (32'h5555_5555)
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'h10; PWDATA==32'h5555_5555;};
	finish_item(req);

	// 5. Configure RGPIO_INTE: Enable interrupts on all bits (32'hffff_ffff)
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'hc; PWDATA==32'hffff_ffff;};
	finish_item(req);
	
	// 6. Configure RGPIO_OE: Set completely to 1s (32'h0)
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'h8; PWDATA==32'h0;};
	finish_item(req);

endtask

class poll_input_eclk_seq extends base_apb_seq;
	`uvm_object_utils(poll_input_eclk_seq)

	function new(string name="poll_input_eclk_seq");
		super.new(name);
	endfunction

	extern task body();
endclass

task poll_input_eclk_seq::body();
	super.body();
	req = APB_txn::type_id::create("req");

	// 1. Configure RGPIO_CTRL: Disable interrupts (32'h0)
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'h18; PWDATA==32'h0;};
	finish_item(req);

	// 3. Configure RGPIO_ECLK: Enable external clock sampling on all bits (32'hffff_ffff)
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'h20; PWDATA==32'hffff_ffff;};
	finish_item(req);

	// 4. Configure RGPIO_NEC: Select active clock edge (0 = Rising / 1 = Falling)
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'h24; PWDATA==32'h0;};
	finish_item(req);

	// 2. Configure RGPIO_INTE: Ensure interrupt enables are cleared (32'h0)
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'hc; PWDATA==32'h0;};
	finish_item(req);
	
	// 5. Configure RGPIO_OE: Set all pins as inputs (32'h0)
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'h8; PWDATA==32'h0;};
	finish_item(req);


endtask

class input_eclk_interrupt_seq extends base_apb_seq;
	`uvm_object_utils(input_eclk_interrupt_seq)

	function new(string name="input_eclk_interrupt_seq");
		super.new(name);
	endfunction

	extern task body();
endclass

task input_eclk_interrupt_seq::body();
	super.body();
	req = APB_txn::type_id::create("req");

	// 1. Configure RGPIO_CTRL: Enable Global Interrupts (32'h1)
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'h18; PWDATA==32'h1;};
	finish_item(req);

	// 2. Configure RGPIO_ECLK: Enable external clock on all bits (32'hffff_ffff)
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'h20; PWDATA==32'hffff_ffff;};
	finish_item(req);

	// 3. Configure RGPIO_NEC: Active high/rising edge for all bits (32'h0)
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'h24; PWDATA==32'h0;};
	finish_item(req);

	// 4. Configure RGPIO_PTRIG: Alternating trigger configuration (32'haaaa_aaaa)
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'h10; PWDATA==32'haaaa_aaaa;};
	finish_item(req);

	// 5. Configure RGPIO_INTE: Enable interrupts on all bits (32'hffff_ffff)
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'hc; PWDATA==32'hffff_ffff;};
	finish_item(req);

	// 6. Configure RGPIO_OE: Set pins to Input mode (32'h0)
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'h8; PWDATA==32'h0;};
	finish_item(req);

endtask

class bidirectional_seq extends base_apb_seq;
	`uvm_object_utils(bidirectional_seq)

	function new(string name="bidirectional_seq");
		super.new(name);
	endfunction

	extern task body();
endclass

task bidirectional_seq::body();
	super.body();
	req = APB_txn::type_id::create("req");
	
	// 1. Configure RGPIO_CTRL: Enable Global Interrupts (32'h1)
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'h18; PWDATA==32'h1;};
	finish_item(req);

	// 2. Configure RGPIO_ECLK: Set External Clock to 0
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'h20; PWDATA==32'h0;};
	finish_item(req);

	// 3. Configure RGPIO_NEC: Set Active Edge configuration to 0
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'h24; PWDATA==32'h0;};
	finish_item(req);

	// 4. Configure RGPIO_PTRIG: Alternating High and Low (32'h5555_5555)
	start_item(req);
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'h10; PWDATA==32'h5555_5555;};
	finish_item(req);

	start_item(req); //RGPIO_OUT
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'h4;};
	finish_item(req);
		
	start_item(req); //RGPIO_AUX
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'h14; PWDATA==32'h0;};
	finish_item(req);

	start_item(req); //RGPIO_OE
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'h8; PWDATA==32'hf0f0_f0f0;};
	finish_item(req);
	
	start_item(req); //RGPIO_INTE
	req.randomize() with {PRESETn==1'b1; PWRITE==1'b1; PADDR==32'hc; PWDATA==32'hffff_ffff;};
	finish_item(req);
		
endtask
