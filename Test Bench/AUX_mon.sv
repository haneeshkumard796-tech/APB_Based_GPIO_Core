class AUX_mon extends uvm_monitor;
    `uvm_component_utils(AUX_mon)
    uvm_analysis_port #(AUX_txn) ap;

    function new(string name = "AUX_mon", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual AUX_interface.MON_MP aux_intrf;
    AUX_Agent_config cfg;
    AUX_txn txn;    

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
	if(!uvm_config_db #(AUX_Agent_config)::get(this,"","AUX Agent Config",cfg))
		`uvm_fatal(get_type_name(),"Getting AUX Agent Config Failed")
    endfunction

    function void connect_phase(uvm_phase phase);
    	super.connect_phase(phase);
        aux_intrf = cfg.aux_intrf;
    endfunction

    extern task run_phase(uvm_phase phase);
    extern task collect_data();
endclass

task AUX_mon::run_phase(uvm_phase phase);
	txn = AUX_txn::type_id::create("txn");
	forever begin
		collect_data();
		ap.write(txn);	
	end
endtask

task AUX_mon::collect_data();
	@(aux_intrf.MON_CB);
	if(txn.AUX_IN != aux_intrf.MON_CB.AUX_IN) begin
		txn.AUX_IN = aux_intrf.MON_CB.AUX_IN;
	end
endtask