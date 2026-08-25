class APB_Agent_config extends uvm_object;
	`uvm_object_utils(APB_Agent_config)

	function new(string name ="APB_Agent_config");
		super.new(name);
	endfunction
	uvm_active_passive_enum is_active = UVM_ACTIVE;
	virtual APB_interface apb_intrf;
endclass
