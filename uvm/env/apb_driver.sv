// apb_driver.sv
`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_driver extends uvm_driver #(apb_txn);
  `uvm_component_utils(apb_driver)

  virtual apb_if vif;

  function new(string name="apb_driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "APB interface not found")
  endfunction

  task run_phase(uvm_phase phase);
    apb_txn tr;

    // Default idle values
    vif.PSEL    <= 0;
    vif.PENABLE <= 0;
    vif.PWRITE  <= 0;
    vif.PADDR   <= '0;
    vif.PWDATA  <= '0;

    forever begin
      seq_item_port.get_next_item(tr);

      // -------------------------
      // APB SETUP phase
      // -------------------------
      vif.PSEL    <= 1;
      vif.PWRITE  <= tr.write;
      vif.PADDR   <= tr.addr;
      vif.PWDATA  <= tr.data;
      vif.PENABLE <= 0;
      @(posedge vif.PCLK);

      // -------------------------
      // APB ACCESS phase
      // -------------------------
      vif.PENABLE <= 1;
      @(posedge vif.PCLK);   // PREADY always 1 in your slave

      // Capture read data
      if (!tr.write)
        tr.rdata = vif.PRDATA;

      // -------------------------
      // APB IDLE phase
      // -------------------------
      vif.PSEL    <= 0;
      vif.PENABLE <= 0;

      seq_item_port.item_done();
    end
  endtask

endclass