// apb_txn.sv
`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_txn extends uvm_sequence_item;

  // -------------------------
  // Fields needed for your DUT
  // -------------------------
  rand bit        write;   // 1 = write, 0 = read
  rand bit [7:0]  addr;    // APB address
  rand bit [7:0]  data;    // write data

  bit  [7:0]      rdata;   // read data returned by slave

  `uvm_object_utils(apb_txn)

  function new(string name="apb_txn");
    super.new(name);
  endfunction

endclass