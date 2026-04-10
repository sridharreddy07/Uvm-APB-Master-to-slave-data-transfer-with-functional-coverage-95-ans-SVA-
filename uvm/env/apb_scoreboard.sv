// apb_scoreboard.sv
`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_scoreboard extends uvm_component;
  `uvm_component_utils(apb_scoreboard)

  // Analysis export to receive transactions from monitor
  uvm_analysis_imp #(apb_txn, apb_scoreboard) sb_ap;

  // Reference model (your slave has only one register at 0x08)
  bit [7:0] reg_model;

  function new(string name="apb_scoreboard", uvm_component parent=null);
    super.new(name, parent);
    sb_ap = new("sb_ap", this);
  endfunction

  // Initialize reference model
  function void build_phase(uvm_phase phase);
    reg_model = 8'h00;
  endfunction

  // Called whenever monitor sends a transaction
  function void write(apb_txn tr);

    if (tr.write) begin
      // WRITE operation → update reference model
      if (tr.addr == 8'h08)
        reg_model = tr.data;

      `uvm_info("APB_SB",
                $sformatf("WRITE: addr=0x%0h data=0x%0h (model updated)",
                          tr.addr, tr.data),
                UVM_LOW)

    end else begin
      // READ operation → compare DUT vs model
      bit [7:0] expected;

      if (tr.addr == 8'h08)
        expected = reg_model;
      else
        expected = 8'h00;

      if (tr.rdata !== expected) begin
        `uvm_error("APB_SB",
                   $sformatf("READ MISMATCH: addr=0x%0h expected=0x%0h got=0x%0h",
                             tr.addr, expected, tr.rdata))
      end else begin
        `uvm_info("APB_SB",
                  $sformatf("READ OK: addr=0x%0h data=0x%0h",
                            tr.addr, tr.rdata),
                  UVM_LOW)
      end
    end

  endfunction

endclass