class Scoreboard extends uvm_scoreboard;
    `uvm_component_utils(Scoreboard)
    
    uvm_tlm_analysis_fifo #(APB_txn)    apb_fifo[];
    uvm_tlm_analysis_fifo #(AUX_txn)    aux_fifo[];
    uvm_tlm_analysis_fifo #(IO_pad_txn) io_pad_fifo[];

    env_config e_cfg;
    APB_txn apb_txn,apb_cov;
    AUX_txn aux_txn,aux_cov;
    IO_pad_txn io_txn,io_cov;

    logic [31:0]RGPIO_IN,RGPIO_OUT,RGPIO_OE,RGPIO_INTE,RGPIO_PTRIG,RGPIO_AUX,RGPIO_INTS,RGPIO_ECLK,RGPIO_NEC,AUX_IN,io_pad;
    logic [1:0]RGPIO_CTRL;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
	if(!uvm_config_db #(env_config)::get(this,"","env_config",e_cfg))
		`uvm_fatal(get_type_name(),"Getting environment config failed")
	
	apb_txn = APB_txn::type_id::create("apb_txn");
	aux_txn = AUX_txn::type_id::create("aux_txn");
	io_txn = IO_pad_txn::type_id::create("io_txn");
	apb_fifo = new[e_cfg.no_of_APB_agents];
	aux_fifo = new[e_cfg.no_of_AUX_agents];
	io_pad_fifo = new[e_cfg.no_of_IO_agents];
        
	foreach(apb_fifo[i])
		apb_fifo[i] = new($sformatf("apb_fifo[%0d]",i), this);
	
	foreach(aux_fifo[i])
		aux_fifo[i] = new($sformatf("aux_fifo[%0d]",i), this);
	
	foreach(io_pad_fifo[i])
		io_pad_fifo[i] = new($sformatf("io_pad_fifo[%0d]",i), this);
    endfunction

    extern task run_phase(uvm_phase phase);
    extern function void predict_model();
    extern function void update_ref_model();

    covergroup gpio_cg;
	option.per_instance = 1;
	option.at_least = 1;
	PRESET : coverpoint apb_cov.PRESETn { bins rst[] = {1'b0,1'b1};}
	PSEL :	coverpoint apb_cov.PSEL {bins sel = {1'b0,1'b1};}
	PENABLE : coverpoint apb_cov.PENABLE {bins enb = {1'b0,1'b1};}
	PWRITE : coverpoint apb_cov.PWRITE {bins wrt[] = {1'b0,1'b1};}
	PREADY : coverpoint apb_cov.PREADY {bins rdy = {1'b0,1'b1};}
	PADDR : coverpoint apb_cov.PADDR {bins addr1[] = {32'h0,32'h4,32'h8,32'hc,32'h10,32'h14,32'h18,32'h1c,32'h20,32'h24};}	
	IRQ : coverpoint apb_cov.IRQ {bins irq[] = {1'b0,1'b1};}
	PWDATA : coverpoint apb_cov.PWDATA {
					bins WDATA1 = {[32'h0 : 32'h3fff_ffff]};
					bins WDATA2 = {[32'h4000_0000 : 32'h7fff_ffff]};
					bins WDATA3 = {[32'h8000_0000 : 32'hbfff_ffff]};
					bins WDATA4 = {[32'hc000_0000 : 32'hffff_ffff]};
					}
	PRDATA : coverpoint apb_cov.PRDATA {
					bins RDATA1 = {[32'h0 : 32'h3fff_ffff]};
					bins RDATA2 = {[32'h4000_0000 : 32'h7fff_ffff]};
					bins RDATA3 = {[32'h8000_0000 : 32'hbfff_ffff]};
					bins RDATA4 = {[32'hc000_0000 : 32'hffff_ffff]};
					}
	AUX : coverpoint aux_cov.AUX_IN {
					bins AUXDATA1 = {[32'h0 : 32'h3fff_ffff]};
					bins AUXDATA2 = {[32'h4000_0000 : 32'h7fff_ffff]};
					bins AUXDATA3 = {[32'h8000_0000 : 32'hbfff_ffff]};
					bins AUXDATA4 = {[32'hc000_0000 : 32'hffff_ffff]};	
					}
	IO : coverpoint io_cov.io_pad {
					bins IODATA1 = {[32'h0 : 32'h3fff_ffff]};
					bins IODATA2 = {[32'h4000_0000 : 32'h7fff_ffff]};
					bins IODATA3 = {[32'h8000_0000 : 32'hbfff_ffff]};
					bins IODATA4 = {[32'hc000_0000 : 32'hffff_ffff]};	
					}
	reset_cross : cross PWRITE,PADDR,PRDATA {
						bins rst1 = binsof(PWRITE) intersect {0} && !binsof(PADDR) intersect {32'h0} && binsof(PRDATA.RDATA1); 
							}
	write_cross : cross PRESET,PWRITE,PADDR,PWDATA	{
						bins wrt1 = binsof(PRESET) intersect {1'b1} && binsof(PWRITE) intersect {1'b1} && binsof(PADDR.addr1) with (PADDR > 32'h0); 
							}
	read_cross : cross PRESET,PWRITE,PADDR,PRDATA	{
						bins rd1 = binsof(PRESET) intersect {1'b1} && binsof(PWRITE) intersect {1'b0}; 
							}	
    endgroup
    
    function new(string name = "Scoreboard", uvm_component parent);
        super.new(name, parent);
	RGPIO_IN = 32'd0;
	RGPIO_INTS = 32'd0;
	RGPIO_IN = 32'd0;
	RGPIO_OUT = 32'd0;
	RGPIO_OE = 32'd0;
	RGPIO_INTE = 32'd0;
	RGPIO_PTRIG = 32'd0;
	RGPIO_AUX = 32'd0;
	RGPIO_INTS = 32'd0;
	RGPIO_ECLK = 32'd0;
	RGPIO_NEC = 32'd0;
	io_pad = 32'dz;
	RGPIO_CTRL = 2'b0;
	
	gpio_cg = new();
    endfunction
endclass

function void Scoreboard::predict_model();	
	if(apb_txn.PRESETn == 1'b0) begin
	RGPIO_IN = 32'd0;
	RGPIO_INTS = 32'd0;
	RGPIO_IN = 32'd0;
	RGPIO_OUT = 32'd0;
	RGPIO_OE = 32'd0;
	RGPIO_INTE = 32'd0;
	RGPIO_PTRIG = 32'd0;
	RGPIO_AUX = 32'd0;
	RGPIO_INTS = 32'd0;
	RGPIO_ECLK = 32'd0;
	RGPIO_NEC = 32'd0;
	io_pad = 32'dz;
	RGPIO_CTRL = 2'b0;	
	end
	
	else begin
	`uvm_info(get_type_name(),$sformatf("RGPIO CTRL = %h, RGPIO_INTE = %h, RGPIO_OE = %h, RGPIO_PTRIG = %h, RGPIO_IN = %h, io_pad = %h, RGPIO_INTS = %h",RGPIO_CTRL,RGPIO_INTE,RGPIO_OE,RGPIO_PTRIG,RGPIO_IN,io_pad,RGPIO_INTS),UVM_MEDIUM)
	
	for(int i=0;i<=31;i++) begin	
	io_pad[i] = RGPIO_OE[i] ? (RGPIO_AUX[i] ? AUX_IN[i] : RGPIO_OUT[i]) : io_txn.io_pad[i];
	
	if(RGPIO_CTRL[0] && RGPIO_INTE[i] && (RGPIO_OE[i]==1'b0))
		if(RGPIO_PTRIG[i] == 1'b1) begin
			if(RGPIO_IN[i] == 1'b0 && io_pad[i] == 1'b1)
				RGPIO_INTS[i] = 1'b1;
			end
		else if (RGPIO_PTRIG[i] == 1'b0) begin	
			if(RGPIO_IN[i] == 1'b1 && io_pad[i] == 1'b0)
				RGPIO_INTS[i] = 1'b1;
			end
	end //end of for
	end //end of else
	
	RGPIO_IN = io_pad;
endfunction

function void Scoreboard::update_ref_model();
	//registers
	if(apb_txn.PWRITE == 1'b1)
	case(apb_txn.PADDR)
		32'h4 : RGPIO_OUT = apb_txn.RGPIO_OUT;
		32'h8 : RGPIO_OE = apb_txn.RGPIO_OE;
		32'hc : RGPIO_INTE = apb_txn.RGPIO_INTE;
		32'h10 : RGPIO_PTRIG = apb_txn.RGPIO_PTRIG;
		32'h14 : RGPIO_AUX = apb_txn.RGPIO_AUX;
		32'h18 : RGPIO_CTRL = {apb_txn.RGPIO_CTRL_IP,apb_txn.RGPIO_CTRL_GIE};
		32'h20 : RGPIO_ECLK = apb_txn.RGPIO_ECLK;
		32'h24 : RGPIO_NEC = apb_txn.RGPIO_NEC;
	endcase

	AUX_IN = aux_txn.AUX_IN;	

endfunction

task Scoreboard::run_phase(uvm_phase phase);
	forever begin
		fork	
			foreach(apb_fifo[i]) begin
			apb_fifo[i].get(apb_txn);
			apb_cov = new apb_txn;
			update_ref_model();
			predict_model();
			if(apb_txn.PRESETn == 1'b1 && apb_txn.PWRITE == 1'b0 && apb_txn.PADDR == 32'h0)
				if(apb_txn.RGPIO_IN === RGPIO_IN)
					`uvm_info(get_type_name(),$sformatf("The RGPIO_IN : %h txn_RGPIO_IN : %h values compared succesfully",RGPIO_IN,apb_txn.RGPIO_IN),UVM_MEDIUM)
				else	
					`uvm_info(get_type_name(),$sformatf("The RGPIO_IN : %h txn_RGPIO_IN : %h values compared unsuccesfully",RGPIO_IN,apb_txn.RGPIO_IN),UVM_MEDIUM)
			else if(apb_txn.PRESETn == 1'b1 && apb_txn.PWRITE == 1'b0 && apb_txn.PADDR == 32'h1c)
				if(apb_txn.RGPIO_INTS === RGPIO_INTS)
					`uvm_info(get_type_name(),$sformatf("The RGPIO_INTS : %h txn_RGPIO_INTS : %h values compared succesfully",RGPIO_INTS,apb_txn.RGPIO_INTS),UVM_MEDIUM)
				else	
					`uvm_info(get_type_name(),$sformatf("The RGPIO_INTS : %h txn_RGPIO_INTS : %h values compared unsuccesfully",RGPIO_INTS,apb_txn.RGPIO_INTS),UVM_MEDIUM)
			gpio_cg.sample();
			end

			foreach(aux_fifo[i]) begin
			aux_fifo[i].get(aux_txn);
			aux_cov = new aux_txn;
			update_ref_model();
			predict_model();
			end

			foreach(io_pad_fifo[i]) begin
			io_pad_fifo[i].get(io_txn);
			io_cov = new io_txn;
			`uvm_info(get_type_name(),$sformatf("The recieved io txn is %s",io_txn.sprint()),UVM_MEDIUM)
			update_ref_model();
			predict_model();
			end
		join_any
	end				
endtask
