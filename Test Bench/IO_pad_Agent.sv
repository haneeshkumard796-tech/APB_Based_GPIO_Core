class IO_pad_Agent extends uvm_agent;
    `uvm_component_utils(IO_pad_Agent)
    
    IO_pad_seqr seqr;
    IO_pad_drv drv;
    IO_pad_mon mon;
    IO_Agent_config cfg;	
	
    function new(string name = "IO_pad_Agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
	if(!uvm_config_db #(IO_Agent_config) ::get(this,"","IO Agent Config",cfg))
		`uvm_fatal(get_type_name(),"Config Object not got")
	
	if(cfg.is_active == UVM_ACTIVE) begin
        	seqr = IO_pad_seqr::type_id::create("seqr", this);
        	drv  = IO_pad_drv::type_id::create("drv", this);
	end
        mon  = IO_pad_mon::type_id::create("mon", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction
endclass