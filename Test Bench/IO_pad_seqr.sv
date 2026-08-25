class IO_pad_seqr extends uvm_sequencer #(IO_pad_txn);
    `uvm_component_utils(IO_pad_seqr)
    function new(string name = "IO_pad_seqr", uvm_component parent);
        super.new(name, parent);
    endfunction
endclass