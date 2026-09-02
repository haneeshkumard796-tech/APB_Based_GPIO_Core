class IO_pad_txn extends uvm_sequence_item;
    `uvm_object_utils(IO_pad_txn)
    function new(string name = "IO_pad_txn");
        super.new(name);
    endfunction

    rand logic [31:0] io_pad;
    rand logic [1:0]io_pad_ctrl;
   
    extern function void do_print(uvm_printer printer);
    extern function void do_copy(uvm_object rhs);
    extern function bit do_compare(uvm_object rhs, uvm_comparer comparer); 
    extern function void post_randomize();
endclass

    function void IO_pad_txn::do_print(uvm_printer printer);
    	printer.print_field("IO PAD",this.io_pad,32,UVM_HEX);
    endfunction
    function void IO_pad_txn::do_copy(uvm_object rhs);
    	IO_pad_txn rhs_;	
	if(!$cast(rhs_,rhs))
		`uvm_fatal(get_type_name(),"Casting Failed")
	this.io_pad = rhs_.io_pad;
	this.io_pad_ctrl = rhs_.io_pad_ctrl;
    endfunction
    function bit IO_pad_txn::do_compare(uvm_object rhs, uvm_comparer comparer); 	
    	IO_pad_txn rhs_;	
	if(!$cast(rhs_,rhs))
		`uvm_fatal(get_type_name(),"Casting Failed")
	return (this.io_pad == rhs_.io_pad && this.io_pad_ctrl == rhs_.io_pad_ctrl);
    endfunction
    function void IO_pad_txn::post_randomize();
	io_pad = io_pad_ctrl == 2'b00 ? 32'hz : io_pad;
    	io_pad[31:28] = io_pad_ctrl == 2'b10 | io_pad_ctrl == 2'b01 ? io_pad[31:28] : 4'hz;
    	io_pad[23:20] = io_pad_ctrl == 2'b10 | io_pad_ctrl == 2'b01 ? io_pad[23:20] : 4'hz;
    	io_pad[15:12] = io_pad_ctrl == 2'b10 | io_pad_ctrl == 2'b01 ? io_pad[15:12] : 4'hz;
    	io_pad[7:4] = io_pad_ctrl == 2'b10 | io_pad_ctrl == 2'b01 ? io_pad[7:4] : 4'hz;	
    endfunction
