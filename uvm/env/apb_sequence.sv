// apb_sequence.sv
`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_sequence extends uvm_sequence #(apb_txn);
  `uvm_object_utils(apb_sequence)

  // Number of bursts (each burst has random length)
  rand int unsigned num_bursts;

  constraint num_bursts_c { num_bursts inside {[5:20]}; }

  function new(string name="apb_sequence");
    super.new(name);
  endfunction

  virtual task body();
    apb_txn tr;

    // Randomize burst count
    if (!randomize())
      `uvm_error("APB_SEQ", "Sequence randomization failed")

    `uvm_info("APB_SEQ",
              $sformatf("Starting APB sequence with %0d bursts", num_bursts),
              UVM_MEDIUM)

    repeat (num_bursts) begin

      // Random burst length
      int burst_len = $urandom_range(5, 30);

      // Randomly choose a burst mode
      int mode = $urandom_range(0, 4);

      for (int i = 0; i < burst_len; i++) begin
        tr = apb_txn::type_id::create("tr");

        case (mode)

          // ---------------------------------------------------------
          // MODE 0: Full random (max entropy)
          // ---------------------------------------------------------
          0: assert(tr.randomize() with {
                addr  inside {[0:255]};
                data  inside {[0:255]};
                write inside {0,1};
              });

          // ---------------------------------------------------------
          // MODE 1: Boundary address sweep
          // ---------------------------------------------------------
          1: assert(tr.randomize() with {
                addr inside {8'h00, 8'h01, 8'h0F, 8'h10,
                             8'h7F, 8'h80, 8'hFE, 8'hFF};
                data inside {[0:255]};
                write inside {0,1};
              });

          // ---------------------------------------------------------
          // MODE 2: Data stress (0x00, 0xFF, walking bits)
          // ---------------------------------------------------------
          2: assert(tr.randomize() with {
                addr  inside {[0:255]};
                data  inside {8'h00, 8'hFF,
                              8'h01, 8'h02, 8'h04, 8'h08,
                              8'h10, 8'h20, 8'h40, 8'h80};
                write inside {0,1};
              });

          // ---------------------------------------------------------
          // MODE 3: Write-only burst
          // ---------------------------------------------------------
          3: assert(tr.randomize() with {
                addr  inside {[0:255]};
                data  inside {[0:255]};
                write == 1;
              });

          // ---------------------------------------------------------
          // MODE 4: Read-only burst
          // ---------------------------------------------------------
          4: assert(tr.randomize() with {
                addr  inside {[0:255]};
                write == 0;
              });

        endcase

        start_item(tr);
        finish_item(tr);

        `uvm_info("APB_SEQ",
                  $sformatf("MODE %0d: %s addr=0x%0h data=0x%0h",
                            mode,
                            tr.write ? "WRITE" : "READ",
                            tr.addr, tr.data),
                  UVM_LOW)
      end
    end
  endtask

endclass