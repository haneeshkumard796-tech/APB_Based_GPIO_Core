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
		uvm_config_db #(env_config)::set(this,"env_h.sb","env_config",e_cfg);	
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
	uvm_config_db #(bit)::set(this,"*","eclk_enb",1'b0);
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

class test_out extends test;
	`uvm_component_utils(test_out)

	function new(string name = "test_out", uvm_component parent);
		super.new(name,parent);
	endfunction
	
	IO_reset_seq io_rst_seq;
	IO_output_seq io_out_seq;
	output_seq out_seq;	
	reset_seq rst_seq;
	read_seq rd_seq;
	AUX_seq aux_seq;

	extern function void build_phase(uvm_phase phase);
	extern function void end_of_elaboration_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

function void test_out::build_phase(uvm_phase phase);
	super.build_phase(phase);
	uvm_config_db #(bit)::set(this,"*","eclk_enb",1'b0);
endfunction

function void test_out::end_of_elaboration_phase(uvm_phase phase);
	super.end_of_elaboration_phase(phase);
endfunction

task test_out::run_phase(uvm_phase phase);
	phase.raise_objection(this);
		io_rst_seq = IO_reset_seq::type_id::create("io_rst_seq");
		io_out_seq = IO_output_seq::type_id::create("io_out_seq");
		rst_seq = reset_seq::type_id::create("rst_seq");
		rd_seq = read_seq::type_id::create("rd_seq");
		out_seq = output_seq::type_id::create("out_seq");
		aux_seq = AUX_seq::type_id::create("aux_seq");	
	
		for(int i=0;i<e_cfg.no_of_APB_agents;i++) begin	

			fork
			rst_seq.start(env_h.apb_ag[i].seqr);
			io_rst_seq.start(env_h.io_pad_ag[i].seqr);
			join
			
			fork	
			out_seq.start(env_h.apb_ag[i].seqr);
			aux_seq.start(env_h.aux_ag[i].seqr);
			io_out_seq.start(env_h.io_pad_ag[i].seqr);
			join
	
		rd_seq.start(env_h.apb_ag[i].seqr);
		end
	phase.drop_objection(this);
endtask

class test_polled_input extends test;
	`uvm_component_utils(test_polled_input)

	function new(string name = "test_polled_input", uvm_component parent);
		super.new(name,parent);
	endfunction
	
	IO_reset_seq io_rst_seq;
	IO_input_seq io_inp_seq;
	poll_input_seq poll_inp_seq;
	reset_seq rst_seq;
	read_seq rd_seq;
	AUX_seq aux_seq;

	extern function void build_phase(uvm_phase phase);
	extern function void end_of_elaboration_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

function void test_polled_input::build_phase(uvm_phase phase);
	super.build_phase(phase);
	uvm_config_db #(bit)::set(this,"*","eclk_enb",1'b0);
endfunction

function void test_polled_input::end_of_elaboration_phase(uvm_phase phase);
	super.end_of_elaboration_phase(phase);
endfunction

task test_polled_input::run_phase(uvm_phase phase);
	phase.raise_objection(this);
		io_rst_seq = IO_reset_seq::type_id::create("io_rst_seq");
		rst_seq = reset_seq::type_id::create("rst_seq");
		rd_seq = read_seq::type_id::create("rd_seq");
		aux_seq = AUX_seq::type_id::create("aux_seq");	
		io_inp_seq = IO_input_seq::type_id::create("io_inp_seq");	
		poll_inp_seq = poll_input_seq::type_id::create("poll_inp_seq");

		for(int i=0;i<e_cfg.no_of_APB_agents;i++) begin	
			fork
				rst_seq.start(env_h.apb_ag[i].seqr);
				io_rst_seq.start(env_h.io_pad_ag[i].seqr);
			join

			fork
				poll_inp_seq.start(env_h.apb_ag[i].seqr);	
				aux_seq.start(env_h.aux_ag[i].seqr);
			join

			repeat(2) io_inp_seq.start(env_h.io_pad_ag[i].seqr);
	
		rd_seq.start(env_h.apb_ag[i].seqr);
		end
	phase.drop_objection(this);
endtask

