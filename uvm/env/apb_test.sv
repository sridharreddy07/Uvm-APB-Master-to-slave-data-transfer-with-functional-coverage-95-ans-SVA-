// apb_test.sv
`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_test extends uvm_test;
  `uvm_component_utils(apb_test)

  apb_env env;

  function new(string name="apb_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = apb_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    apb_sequence seq;   // declaration first

    phase.raise_objection(this);

    seq = apb_sequence::type_id::create("seq");
    seq.start(env.agent.sqr);

    #200ns;

    phase.drop_objection(this);
  endtask

  function void report_phase(uvm_phase phase);
    real cov;           // ✅ declaration first

    super.report_phase(phase);

    cov = $get_coverage();

    `uvm_info("COV",
              $sformatf("APB Functional Coverage = %0.2f%%", cov),
              UVM_LOW)
  endfunction

endclass