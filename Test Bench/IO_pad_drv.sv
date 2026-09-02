class IO_pad_drv extends uvm_driver #(IO_pad_txn);
    `uvm_component_utils(IO_pad_drv)
    
    function new(string name = "IO_pad_drv", uvm_component parent);
        super.new(name, parent);
    endfunction
    
    bit eclk_enb = 1'b0;
    virtual IO_pad_interface.DRV_MP io_intrf;
    IO_Agent_config cfg;

    function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
	if(!uvm_config_db #(IO_Agent_config)::get(this,"","IO Agent Config",cfg))
		`uvm_fatal(get_type_name(),"Getting IO Agent Config Failed")
	if(!uvm_config_db #(bit)::get(this,"","eclk_enb",eclk_enb))
		`uvm_fatal(get_type_name(),"Getting eclk_enb Config Failed")
    endfunction


    function void connect_phase(uvm_phase phase);
    	super.connect_phase(phase);
        io_intrf = cfg.io_intrf;
    endfunction

    extern task run_phase(uvm_phase phase);
    extern task send_to_dut(IO_pad_txn txn);
endclass

task IO_pad_drv::run_phase(uvm_phase phase);
	forever begin
		seq_item_port.get_next_item(req);
		send_to_dut(req);
		seq_item_port.item_done();
	end
endtask

task IO_pad_drv::send_to_dut(IO_pad_txn txn);
	@(io_intrf.DRV_CB);
	if(eclk_enb == 1'b1) begin
	@(negedge io_intrf.DRV_CB.eclk)
	io_intrf.DRV_CB.io_pad <= txn.io_pad;
	end
	else
	io_intrf.DRV_CB.io_pad <= txn.io_pad;
	`uvm_info(get_type_name(),$sformatf("The driven txn is %s",txn.sprint()),UVM_MEDIUM)	
	@(io_intrf.DRV_CB);
endtask	io_intrf.DRV_CB.io_pad <= txn.io_pad;	
endtask
