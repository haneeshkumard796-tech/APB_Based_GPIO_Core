class AUX_txn extends uvm_sequence_item;
    `uvm_object_utils(AUX_txn)
    function new(string name = "AUX_txn");
        super.new(name);
    endfunction

    rand logic [31:0]AUX_IN;
    extern function void do_print(uvm_printer printer);
    extern function void do_copy(uvm_object rhs);
    extern function bit do_compare(uvm_object rhs, uvm_comparer comparer); 
endclass

    function void AUX_txn::do_print(uvm_printer printer);
	printer.print_field("AUX_IN",this.AUX_IN,32,UVM_HEX);
    endfunction

    function void AUX_txn::do_copy(uvm_object rhs);
    	AUX_txn rhs_;
	if(!$cast(rhs_,rhs))
		`uvm_fatal(get_type_name(),"Casting Failed")
	this.AUX_IN = rhs_.AUX_IN;
    endfunction
    
    function bit AUX_txn::do_compare(uvm_object rhs, uvm_comparer comparer);
    	AUX_txn rhs_;
	if(!$cast(rhs_,rhs))
		`uvm_fatal(get_type_name(),"Casting Failed")
	return (this.AUX_IN == rhs_.AUX_IN);
    endfunction