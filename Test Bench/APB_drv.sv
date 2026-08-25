class APB_drv extends uvm_driver #(APB_txn);
    `uvm_component_utils(APB_drv)
    
    function new(string name = "APB_drv", uvm_component parent);
        super.new(name, parent);
    endfunction
    
    virtual APB_interface.DRV_MP apb_intrf;
    APB_Agent_config cfg;

    function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
	if(!uvm_config_db #(APB_Agent_config)::get(this,"","APB Agent Config",cfg))
		`uvm_fatal(get_type_name(),"Getting APB Agent Config Failed")
    endfunction

    function void connect_phase(uvm_phase phase);
    	super.connect_phase(phase);
        apb_intrf = cfg.apb_intrf;
    endfunction

    extern task run_phase(uvm_phase phase);
    extern task send_to_dut(APB_txn txn);
endclass 

task APB_drv::run_phase(uvm_phase phase);
	forever begin
		seq_item_port.get_next_item(req);
		send_to_dut(req);
		seq_item_port.item_done();		
	end
endtask

task APB_drv::send_to_dut(APB_txn txn);
	@(apb_intrf.DRV_CB);
	apb_intrf.DRV_CB.PRESETn <= txn.PRESETn;
	
	if(txn.PRESETn == 1'b1) begin
	apb_intrf.DRV_CB.PSEL <= 1'b1;
	apb_intrf.DRV_CB.PENABLE <= 1'b0;
	
	apb_intrf.DRV_CB.PWRITE <= txn.PWRITE;
	apb_intrf.DRV_CB.PADDR <= txn.PADDR;
	apb_intrf.DRV_CB.PWDATA <= txn.PWDATA;		
	
	@(apb_intrf.DRV_CB);
	apb_intrf.DRV_CB.PENABLE <= 1'b1;

	wait(apb_intrf.DRV_CB.PREADY);
	apb_intrf.DRV_CB.PSEL <= 1'b0;
	apb_intrf.DRV_CB.PENABLE <= 1'b0;
	end	
		
	@(apb_intrf.DRV_CB);
	`uvm_info(get_type_name(),$sformatf("The driven txn is %s",txn.sprint()), UVM_LOW)	
endtask

