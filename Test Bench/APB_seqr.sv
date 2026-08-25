class APB_seqr extends uvm_sequencer #(APB_txn);
    `uvm_component_utils(APB_seqr)
    function new(string name = "APB_seqr", uvm_component parent);
        super.new(name, parent);
    endfunction
endclass