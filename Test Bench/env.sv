class env extends uvm_env;
    `uvm_component_utils(env)
    
    APB_Agent    apb_ag[];
    AUX_Agent    aux_ag[];
    IO_pad_Agent io_pad_ag[];
    Scoreboard   sb;
    env_config e_cfg;
    APB_Agent_config apb_cfg;
    AUX_Agent_config aux_cfg;
    IO_Agent_config  io_cfg;

    function new(string name = "env", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
	if(!uvm_config_db #(env_config) ::get(this,"","env_config",e_cfg))
		`uvm_fatal(get_type_name(),"Getting Environment Config Failed")
        
	if(!uvm_config_db #(APB_Agent_config) ::get(this,"","APB_Agent_config",apb_cfg))
		`uvm_fatal(get_type_name(),"Getting APB Agent Config Failed")
	
	if(!uvm_config_db #(AUX_Agent_config) ::get(this,"","AUX_Agent_config",aux_cfg))
		`uvm_fatal(get_type_name(),"Getting AUX Agent Config Failed")
	
	if(!uvm_config_db #(IO_Agent_config) ::get(this,"","IO_Agent_config",io_cfg))
		`uvm_fatal(get_type_name(),"Getting IO Agent Config Failed")


	apb_ag = new[e_cfg.no_of_APB_agents];
        aux_ag = new[e_cfg.no_of_AUX_agents];
        io_pad_ag = new[e_cfg.no_of_IO_agents];
	
	foreach(apb_ag[i]) begin
		apb_ag[i] = APB_Agent::type_id::create($sformatf("apb_ag[%0d]",i),this);
		uvm_config_db #(APB_Agent_config)::set(this,$sformatf("apb_ag[%0d]*",i),"APB Agent Config",apb_cfg);
	end
	foreach(aux_ag[i]) begin
		aux_ag[i] = AUX_Agent::type_id::create($sformatf("aux_ag[%0d]",i),this);
		uvm_config_db #(AUX_Agent_config)::set(this,$sformatf("aux_ag[%0d]*",i),"AUX Agent Config",aux_cfg);
	end
	foreach(io_pad_ag[i]) begin
        	io_pad_ag[i] = IO_pad_Agent::type_id::create($sformatf("io_pad_ag[%0d]",i),this);
		uvm_config_db #(IO_Agent_config)::set(this,$sformatf("io_pad_ag[%0d]*",i),"IO Agent Config",io_cfg);
	end
	
	sb = Scoreboard::type_id::create("sb", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        // Connect monitor analysis ports to scoreboard analysis fifo exports
	for(int i=0;i<e_cfg.no_of_APB_agents;i++)
		apb_ag[i].mon.ap.connect(sb.apb_fifo[i].analysis_export);
	
	for(int i=0;i<e_cfg.no_of_AUX_agents;i++)
		aux_ag[i].mon.ap.connect(sb.aux_fifo[i].analysis_export);
	
	for(int i=0;i<e_cfg.no_of_IO_agents;i++)
		io_pad_ag[i].mon.ap.connect(sb.io_pad_fifo[i].analysis_export);
    endfunction
endclass