class test_interrupt_input extends test;
	`uvm_component_utils(test_interrupt_input)
	
	function new(string name = "test_interrupt_input", uvm_component parent);
		super.new(name,parent);
	endfunction

	IO_reset_seq io_rst_seq;
	IO_input_seq io_inp_seq;
	reset_seq rst_seq;
	read_seq rd_seq;
	AUX_seq aux_seq;
	input_interrupt_seq inp_intr_seq;

	extern function void build_phase(uvm_phase phase);
	extern function void end_of_elaboration_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

function void test_interrupt_input::build_phase(uvm_phase phase);
	super.build_phase(phase);
	uvm_config_db #(bit)::set(this,"*","eclk_enb",1'b0);
endfunction

function void test_interrupt_input::end_of_elaboration_phase(uvm_phase phase);
	super.end_of_elaboration_phase(phase);
endfunction

task test_interrupt_input::run_phase(uvm_phase phase);
	phase.raise_objection(this);
		io_rst_seq = IO_reset_seq::type_id::create("io_rst_seq");
		rst_seq = reset_seq::type_id::create("rst_seq");
		rd_seq = read_seq::type_id::create("rd_seq");
		aux_seq = AUX_seq::type_id::create("aux_seq");	
		io_inp_seq = IO_input_seq::type_id::create("io_inp_seq");	
		inp_intr_seq = input_interrupt_seq::type_id::create("inp_intr_seq");	
	
		for(int i=0;i<e_cfg.no_of_APB_agents;i++) begin	
			fork
				rst_seq.start(env_h.apb_ag[i].seqr);
				io_rst_seq.start(env_h.io_pad_ag[i].seqr);
			join

			fork
				inp_intr_seq.start(env_h.apb_ag[i].seqr);	
				aux_seq.start(env_h.aux_ag[i].seqr);
			join
			repeat(2) io_inp_seq.start(env_h.io_pad_ag[i].seqr);
	
		rd_seq.start(env_h.apb_ag[i].seqr);
		end
	phase.drop_objection(this);
endtask

class test_aux_output extends test;
	`uvm_component_utils(test_aux_output)
	
	function new(string name = "test_aux_output", uvm_component parent);
		super.new(name,parent);
	endfunction

	IO_reset_seq io_rst_seq;
	reset_seq rst_seq;
	read_seq rd_seq;
	AUX_seq aux_seq;
	aux_output_seq aux_out_seq;

	extern function void build_phase(uvm_phase phase);
	extern function void end_of_elaboration_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

function void test_aux_output::build_phase(uvm_phase phase);
	super.build_phase(phase);
	uvm_config_db #(bit)::set(this,"*","eclk_enb",1'b0);
endfunction

function void test_aux_output::end_of_elaboration_phase(uvm_phase phase);
	super.end_of_elaboration_phase(phase);
endfunction

task test_aux_output::run_phase(uvm_phase phase);
	phase.raise_objection(this);
		io_rst_seq = IO_reset_seq::type_id::create("io_rst_seq");
		rst_seq = reset_seq::type_id::create("rst_seq");
		rd_seq = read_seq::type_id::create("rd_seq");
		aux_seq = AUX_seq::type_id::create("aux_seq");	
		aux_out_seq = aux_output_seq::type_id::create("aux_out_seq");	
		for(int i=0;i<e_cfg.no_of_APB_agents;i++) begin	
			fork
				rst_seq.start(env_h.apb_ag[i].seqr);
				io_rst_seq.start(env_h.io_pad_ag[i].seqr);
			join

			fork
				aux_out_seq.start(env_h.apb_ag[i].seqr);
				aux_seq.start(env_h.aux_ag[i].seqr);
			join
	
		rd_seq.start(env_h.apb_ag[i].seqr);
		end
	phase.drop_objection(this);
endtask

class test_bidirectional extends test;
	`uvm_component_utils(test_bidirectional)
	
	function new(string name = "test_bidirectional", uvm_component parent);
		super.new(name,parent);
	endfunction

	IO_reset_seq io_rst_seq;
	reset_seq rst_seq;
	read_seq rd_seq;
	AUX_seq aux_seq;
	bidirectional_seq bidir_seq;
	IO_bidir_seq io_bidir_seq;

	extern function void build_phase(uvm_phase phase);
	extern function void end_of_elaboration_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

function void test_bidirectional::build_phase(uvm_phase phase);
	super.build_phase(phase);
	uvm_config_db #(bit)::set(this,"*","eclk_enb",1'b0);
endfunction

function void test_bidirectional::end_of_elaboration_phase(uvm_phase phase);
	super.end_of_elaboration_phase(phase);
endfunction

task test_bidirectional::run_phase(uvm_phase phase);
	phase.raise_objection(this);
		io_rst_seq = IO_reset_seq::type_id::create("io_rst_seq");
		rst_seq = reset_seq::type_id::create("rst_seq");
		rd_seq = read_seq::type_id::create("rd_seq");
		aux_seq = AUX_seq::type_id::create("aux_seq");	
		bidir_seq = bidirectional_seq::type_id::create("bidir_seq");
		io_bidir_seq = IO_bidir_seq::type_id::create("io_bidir_seq");
		
		for(int i=0;i<e_cfg.no_of_APB_agents;i++) begin	
			fork
				rst_seq.start(env_h.apb_ag[i].seqr);
				io_rst_seq.start(env_h.io_pad_ag[i].seqr);
			join
			
			fork
				bidir_seq.start(env_h.apb_ag[i].seqr);
				aux_seq.start(env_h.aux_ag[i].seqr);
			join	
			repeat(2) io_bidir_seq.start(env_h.io_pad_ag[i].seqr);
		
		rd_seq.start(env_h.apb_ag[i].seqr);
		end
	phase.drop_objection(this);
endtask

class test_polled_input_eclk extends test;
	`uvm_component_utils(test_polled_input_eclk)

	function new(string name = "test_polled_input_eclk", uvm_component parent);
		super.new(name,parent);
	endfunction

	IO_reset_seq io_rst_seq;
	IO_input_seq io_inp_seq;
	reset_seq rst_seq;
	read_seq rd_seq;
	AUX_seq aux_seq;
	poll_input_eclk_seq poll_inp_eclk_seq;

	extern function void build_phase(uvm_phase phase);
	extern function void end_of_elaboration_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

