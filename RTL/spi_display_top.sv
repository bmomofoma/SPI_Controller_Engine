`timescale 1ns / 1ps

module spi_display_top (
    input  logic       clk,       // Physical 100 MHz oscillator on Basys 3
    input  logic       rst_n,     
    input  logic       start,    
    input  logic [7:0] tx_data,   // Byte to send
    output logic       ready,     // Status flag
    
    // Physical pins out to the OLED PMOD connector
    output logic       sclk,      
    output logic       mosi,      
    output logic       cs_n       
);

    // Internal interconnect wire to bridge the modules
    logic spi_ce_wire;

    // the clock divider
    spi_clk_div #(
        .DIVISOR(10) // 100 MHz / 10 = 10 MHz pulses (gives 5 MHz SCLK)
    ) clk_divider (
        .clk_in(clk),
        .rst_n(rst_n),
        .spi_ce(spi_ce_wire)
    );

    // the SPI Master serialization engine
    spi_master master_engine (
        .clk(clk),
        .rst_n(rst_n),
        .spi_ce(spi_ce_wire), // Driven by the clock divider output
        .start(start),
        .tx_data(tx_data),
        .ready(ready),
        .sclk(sclk),
        .mosi(mosi),
        .cs_n(cs_n)
    );

endmodule
