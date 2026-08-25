class IO_pad_drv extends uvm_driver #(IO_pad_txn);
    `uvm_component_utils(IO_pad_drv)
    
    function new(string name = "IO_pad_drv", uvm_component parent);
        super.new(name, parent);
    endfunction
    
    virtual IO_pad_interface.DRV_MP io_intrf;
    IO_Agent_config cfg;

    function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
	if(!uvm_config_db #(IO_Agent_config)::get(this,"","IO Agent Config",cfg))
		`uvm_fatal(get_type_name(),"Getting IO Agent Config Failed")
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
	io_intrf.DRV_CB.io_pad <= txn.io_pad;	
endtask