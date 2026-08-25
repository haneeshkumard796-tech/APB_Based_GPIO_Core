class APB_txn extends uvm_sequence_item;
    `uvm_object_utils(APB_txn)
    function new(string name = "APB_txn");
        super.new(name);
    endfunction
	
   rand logic PRESETn;
   logic PSEL;
   logic PENABLE;
   rand logic PWRITE;
   rand logic [31:0]PADDR;
   rand logic [31:0]PWDATA;
   logic [31:0]PRDATA;

   logic [31:0]RGPIO_IN,RGPIO_OUT,RGPIO_OE,RGPIO_INTE,RGPIO_PTRIG,RGPIO_AUX,RGPIO_INTS,RGPIO_ECLK,RGPIO_NEC;
   logic RGPIO_CTRL_GIE;
   logic RGPIO_CTRL_IP;

   extern function void do_print(uvm_printer printer);
   extern function void do_copy(uvm_object rhs);
   extern function bit do_compare(uvm_object rhs, uvm_comparer comparer); 
endclass

   function void APB_txn::do_print(uvm_printer printer);
	printer.print_field("PRESETn",this.PRESETn,1,UVM_HEX);
	printer.print_field("PWRITE",this.PWRITE,1,UVM_HEX);
	printer.print_field("PADDR",this.PADDR,32,UVM_HEX);
	printer.print_field("PWDATA",this.PWDATA,32,UVM_HEX);
	printer.print_field("PRDATA",this.PRDATA,32,UVM_HEX);
   endfunction

   function void APB_txn::do_copy(uvm_object rhs);
   	APB_txn rhs_;
	if(!$cast(rhs_,rhs))
		`uvm_fatal(get_type_name(),"Casting Failed")
	this.PRESETn        = rhs_.PRESETn;
	this.PSEL           = rhs_.PSEL;
	this.PENABLE        = rhs_.PENABLE;
	this.PWRITE         = rhs_.PWRITE;
	this.PADDR          = rhs_.PADDR;
	this.PWDATA         = rhs_.PWDATA;
	this.PRDATA         = rhs_.PRDATA;
	this.RGPIO_IN       = rhs_.RGPIO_IN;
	this.RGPIO_OUT      = rhs_.RGPIO_OUT;
	this.RGPIO_OE       = rhs_.RGPIO_OE;
	this.RGPIO_INTE     = rhs_.RGPIO_INTE;
	this.RGPIO_PTRIG    = rhs_.RGPIO_PTRIG;
	this.RGPIO_AUX      = rhs_.RGPIO_AUX;
	this.RGPIO_INTS     = rhs_.RGPIO_INTS;
	this.RGPIO_ECLK     = rhs_.RGPIO_ECLK;
	this.RGPIO_NEC      = rhs_.RGPIO_NEC;
	this.RGPIO_CTRL_GIE = rhs_.RGPIO_CTRL_GIE;
	this.RGPIO_CTRL_IP  = rhs_.RGPIO_CTRL_IP;	
   endfunction

   function bit APB_txn::do_compare(uvm_object rhs,uvm_comparer comparer);
   	APB_txn rhs_;
	if(!$cast(rhs_,rhs))
		`uvm_fatal(get_type_name(),"Casting Failed")
  	return (
		(this.PRESETn        == rhs_.PRESETn)        &&
		(this.PSEL           == rhs_.PSEL)           &&
		(this.PENABLE        == rhs_.PENABLE)        &&
		(this.PWRITE         == rhs_.PWRITE)         &&
		(this.PADDR          == rhs_.PADDR)          &&
		(this.PWDATA         == rhs_.PWDATA)         &&
		(this.PRDATA         == rhs_.PRDATA)         &&
		(this.RGPIO_IN       == rhs_.RGPIO_IN)       &&
		(this.RGPIO_OUT      == rhs_.RGPIO_OUT)      &&
		(this.RGPIO_OE       == rhs_.RGPIO_OE)       &&
		(this.RGPIO_INTE     == rhs_.RGPIO_INTE)     &&
		(this.RGPIO_PTRIG    == rhs_.RGPIO_PTRIG)    &&
		(this.RGPIO_AUX      == rhs_.RGPIO_AUX)      &&
		(this.RGPIO_INTS     == rhs_.RGPIO_INTS)     &&
		(this.RGPIO_ECLK     == rhs_.RGPIO_ECLK)     &&
		(this.RGPIO_NEC      == rhs_.RGPIO_NEC)      &&
		(this.RGPIO_CTRL_GIE == rhs_.RGPIO_CTRL_GIE) &&
		(this.RGPIO_CTRL_IP  == rhs_.RGPIO_CTRL_IP)
	); 
   endfunction