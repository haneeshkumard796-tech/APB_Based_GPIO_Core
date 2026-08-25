class env_config extends uvm_object;
	`uvm_object_utils(env_config)

	function new(string name="env_config");
		super.new(name);
	endfunction

	int no_of_APB_agents = 1;	
	int no_of_AUX_agents = 1;	
	int no_of_IO_agents = 1;

endclass