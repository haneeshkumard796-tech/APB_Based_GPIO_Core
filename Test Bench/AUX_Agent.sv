class AUX_Agent extends uvm_agent;
    `uvm_component_utils(AUX_Agent)
    
    AUX_seqr seqr;
    AUX_drv drv;
    AUX_mon mon;
    AUX_Agent_config cfg;	
	
    function new(string name = "AUX_Agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
	if(!uvm_config_db #(AUX_Agent_config) ::get(this,"","AUX Agent Config",cfg))
		`uvm_fatal(get_type_name(),"Config Object not got")
	
	if(cfg.is_active == UVM_ACTIVE) begin
        	seqr = AUX_seqr::type_id::create("seqr", this);
        	drv  = AUX_drv::type_id::create("drv", this);
	end
        mon  = AUX_mon::type_id::create("mon", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction
endclass