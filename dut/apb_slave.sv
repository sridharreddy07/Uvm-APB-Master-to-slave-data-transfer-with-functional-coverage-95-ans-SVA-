module apb_slave (
    input  logic        PCLK,
    input  logic        PRESETn,
    input  logic        PSEL,
    input  logic        PENABLE,
    input  logic        PWRITE,
    input  logic [7:0]  PADDR,
    input  logic [7:0]  PWDATA,
    output logic [7:0]  PRDATA,
    output logic        PREADY
);

    logic [7:0] reg0;

    assign PREADY = 1'b1;

    // -------- WRITE --------
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn)
            reg0 <= 8'h00;
        else if (PSEL && PENABLE && PWRITE && (PADDR == 8'h08))
            reg0 <= PWDATA;
    end

    // -------- READ --------
    // combinational read output
    always_comb begin
        if (PSEL && !PWRITE)
            case (PADDR)
                8'h08: PRDATA = reg0;
                default: PRDATA = 8'h00;
            endcase
        else
            PRDATA = 8'h00;
    end

endmodule