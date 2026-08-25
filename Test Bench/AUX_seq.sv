class AUX_seq extends uvm_sequence #(AUX_txn);
	`uvm_object_utils(AUX_seq)

//	AUX_txn aux_txn;
	function new(string name="AUX_seq");
		super.new(name);
	endfunction

	task body();
		req = AUX_txn::type_id::create("aux_txn");
		start_item(req);
			req.randomize();
		finish_item(req);
	endtask			
endclass