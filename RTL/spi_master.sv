`timescale 1ns / 1ps

module spi_master (
    input  logic       clk,       // Global 100 MHz board clock
    input  logic       rst_n,     
    input  logic       spi_ce,    // 10 MHz clock enable strobe from divider (for 5 MHz SCLK)
    input  logic       start,     // Pulse high for 1 cycle to kick off transmission
    input  logic [7:0] tx_data,   
    output logic       ready,     // High if the SPI engine is idle and ready for data
    
    // Physical SPI Bus Interface pins to external hardware
    output logic       sclk,      // Serial SPI clock driven out to peripheral
    output logic       mosi,      // Master-Out Slave-In serial data line
    output logic       cs_n       // Chip Select (Active Low)
);

    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        START = 2'b01,
        SHIFT = 2'b10,
        STOP  = 2'b11
    } state_t;

    state_t current_state;

    // Internal tracking registers
    logic [7:0] shift_reg; 
    logic [2:0] bit_cnt;   
    logic       sclk_reg;   
    logic       phase;    
    
    // FINITE STATE MACHINE (FSM) SEQUENTIAL BLOCK
    always_ff @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin
            current_state <= IDLE;
            shift_reg     <= '0;
            bit_cnt       <= '0;
            sclk_reg      <= 1'b0;
            phase         <= 1'b0;
        end 
        else begin
            case (current_state)
                IDLE: begin
                    sclk_reg <= 1'b0; // SPI Mode 0 idles low
                    phase    <= 1'b0;
     
                    if (start) begin
                        shift_reg     <= tx_data; // Safely latch data input
                        bit_cnt       <= '0;      
                        current_state <= START;   // Advance to synchronization staging
                    end 
                end

                START: begin
                    if (spi_ce) begin 
                        current_state <= SHIFT;
                    end
                end

               SHIFT: begin
                    if (spi_ce) begin
                        phase <= ~phase; 
                        
                        if (phase == 1'b0) begin
                            sclk_reg <= 1'b1; // Drive SCLK high (Rising Edge)
                        end 
                        else begin
                            sclk_reg <= 1'b0; // Drive SCLK low (Falling Edge)
                            // Shift data ONLY on the falling edge, right after the slave sampled it!
                            if (bit_cnt == 3'd7) begin
                                current_state <= STOP;
                            end else begin
                                bit_cnt   <= bit_cnt + 3'd1;
                                shift_reg <= {shift_reg[6:0], 1'b0}; 
                            end
                        end
                    end
                end

                STOP: begin 
                    if (spi_ce) begin 
                        current_state <= IDLE;
                    end
                end
                
                default: current_state <= IDLE;
            endcase 
        end
    end 

    // COMBINATIONAL BUS OUTPUTS
    assign ready = (current_state == IDLE);
    assign cs_n  = (current_state == IDLE);
    assign mosi  = shift_reg[7]; // Continuously drive out the MSB
    assign sclk  = sclk_reg;

endmodule
