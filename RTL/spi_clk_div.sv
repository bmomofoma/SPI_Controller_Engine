`timescale 1ns / 1ps

module spi_clk_div #(
    parameter int DIVISOR = 10  // Default: 100 MHz board clock / 10 = 10 MHz SPI strobe
)(
    input  logic clk_in,        
    input  logic rst_n,         
    output logic spi_ce         
);

    // Calculate how many bits your counter needs dynamically using $clog2
    localparam int COUNTER_WIDTH = $clog2(DIVISOR);

    // Declare your internal tracking registers here
    logic [COUNTER_WIDTH-1:0] count;

    // Write your sequential logic block next...
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