function void test_polled_input_eclk::build_phase(uvm_phase phase);
	super.build_phase(phase);
	uvm_config_db #(bit)::set(this,"*","eclk_enb",1'b1);
endfunction

function void test_polled_input_eclk::end_of_elaboration_phase(uvm_phase phase);
	super.end_of_elaboration_phase(phase);
endfunction

task test_polled_input_eclk::run_phase(uvm_phase phase);
	phase.raise_objection(this);
		io_rst_seq = IO_reset_seq::type_id::create("io_rst_seq");
		rst_seq = reset_seq::type_id::create("rst_seq");
		rd_seq = read_seq::type_id::create("rd_seq");
		aux_seq = AUX_seq::type_id::create("aux_seq");	
		poll_inp_eclk_seq = poll_input_eclk_seq::type_id::create("poll_inp_eclk_seq");
		io_inp_seq = IO_input_seq::type_id::create("io_inp_seq");
		for(int i=0;i<e_cfg.no_of_APB_agents;i++) begin	
		fork
			rst_seq.start(env_h.apb_ag[i].seqr);
			io_rst_seq.start(env_h.io_pad_ag[i].seqr);
		join

		fork
			poll_inp_eclk_seq.start(env_h.apb_ag[i].seqr);
			aux_seq.start(env_h.aux_ag[i].seqr);
		join
		repeat(2) io_inp_seq.start(env_h.io_pad_ag[i].seqr);
		rd_seq.start(env_h.apb_ag[i].seqr);	
		end
	phase.drop_objection(this);
endtask

class test_interrupt_input_eclk extends test;
	`uvm_component_utils(test_interrupt_input_eclk)

	function new(string name = "test_interrupt_input_eclk", uvm_component parent);
		super.new(name,parent);
	endfunction

	IO_reset_seq io_rst_seq;
	IO_input_seq io_inp_seq;
	reset_seq rst_seq;
	read_seq rd_seq;
	AUX_seq aux_seq;
	input_eclk_interrupt_seq  intr_inp_eclk_seq;

	extern function void build_phase(uvm_phase phase);
	extern function void end_of_elaboration_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

function void test_interrupt_input_eclk::build_phase(uvm_phase phase);
	super.build_phase(phase);
	uvm_config_db #(bit)::set(this,"*","eclk_enb",1'b1);
endfunction

function void test_interrupt_input_eclk::end_of_elaboration_phase(uvm_phase phase);
	super.end_of_elaboration_phase(phase);
endfunction

task test_interrupt_input_eclk::run_phase(uvm_phase phase);
	phase.raise_objection(this);
		io_rst_seq = IO_reset_seq::type_id::create("io_rst_seq");
		rst_seq = reset_seq::type_id::create("rst_seq");
		rd_seq = read_seq::type_id::create("rd_seq");
		aux_seq = AUX_seq::type_id::create("aux_seq");	
		intr_inp_eclk_seq = input_eclk_interrupt_seq::type_id::create("intr_inp_eclk_seq");
		io_inp_seq = IO_input_seq::type_id::create("io_inp_seq");
		for(int i=0;i<e_cfg.no_of_APB_agents;i++) begin	
		fork
			rst_seq.start(env_h.apb_ag[i].seqr);
			io_rst_seq.start(env_h.io_pad_ag[i].seqr);
		join

		fork
			intr_inp_eclk_seq.start(env_h.apb_ag[i].seqr);
			aux_seq.start(env_h.aux_ag[i].seqr);
		join
		repeat(2) io_inp_seq.start(env_h.io_pad_ag[i].seqr);
		rd_seq.start(env_h.apb_ag[i].seqr);	
		end
	phase.drop_objection(this);
endtask
