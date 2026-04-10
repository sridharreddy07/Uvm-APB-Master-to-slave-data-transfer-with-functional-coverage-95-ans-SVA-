interface apb_if (
  input  logic PCLK,
  input  logic PRESETn
);

  logic        PSEL;
  logic        PENABLE;
  logic        PWRITE;
  logic [7:0]  PADDR;
  logic [7:0]  PWDATA;
  logic [7:0]  PRDATA;
  logic        PREADY;

  // ---------------------------------------------------------
  // APB PROTOCOL ASSERTIONS (SVA)
  // ---------------------------------------------------------

  // SETUP → ACCESS transition
  apb_setup_to_access: assert property (
    @(posedge PCLK)
    disable iff (!PRESETn)
    (PSEL && !PENABLE) |-> ##1 (PSEL && PENABLE)
  ) else $error("APB ERROR: SETUP did not transition to ACCESS");

  // PREADY must be stable during ACCESS
  apb_pready_stable: assert property (
    @(posedge PCLK)
    disable iff (!PRESETn)
    (PSEL && PENABLE) |-> $stable(PREADY)
  );

  // No overlapping transfers
  apb_no_overlap: assert property (
    @(posedge PCLK)
    disable iff (!PRESETn)
    (PSEL && PENABLE) |-> !(PSEL && !PENABLE)
  );

  // Address must remain stable during ACCESS
  apb_addr_stable: assert property (
    @(posedge PCLK)
    disable iff (!PRESETn)
    (PSEL && PENABLE) |-> $stable(PADDR)
  );

  // Write data must remain stable during ACCESS
  apb_wdata_stable: assert property (
    @(posedge PCLK)
    disable iff (!PRESETn)
    (PSEL && PENABLE && PWRITE) |-> $stable(PWDATA)
  );

endinterface