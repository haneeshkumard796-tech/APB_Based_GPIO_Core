class test extends uvm_test;
	`uvm_component_utils(test)
	function new(string name = "test",uvm_component parent);
		super.new(name,parent);	
	endfunction
	
	env env_h;
	env_config e_cfg;
	APB_Agent_config apb_cfg;	
	AUX_Agent_config aux_cfg;	
	IO_Agent_config io_cfg;	

	extern function void build_phase(uvm_phase phase);
	extern function void end_of_elaboration_phase(uvm_phase phase);
endclass

	function void test::build_phase(uvm_phase phase);
		super.build_phase(phase);
		env_h = env::type_id::create("env_h",this);
		e_cfg = env_config::type_id::create("e_cfg");
		apb_cfg = APB_Agent_config::type_id::create("apb_cfg");
		aux_cfg = AUX_Agent_config::type_id::create("aux_cfg");
		io_cfg = IO_Agent_config::type_id::create("io_cfg");
		if(!uvm_config_db #(virtual APB_interface)::get(this,"","APB_interface",apb_cfg.apb_intrf))
		`uvm_fatal(get_type_name(),"Getting APB interface Failed") 
		
		if(!uvm_config_db #(virtual AUX_interface)::get(this,"","AUX_interface",aux_cfg.aux_intrf))
		`uvm_fatal(get_type_name(),"Getting AUX interface Failed") 
		
		if(!uvm_config_db #(virtual IO_pad_interface)::get(this,"","IO_pad_interface",io_cfg.io_intrf))
		`uvm_fatal(get_type_name(),"Getting IO interface Failed")

		
		uvm_config_db #(env_config)::set(this,"env_h","env_config",e_cfg);	
		uvm_config_db #(APB_Agent_config)::set(this,"env_h","APB_Agent_config",apb_cfg);	
		uvm_config_db #(AUX_Agent_config)::set(this,"env_h","AUX_Agent_config",aux_cfg);	
		uvm_config_db #(IO_Agent_config)::set(this,"env_h","IO_Agent_config",io_cfg);	
	endfunction

	function void test::end_of_elaboration_phase(uvm_phase phase);
		super.end_of_elaboration_phase(phase);		
		uvm_top.print_topology();
	endfunction


class test_reset extends test;
	`uvm_component_utils(test_reset)
	
	output_seq out_seq;	
	reset_seq rst_seq;
	read_seq rd_seq;
	IO_reset_seq io_rst_seq;

	function new(string name = "test_reset", uvm_component parent);
		super.new(name,parent);
	endfunction
	
	extern function void build_phase(uvm_phase phase);
	extern function void end_of_elaboration_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

function void test_reset::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

function void test_reset::end_of_elaboration_phase(uvm_phase phase);
	super.end_of_elaboration_phase(phase);
endfunction

task test_reset::run_phase(uvm_phase phase);
	super.run_phase(phase);
	phase.raise_objection(this);
		rst_seq = reset_seq::type_id::create("rst_seq");
		rd_seq = read_seq::type_id::create("rd_seq");
		out_seq = output_seq::type_id::create("out_seq");
		for(int i=0;i<e_cfg.no_of_APB_agents;i++) begin
			out_seq.start(env_h.apb_ag[i].seqr);
			rst_seq.start(env_h.apb_ag[i].seqr);	
			rd_seq.start(env_h.apb_ag[i].seqr);
		end
	phase.drop_objection(this);	
endtask