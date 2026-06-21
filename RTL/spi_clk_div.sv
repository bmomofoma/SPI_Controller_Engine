`timescale 1ns / 1ps

module spi_clk_div #(
    parameter int DIVISOR = 10  // Default: 100 MHz board clock / 10 = 10 MHz SPI strobe
)(
    input  logic clk_in,        // Connects to the physical 100 MHz oscillator
    input  logic rst_n,         // Asynchronous active-low reset button
    output logic spi_ce         // Our single-cycle clock enable strobe output
);

    // 1. Calculate how many bits your counter needs dynamically using $clog2
    //    Hint: If DIVISOR is 10, we need enough bits to count up to 9.
    localparam int COUNTER_WIDTH = $clog2(DIVISOR);

    // 2. Declare your internal tracking registers here
    logic [COUNTER_WIDTH-1:0] count;

    // 3. Write your sequential logic block next...
    always_ff @(posedge clk_in or negedge rst_n) begin 
        if (!rst_n) begin
            count <= '0;
            spi_ce <= 1'b0;
        end
        else if (count == (DIVISOR - 1)) begin 
            count <= '0;
            spi_ce <= 1'b1;
        end
        else begin
            count <= count + 1;
            spi_ce <= 1'b0;
        end
    end 

endmodule