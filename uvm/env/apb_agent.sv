// apb_agent.sv
`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_agent extends uvm_agent;
  `uvm_component_utils(apb_agent)

  // Components inside the agent
  uvm_sequencer #(apb_txn) sqr;
  apb_driver               drv;
  apb_monitor              mon;

  function new(string name="apb_agent", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create components
    sqr = uvm_sequencer#(apb_txn)::type_id::create("sqr", this);
    drv = apb_driver::type_id::create("drv", this);
    mon = apb_monitor::type_id::create("mon", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    // Connect sequencer → driver
    drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction

endclass