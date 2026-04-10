// apb_monitor.sv
`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_monitor extends uvm_monitor;
  `uvm_component_utils(apb_monitor)

  virtual apb_if vif;
  uvm_analysis_port #(apb_txn) mon_ap;

  // ---------------------------------------------------------
  // High‑efficiency APB functional coverage (unclocked)
  // ---------------------------------------------------------
  covergroup apb_cg;

    // Read vs Write
    rw_cp : coverpoint vif.PWRITE {
      bins READ  = {0};
      bins WRITE = {1};
    }

    // Address coverage (coarse bins → easier to hit)
    addr_cp : coverpoint vif.PADDR {
      bins low  = {[0:63]};
      bins mid  = {[64:191]};
      bins high = {[192:255]};
    }

    // Data coverage (coarse bins + special values)
    data_cp : coverpoint vif.PWDATA {
      bins zero      = {8'h00};
      bins ones      = {8'hFF};
      bins walking[] = {8'h01, 8'h02, 8'h04, 8'h08,
                        8'h10, 8'h20, 8'h40, 8'h80};
      bins others    = default;
    }

    // Cross coverage (reduced complexity)
    rw_addr_cross : cross rw_cp, addr_cp;

  endgroup

  // ---------------------------------------------------------
  // Constructor — MUST construct covergroup here (Questa rule)
  // ---------------------------------------------------------
  function new(string name="apb_monitor", uvm_component parent=null);
    super.new(name, parent);
    mon_ap = new("mon_ap", this);

    apb_cg = new();   // Safe: no clocking event → no segfault
  endfunction

  // ---------------------------------------------------------
  // Build phase — get virtual interface
  // ---------------------------------------------------------
  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "APB interface not found in monitor")
  endfunction

  // ---------------------------------------------------------
  // Run phase — sample coverage + send transactions
  // ---------------------------------------------------------
  task run_phase(uvm_phase phase);
    apb_txn tr;

    forever begin
      @(posedge vif.PCLK);

      // Valid APB transfer: PSEL=1, PENABLE=1, PREADY=1
      if (vif.PSEL && vif.PENABLE && vif.PREADY) begin

        // Sample coverage
        apb_cg.sample();

        // Create and populate transaction
        tr = apb_txn::type_id::create("tr");
        tr.write = vif.PWRITE;
        tr.addr  = vif.PADDR;
        tr.data  = vif.PWDATA;

        if (!vif.PWRITE)
          tr.rdata = vif.PRDATA;

        // Send to scoreboard
        mon_ap.write(tr);

        // Logging
        `uvm_info("APB_MON",
                  $sformatf("MONITOR: %s addr=0x%0h data=0x%0h rdata=0x%0h",
                            tr.write ? "WRITE" : "READ",
                            tr.addr, tr.data, tr.rdata),
                  UVM_LOW)
      end
    end
  endtask

endclass