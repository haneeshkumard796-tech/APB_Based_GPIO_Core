class Scoreboard extends uvm_scoreboard;
    `uvm_component_utils(Scoreboard)
    
    uvm_tlm_analysis_fifo #(APB_txn)    apb_fifo;
    uvm_tlm_analysis_fifo #(AUX_txn)    aux_fifo;
    uvm_tlm_analysis_fifo #(IO_pad_txn) io_pad_fifo;

    function new(string name = "Scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        apb_fifo    = new("apb_fifo", this);
        aux_fifo    = new("aux_fifo", this);
        io_pad_fifo = new("io_pad_fifo", this);
    endfunction
endclass