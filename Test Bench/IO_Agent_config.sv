class IO_Agent_config extends uvm_object;
	`uvm_object_utils(IO_Agent_config)

	function new(string name ="IO_Agent_config");
		super.new(name);
	endfunction
	uvm_active_passive_enum is_active = UVM_ACTIVE;
	virtual IO_pad_interface io_intrf;
endclass