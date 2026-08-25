class AUX_drv extends uvm_driver #(AUX_txn);
    `uvm_component_utils(AUX_drv)
    function new(string name = "AUX_drv", uvm_component parent);
        super.new(name, parent);
    endfunction
    virtual AUX_interface.DRV_MP aux_intrf;
    AUX_Agent_config cfg;

    function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
	if(!uvm_config_db #(AUX_Agent_config)::get(this,"","AUX Agent Config",cfg))
		`uvm_fatal(get_type_name(),"Getting AUX Agent Config Failed")	
    endfunction


    function void connect_phase(uvm_phase phase);
    	super.connect_phase(phase);
        aux_intrf = cfg.aux_intrf;
    endfunction

    extern task run_phase(uvm_phase phase);
    extern task send_to_dut(AUX_txn txn);
endclass

task AUX_drv::run_phase(uvm_phase phase);
	forever begin
		seq_item_port.get_next_item(req);
		send_to_dut(req);
		seq_item_port.item_done();
	end
endtask

task AUX_drv::send_to_dut(AUX_txn txn);
	@(aux_intrf.DRV_CB);
	aux_intrf.DRV_CB.AUX_IN <= txn.AUX_IN;	
endtask