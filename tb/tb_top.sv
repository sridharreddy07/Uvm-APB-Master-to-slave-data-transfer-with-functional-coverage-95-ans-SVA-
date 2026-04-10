`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_pkg::*;   // your full UVM package

module tb_top;

    logic clk;
    logic rst;

    // -------------------------------------
    // Clock generation
    // -------------------------------------
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // -------------------------------------
    // Reset generation
    // -------------------------------------
    initial begin
        rst = 1;
        #20 rst = 0;
    end

    // -------------------------------------
    // Instantiate APB interface
    // -------------------------------------
    apb_if apb_if_inst(clk);

    // Connect reset
    assign apb_if_inst.PRESETn = ~rst;

    // -------------------------------------
    // DUT: APB Slave
    // -------------------------------------
    apb_slave dut (
        .PCLK   (clk),
        .PRESETn(apb_if_inst.PRESETn),
        .PSEL   (apb_if_inst.PSEL),
        .PENABLE(apb_if_inst.PENABLE),
        .PWRITE (apb_if_inst.PWRITE),
        .PADDR  (apb_if_inst.PADDR),
        .PWDATA (apb_if_inst.PWDATA),
        .PRDATA (apb_if_inst.PRDATA),
        .PREADY (apb_if_inst.PREADY)
    );

    // -------------------------------------
    // Start UVM
    // -------------------------------------
    initial begin
        // Pass interface to UVM
        uvm_config_db#(virtual apb_if)::set(null, "*", "vif", apb_if_inst);

        // Run test
        run_test("apb_test");
    end

endmodule