// apb_env.sv
`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_env extends uvm_env;

  `uvm_component_utils(apb_env)

  // Components
  apb_agent       agent;
  apb_scoreboard  sb;

  // Constructor
  function new(string name = "apb_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create agent
    agent = apb_agent::type_id::create("agent", this);

    // Create scoreboard
    sb = apb_scoreboard::type_id::create("sb", this);
  endfunction

  // Connect Phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect Monitor → Scoreboard
    if (agent != null && agent.mon != null) begin
      agent.mon.mon_ap.connect(sb.sb_ap);
    end
    else begin
      `uvm_error("ENV_CONNECT", "Agent or Monitor is NULL")
    end
  endfunction

endclass