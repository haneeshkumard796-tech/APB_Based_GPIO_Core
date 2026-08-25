class AUX_Agent_config extends uvm_object;
	`uvm_object_utils(AUX_Agent_config)

	function new(string name ="AUX_Agent_config");
		super.new(name);
	endfunction
	uvm_active_passive_enum is_active = UVM_ACTIVE;
	virtual AUX_interface aux_intrf;
endclass
