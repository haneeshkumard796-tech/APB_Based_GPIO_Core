class APB_Agent extends uvm_agent;
    `uvm_component_utils(APB_Agent)
    	
    APB_seqr seqr;
    APB_drv drv;
    APB_mon mon;
    APB_Agent_config cfg;	
	
    function new(string name = "APB_Agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
	if(!uvm_config_db #(APB_Agent_config) ::get(this,"","APB Agent Config",cfg))
		`uvm_fatal(get_type_name(),"Config Object not got")
	
	if(cfg.is_active == UVM_ACTIVE) begin
        	seqr = APB_seqr::type_id::create("seqr", this);
        	drv  = APB_drv::type_id::create("drv", this);
	end
        mon  = APB_mon::type_id::create("mon", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction
endclass

