`timescale 1ns / 1ps

module tb_spi_display_top;
    logic       clk;
    logic       rst_n;
    logic       start;
    logic [7:0] tx_data;
    logic       ready;
    logic       sclk;
    logic       mosi;
    logic       cs_n;

    // Top-Level DUT (Device Under Test)
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

    // Generate 100 MHz Master Clock (10ns period)
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // Stimulus Sequence
    initial begin
        rst_n   = 1'b0;
        start   = 1'b0;
        tx_data = 8'h00;
        #40;
        rst_n = 1'b1;
        #20;
        
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

        //  Send Data Byte 0x3C
        @(posedge clk);
        tx_data <= 8'h3C;
        start   <= 1'b1;
        
        @(posedge clk);
        start   <= 1'b0;
        tx_data <= 8'h00;
        #2000;
        $display("SPI Master Simulation Successful!");
        $finish;
    end

endmodule
