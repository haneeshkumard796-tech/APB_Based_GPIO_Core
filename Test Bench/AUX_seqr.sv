class AUX_seqr extends uvm_sequencer #(AUX_txn);
    `uvm_component_utils(AUX_seqr)
    function new(string name = "AUX_seqr", uvm_component parent);
        super.new(name, parent);
    endfunction
endclass