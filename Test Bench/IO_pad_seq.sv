class IO_pad_base_seq extends uvm_sequence #(IO_pad_txn);
	`uvm_object_utils(IO_pad_base_seq)
	
//	IO_pad_txn req;

	function new(string name="IO_pad_base_seq");
		super.new(name);
	endfunction

endclass

class IO_input_interrupt_seq extends IO_pad_base_seq;
	`uvm_object_utils(IO_input_interrupt_seq)
	
	function new(string name="IO_input_interrupt_seq");
		super.new(name);
	endfunction

	extern task body();
endclass

task IO_input_interrupt_seq::body();
	req = IO_pad_txn::type_id::create("req");

	repeat(2) begin	
	start_item(req);
		req.randomize() with {io_pad_ctrl==2'b10;};
	finish_item(req);	
	end
endtask

class IO_input_seq extends IO_pad_base_seq;
	`uvm_object_utils(IO_input_seq)
	
	function new(string name="IO_input_seq");
		super.new(name);
	endfunction

	extern task body();
endclass

task IO_input_seq::body();
	req = IO_pad_txn::type_id::create("req");
	
	start_item(req);
		req.randomize() with {io_pad_ctrl==2'b01;};
	finish_item(req);	
endtask

class IO_output_seq extends IO_pad_base_seq;
	`uvm_object_utils(IO_output_seq)
	
	function new(string name="IO_output_seq");
		super.new(name);
	endfunction

	extern task body();
endclass

task IO_output_seq::body();
	req = IO_pad_txn::type_id::create("req");
	
	start_item(req);
		req.randomize() with {io_pad_ctrl==2'b0;};
	finish_item(req);	
endtask

class IO_bidir_seq extends IO_pad_base_seq;
	`uvm_object_utils(IO_bidir_seq)
	
	function new(string name="IO_bidir_seq");
		super.new(name);
	endfunction

	extern task body();
endclass

task IO_bidir_seq::body();
	req = IO_pad_txn::type_id::create("req");
	
	start_item(req);
		req.randomize() with {io_pad_ctrl==2'b11;};
	finish_item(req);	
endtask

class IO_reset_seq extends IO_pad_base_seq;
	`uvm_object_utils(IO_reset_seq)
	
	function new(string name="IO_reset_seq");
		super.new(name);
	endfunction

	extern task body();
endclass

task IO_reset_seq::body();
	req = IO_pad_txn::type_id::create("req");
	
	start_item(req);
		req.randomize() with {io_pad_ctrl == 2'b0;};
	finish_item(req);	
endtask
