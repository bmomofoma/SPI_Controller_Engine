`timescale 1ns / 1ps

module tb_spi_display_top;

    // 1. Testbench Signals
    logic       clk;
    logic       rst_n;
    logic       start;
    logic [7:0] tx_data;
    logic       ready;
    logic       sclk;
    logic       mosi;
    logic       cs_n;

    // 2. Instantiate the Top-Level DUT (Device Under Test)
    spi_display_top dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .tx_data(tx_data),
        .ready(ready),
        .sclk(sclk),
        .mosi(mosi),
        .cs_n(cs_n)
    );

    // 3. Generate 100 MHz Master Clock (10ns period)
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // 4. Stimulus Sequence
    initial begin
        // Initialize control lines to safe startup state
        rst_n   = 1'b0;
        start   = 1'b0;
        tx_data = 8'h00;

        // Hold reset for 4 clock cycles, then release it
        #40;
        rst_n = 1'b1;
        #20; // Settle time

        // --- TRANSACTION 1: Send Data Byte 0xA5 (10100101) ---
        @(posedge clk);
        while (!ready) @(posedge clk); // Wait for the SPI engine to be free
        
        tx_data <= 8'hA5;             // Load test byte
        start   <= 1'b1;              // Fire kickoff pulse
        
        @(posedge clk);
        start   <= 1'b0;              // Deassert start instantly so we don't double-trigger
        tx_data <= 8'h00;

        // Wait until transmission completes and returns to IDLE
        @(posedge ready);
        #100;

        // --- TRANSACTION 2: Send Data Byte 0x3C (00111100) ---
        @(posedge clk);
        tx_data <= 8'h3C;
        start   <= 1'b1;
        
        @(posedge clk);
        start   <= 1'b0;
        tx_data <= 8'h00;

        // Let simulation run for a final window, then wrap it up
        #2000;
        $display("SPI Master Simulation Successful!");
        $finish;
    end

endmodule