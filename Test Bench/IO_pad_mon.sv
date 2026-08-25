class IO_pad_mon extends uvm_monitor;
    `uvm_component_utils(IO_pad_mon)
    uvm_analysis_port #(IO_pad_txn) ap;

    function new(string name = "IO_pad_mon", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual IO_pad_interface.MON_MP io_intrf;
    IO_Agent_config cfg;
    IO_pad_txn txn;    

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
	if(!uvm_config_db #(IO_Agent_config)::get(this,"","IO Agent Config",cfg))
		`uvm_fatal(get_type_name(),"Getting IO Agent Config Failed")	
    endfunction

    function void connect_phase(uvm_phase phase);
    	super.connect_phase(phase);
        io_intrf = cfg.io_intrf;
    endfunction

    extern task run_phase(uvm_phase phase);
    extern task collect_data();
endclass

task IO_pad_mon::run_phase(uvm_phase phase);
	txn = IO_pad_txn::type_id::create("txn");
	forever begin
		collect_data();
		ap.write(txn);
	end
endtask

task IO_pad_mon::collect_data();
	@(io_intrf.MON_CB);
	for(int i=0;i<=31;i++)
		if(io_intrf.MON_CB.io_pad[i] != 1'hz) begin
			if(txn.io_pad != io_intrf.MON_CB.io_pad) begin	
				txn.io_pad = io_intrf.MON_CB.io_pad;
				break;
			end
		end
endtask