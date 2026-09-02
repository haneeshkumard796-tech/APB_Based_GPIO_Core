class APB_mon extends uvm_monitor;
    `uvm_component_utils(APB_mon)
    uvm_analysis_port #(APB_txn) ap;

    APB_txn txn;

    function new(string name = "APB_mon", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual APB_interface.MON_MP apb_intrf;
    APB_Agent_config cfg;
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
	if(!uvm_config_db #(APB_Agent_config)::get(this,"","APB Agent Config",cfg))
		`uvm_fatal(get_type_name(),"Getting APB Agent Config Failed")
    endfunction

    function void connect_phase(uvm_phase phase);
    	super.connect_phase(phase);
        apb_intrf = cfg.apb_intrf;
    endfunction

    extern task run_phase(uvm_phase phase);
    extern task collect_data();
endclass

task APB_mon::run_phase(uvm_phase phase);
	txn = APB_txn::type_id::create("txn");	
	forever begin
		collect_data();
		`uvm_info(get_type_name(),$sformatf("The txn data collected is %s",txn.sprint()), UVM_MEDIUM)	
		ap.write(txn);
	end
endtask

task APB_mon::collect_data();
	@(apb_intrf.MON_CB);
	wait(apb_intrf.MON_CB.PREADY == 1'b1 | apb_intrf.MON_CB.PRESETn == 1'b0);
//	`uvm_info(get_type_name(),"PREADY and PWRITE are 1 & 0",UVM_MEDIUM)
	txn.PRESETn = apb_intrf.MON_CB.PRESETn;
	txn.PWRITE = apb_intrf.MON_CB.PWRITE;
	txn.PADDR = apb_intrf.MON_CB.PADDR;
	txn.PREADY = apb_intrf.MON_CB.PREADY;
	txn.PSEL = apb_intrf.MON_CB.PSEL;
	txn.PENABLE = apb_intrf.MON_CB.PENABLE;
	txn.IRQ = apb_intrf.MON_CB.IRQ;
	txn.PWDATA = apb_intrf.MON_CB.PWDATA;
	txn.PRDATA = apb_intrf.MON_CB.PRDATA;
	if(txn.PWRITE == 1'b1)
	case(txn.PADDR)
		32'h4 : 	txn.RGPIO_OUT = apb_intrf.MON_CB.PWDATA;
	 	32'h8 :  	txn.RGPIO_OE = apb_intrf.MON_CB.PWDATA;
		32'hc : 	txn.RGPIO_INTE = apb_intrf.MON_CB.PWDATA;
		32'h10 : 	txn.RGPIO_PTRIG = apb_intrf.MON_CB.PWDATA;
		32'h14 :  	txn.RGPIO_AUX = apb_intrf.MON_CB.PWDATA;
		32'h18 :	begin
				txn.RGPIO_CTRL_GIE = apb_intrf.MON_CB.PWDATA[0];
				txn.RGPIO_CTRL_IP = apb_intrf.MON_CB.PWDATA[1];
				end
		32'h1c :  	txn.RGPIO_INTS = apb_intrf.MON_CB.PWDATA;
		32'h20 :  	txn.RGPIO_ECLK = apb_intrf.MON_CB.PWDATA;
		32'h24 : 	txn.RGPIO_NEC = apb_intrf.MON_CB.PWDATA;	
	endcase
	else if (txn.PWRITE == 1'b0)
	case(txn.PADDR)
		32'h0 :		txn.RGPIO_IN = apb_intrf.MON_CB.PRDATA;
		32'h4 : 	txn.RGPIO_OUT = apb_intrf.MON_CB.PRDATA;
	 	32'h8 :  	txn.RGPIO_OE = apb_intrf.MON_CB.PRDATA;
		32'hc : 	txn.RGPIO_INTE = apb_intrf.MON_CB.PRDATA;
		32'h10 : 	txn.RGPIO_PTRIG = apb_intrf.MON_CB.PRDATA;
		32'h14 :  	txn.RGPIO_AUX = apb_intrf.MON_CB.PRDATA;
		32'h18 :	begin
				txn.RGPIO_CTRL_GIE = apb_intrf.MON_CB.PRDATA[0];
				txn.RGPIO_CTRL_IP = apb_intrf.MON_CB.PRDATA[1];
				end
		32'h1c :  	txn.RGPIO_INTS = apb_intrf.MON_CB.PRDATA;
		32'h20 :  	txn.RGPIO_ECLK = apb_intrf.MON_CB.PRDATA;
		32'h24 : 	txn.RGPIO_NEC = apb_intrf.MON_CB.PRDATA;	
	endcase

	@(apb_intrf.MON_CB);	
endtask
